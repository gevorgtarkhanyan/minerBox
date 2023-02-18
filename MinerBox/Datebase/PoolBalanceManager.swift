//
//  PoolBalanceManager.swift
//  MinerBox
//
//  Created by Vazgen Hovakinyan on 14.05.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift


class PoolBalanceManager: NSObject {
    
    // MARK: - Static
    static let shared = PoolBalanceManager()
    
    fileprivate var userID: String? {
        return DatabaseManager.shared.currentUser?.id
    }
    
    public func addBalanceAccount(_ balance: PoolBalanceModel) {
        
        do {
            let realm = try Realm()
            try realm.write {
                let realmModel = realm.create(PoolBalanceModel.self, value: balance, update: .error)
                realm.add(realmModel)
            }
        } catch {
            debugPrint("Something went wrong!")
        }
    }
    public func addBalanceType(_ selectedBalance: BalanceSelectedType) {
        
        do {
            let realm = try Realm()
            try realm.write {
                let realmModel = realm.create(BalanceSelectedType.self, value: selectedBalance, update: .error)
                realm.add(realmModel)
            }
        } catch {
            debugPrint("Something went wrong!")
        }
    }
    public func removeBalance(_ poolId: String) {
        guard let userID = userID else { return }
        do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "userId = '\(userID)'and poolId = '\(poolId)'")
            
            let model = realm.objects(PoolBalanceModel.self).filter(predicate)
            
            try realm.write {
                realm.delete(model)
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    public func getBalancies() -> [PoolBalanceModel] {
        guard let userID = userID else { return []}
        
        do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "userId = '\(userID)'")
            let balance = realm.objects(PoolBalanceModel.self).filter(predicate)
            
            return Array(balance).map { $0 }
        } catch {
            debugPrint(error.localizedDescription)
        }
        
        return []
    }
    public func getSelectedBalancies() -> [BalanceSelectedType] {
        guard let userID = userID else { return []}
        
        do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "userId = '\(userID)'")
            let balance = realm.objects(BalanceSelectedType.self).filter(predicate)
            
            return Array(balance).map { $0 }
        } catch {
            debugPrint(error.localizedDescription)
        }
        
        return []
    }
    public func ubdateSelectedBalance(_ selectedBalance: BalanceSelectedType) {
        do {
            
            let realm = try Realm()
            
            let predicate = NSPredicate(format: "userId = '\(selectedBalance.userId)'and balanceName = '\(selectedBalance.balanceName)'")
            let model = realm.objects(BalanceSelectedType.self).filter(predicate).first
            
            if model == nil {
                addBalanceType(selectedBalance)
            } else {
                try realm.write {
                    model?.isSelected.toggle()
                }
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    public func ubdateBalanceCount(_ selectedBalance: BalanceSelectedType) {
        do {
            
            let realm = try Realm()
            
            let predicate = NSPredicate(format: "userId = '\(selectedBalance.userId)'and balanceName = '\(selectedBalance.balanceName)'")
            let model = realm.objects(BalanceSelectedType.self).filter(predicate).first
            
            if model == nil {
                addBalanceType(selectedBalance)
            } else {
                try realm.write {
                    model?.count = selectedBalance.count
                }
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }

    public func ubdateAccount(_ balance: PoolBalanceModel) {
        do {
            
            let realm = try Realm()
            
            let predicate = NSPredicate(format: "userId = '\(balance.userId)'and poolId = '\(balance.poolId)'")
            let model = realm.objects(PoolBalanceModel.self).filter(predicate).first
            
            if model == nil {
                balance.isSelected = false
                addBalanceAccount(balance)
            }
            
            try realm.write {
                model?.isSelected.toggle()
            }
            
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}
