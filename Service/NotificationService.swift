//
//  NotificationService.swift
//  Service
//
//  Created by Ruben Nahatakyan on 11/28/18.
//  Copyright © 2018 WitPlex. All rights reserved.
//

import UIKit
import RealmSwift
import Localize_Swift
import UserNotifications

@available(iOS 10.0, *)
class NotificationService: UNNotificationServiceExtension {
    fileprivate var hsUnit = ""
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        guard let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent) else {
            contentHandler(request.content)
            return
        }

        guard
            let stringType = request.content.userInfo["notificationType"] as? String,
            let _ = NotificationType(rawValue: stringType) else {
                bestAttemptContent.title = "Hi"
                bestAttemptContent.body = "Are you remember about us?"
                bestAttemptContent.badge = nil
                contentHandler(bestAttemptContent)
                return
        }

        bestAttemptContent.categoryIdentifier = "CustomSamplePush"
        Localize.setCurrentLanguage(UserDefaults(suiteName: "group.com.witplex.MinerBox")?.string(forKey: "appLanguage") ?? "en")

        setupRealm()
        let notification = convertReceivedDataToModel(userInfo: request.content.userInfo as NSDictionary, title: bestAttemptContent.title, body: bestAttemptContent.body)
        var userInfo = request.content.userInfo
        incrementNotificationCount(type: notification.notificationType)

        switch notification.notificationType {
        case .hashrate, .worker, .reportedHashrate :
            let isHashrate = notification.notificationType == .hashrate
            let isWorker = notification.notificationType == .worker
            let isrepHash = notification.notificationType == .reportedHashrate
            // Add image to notification
            if isHashrate {
                addImageToAttachments(name: "hashrate_alert", to: bestAttemptContent)
            } else if isWorker {
                addImageToAttachments(name: "worker_alert", to: bestAttemptContent)
            } else if isrepHash {
                addImageToAttachments(name: "repHash_alert", to: bestAttemptContent)
            }
            // Config notification message and title
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                bestAttemptContent.title = notification.data.name + "      \(getPoolType(from: notification.title))"
                userInfo["first_title"] = notification.data.name
                userInfo["second_title"] = getPoolType(from: notification.title)
            } else {
                //
                let shortedTitle = getShortVersion(for: notification.data.name)
                bestAttemptContent.title = shortedTitle + getPoolType(from: notification.title)
                userInfo["first_title"] =  bestAttemptContent.title
            }
            
            var message = ""
            if notification.data.isAuto {
                message = isHashrate ? "notificaiton_auto_hashrate_changed".localized() : "notificaiton_auto_worker_changed".localized()
                if isHashrate {
                message = "notificaiton_auto_hashrate_changed".localized()
                } else if isWorker {
                message =  "notificaiton_auto_worker_changed".localized()
                } else if isrepHash {
                message =  "notificaiton_auto_repHashrate_changed".localized()
                }
            } else {
                if isHashrate {
                    message = notification.data.comparison ? "notification_hashrate_less_than".localized() : "notification_hashrate_greater_than".localized()
                } else if isWorker {
                    message = notification.data.comparison ? "notification_workers_less_than".localized() : "notification_workers_greater_than".localized()
                } else if isrepHash{
                    message = notification.data.comparison ? "notification_repHashrate_less_than".localized() : "notification_repHashrate_greater_than".localized()
                }
            }

            if isHashrate {
                message = message.replacingOccurrences(of: "xxx", with: notification.data.alertValue.textFromHashrate(hsUnit:hsUnit))
                message = message.replacingOccurrences(of: "yyy", with: notification.data.currentValue.textFromHashrate(hsUnit:hsUnit))
            } else if isWorker {
                message = message.replacingOccurrences(of: "xxx", with: notification.data.alertValue.getString())
                message = message.replacingOccurrences(of: "yyy", with: notification.data.currentValue.getString())
            } else if isrepHash{
                message = message.replacingOccurrences(of: "xxx", with: notification.data.alertValue.textFromHashrate(hsUnit:hsUnit))
                message = message.replacingOccurrences(of: "yyy", with: notification.data.currentValue.textFromHashrate(hsUnit:hsUnit))
            }

            bestAttemptContent.body = message
            userInfo["received_message"] = message

            // Save notification
            bestAttemptContent.userInfo = userInfo

            // Grouping notification by type
            if #available(iOS 12.0, *) {
                bestAttemptContent.threadIdentifier = String(userInfo["bundleId"] as? Int ?? 0)
                bestAttemptContent.summaryArgument = userInfo["second_title"] as? String ?? ""
            }
        case .coin:
            // Add image to notification
            addImageToAttachments(name: "coin_alert", to: bestAttemptContent)

            // Config notification message and title
            bestAttemptContent.title = notification.data.name
            userInfo["first_title"] = bestAttemptContent.title
            if let aps = userInfo["aps"] as? NSDictionary, let alert = aps.value(forKey: "alert") as? NSDictionary, let coinName = alert.value(forKey: "title") as? String {
                userInfo["second_title"] = coinName
            }

            var message = notification.data.comparison ? "notification_coin_less_than".localized() : "notification_coin_greater_than".localized()
            message = message.replacingOccurrences(of: "xxx",
                                                   with:"\(notification.data.currency) "  + notification.data.alertValue.getString())
            message = message.replacingOccurrences(of: "yyy",
                                                   with:"\(notification.data.currency) " + notification.data.currentValue.getString())
            bestAttemptContent.body = message.htmlToString
            userInfo["received_message"] = message

            // Save notification
            bestAttemptContent.userInfo = userInfo

            // Grouping notification by type
            if #available(iOS 12.0, *) {
                bestAttemptContent.threadIdentifier = "Coin"
                bestAttemptContent.summaryArgument = "Coin"
            }
        case .info:
            // Add image to notification
            addImageToAttachments(name: "info_alert", to: bestAttemptContent)

            // Config notification message and title
            bestAttemptContent.title = notification.title
            bestAttemptContent.body = notification.content.htmlToString
            userInfo["first_title"] = bestAttemptContent.title
            userInfo["received_message"] = bestAttemptContent.body

            // Save notification
            bestAttemptContent.userInfo = userInfo

            // Grouping notification by type
            if #available(iOS 12.0, *) {
                bestAttemptContent.threadIdentifier = "Info"
                bestAttemptContent.summaryArgument = "Info"
            }
        case .payout:
            // Add image to notification
            addImageToAttachments(name: "payout_alert", to: bestAttemptContent)

            // Config notification message and title
                   
            if UIDevice.current.userInterfaceIdiom == .pad {
                bestAttemptContent.title = notification.data.name + "      \(getPoolType(from: notification.title))"
                userInfo["second_title"] = getPoolType(from: notification.title)
                userInfo["first_title"] = notification.data.name
            } else {
                let shortedTitle = getShortVersion(for: notification.data.name)
                bestAttemptContent.title = shortedTitle + getPoolType(from: notification.title)
                userInfo["first_title"] =  bestAttemptContent.title
            }

            var message = "new_payout_detected".localized()
            message = message.replacingOccurrences(of: "xxx", with: notification.data.currency + " " + notification.data.value.getString()  )
            bestAttemptContent.body = message.htmlToString
            userInfo["received_message"] = message

            // Save notification
            bestAttemptContent.userInfo = userInfo

            // Grouping notification by type
            if #available(iOS 12.0, *) {
                bestAttemptContent.threadIdentifier = String(userInfo["bundleId"] as? Int ?? 0)
                bestAttemptContent.summaryArgument = userInfo["second_title"] as? String ?? ""
            }
        }

        contentHandler(bestAttemptContent)
    }
    
    // MARK: -- Helper function for cutting pool notification title
    private func getShortVersion(for title: String) -> String {
        let distanceString = "      "
        if title.count > 15 {
            let startIndex = title.index(title.startIndex, offsetBy: 0)
            let endIndex = title.index(startIndex, offsetBy: 14)
            return title[startIndex..<endIndex] + "..." + distanceString
        } else {
            return title + distanceString
        }
    }

    fileprivate func getPoolType(from title: String) -> String {
        let components = title.components(separatedBy: ",")
        if components.indices.contains(1), let pool = Int(components[0]), let subPool = Int(components[1]) {
            return getTitle(pool: pool, subPool: subPool)
        } else if components.indices.contains(0), let pool = Int(components[0]) {
            return getTitle(pool: pool, subPool: nil)
        }
        return ""
    }

    func addImageToAttachments(name: String, to bestAttemptContent: UNMutableNotificationContent) {
        let image = UIImage(named: name)!
        let url = image.createLocalURL(name: name)
        if let attachmentURL = url?.absoluteString, let imageData = try? Data(contentsOf: URL(string: attachmentURL)!), let attachment = save((name + ".png"), data: imageData, options: nil) {
            bestAttemptContent.attachments = [attachment]
        }
    }

    func save(_ identifier: String, data: Data, options: [AnyHashable: Any]?) -> UNNotificationAttachment? {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString, isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            let fileURL = directory.appendingPathComponent(identifier)
            try data.write(to: fileURL, options: [])
            return try UNNotificationAttachment(identifier: identifier, url: fileURL, options: options)
        } catch {
            debugPrint(error.localizedDescription)
        }

        return nil
    }

    override func serviceExtensionTimeWillExpire() {
        super.serviceExtensionTimeWillExpire()
        debugPrint("Notification handling error")
    }

    func incrementNotificationCount(type: NotificationType) {
        guard let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox"), let user = DatabaseManager.shared.currentUser else { return }
        var keyName = ""
        switch type {
        case .hashrate:
            keyName = "\(user.id)hashrateNotificationsCount"
        case .reportedHashrate:
            keyName = "\(user.id)repHashrateNotificationsCount"
        case .worker:
            keyName = "\(user.id)workerNotificationsCount"
        case .payout:
            keyName = "\(user.id)payoutNotificationsCount"
        case .info:
            keyName = "\(user.id)infoNotificationsCount"
        case .coin:
            keyName = "\(user.id)coinNotificationsCount"
        }
        let count = userDefaults.integer(forKey: keyName)
        userDefaults.set(count + 1, forKey: keyName)
    }

    fileprivate func getTitle(pool: Int, subPool: Int?) -> String {
        guard let pool = getPool(id: pool, subPoolId: subPool) else { return "" }
        return subPool == nil ? pool.name : "\(pool.name) / \(pool.subPoolName)"
    }

    fileprivate func getPool(id: Int, subPoolId: Int?) -> (name: String, subPoolName: String)? {
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
                hsUnit = pool.value(forKey: "hsUnit") as? String ?? ""
                if let subItems = pool.value(forKey: "subItems") as? [NSDictionary], let subId = subPoolId {
                    for subitem in subItems {
                        if let id = subitem.value(forKey: "id") as? Int, id == subId {
                            if let subPoolShortName = subitem.value(forKey: "shortName") as? String , subPoolShortName != ""  {
                                subPoolName = subPoolShortName
                            } else {
                                subPoolName = subitem.value(forKey: "name") as? String ?? ""
                            }
                            hsUnit = subitem.value(forKey: "hsUnit") as? String ?? ""
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

// MARK: - Actions
@available(iOS 10.0, *)
extension NotificationService {
    fileprivate func convertReceivedDataToModel(userInfo: NSDictionary, title: String, body: String) -> NotificationModel {
        let modelData = NSMutableDictionary()
        modelData.setValue(userInfo["name"], forKey: "name")
        modelData.setValue(userInfo["comparison"], forKey: "comparison")
        modelData.setValue(userInfo["alertValue"], forKey: "alertValue")
        modelData.setValue(userInfo["notificationType"], forKey: "notificationType")
        modelData.setValue(userInfo["currentValue"], forKey: "currentValue")
        modelData.setValue(userInfo["value"], forKey: "value")
        modelData.setValue(userInfo["currency"], forKey: "currency")
        modelData.setValue(userInfo["isAuto"], forKey: "isAuto")
        modelData.setValue(userInfo["poolId"], forKey: "poolId")


        let dictionary = NSMutableDictionary()
        dictionary.setValue(title, forKey: "title")
        dictionary.setValue(body, forKey: "content")
        dictionary.setValue(modelData, forKey: "data")

        return NotificationModel(json: dictionary,isFromPushUp: true)
    }
}

// MARK: - Realm
@available(iOS 10.0, *)
extension NotificationService {
    fileprivate func setupRealm() {
        DatabaseManager.shared.migrateRealm()
    }
}
