//
//  ResponceHandler.swift
//  MinerBox
//
//  Created by Haykaz Melikyan on 7/4/18.
//  Copyright © 2018 WitPlex. All rights reserved.
//

import UIKit
import FirebaseCrashlytics

class ResponceHandler: NSObject {
    public func createAndSaveUser(dict: NSDictionary) {
        let user = UserModel(json: dict)
        RealmWrapper.sharedInstance.addObjectInRealmDB(user)
    }

    public func removeUser() {
        if let user = DatabaseManager().currentUser {
            RealmWrapper.sharedInstance.deleteObjectFromRealmDB(user)
        }

        removeCrashInfo()
//        removeSecuritySettings()
        UserDefaults(suiteName: "group.com.witplex.MinerBox")?.removeObject(forKey: "userId")
        UserDefaults(suiteName: "group.com.witplex.MinerBox")?.removeObject(forKey: "authKey")
    }

    fileprivate func removeCrashInfo() {
        Crashlytics.crashlytics().setUserID("not reg.")
    }

    fileprivate func removeSecuritySettings() {
        UserDefaults.standard.set(false, forKey: "security_use_\(SecurityTableEnum.usePin.rawValue)")
        UserDefaults.standard.set(false, forKey: "security_use_\(SecurityTableEnum.useBiometry.rawValue)")
        UserDefaults.standard.removeObject(forKey: "pin_code")
    }

    public func createAndSavePoolsType(dict: NSDictionary, key: Int) {
        let poolTypeObject = PoolTypeModel(json: dict)
        poolTypeObject.index = key
        RealmWrapper.sharedInstance.addObjectInRealmDB(poolTypeObject)
    }
    
    public func createAndSavePoolAccount(dict: NSDictionary) {
        let poolAccountObject = PoolAccountModel(json: dict)
        RealmWrapper.sharedInstance.addObjectInRealmDB(poolAccountObject)
    }
    
    public func removePoolAccount(poolId: String) {
        if let account = DatabaseManager().getPoolAccount(id: poolId) {
            RealmWrapper.sharedInstance.deleteObjectFromRealmDB(account)
        }
    }
    public func updatePoolAccount(poolId: String, poolAccountId: String, poolAccountLabel: String) {
        if let account = DatabaseManager().getPoolAccount(id: poolId) {
            RealmWrapper.sharedInstance.updateObjects {
                account.poolAccountId = poolAccountId
                account.poolAccountLabel = poolAccountLabel
            }
        }
    }
}
