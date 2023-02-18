//
//  KitAccountModel.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 27.09.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift


class  KitAccountModel: Object {
    
    @objc dynamic var _id = UUID().uuidString
    @objc dynamic var poolId = ""
    @objc dynamic var poolSubItem = 0
    @objc dynamic var poolType = 0
    @objc dynamic var poolAccountLabel = ""
    @objc dynamic var poolIcon = ""
    @objc dynamic var userId = ""
    @objc dynamic var poolSubItemName = ""
    @objc dynamic var poolTypeName = ""
    @objc dynamic var currentHashrate: Double = 0.0
    @objc dynamic var workersCount = 0
    @objc dynamic var hsUnit: String = ""
    
    var coinsItems = List<KitBalanceCoin>()
    
    var coins: [KitBalanceCoin] {
        
        if coinsItems.count == 0 {
            return []
        }
        let items = Array(coinsItems)
        return items
    }
    
    override class func primaryKey() -> String? {
        return "_id"
    }
    
    
    convenience init(json: NSDictionary) {
        self.init()
        
        self.poolId = json.value(forKey: "poolId") as? String ?? ""
        
        self.poolSubItem = json.value(forKey: "poolSubItem") as? Int ?? 0
        self.poolType = json.value(forKey: "poolType") as? Int ?? 0
        
        self.poolAccountLabel = json.value(forKey: "poolAccountLabel") as? String ?? ""
        self.poolIcon = json.value(forKey: "poolIcon") as? String ?? ""
        self.currentHashrate = json.value(forKey: "currentHashrate") as? Double ?? 0.0
        self.workersCount = json.value(forKey: "workersCount") as? Int ?? 0
        
        if let _coins = json.value(forKey: "coins") as? [NSDictionary] {
            _coins.forEach { self.coinsItems.append((KitBalanceCoin(json: $0)))}
        }
        
        guard let poolId = json.value(forKey: "poolType") as? Int, let currentPool = DatabaseManager.shared.getPool(id: poolId) else { return }
        self.poolType = currentPool.poolId
        self.poolTypeName = currentPool.poolName
        self.hsUnit = currentPool.hsUnit
        if let subPoolId = json.value(forKey: "poolSubItem") as? Int {
            let subPool = currentPool.subItems.first { $0.id == subPoolId }
            if subPool?.name != nil {
                if subPool!.shortName != "" {
                    self.poolSubItemName = "\(subPool!.shortName)"
                } else {
                    self.poolSubItemName = "\(subPool!.name)"
                }
                self.hsUnit = subPool?.hsUnit ?? ""
                
            }
        }
    }
}

class KitBalanceCoin: Object {
    
    @objc dynamic var currency = ""
    @objc dynamic var coinId = ""
    @objc dynamic var paid: Double = 0
    @objc dynamic var unpaid: Double = 0
    @objc dynamic var unconfirmed: Double = 0
    @objc dynamic var confirmed: Double = 0
    @objc dynamic var orphaned: Double = 0
    @objc dynamic var credit: Double = 0
    @objc dynamic var marketPriceBTC: Double = 0
    @objc dynamic var totalBalance: Double = 0
    
    convenience init(json: NSDictionary) {
        self.init()
        
        self.currency = json.value(forKey: "currency") as? String ?? ""
        self.coinId = json.value(forKey: "coinId") as? String ?? ""
        self.paid = json.value(forKey: "paid") as? Double ?? -1.0
        self.unpaid = json.value(forKey: "unpaid") as? Double ?? -1.0
        self.unconfirmed = json.value(forKey: "unconfirmed") as? Double ?? -1.0
        self.confirmed = json.value(forKey: "confirmed") as? Double ?? -1.0
        self.orphaned = json.value(forKey: "orphaned") as? Double ?? -1.0
        self.credit = json.value(forKey: "credit") as? Double ?? -1.0
        self.marketPriceBTC = json.value(forKey: "priceBTC") as? Double ?? 0.0
        self.totalBalance = json.value(forKey: "totalBalance") as? Double ?? -1.0
    }
}


