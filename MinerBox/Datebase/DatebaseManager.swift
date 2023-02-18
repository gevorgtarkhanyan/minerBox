//
//  DatebaseManager.swift
//  MinerBox
//
//  Created by Haykaz Melikyan on 7/6/18.
//  Copyright © 2018 WitPlex. All rights reserved.
//

import UIKit
import RealmSwift

class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    var currentUser: UserModel? {
        do {
            return try Realm().objects(UserModel.self).last
        } catch {
            debugPrint(error.localizedDescription)
        }
        
        return nil
    }
    
    var communityModel: CommunityModel? {
        do {
            return try Realm().objects(CommunityModel.self).last
        } catch {
            debugPrint(error.localizedDescription)
        }
        
        return nil
    }
    
    var allEnabledPoolTypes: [PoolTypeModel]? {
        do {
            let predicate = NSPredicate(format: "isEnabled = true")
            let poolsType = try Realm().objects(PoolTypeModel.self).filter(predicate)
            let array = Array(poolsType)
            return array
        } catch {
            debugPrint(error.localizedDescription)
        }
        return nil
    }
    
    var allPoolTypes: [PoolTypeModel]? {
        do {
            
            let poolsType = try Realm().objects(PoolTypeModel.self)
            let array = Array(poolsType)
            return array
        } catch {
            debugPrint(error.localizedDescription)
        }
        return nil
    }
    
    var allPoolAccounts: [PoolAccountModel]? {
        do {
            let poolsAccounts = try Realm().objects(PoolAccountModel.self)
            let array = Array(poolsAccounts)
            return array
        } catch {
            debugPrint(error.localizedDescription)
        }
        return nil
    }
    
    var fiats: [FiatModel]? {
        return RealmWrapper.sharedInstance.getAllObjectsOfModel(FiatModel.self) as? [FiatModel]
    }
    
    var firstLaunch: String? {
        set {
            if newValue != nil {
                UserDefaults.standard.setValue(newValue, forKey: "firstTimeKey")
                UserDefaults.standard.synchronize()
            }
        }
        
        get {
            return UserDefaults.standard.value(forKey: "firstTimeKey") as? String
        }
    }
    
    public func getPoolAccount(id: String) -> PoolAccountModel? {
        do {
            let poolsType = try Realm().objects(PoolAccountModel.self).first { $0.id == id }
            return poolsType
        } catch {
            debugPrint(error.localizedDescription)
        }
        return nil
    }
    
    public func getPool(id: Int) -> PoolTypeModel? {
        do {
            let poolsType = try Realm().objects(PoolTypeModel.self)
            let pool = Array(poolsType).first { $0.poolId == id }
            return pool
        } catch {
            debugPrint(error.localizedDescription)
        }
        return nil
    }
    
    //MARK: - Migration
    func migrateRealm(with user: UserModel? = nil) {
        UserDefaults.standard.set(true, forKey: "RealmDBUpdated")
        
        let config = Realm.Configuration(
            fileURL: Constants.RealmDBUrl,
            schemaVersion: Constants.RealmSchemaVersion,
            migrationBlock: { migration, oldSchemaVersion in
                
                //Migrate PoolTypeModel primaryKey
                if (oldSchemaVersion < 57) {
                    var index = 0
                    migration.enumerateObjects(ofType: PoolTypeModel.className()) { oldObject, newObject in
                        newObject?["index"] = index
                        index += 1
                    }
                }
            }
        )
        
        Realm.Configuration.defaultConfiguration = config
        
        do {
            let realm = try Realm()
            if let newUser = user {
                try realm.write {
                    realm.create(UserModel.self, value: newUser, update: .all)
                }
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
}
