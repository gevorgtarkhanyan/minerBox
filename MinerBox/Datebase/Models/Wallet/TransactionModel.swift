//
//  TransactionModel.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 28.02.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import Foundation

class TransactionModel {
    
    var _id: String = ""
    var txId: String?
    var txType: String = ""
    var userId: String = ""
    var walletId: String = ""
    var type: String?
    var status: String?
    var network: String?
    var fee: Double?
    var feePer: Double?
    var amount: Double?
    var confirmations: Double?
    var address: String?
    var currency = ""
    var date: Double = 0.0
    var coinId: String = ""

    convenience init(json: NSDictionary) {
        self.init()
        self._id      = json.value(forKey: "_id") as? String ?? ""
        self.txId     = json.value(forKey: "txId") as? String 
        self.txType   = json.value(forKey: "txType") as? String ?? ""
        self.userId   = json.value(forKey: "userId") as? String ?? ""
        self.walletId = json.value(forKey: "walletId") as? String ?? ""
        self.type     = json.value(forKey: "type") as? String
        self.status   = json.value(forKey: "sts") as? String
        self.network  = json.value(forKey: "ntw") as? String 
        self.amount   = json.value(forKey: "amnt") as? Double
        self.fee      = json.value(forKey: "fee") as? Double
        self.feePer   = json.value(forKey: "feePer") as? Double
        self.confirmations = json.value(forKey: "cfms") as? Double
        self.address  = json.value(forKey: "adr") as? String
        self.currency = json.value(forKey: "cur") as? String ?? ""
        self.date     = json.value(forKey: "date") as? Double ?? 0.0
        self.coinId   = json.value(forKey: "cId") as? String ?? ""

    }
}



