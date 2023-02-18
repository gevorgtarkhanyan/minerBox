//
//  NotificationModel.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 8/2/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import FirebaseCrashlytics


class NotificationModel: NSObject, Codable {
    let id: String
    let userId: String
    let title: String
    let content: String
    let data: NotificationModelData
    let sentDate: Double
    let fromPushUp: Bool
    
    init(json: NSDictionary, isFromPushUp: Bool = false) {
        
        Crashlytics.crashlytics().setCustomValue(isFromPushUp, forKey: "isFromPushUp")

        self.id = json.value(forKey: "_id") as? String ?? UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        self.userId = DatabaseManager.shared.currentUser?.id ?? ""
        self.title = json.value(forKey: "title") as? String ?? ""
        self.content = json.value(forKey: "content") as? String ?? ""
        self.data = NotificationModelData(json: json.value(forKey: "data") as? NSDictionary)
        self.fromPushUp = isFromPushUp

        if let sendDate = json.value(forKey: "sentDate") as? Double {
            self.sentDate = sendDate
        } else if let sendDate = json.value(forKey: "sentDate") as? Int {
            self.sentDate = Double(sendDate)
        } else {
            self.sentDate = Date().timeIntervalSince1970
        }

        super.init()
        NotificationManager.shared.writeToFile(notification: self)
        
    }

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

    var poolType: String {
        return NotificationManager.shared.getPoolType(from: title)//getPoolType(from: title)
    }
    
    var notificationType: NotificationType {
        return NotificationType(rawValue: self.data.notificationType) ?? .info
    }

    var asDictionary: [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary["id"] = self.id
        dictionary["userId"] = self.userId
        dictionary["title"] = self.title
        dictionary["content"] = self.content
        dictionary["data"] = self.data.asDictionary
        dictionary["sentDate"] = self.sentDate
        
        return dictionary
    }
    
//    private func getSavedPoolType(with savedKey: String) -> String? {
//        let poolDict = httpAttributedStrDict.first { Array($0.keys)[0] == savedKey }
//        if let poolDict = poolDict, let poolType = poolDict[savedKey] {
//            return poolType
//        }
//        return nil
//    }

}

class NotificationModelData: NSObject, Codable {
    let name: String
    let comparison: Bool
    let alertValue: Double
    let notificationType: String
    let currentValue: Double
    let value: Double
    let currency: String
    let isAuto: Bool
    let poolId: String
    let coinId: String

    init(json: NSDictionary?) {
        let json = json ?? NSDictionary()
        self.name = json.value(forKey: "name") as? String ?? ""
        self.comparison = json.value(forKey: "comparison") as? Bool ?? false
        self.alertValue = json.value(forKey: "alertValue") as? Double ?? 0
        self.notificationType = json.value(forKey: "notificationType") as? String ?? ""
        self.currentValue = json.value(forKey: "currentValue") as? Double ?? 0
        self.value = json.value(forKey: "value") as? Double ?? 0
        self.currency = json.value(forKey: "currency") as? String ?? "$"
        self.isAuto = json.value(forKey: "isAuto") as? Bool ?? false
        self.poolId = json.value(forKey: "poolId") as? String ?? ""
        self.coinId = json.value(forKey: "coinId") as? String ?? ""
    }

    var asDictionary: [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary["name"] = self.name
        dictionary["comparison"] = self.comparison
        dictionary["alertValue"] = self.alertValue
        dictionary["notificationType"] = self.notificationType
        dictionary["currentValue"] = self.currentValue
        dictionary["value"] = self.value
        dictionary["currency"] = self.currency
        dictionary["isAuto"] = self.isAuto
        dictionary["poolId"] = self.poolId
        dictionary["coinId"] = self.coinId
        return dictionary
    }
}

class WelcomeNotificationModel: NSObject {
    let welcomeMessage: String
    let communityURL: NSDictionary
    
     init(json: NSDictionary) {
        self.welcomeMessage = json.value(forKey: "welcomeMessage") as? String ?? ""
        self.communityURL = json.value(forKey: "communityList") as? NSDictionary ?? [:]
    }
    
}

//MARK: - Custom content
extension NotificationModel {
    var customContent: String {
        var content: String
        let account = DatabaseManager.shared.getPoolAccount(id: data.poolId)
        switch notificationType {
        case .hashrate:
            if data.isAuto {
                let localizableText = "notificaiton_auto_hashrate_changed".localized()
                
                content = localizableText.replace(xxx: data.alertValue.textFromHashrate(account: account), yyy: data.currentValue.textFromHashrate(account: account))
            } else {
                let localizableText = (data.comparison ? "notification_hashrate_less_than" : "notification_hashrate_greater_than").localized()
                content = localizableText.replace(xxx: data.alertValue.textFromHashrate(account: account), yyy: data.currentValue.textFromHashrate(account: account))
            }
        case .worker:
            if data.isAuto {
                let localizableText = "notificaiton_auto_worker_changed".localized()
                
                content = localizableText.replace(xxx: data.alertValue.getString(), yyy: data.currentValue.getString())
            } else {
                let localizableText = (data.comparison ? "notification_workers_less_than" : "notification_workers_greater_than").localized()
                content = localizableText.replace(xxx: data.alertValue.textFromHashrate(account: account), yyy: data.currentValue.textFromHashrate(account: account))
            }
        case .coin:
            let localizableText = (data.comparison ? "notification_coin_less_than" : "notification_coin_greater_than").localized()
            content = localizableText.replace(xxx: "\( data.currency) " + data.alertValue.getString(), yyy: "\( data.currency) " + data.currentValue.getString())
        case .info:
            content = self.content
        case .payout:
            let localizableText = "new_payout_detected".localized()
            content = localizableText.replace(xxx:"\( data.currency) " + data.value.getString(), yyy: "")
        case .reportedHashrate:
            if data.isAuto {
                let localizableText = "notificaiton_auto_repHashrate_changed".localized()
                
                content = localizableText.replace(xxx: data.alertValue.textFromHashrate(account: account), yyy: data.currentValue.textFromHashrate(account: account))
            } else {
                let localizableText = (data.comparison ? "notification_repHashrate_less_than" : "notification_repHashrate_greater_than").localized()
                content = localizableText.replace(xxx: data.alertValue.textFromHashrate(account: account), yyy: data.currentValue.textFromHashrate(account: account))
            }
        }
        
        return content
    }
}
