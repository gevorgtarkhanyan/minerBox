//
//  PoolBalanceModel.swift
//  MinerBox
//
//  Created by Vazgen Hovakinyan on 14.05.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class PoolBalanceModel: Object {
    
    @objc dynamic var poolId = ""
    @objc dynamic var poolSubItem = 0
    @objc dynamic var poolType = 0
    @objc dynamic var poolAccountLabel = ""
    @objc dynamic var userId = ""
    @objc dynamic var poolSubItemName = ""
    @objc dynamic var poolTypeName = ""
    @objc dynamic var currentHashrate: Double = 0.0
    @objc dynamic var workersCount = 0
    @objc dynamic var isSelected = true
    var coinsItems = List<BalanceCoin>()

    var coins: [BalanceCoin]? {
        
        if coinsItems.count == 0 {
            return []
        }
        let items = Array(coinsItems)
        return items
    }

    convenience init(json: NSDictionary) {
        self.init()
        
        self.poolId = json.value(forKey: "_id") as? String ?? ""

        self.poolSubItem = json.value(forKey: "poolSubItem") as? Int ?? 0
        self.poolType = json.value(forKey: "poolType") as? Int ?? 0
        
        self.poolAccountLabel = json.value(forKey: "poolAccountLabel") as? String ?? ""
        self.currentHashrate = json.value(forKey: "currentHashrate") as? Double ?? 0.0
        self.workersCount = json.value(forKey: "allWorkers") as? Int ?? 0
        
        if let coins = json.value(forKey: "coins") as? [NSDictionary] {
            coins.forEach { self.coinsItems.append((BalanceCoin(json: $0)))}
        }
        
        guard let poolId = json.value(forKey: "poolType") as? Int, let currentPool = DatabaseManager.shared.getPool(id: poolId) else { return }
        self.poolType = currentPool.poolId
        self.poolTypeName = currentPool.poolName
        if let subPoolId = json.value(forKey: "poolSubItem") as? Int {
            let subPool = currentPool.subItems.first { $0.id == subPoolId }
            self.poolSubItemName =  subPool != nil  && subPool?.shortName != "" ? "/ \(subPool!.shortName)" : "/ \(subPool!.name)"

        }
    }
    static func > (lhs: PoolBalanceModel, rhs: PoolBalanceModel) -> Bool {
        return lhs.isSelected && !rhs.isSelected
    }
}

class BalanceCoin: Object {
    
    @objc dynamic var coinId = ""
    @objc dynamic var currency = ""
    @objc dynamic var orphaned: Double = 0
    @objc dynamic var unconfirmed: Double = 0
    @objc dynamic var confirmed: Double = 0
    @objc dynamic var unpaid: Double = 0
    @objc dynamic var paid: Double = 0
    @objc dynamic var paid24h: Double = 0
    @objc dynamic var reward24h: Double = 0
    @objc dynamic var totalBalance: Double = 0
    @objc dynamic var credit: Double = 0
    @objc dynamic var marketPriceBTC: Double = 0

    
    convenience init(json: NSDictionary) {
        self.init()
        
        self.coinId = json.value(forKey: "coinId") as? String ?? ""
        self.currency = json.value(forKey: "currency") as? String ?? ""
        self.orphaned = json.value(forKey: "orphaned") as? Double ?? -1.0
        self.unconfirmed = json.value(forKey: "unconfirmed") as? Double ?? -1.0
        self.confirmed = json.value(forKey: "confirmed") as? Double ?? -1.0
        self.unpaid = json.value(forKey: "unpaid") as? Double ?? -1.0
        self.paid = json.value(forKey: "paid") as? Double ?? -1.0
        self.paid24h = json.value(forKey: "paid24h") as? Double ?? -1.0
        self.reward24h = json.value(forKey: "reward24h") as? Double ?? -1.0
        self.totalBalance = json.value(forKey: "totalBalance") as? Double ?? -1.0
        self.credit = json.value(forKey: "credit") as? Double ?? -1.0
        self.marketPriceBTC = json.value(forKey: "priceBTC") as? Double ?? 0.0
        
        
    }
}


enum BalanceType: String, CaseIterable {
    case orphaned = "orphaned"
    case unconfirmed = "unconfirmed"
    case confirmed = "confirmed"
    case unpaid = "unpaid"
    case paid = "paid"
    case paid24h = "paid24h"
    case reward24h = "reward24h"
    case totalBalance = "totalBalance"
    case credit = "credit"
}

class BalanceSelectedType: Object {
    
//    @objc dynamic var _id = UUID().uuidString
    @objc dynamic var userId = ""
    @objc dynamic var balanceName: String = ""
    @objc dynamic var isSelected = true
    @objc dynamic var count = 0

    convenience init(name: BalanceType, userId: String,  isSelected: Bool = true) {
        
        self.init()
        self.balanceName = name.rawValue
        self.userId = userId
        self.isSelected = isSelected
    }
    static func > (lhs: BalanceSelectedType, rhs: BalanceSelectedType) -> Bool {
        return lhs.isSelected && !rhs.isSelected
    }
    static func == (lhs: BalanceSelectedType, rhs: BalanceSelectedType) -> Bool {
        return lhs.balanceName == rhs.balanceName && lhs.userId == rhs.userId
    }
}



