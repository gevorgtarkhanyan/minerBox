//
//  ExchangeModel.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 22.02.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import Foundation

class ExchangeModel {
    
    var _id: String = ""
    var historyTypes: [String] = []
    var transactionsLoaded: Bool = false
    var userId: String = ""
    var exchange: String = ""
    var wallets: [WalletModel] = []
    var walletCoins: [WalletCoinModel] = []
    var showWalletTotalValue: Bool = true

    
    convenience init(json: NSDictionary) {
        self.init()
        self._id = json.value(forKey: "_id") as? String ?? ""
        self.historyTypes = json.value(forKey: "historyTypes") as? [String] ?? []
        self.transactionsLoaded = json.value(forKey: "transactionsLoaded") as? Bool ?? false
        self.userId = json.value(forKey: "userId") as? String ?? ""
        self.exchange = json.value(forKey: "exchange") as? String ?? ""
        
        if let walletsJson =  json.value(forKey: "wallets") as? [NSDictionary] {
            walletsJson.forEach{ wallets.append(WalletModel(json: $0)) }
        }
        if let coinJson =  json.value(forKey: "coins") as? [NSDictionary] {
            coinJson.forEach{ walletCoins.append(WalletCoinModel(json: $0)) }
        }
    }
}
