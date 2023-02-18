//
//  SubscriptionModel.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 1/21/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import RealmSwift

class SubscriptionModel: Object {
    @objc dynamic var promoType: Int = 0
    @objc dynamic var subscriptionType: Int = 0
    @objc dynamic var subscriptionState: Int = 0
    @objc dynamic var maxAccountCount: Int = 0
    @objc dynamic var maxConvertCoinCount: Int = 0
    @objc dynamic var storeType: Int = -1
    @objc dynamic var purchaseRecipt: PurchaseRecipt? = nil
    @objc dynamic var trialState: Int = 0
    @objc dynamic var standartMaxAccountCount: Int = 0
    @objc dynamic var premiumMaxAccountCount: Int = 0
    

    convenience init(json: NSDictionary) {
        self.init()
        self.promoType = json.value(forKey: "promoType") as? Int ?? 0
        self.subscriptionType = json.value(forKey: "subscriptionType") as? Int ?? 0
        self.subscriptionState = json.value(forKey: "subscriptionState") as? Int ?? 0
        self.maxAccountCount = json.value(forKey: "maxAccountCount") as? Int ?? 0
        self.maxConvertCoinCount = json.value(forKey: "maxConvertCoinCount") as? Int ?? 0
        self.trialState = json.value(forKey: "trialState") as? Int ?? 0
        self.standartMaxAccountCount = json.value(forKey: "standardAccountCount") as? Int ?? 0
        self.premiumMaxAccountCount = json.value(forKey: "premiumAccountCount") as? Int ?? 0
    }

    public func getStoreType() -> SubscriptionStoreType {
        return SubscriptionStoreType(rawValue: storeType) ?? .none
    }

    public func getSubscriptionType() -> SubscriptionTypeEnum {
        return SubscriptionTypeEnum(rawValue: subscriptionType) ?? .none
    }

    public func getSubscriptionState() -> SubscriptionStateEnum {
        return SubscriptionStateEnum(rawValue: subscriptionState) ?? .none
    }
}

class PurchaseRecipt: Object {
    @objc dynamic var product_id: String? = nil
    @objc dynamic var auto_renew_product_id: String? = nil
    @objc dynamic var auto_renew_status: Int = 0

    convenience init(json: NSDictionary) {
        self.init()
        self.product_id = json.value(forKey: "product_id") as? String
        self.auto_renew_product_id = json.value(forKey: "auto_renew_product_id") as? String

        if let statusStr = json.value(forKey: "auto_renew_status") as? String, let status = Int(statusStr) {
            self.auto_renew_status = status
        } else {
            self.auto_renew_status = -1
        }
    }
}

// MARK: - Helpers
enum SubscriptionStoreType: Int {
    case none = -1
    case appStore = 0
    case playStore = 1
}

enum SubscriptionTypeEnum: Int {
    case none = 0
    case standardMonthly = 1
    case standardYearly = 2
    case premiumMonthly = 3
    case premiumYearly = 4
}

enum SubscriptionStateEnum: Int {
    case none = 0
    case active = 1
    case activeBut = 2
    case canceled = 3
    case billingRetry = 4
}
