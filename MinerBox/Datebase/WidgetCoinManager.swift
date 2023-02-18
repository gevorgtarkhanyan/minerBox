//
//  WidgetCoinManager.swift
//  MinerBox
//
//  Created by Vazgen Hovakinyan on 25.02.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit
import RealmSwift

class WidgetCointManager: NSObject {
    
    static let shared = WidgetCointManager()
    
    fileprivate var userID: String? {
        return DatabaseManager.shared.currentUser?.id
    }
    var isAccount = true
    
    public func addCoin(_ coin: CoinModel) {
        guard let id = userID else { return }
        let model = CoinWidgetModel(userId: id, coin: coin)
        
        do {
            let realm = try Realm()
            try realm.write {
                let realmModel = realm.create(CoinWidgetModel.self, value: model, update: .error)
                realm.add(realmModel)
            }
        } catch {
            debugPrint("Something went wrong!")
        }
    }
    
    public func addSelectedCoin(_ coinId: String) {
        guard let id = userID else { return }
        
        let predicate = NSPredicate(format: "userId = '\(id)' and coinId = '\(coinId)'")
        
        do {
            let realm = try Realm()
            let coin = realm.objects(CoinWidgetModel.self).filter(predicate)
            if let coin = coin.first {
                try realm.write {
                    coin.isSelect = true
                }
            }
        } catch {
            debugPrint("Something went wrong!")
        }
    }
    
    public func removeCoin(_ coinId: String) {
        guard let id = userID else { return }
        do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "userId = '\(id)' and coinId = '\(coinId)'")
            let coin = realm.objects(CoinWidgetModel.self).filter(predicate)
            
            try realm.write {
                realm.delete(coin)
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    public func removeSelectedCoin(_ coinId: String) {
        guard let id = userID else { return }
        
        let predicate = NSPredicate(format: "userId = '\(id)' and coinId = '\(coinId)'")
        
        do {
            let realm = try Realm()
            let coin = realm.objects(CoinWidgetModel.self).filter(predicate)
            if let coin = coin.first {
                try realm.write {
                    coin.isSelect = false
                }
            }
        } catch {
            debugPrint("Something went wrong!")
        }
    }
    
    public func getSelectedCoinIds() -> String? {
        guard let id = userID else { return nil }
        
        do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "userId = '\(id)' and isSelect == true")
            let coins = realm.objects(CoinWidgetModel.self).filter(predicate)
            
            guard  let coin = coins.first else { return nil }
            return coin.coinId
        } catch {
            debugPrint(error.localizedDescription)
        }
        return nil
    }
    
    public func getCoinsIds() -> [String] {
        guard let id = userID else { return [] }
        
        do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "userId = '\(id)'")
            let coins = realm.objects(CoinWidgetModel.self).filter(predicate)
            
            return Array(coins).map { $0.coinId }
        } catch {
            debugPrint(error.localizedDescription)
        }
        return []
    }
    
}
