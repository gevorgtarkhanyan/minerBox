//
//  WalletBallanceModel.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 22.02.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import Foundation

class WalletBalanceModel {
    
    var availableBalance: Double?
    var coinId: String = ""
    var coinName: String = ""
    var currency: String = ""
    var priceUSD: Double?
    var isDepositEnabled: Bool = false
    
    init (json: NSDictionary) {
        self.availableBalance = json.value(forKey: "availableBalance") as? Double ?? nil
        self.coinId = json.value(forKey: "coinId") as? String ?? ""
        self.coinName = json.value(forKey: "coinName") as? String ?? ""
        self.currency = json.value(forKey: "currency") as? String ?? ""
        self.priceUSD = json.value(forKey: "priceUSD") as? Double ?? nil
        self.isDepositEnabled = json.value(forKey: "depositEnabled") as? Bool ?? false
    }
}
