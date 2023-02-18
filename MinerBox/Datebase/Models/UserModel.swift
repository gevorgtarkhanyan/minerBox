//
//  UserModel.swift
//  MinerBox
//
//  Created by Haykaz Melikyan on 7/9/18.
//  Copyright © 2018 WitPlex. All rights reserved.
//

import UIKit
import RealmSwift

class UserModel: Object {
    @objc dynamic var id = ""
    @objc dynamic var name = ""
    @objc dynamic var auth = ""
    @objc dynamic var email = ""
    @objc dynamic var currency = "USD"
    @objc dynamic var subsciptionInfo: SubscriptionModel?

    open override class func primaryKey() -> String? {
        return "id"
    }

    convenience init(json: NSDictionary) {
        self.init()
        self.id = json.value(forKey: "_id") as? String ?? ""
        self.name = json.value(forKey: "name") as? String ?? ""
        self.auth = json.value(forKey: "auth") as? String ?? ""
        self.currency = json.value(forKey: "currencyMode") as? String ?? "USD"
        self.email = json.value(forKey: "email") as? String ?? ""

        if let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") {
            userDefaults.set(self.id, forKey: "userId")
            userDefaults.set(self.auth, forKey: "authKey")
        }
    }

    @objc var isSubscribted: Bool {
        if (subsciptionInfo?.subscriptionState == 1 || subsciptionInfo?.subscriptionState == 2) {
            return true
        }
        return isPromoUser
    }

    @objc dynamic var trialState: Bool {
        return subsciptionInfo?.trialState == 2
    }

    @objc dynamic var subscriptionId: String? {
        return subsciptionInfo?.purchaseRecipt?.product_id
    }

    @objc dynamic var nextSubscriptionId: String? {
        return subsciptionInfo?.purchaseRecipt?.auto_renew_product_id
    }

    @objc dynamic var isPromoUser: Bool {
        if let promotype = subsciptionInfo?.promoType, promotype == 2 || promotype == 1 {
            return true
        }
        return false
    }

    @objc dynamic var isPremiumUser: Bool {
        let premiumSubscription = (subsciptionInfo?.subscriptionType == 3 || subsciptionInfo?.subscriptionType == 4)
        let subscriptionActive = (subsciptionInfo?.subscriptionState == 1 || subsciptionInfo?.subscriptionState == 2)

        if premiumSubscription, subscriptionActive {
            return true
        } else if let promotype = subsciptionInfo?.promoType, promotype == 2 {
            return true
        }
        return false
    }

    @objc dynamic var isStandardUser: Bool {
        
        let standardSubscription = (subsciptionInfo?.subscriptionType == 1 || subsciptionInfo?.subscriptionType == 2)
        let subscriptionActive = (subsciptionInfo?.subscriptionState == 1 || subsciptionInfo?.subscriptionState == 2)

        if standardSubscription, subscriptionActive {
            return true
        } else if let promotype = subsciptionInfo?.promoType, promotype == 1 {
            return true
        }
        return false
        
    }

    @objc dynamic var maxAccountCount: Int {
        if let subscribtion = subsciptionInfo {
            return subscribtion.maxAccountCount
        }
        return 1
    }
}
