//
//  LocalNotificationManager.swift
//  MinerBox
//
//  Created by Vazgen Hovakinyan on 29.04.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import Alamofire


struct LocalNotification: Codable {
    var id: String
    var title: String
    var body: String
    
    public func getJsonData() -> Data? {
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(self)
            return jsonData
        } catch {
            debugPrint("Can't convert notification model to json: \(error.localizedDescription)")
        }
        return nil
    }
}

enum LocalNotificationDurationType {
    case days
    case hours
    case minutes
    case seconds
}

class LocalNotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    // MARK: - Properties
    var currentUser: UserModel? {
        return DatabaseManager.shared.currentUser
    }
    
    // MARK: - Static
    static let shared = LocalNotificationManager()
    
    // MARK: - Init
    fileprivate override init() {
        super.init()
    }
    
    private var localNotifications = [LocalNotification]()
    
    fileprivate var welcomeMessagePresent = false


    private func addLocalNotification(title: String, body: String) -> Void {
        self.localNotifications.removeAll()
        self.localNotifications.append(LocalNotification(id: UUID().uuidString, title: title.htmlToString, body: body))
            writeToFile(notification: localNotifications.first!)
    }
    
    @available(iOS 10.0, *)
    private func scheduleNotifications(_ durationInSeconds: Int, repeats: Bool, userInfo: [AnyHashable : Any]) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        for notification in localNotifications {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.body = notification.body.htmlToString
            content.sound = UNNotificationSound.default
            content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
            content.userInfo = userInfo
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(durationInSeconds), repeats: repeats)
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().add(request) { error in
                guard error == nil else { return }
                print("Scheduling notification with id: \(notification.id)")
            }
        }
        localNotifications.removeAll()
    }
    
    private func scheduleNotifications(_ duration: Int, of type: LocalNotificationDurationType, repeats: Bool, userInfo: [AnyHashable : Any]) {
        var seconds = 0
        switch type {
        case .seconds:
            seconds = duration
        case .minutes:
            seconds = duration * 60
        case .hours:
            seconds = duration * 60 * 60
        case .days:
            seconds = duration * 60 * 60 * 24
        }
        if #available(iOS 10.0, *) {
            scheduleNotifications(seconds, repeats: repeats, userInfo: userInfo)
        } else {
            // Fallback on earlier versions
        }
    }
    
    func setNotification(_ duration: Int, of type: LocalNotificationDurationType, repeats: Bool, title: String, body: String, userInfo: [AnyHashable : Any]) {
        
        addLocalNotification(title: title, body: body)
        guard !welcomeMessagePresent else { return }
        scheduleNotifications(duration, of: type, repeats: repeats, userInfo: userInfo)

    }
    
    
    //MARK: Methods Backend
    
    public func getWelcomeNotification(success: @escaping(String) -> Void, failer: @escaping(String) -> Void) {
        let endpoint = "appSettings/welcomeMessageWithUrl"
        
        NetworkManager.shared.request(method: .get, endpoint: endpoint) { (json) in
            
            if let status = json.value(forKey: "status") as? Int, status == 0, let jsonData = json["data"] as? NSDictionary {
                let welcomeMessageDate = WelcomeNotificationModel(json: jsonData)
                let communityModel = CommunityModel(dict: welcomeMessageDate.communityURL)
                CommunityManager.shared.removeFromDB()
                RealmWrapper.sharedInstance.addObjectInRealmDB(communityModel)
                success(welcomeMessageDate.welcomeMessage)
            } else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
            }
        } failure: { (error) in
            debugPrint(error.localized())
            
        }
    }
    
    //MARK: Methods FileManager
    
    private func writeToFile(notification: LocalNotification) {
        guard let _ = notification.getJsonData(),
              let directory = getDocumentDirectory(for: "welcome_Message") else { return }
        do {
            try FileManager.default.removeItem(atPath: directory.path)
        } catch {
            debugPrint("Can't delete notification: \(error.localizedDescription)")
        }
        
        guard let newData = notification.getJsonData(),
              let newDirectory = getDocumentDirectory(for: "welcome_Message") else { return }
        do {
            try newData.write(to: newDirectory.appendingPathComponent("\(notification.id).json"))
        } catch {
            debugPrint("Can't write notification model json data to file: \(error.localizedDescription)")
        }
    }
    
    fileprivate func getDocumentDirectory(for type: String) -> URL? {
        let fileManager = FileManager.default
        do {
            let docURL = Constants.fileManagerURL
            let notificationsUrl = docURL.appendingPathComponent("LocalNotifications")
            if !fileManager.fileExists(atPath: notificationsUrl.path) {
                try fileManager.createDirectory(atPath: notificationsUrl.path, withIntermediateDirectories: true, attributes: nil)
            }
            
            let notificationTypeUrl = notificationsUrl.appendingPathComponent(type)
            if !fileManager.fileExists(atPath: notificationTypeUrl.path) {
                try fileManager.createDirectory(atPath: notificationTypeUrl.path, withIntermediateDirectories: true, attributes: nil)
            }
            return notificationTypeUrl
        } catch {
            debugPrint("Can't get docURL: \(error.localizedDescription)")
            return nil
        }
    }
    public func getLocalSavedLocalNotifications( success: @escaping([LocalNotification]) -> Void) {
        
        guard let welcomeMessageDirectory = getDocumentDirectory(for: "welcome_Message") else {
            success([])
            return
            
        }
        
        success(getLocalNotificationsFromDirectory(directory: welcomeMessageDirectory))
    }
    fileprivate func getLocalNotificationsFromDirectory(directory: URL) -> [LocalNotification] {
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            var notifications: [LocalNotification] = []
            
            for url in urls {
                let jsonData = try Data(contentsOf: url)
                let notification = try JSONDecoder().decode(LocalNotification.self, from: jsonData)
                notifications.append(notification)
                self.localNotifications.append((notification))
            }
            if !notifications.isEmpty {self.welcomeMessagePresent = true}
            return notifications
        } catch {
            debugPrint("Can't get notification from json: \(error.localizedDescription)")
        }
        return []
    }
}
