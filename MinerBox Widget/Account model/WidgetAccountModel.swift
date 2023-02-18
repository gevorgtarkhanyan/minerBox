//
//  WidgetAccountModel.swift
//  MinerBox Widget
//
//  Created by Ruben Nahatakyan on 6/11/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class WidgetAccountModel: NSObject {
    var poolId: String
    var poolAccountLabel: String
    var poolType: Int
    var poolSubItem: Int?
    var workersCount: Int
    var currentHashrate: Double
    var currency: String? = ""
    var paid: Double = 0
    var unpaid: Double = 0
    var unconfirmed: Double = 0
    var confirmed: Double = 0
    var orphaned: Double = 0
    var credit: Double = 0
    var selectedBalanceType: String = ""

    
    var poolSubItemHsUnit = ""
    var poolTypeHsUnit = ""

    init(json: NSDictionary) {
        self.poolId = json.value(forKey: "poolId") as? String ?? ""
        self.poolAccountLabel = json.value(forKey: "poolAccountLabel") as? String ?? ""
        self.poolType = json.value(forKey: "poolType") as? Int ?? 0
        self.poolSubItem = json.value(forKey: "poolSubItem") as? Int
        self.workersCount = json.value(forKey: "workersCount") as? Int ?? 0
        self.currentHashrate = json.value(forKey: "currentHashrate") as? Double ?? 0
        self.paid = json.value(forKey: "paid") as? Double ?? -1.0
        self.unpaid = json.value(forKey: "unpaid") as? Double ?? -1.0
        self.unconfirmed = json.value(forKey: "unconfirmed") as? Double ?? -1.0
        self.confirmed = json.value(forKey: "confirmed") as? Double ?? -1.0
        self.orphaned = json.value(forKey: "orphaned") as? Double ?? -1.0
        self.credit = json.value(forKey: "credit") as? Double ?? -1.0
        self.currency = json.value(forKey: "currency") as? String

        
        guard let poolId = json.value(forKey: "poolType") as? Int, let currentPool = DatabaseManager.shared.getPool(id: poolId) else { return }
        self.poolTypeHsUnit = currentPool.hsUnit
        if let subPoolId = json.value(forKey: "poolSubItem") as? Int {
            let subPool = currentPool.subItems.first { $0.id == subPoolId }
            self.poolSubItemHsUnit = subPool?.hsUnit ?? ""
        }
    }

    public func getPoolName() -> String {
        guard let pool = DatabaseManager.shared.getPool(id: poolType) else { return "" }
        if let subPoolId = poolSubItem {
            let sub = pool.subItems.first { $0.id == subPoolId }
            if let subPool = sub {
                
                guard !subPool.shortName.isEmpty else {
                    return "\(pool.poolName) / \(subPool.name)"
                }
                return "\(pool.poolName) / \(subPool.shortName)"
            }
        }
        return pool.poolName
    }
    
    public var hsUnit: String {
        return poolSubItem == 0 ? poolTypeHsUnit : poolSubItemHsUnit
    }
}
