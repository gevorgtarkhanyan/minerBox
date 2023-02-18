//
//  PoolTypeModel.swift
//  MinerBox
//
//  Created by Haykaz Melikyan on 7/27/18.
//  Copyright © 2018 WitPlex. All rights reserved.
//

import Foundation
import RealmSwift

class PoolTypeModel: Object {
    @objc dynamic var index: Int = 0
    @objc dynamic var poolId: Int = 0
    @objc dynamic var poolName = ""
    @objc dynamic var poolLogoImagePath = ""
    @objc dynamic var isEnabled = false

    @objc dynamic var extBalance = false
    @objc dynamic var extEstimations = false
    @objc dynamic var extHashrate = false
    @objc dynamic var extRepHash = false
    @objc dynamic var extPayouts = false
    @objc dynamic var extShares = false
    @objc dynamic var extWorkers = false

    @objc dynamic var extGroups = false
    @objc dynamic var extBlocks = false
    @objc dynamic var extRewards = false

    @objc dynamic var keywords = ""
    
    @objc dynamic var acceptChars = ""
    @objc dynamic var urlParamAsId = ""
    @objc dynamic var webUrl: String?
    @objc dynamic var placeholder = ""
    @objc dynamic var shortName = ""
    @objc dynamic var puidPlaceholder = ""
    @objc dynamic var puidAcceptChars = ""
    @objc dynamic var hsUnit = ""
    @objc dynamic var guide = ""
    
    var extrasItems = List<Extra>()
    
    var extras: [Extra] {
        
        if extrasItems.count == 0 {
            return []
        }
        let items = Array(extrasItems)
        return items
    }

    

    var subItems = List<SubPoolItem>()

    var subPools: [SubPoolItem] {
        if subItems.count == 0 {
            return []
        }
        let items = Array(subItems).filter { $0.enabled == true }
        return items.sorted { $0.name < $1.name }
    }

    func addSubPools(_ s_pool: SubPoolItem) {
        self.subItems.append(s_pool)
    }

    open override class func primaryKey() -> String? {
        return "index"
    }

    convenience init(json: NSDictionary) {
        self.init()
        
        self.poolId     = json.value(forKey: "poolId") as? Int ?? 0
        self.poolName   = json.value(forKey: "poolName") as? String ?? ""
        self.shortName  = json.value(forKey: "shortName") as? String ?? ""
        
        if let poolIcon = json.value(forKey: "poolIcon") as? String, let path = poolIcon.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            self.poolLogoImagePath = path
        }
        
        if let extras = json.value(forKey: "extras") as? [NSDictionary] {
            extras.forEach { self.extrasItems.append((Extra(json: $0)))}
        }

        self.isEnabled = json.value(forKey: "enabled") as? Bool ?? false

        self.extBalance      =   json.value(forKey: "extBalance") as? Bool ?? false
        self.extEstimations  =   json.value(forKey: "extEstimations") as? Bool ?? false
        self.extHashrate     =   json.value(forKey: "extHashrate") as? Bool ?? false
        self.extRepHash      =   json.value(forKey: "extRepHash") as? Bool ?? false
        self.extPayouts      =   json.value(forKey: "extPayouts") as? Bool ?? false
        self.extShares       =   json.value(forKey: "extShares") as? Bool ?? false
        self.extWorkers      =   json.value(forKey: "extWorkers") as? Bool ?? false
        self.extGroups       =   json.value(forKey: "extGroups") as? Bool ?? false
        self.extBlocks       =   json.value(forKey: "extBlocks") as? Bool ?? false
        self.extRewards      =   json.value(forKey: "extRewards") as? Bool ?? false
        self.keywords        =   json.value(forKey: "keywords") as? String ?? ""
        self.acceptChars     =   json.value(forKey: "acceptChars") as? String ?? ""
        self.urlParamAsId    =   json.value(forKey: "urlParamAsId") as? String ?? ""
        self.webUrl          =   json.value(forKey: "webUrl") as? String
        self.placeholder     =   json.value(forKey: "placeholder") as? String ?? ""
        self.puidPlaceholder =   json.value(forKey: "puidPlaceholder") as? String ?? ""
        self.puidAcceptChars =   json.value(forKey: "puidAcceptChars") as? String ?? ""
        self.hsUnit          =   json.value(forKey: "hsUnit") as? String ?? ""
        self.guide           =   json.value(forKey: "guide") as? String ?? ""

        if let subItems = json.value(forKey: "subItems") as? [NSDictionary] {
            subItems.forEach { self.addSubPools(SubPoolItem(json: $0)) }
        }
    }
    
    static func getPoolType(from title: String) -> (pool: PoolTypeModel, subPool: SubPoolItem?)? {
        let components = title.components(separatedBy: ",")
        var poolId: Int = 0
        var subPoolId: Int?
        
        if components.indices.contains(1), let pool = Int(components[0]), let subPool = Int(components[1]) {
            poolId = pool
            subPoolId = subPool
        } else if components.indices.contains(0), let pool = Int(components[0]) {
            poolId = pool
        } else {
            return nil
        }
        
        if let allPoolTypes = DatabaseManager.shared.allPoolTypes {
            for pool in allPoolTypes {
                if pool.poolId == poolId {
                    if let subPoolId = subPoolId {
                        for subPool in pool.subItems {
                            if subPool.id == subPoolId {
                                return (pool: pool, subPool: subPool)
                            }
                        }
                    } else {
                        return (pool: pool, subPool: nil)
                    }
                }
            }
        }
        
        return nil
    }
    
}

class SubPoolItem: Object {
    
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var shortName = ""
    @objc dynamic var enabled = false
    @objc dynamic var coinId = ""
    @objc dynamic var keywords = ""
    @objc dynamic var placeholder = ""
    @objc dynamic var coinIconUrl = ""
    @objc dynamic var extEstimations = -1
    @objc dynamic var extRepHash = -1
    @objc dynamic var extRewards = -1
    @objc dynamic var hsUnit = ""
    @objc dynamic var guide = ""
    @objc dynamic var extraDataIsExist = false
    @objc dynamic var webUrl: String?

    
    var extrasItems = List<Extra>()

    var extras: [Extra]? {
        
        if extrasItems.count == 0 {
            return []
        }
        let items = Array(extrasItems)
        return items
    }


    convenience init(json: NSDictionary) {
        self.init()
        
        self.id              = json.value(forKey: "id") as? Int ?? 0
        self.name            = json.value(forKey: "name") as? String ?? ""
        self.shortName       = json.value(forKey: "shortName") as? String ?? ""
        self.enabled         = json.value(forKey: "enabled") as? Bool ?? false
        self.coinId          = json.value(forKey: "coinId") as? String ?? ""
        self.keywords        = json.value(forKey: "keywords") as? String ?? ""
        self.placeholder     = json.value(forKey: "placeholder") as? String ?? ""
        self.extEstimations  = json.value(forKey: "extEstimations") as? Int ?? -1
        self.extRepHash      = json.value(forKey: "extRepHash") as? Int ?? -1
        self.extRewards      = json.value(forKey: "extRewards") as? Int ?? -1
        self.hsUnit          = json.value(forKey: "hsUnit") as? String ?? ""
        self.guide           = json.value(forKey: "guide") as? String ?? ""
        self.webUrl          = json.value(forKey: "webUrl") as? String

        if let coinIconUrl = json.value(forKey: "coinIconUrl") as? String, let path = coinIconUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            self.coinIconUrl = path
        }
        
        if let extras = json.value(forKey: "extras") as? [NSDictionary] {
            self.extraDataIsExist = true
            extras.forEach { self.extrasItems.append((Extra(json: $0)))}
        }
    }
}

class Extra: Object {
    
    @objc dynamic var extraId = ""
    @objc dynamic var placeholder = ""
    @objc dynamic var acceptChars = ""
    @objc dynamic var text = ""
    @objc dynamic var optional:Bool = false
    

    convenience init(json: NSDictionary) {
        self.init()
        
        self.extraId     = json.value(forKey: "id") as? String ?? ""
        self.placeholder = json.value(forKey: "placeholder") as? String ?? ""
        self.acceptChars = json.value(forKey: "acceptChars") as? String ?? ""
        self.optional = json.value(forKey: "optional") as? Bool ?? false
        
    }
}
