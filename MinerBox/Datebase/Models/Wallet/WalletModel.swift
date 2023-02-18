//
//  WalletModel.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 21.02.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import Foundation
import UIKit

class WalletModel {
    
    var name: String?
    var type: String = ""
    var lastUpdated: Double?
    var totalBalance: TotalBalance?
    var balances: [WalletBalanceModel] = []
    var showingBalances: [WalletBalanceModel] = []
    var isSelected: Bool = false
    var selectedBalance: WalletBalanceModel?
    var selectedWalletCoin: WalletCoinModel?


    
    convenience init(json: NSDictionary) {
        self.init()
        self.name = json.value(forKey: "name") as? String ?? nil
        self.type = json.value(forKey: "type") as? String ?? ""
        self.lastUpdated = json.value(forKey: "lastUpdated") as? Double ?? nil
        
        if let balanceJson =  json.value(forKey: "balances") as? [NSDictionary] {
            balanceJson.forEach{ balances.append(WalletBalanceModel(json: $0)) }
        }
        if let totalJson =  json.value(forKey: "totalBalance") as? NSDictionary {
            totalBalance = TotalBalance(json: totalJson)
        }
        self.showingBalances = self.balances
    }
}

class TotalBalance {
    
    var value: Double?
    var currency: String = ""
    var priceUSD: Double?
    var coinId: String = ""
    
    
    convenience init(json: NSDictionary) {
        self.init()
        self.value    = json.value(forKey: "value") as? Double ?? nil
        self.currency = json.value(forKey: "currency") as? String ?? ""
        self.priceUSD = json.value(forKey: "priceUSD") as? Double ?? nil
        self.coinId   = json.value(forKey: "coinId") as? String ?? ""
    }
}
