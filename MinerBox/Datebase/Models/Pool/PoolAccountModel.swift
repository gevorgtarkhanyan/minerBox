//
//  PoolAcoountModel.swift
//  MinerBox
//
//  Created by Haykaz Melikyan on 7/31/18.
//  Copyright © 2018 WitPlex. All rights reserved.
//

import Foundation
import RealmSwift
var Testsssa = "asasd"

class PoolAccountModel: Object {
    @objc dynamic var id = ""
    var active = false
    var created = ""
    var currentHashrate: Double = 0.0
    @objc dynamic var poolAccountId = ""
    @objc dynamic var poolAccountLabel = ""
    @objc dynamic var poolSubItem = 0
    @objc dynamic var poolType = 0
    var name = 0
    var workersCount = 0
    var Isloaded = false
    var invalidCredentials = false
    var accountExtras: [AccountExtra] = []
    
    @objc dynamic var poolSubItemName = ""
    @objc dynamic var poolSubItemHsUnit = ""
    @objc dynamic var poolTypeName = ""
    @objc dynamic var poolTypeHsUnit = ""
    var balances: [String] = []
    var selectedBalanceType: String = ""
    var selected = false
    
    
    @objc dynamic var order = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override init() {
        super.init()
    }
    
    init(json: NSDictionary) {
        self.id = json.value(forKey: "_id") as? String ?? ""
        self.active = json.value(forKey: "active") as? Bool ?? false
        self.created = json.value(forKey: "created") as? String ?? ""
        self.currentHashrate = json.value(forKey: "currentHashrate") as? Double ?? 0.0
        self.poolAccountId = json.value(forKey: "poolAccountId") as? String ?? ""
        self.poolAccountLabel = json.value(forKey: "poolAccountLabel") as? String ?? ""
        self.poolSubItem = json.value(forKey: "poolSubItem") as? Int ?? -1
        self.poolType = json.value(forKey: "poolType") as? Int ?? -1
        self.workersCount = json.value(forKey: "workersCount") as? Int ?? 0
        self.order = json.value(forKey: "order") as? Int ?? 0
        self.Isloaded = json.value(forKey: "loaded") as? Bool ?? false
        self.invalidCredentials = json.value(forKey: "invalidCredentials") as? Bool ?? false
        
        guard let poolId = json.value(forKey: "poolType") as? Int, let currentPool = DatabaseManager.shared.getPool(id: poolId) else { return }
        self.poolType = currentPool.poolId
        self.poolTypeName = currentPool.poolName 
        self.poolTypeHsUnit = currentPool.hsUnit
        
        
        let extrasFromBeckedn = json.value(forKey: "extras") as? [String:String]
        
        for extra in currentPool.extras {
            self.accountExtras.append(AccountExtra(extraName: extra.placeholder , extraValue: extrasFromBeckedn?[extra.extraId]))
        }
        
        if let subPoolId = json.value(forKey: "poolSubItem") as? Int {
            let subPool = currentPool.subItems.first { $0.id == subPoolId }
            self.poolSubItemName = subPool?.name ?? ""
            self.poolSubItemHsUnit = subPool?.hsUnit ?? ""
            
            if subPool!.extraDataIsExist {
                accountExtras.removeAll()
                for extra in subPool!.extras! {
                    self.accountExtras.append(AccountExtra(extraName: extra.placeholder , extraValue: extrasFromBeckedn?[extra.extraId]))
                }
            }
        }
    }
    
    static func == (lhs: PoolAccountModel, rhs: PoolAccountModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    public var poolName : String {
        return poolSubItemName != "" ? "\(poolTypeName) / \(poolSubItemName)" : poolTypeName
    }
    
    public var keyPath: String {
        return "\(poolAccountId)\(poolType)\(poolSubItem)"
    }
    
    public var hsUnit: String {
        return poolSubItem == -1 ? poolTypeHsUnit : poolSubItemHsUnit
    }
}

//Helpers
class AccountExtra {
    
    var extraName:String?
    var extraValue:String?
    
    convenience init(extraName: String?,extraValue: String?) {
        self.init()
        
        self.extraName  = extraName
        self.extraValue = extraValue
        
    }
}
