
//
//  NotificationManager.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 8/2/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import Alamofire

class NotificationManager: NSObject {
    
    // MARK: - Properties
    var currentUser: UserModel? {
        return DatabaseManager.shared.currentUser
    }
    
//    let queue = OperationQueue()
    
    fileprivate var poolDictArray = [[String: String]]()
    
    // MARK: - Static
    static let shared = NotificationManager()
    
    // MARK: - Init
    fileprivate override init() {
        super.init()
    }
    
//    public func stopTask() {
//        queue.cancelAllOperations()
//    }
}

// MARK: - Requests
extension NotificationManager {
    public func sendNotificationsToServer() {
        
        debugPrint("sendNotificationsToServer")
        guard let user = currentUser else { return }
        let endpoint = "notification/\(user.id)/save"
        let notificaitons = getAllSavedNotifications().map { $0.asDictionary }
        guard !notificaitons.isEmpty else { return }
        let params: [String: Any] = ["count": notificaitons.count, "notifications": notificaitons]
        
        NetworkManager.shared.request(method: .post, endpoint: endpoint, params: params, encoding: JSONEncoding.default, success: { (dictionary) in
            guard let status = dictionary.value(forKey: "status") as? Int, status == 0 else {
                let message = dictionary["description"] as? String ?? "unknown_error"
                debugPrint(message.localized())
                return
            }
            debugPrint("All notifications sended to backend")
            self.deleteAllNotifications(success: { }, failer: { (error) in
                debugPrint(error.localized())
            })
        }) { (error) in
            debugPrint(error.localized())
        }
    }
    
    public func getAllNotificationsFromServer() {
        guard let user = currentUser else { return }
        let endpoint = "notification/\(user.id)/all/list"
        
        NetworkManager.shared.request(method: .get, endpoint: endpoint, params: nil, success: { (dictionary) in
            guard let status = dictionary.value(forKey: "status") as? Int, status == 0, let array = dictionary.value(forKey: "data") as? [NSDictionary] else {
                let message = dictionary["description"] as? String ?? "unknown_error"
                debugPrint(message.localized())
                return
            }
            let _ = array.map { NotificationModel(json: $0) }
            self.deleteNotificationsByTypeInServer(notificationType: nil, success: { }, failer: { (_) in })
        }) { (error) in
            debugPrint(error.localized())
        }
    }
    
    fileprivate func deleteNotificationsByTypeInServer(notificationType: NotificationSegmentTypeEnum?, success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        guard let user = currentUser else { failer("unknown_error"); return }
        guard user.isSubscribted else { success(); return}
        let endpoint = "notification/\(user.id)/deleteByType/\(notificationType?.getRequestTypeString() ?? "all")"
        
        NetworkManager.shared.request(method: .delete, endpoint: endpoint, params: nil, success: { (dictionary) in
            guard let status = dictionary.value(forKey: "status") as? Int, status == 0 else {
                let message = dictionary["description"] as? String ?? "unknown_error"
                failer(message.localized())
                debugPrint(message.localized())
                return
            }
            success()
        }) { (error) in
            failer(error.localized())
            debugPrint(error.localized())
        }
    }
    
    fileprivate func deleteNotificationInServer(notification: NotificationModel, success: @escaping() -> Void, failer: @escaping(String) -> ()) {
        guard let user = currentUser else { failer("unknown_error"); return }
        guard user.isSubscribted else { success(); return}
        let endpoint = "notification/\(user.id)/delete/\(notification.id)"
        
        NetworkManager.shared.request(method: .delete, endpoint: endpoint, success: { (dictionary) in
            guard let status = dictionary.value(forKey: "status") as? Int, status == 0 else {
                let message = dictionary["description"] as? String ?? "unknown_error"
                failer(message.localized())
                debugPrint(message.localized())
                return
            }
            success()
        }) { (error) in
            failer(error.localized())
            debugPrint(error.localized())
        }
    }
}

// MARK: - Public methods
extension NotificationManager {
    public func writeToFile(notification: NotificationModel) {
        guard let data = notification.getJsonData(),
              let directory = getDocumentDirectory(for: notification.notificationType) else { return }
        let localnNotifactions =  getNotificationsFromDirectory(directory: directory)
        
        // Check duplicate value
        if notification.fromPushUp {
            switch notification.notificationType {
            case .coin:
                guard !localnNotifactions.contains(where: {$0.sentDate == notification.sentDate && $0.data.currentValue == notification.data.currentValue}) else { return }
            case .hashrate:
                guard !localnNotifactions.contains(where: {$0.sentDate == notification.sentDate && $0.data.currentValue == notification.data.currentValue && $0.data.alertValue == notification.data.alertValue}) else { return }
            case .reportedHashrate:
                guard !localnNotifactions.contains(where: {$0.sentDate == notification.sentDate && $0.data.currentValue == notification.data.currentValue && $0.data.alertValue == notification.data.alertValue}) else { return }
            case .worker:
                guard !localnNotifactions.contains(where: {$0.sentDate == notification.sentDate && $0.data.currentValue == notification.data.currentValue && $0.data.alertValue == notification.data.alertValue}) else { return }
            case .payout:
                guard !localnNotifactions.contains(where: {$0.sentDate == notification.sentDate && $0.data.value == notification.data.value}) else { return }
            case .info:
                guard !localnNotifactions.contains(where: {$0.sentDate == notification.sentDate && $0.data.currentValue == notification.data.currentValue}) else { return }
            }
        }
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            // Check for max notifications limit
            if urls.count > 99, let firstUrl = urls.first {
                try FileManager.default.removeItem(at: firstUrl)
            }
            
            try data.write(to: directory.appendingPathComponent("\(notification.id).json"))
        } catch {
            debugPrint("Can't write notification model json data to file: \(error.localizedDescription)")
        }
    }
    
    public func getNotifications(for type: NotificationSegmentTypeEnum, success: @escaping([NotificationModel]) -> Void,failer: @escaping(String) -> Void) {
        guard let user = currentUser else { success([]); return }
        if user.isSubscribted {
            let endpoint = "notification/\(user.id)/\(type.getRequestTypeString())/list"
            
            self.deleteAllNotifications(success: { }, failer: { (error) in
                debugPrint(error.localized())
            })
            
            NetworkManager.shared.request(method: .get, endpoint: endpoint, params: nil, success: { (dictionary) in
                guard let status = dictionary.value(forKey: "status") as? Int, status == 0, let array = dictionary.value(forKey: "data") as? [NSDictionary] else {
                    let message = dictionary["description"] as? String ?? "unknown_error"
                    debugPrint(message.localized())
                    success([])
                    return
                }
                DispatchQueue.global().async {
                    success(array.map { NotificationModel(json: $0) })
                }
            }) { (error) in
                success([])
                failer(error)
                debugPrint(error.localized())
            }
        } else {
            getLocalSavedNotifications(type: type, success: success)
        }
    }
    
    public func deleteAllNotifications(for type: NotificationSegmentTypeEnum? = nil, success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        if let notificationType = type {
            deleteNotificationsForType(notificationType, success: {
                
                success()
            }) { (error) in
                failer("unknown_error")
            }
            return
        }
        
        let fileManager = FileManager.default
        do {
            let docURL = Constants.fileManagerURL
            let notificationsUrl = docURL.appendingPathComponent("Notifications")
            if !fileManager.fileExists(atPath: notificationsUrl.path) {
                try fileManager.createDirectory(atPath: notificationsUrl.path, withIntermediateDirectories: true, attributes: nil)
            }
            
            let userNotificationsUrl = notificationsUrl.appendingPathComponent(DatabaseManager.shared.currentUser?.id ?? "")
            removeNotificationsByFolder(url: userNotificationsUrl)
            clearNotificationsCount()
        } catch {
            debugPrint("Can't get docURL: \(error.localizedDescription)")
        }
    }
    
    public func deleteNotification(notification: NotificationModel, success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        
        deleteNotificationInServer(notification: notification, success: success, failer: failer)
        
        guard let directory = getDocumentDirectory(for: notification.notificationType)?.appendingPathComponent("\(notification.id).json") else {
            failer("unknown_error")
            return }
        do {
            if FileManager.default.fileExists(atPath: directory.path) {
                try FileManager.default.removeItem(atPath: directory.path)
            }
        } catch {
            failer("unknown_error")
            debugPrint("Can't delete notification: \(error.localizedDescription)")
        }
    }
}

// MARK: - Actions
extension NotificationManager {
    fileprivate func getAllSavedNotifications() -> [NotificationModel] {
        guard
            let workerDirectory = getDocumentDirectory(for: .worker),
            let payoutDirectory = getDocumentDirectory(for: .payout),
            let hashrateDirectory = getDocumentDirectory(for: .hashrate),
            let reportedHashrateDirectory = getDocumentDirectory(for: .reportedHashrate),
            let coinDirectory = getDocumentDirectory(for: .coin),
            let infoDirectory = getDocumentDirectory(for: .info)
        else { return [] }
        
        var notifications: [NotificationModel] = []
        notifications += getNotificationsFromDirectory(directory: workerDirectory)
        notifications += getNotificationsFromDirectory(directory: payoutDirectory)
        notifications += getNotificationsFromDirectory(directory: hashrateDirectory)
        notifications += getNotificationsFromDirectory(directory: reportedHashrateDirectory)
        notifications += getNotificationsFromDirectory(directory: coinDirectory)
        notifications += getNotificationsFromDirectory(directory: infoDirectory)
        return notifications
    }
    
    fileprivate func getNotificationsFromDirectory(directory: URL) -> [NotificationModel] {
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            var notifications: [NotificationModel] = []
            
            for url in urls {
                let jsonData = try Data(contentsOf: url)
                let notification = try JSONDecoder().decode(NotificationModel.self, from: jsonData)
                notifications.append(notification)
            }
            return notifications
        } catch {
            debugPrint("Can't get notification from json: \(error.localizedDescription)")
        }
        
        return []
    }
    
    fileprivate func getDocumentDirectory(for type: NotificationType) -> URL? {
        let fileManager = FileManager.default
        do {
            let docURL = Constants.fileManagerURL
            let notificationsUrl = docURL.appendingPathComponent("Notifications")
            if !fileManager.fileExists(atPath: notificationsUrl.path) {
                try fileManager.createDirectory(atPath: notificationsUrl.path, withIntermediateDirectories: true, attributes: nil)
            }
            
            let userNotificationsUrl = notificationsUrl.appendingPathComponent(DatabaseManager.shared.currentUser?.id ?? "")
            if !fileManager.fileExists(atPath: userNotificationsUrl.path) {
                try fileManager.createDirectory(atPath: userNotificationsUrl.path, withIntermediateDirectories: true, attributes: nil)
            }
            
            let notificationTypeUrl = userNotificationsUrl.appendingPathComponent(type.rawValue)
            if !fileManager.fileExists(atPath: notificationTypeUrl.path) {
                try fileManager.createDirectory(atPath: notificationTypeUrl.path, withIntermediateDirectories: true, attributes: nil)
            }
            return notificationTypeUrl
        } catch {
            debugPrint("Can't get docURL: \(error.localizedDescription)")
            return nil
        }
    }
    
    fileprivate func deleteNotificationsForType(_ notificationType: NotificationSegmentTypeEnum, success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        guard let user = currentUser else { failer("unknown_error"); return }
        if user.isSubscribted  {
        deleteNotificationsByTypeInServer(notificationType: notificationType, success: success, failer: failer)
        clearNotificationsCount(for: notificationType)
        }
        
        switch notificationType {
        case .pool:
            guard
                let workerDirectory = getDocumentDirectory(for: .worker),
                let payoutDirectory = getDocumentDirectory(for: .payout),
                let hashrateDirectory = getDocumentDirectory(for: .hashrate),
                let reportedHashrateDirectory = getDocumentDirectory(for: .reportedHashrate)
            else  { failer("unknown_error"); break }
            
            do {
                try FileManager.default.removeItem(atPath: workerDirectory.path)
                try FileManager.default.removeItem(atPath: payoutDirectory.path)
                try FileManager.default.removeItem(atPath: hashrateDirectory.path)
                try FileManager.default.removeItem(atPath: reportedHashrateDirectory.path)
                success()
            } catch {
                failer("unknown_error")
                debugPrint("Can't delete notification: \(error.localizedDescription)")
            }
            
        case .coin:
            guard let coinDirectory = getDocumentDirectory(for: .coin) else { failer("unknown_error"); break }
            do {
                try FileManager.default.removeItem(atPath: coinDirectory.path)
                success()
            } catch {
                failer("unknown_error")
                debugPrint("Can't delete notification: \(error.localizedDescription)")
            }
        case .info:
            guard let infoDirectory = getDocumentDirectory(for: .info) else { failer("unknown_error"); break }
            do {
                try FileManager.default.removeItem(atPath: infoDirectory.path)
                success()
            } catch {
                failer("unknown_error")
                debugPrint("Can't delete notification: \(error.localizedDescription)")
            }
        }
    }
    
    public func clearNotificationsCount(for type: NotificationSegmentTypeEnum? = nil) {
        guard let user = currentUser else { return }
        guard let notificationType = type else {
            UserDefaults(suiteName: "group.com.witplex.MinerBox")?.removeObject(forKey: "\(user.id)workerNotificationsCount")
            UserDefaults(suiteName: "group.com.witplex.MinerBox")?.removeObject(forKey: "\(user.id)hashrateNotificationsCount")
            UserDefaults(suiteName: "group.com.witplex.MinerBox")?.removeObject(forKey: "\(user.id)repHashrateNotificationsCount")
            UserDefaults(suiteName: "group.com.witplex.MinerBox")?.removeObject(forKey: "\(user.id)payoutNotificationsCount")
            UserDefaults(suiteName: "group.com.witplex.MinerBox")?.removeObject(forKey: "\(user.id)coinNotificationsCount")
            UserDefaults(suiteName: "group.com.witplex.MinerBox")?.removeObject(forKey: "\(user.id)infoNotificationsCount")
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.notificationCountChanged), object: nil)
            return
        }
        
        switch notificationType {
        case .coin:
            UserDefaults(suiteName: "group.com.witplex.MinerBox")?.removeObject(forKey: "\(user.id)coinNotificationsCount")
        case .pool:
            UserDefaults(suiteName: "group.com.witplex.MinerBox")?.removeObject(forKey: "\(user.id)workerNotificationsCount")
            UserDefaults(suiteName: "group.com.witplex.MinerBox")?.removeObject(forKey: "\(user.id)hashrateNotificationsCount")
            UserDefaults(suiteName: "group.com.witplex.MinerBox")?.removeObject(forKey: "\(user.id)repHashrateNotificationsCount")
            UserDefaults(suiteName: "group.com.witplex.MinerBox")?.removeObject(forKey: "\(user.id)payoutNotificationsCount")
        case .info:
            UserDefaults(suiteName: "group.com.witplex.MinerBox")?.removeObject(forKey: "\(user.id)infoNotificationsCount")
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.notificationCountChanged), object: nil)
    }
    
    public func getLocalSavedNotifications(type: NotificationSegmentTypeEnum, success: @escaping([NotificationModel]) -> Void) {
        switch type {
        case .pool:
            guard
                let workerDirectory = getDocumentDirectory(for: .worker),
                let payoutDirectory = getDocumentDirectory(for: .payout),
                let hashrateDirectory = getDocumentDirectory(for: .hashrate),
                let reportedHashrateDirectory = getDocumentDirectory(for: .reportedHashrate)
            else { success([]); break }
            
            var notifications: [NotificationModel] = []
            notifications = getNotificationsFromDirectory(directory: workerDirectory)
            notifications = getNotificationsFromDirectory(directory: payoutDirectory)
            notifications = getNotificationsFromDirectory(directory: hashrateDirectory)
            notifications = getNotificationsFromDirectory(directory: reportedHashrateDirectory)
            success(notifications.sorted { $0.sentDate > $1.sentDate })
        case .coin:
            guard let coinDirectory = getDocumentDirectory(for: .coin) else { break }
            success(getNotificationsFromDirectory(directory: coinDirectory).sorted { $0.sentDate > $1.sentDate })
        case .info:
            guard let infoDirectory = getDocumentDirectory(for: .info) else { break }
            success(getNotificationsFromDirectory(directory: infoDirectory).sorted { $0.sentDate > $1.sentDate })
        }
    }
    
    fileprivate func removeNotificationsByFolder(url: URL) {
        let fileManager = FileManager.default
        do {
            let directoryContents = try fileManager.contentsOfDirectory(atPath: url.path)
            
            for path in directoryContents {
                let fullPath = url.appendingPathComponent(path)
                try FileManager.default.removeItem(atPath: fullPath.path)
            }
            
            try FileManager.default.removeItem(atPath: url.path)
        } catch {
            debugPrint("Can't delete saved notificaiton: \(error.localizedDescription)")
        }
    }
}


// MARK: - Get Pool Type
extension NotificationManager {
    func getPoolType(from title: String) -> String {
        let components = title.components(separatedBy: ",")
        var savedKey: String
        if components.indices.contains(1), let pool = Int(components[0]), let subPool = Int(components[1]) {
            savedKey = "\(pool), \(subPool)"
            if let poolType = getSavedPoolType(with: savedKey) {
                return poolType
            } else {
                let dict: [String: String] = [savedKey: getTitle(pool: pool, subPool: subPool)]
                poolDictArray.append(dict)
            }
            
            return getTitle(pool: pool, subPool: subPool)
        } else if components.indices.contains(0), let pool = Int(components[0]) {
            savedKey = "\(pool)"
            if let poolType = getSavedPoolType(with: savedKey) {
                return poolType
            } else {
                let dict: [String: String] = [savedKey: getTitle(pool: pool, subPool: nil)]
                poolDictArray.append(dict)
            }
            
            return getTitle(pool: pool, subPool: nil)
        }
        return ""
    }
    
    private func getSavedPoolType(with savedKey: String) -> String? {
        let poolDict = poolDictArray.first { Array($0.keys)[0] == savedKey }
        if let poolDict = poolDict, let poolType = poolDict[savedKey] {
            return poolType
        }
        return nil
    }
    
    private func getTitle(pool: Int, subPool: Int?) -> String {
        guard let pool = getPool(id: pool, subPoolId: subPool) else { return "" }
        return subPool == nil ? pool.name : "\(pool.name) / \(pool.subPoolName)"
    }
    
    private func getPool(id: Int, subPoolId: Int?) -> (name: String, subPoolName: String)? {
        do {
            let url = Constants.fileManagerURL
            let poolListUrl = url.appendingPathComponent("PoolList")
            let data = try Data(contentsOf: poolListUrl)
            
            guard let dict = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [NSDictionary] else { return nil }
            
            var poolName = ""
            var subPoolName = ""
            for pool in dict {
                guard let poolId = pool.value(forKey: "poolId") as? Int, poolId == id else { continue }
                
                poolName = pool.value(forKey: "poolName") as? String ?? ""
                if let subItems = pool.value(forKey: "subItems") as? [NSDictionary], let subId = subPoolId {
                    for subitem in subItems {
                        if let id = subitem.value(forKey: "id") as? Int, id == subId {
                            subPoolName = subitem.value(forKey: "name") as? String ?? ""
                        }
                    }
                }
            }
            return (name: poolName, subPoolName: subPoolName)
        } catch {
            debugPrint(error.localizedDescription)
        }
        
        return nil
    }
}


// MARK: - Helpers
enum NotificationSegmentTypeEnum: String, CaseIterable {
    case coin = "notifications_coin_alerts"
    case pool = "notifications_pool_alerts"
    case info = "notifications_info_alerts"
    
    func getRequestTypeString() -> String {
        switch self {
        case .coin:
            return "coin"
        case .pool:
            return "pool"
        case .info:
            return "info"
        }
    }
}
