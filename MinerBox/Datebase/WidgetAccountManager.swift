//
//  WidgetAccountManager.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/12/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import RealmSwift

class WidgetAccountManager: NSObject {
    
    static let shared = WidgetAccountManager()
    
    fileprivate var userID: String? {
        return DatabaseManager.shared.currentUser?.id
    }
    
    public func addAccount(_ account: PoolAccountModel) {
        guard let id = userID else { return }
        let model = WidgetModel(userId: id, account: account)
        
        do {
            let realm = try Realm()
            try realm.write {
                let realmModel = realm.create(WidgetModel.self, value: model, update: .error)
                realm.add(realmModel)
            }
            
        } catch {
            debugPrint("Something went wrong!")
        }
    }

    public func updateAccount(_ account: PoolAccountModel) {
        guard let id = userID else { return }
        let model = WidgetModel(userId: id, account: account)
        
        do {
            let realm = try Realm()
            try realm.write {
                let realmModel = realm.create(WidgetModel.self, value: model, update: .error)
                realmModel.selectedBalanceType = account.selectedBalanceType
                realm.add(realmModel)
            }
            
        } catch {
            debugPrint("Something went wrong!")
        }
    }
    
    public func removeAccount(_ account: PoolAccountModel) {
        guard let id = userID else { return }
        do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "userId = '\(id)' and accountId = '\(account.id)'")
            let accounts = realm.objects(WidgetModel.self).filter(predicate)
            
            try realm.write {
                realm.delete(accounts)
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }

    public func getAccountsIds() -> [String] {
        guard let id = userID else { return [] }
        
        do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "userId = '\(id)'")
            let accounts = realm.objects(WidgetModel.self).filter(predicate)
            
            return Array(accounts).map { $0.accountId }
        } catch {
            debugPrint(error.localizedDescription)
        }
        
        return []
    }
    public func getAccounts() -> [WidgetModel] {
        guard let id = userID else { return [] }
        
        do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "userId = '\(id)'")
            let accounts = realm.objects(WidgetModel.self).filter(predicate)
            
            return Array(accounts).map { $0 }
        } catch {
            debugPrint(error.localizedDescription)
        }
        
        return []
    }
}
