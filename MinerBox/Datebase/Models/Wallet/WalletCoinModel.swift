//
//  WalletCoinModel.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 22.02.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import Foundation

class WalletCoinModel {
    
    var currency: String = ""
    var coinId: String = ""
    var addresses: [WalletAddresModel] = []
    
    convenience init(json: NSDictionary) {
        self.init()
        self.currency = json.value(forKey: "currency") as? String ?? ""
        self.coinId = json.value(forKey: "coinId") as? String ?? ""
        if let addressJson =  json.value(forKey: "addresses") as? [NSDictionary] {
            addressJson.forEach{ addresses.append(WalletAddresModel(json: $0)) }
        }
    }
}

class WalletAddresModel {
    
    var network: String = ""
    var address: String = ""
    
    convenience init(json: NSDictionary) {
        self.init()
        self.network = json.value(forKey: "network") as? String ?? ""
        self.address = json.value(forKey: "address") as? String ?? ""
    }
}
