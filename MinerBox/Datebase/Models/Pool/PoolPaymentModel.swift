//
//  PoolPaymentModel.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 02.11.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit
import RealmSwift

class PoolPaymentModel: Object {
    
    @objc dynamic var paidOn: Double = 0.0
    
    @objc dynamic var id: String? = nil
    @objc dynamic var type: String? = nil
    
    @objc dynamic var block: String? = nil
    @objc dynamic var duration: String? = nil
    
    @objc dynamic var amount: Double = 0.0
    @objc dynamic var coinId: String? = nil
    @objc dynamic var currency: String? = nil
    @objc dynamic var txHash: String? = nil
    
    @objc dynamic var txId: String? = nil
    @objc dynamic var mixin: Double = 0.0
    @objc dynamic var confirmations: Double = 0.0
    @objc dynamic var coinAddress: String? = nil
    
    @objc dynamic var networkFee: Double = 0.0
    @objc dynamic var networkFeePer: Double = 0.0
    @objc dynamic var txFee: Double = 0.0
    @objc dynamic var txFeePer: Double = 0.0
    
    @objc dynamic var coinPrice = -1.0
    @objc dynamic var dateUnix = 0.0
    @objc dynamic var sharePer = -1.0
    @objc dynamic var blockNumber = -1.0
    @objc dynamic var immature = -1
    @objc dynamic var status: String?
    @objc dynamic var cfms = -1.0

    @objc dynamic var worker: String? = nil
    @objc dynamic var height = 0.0
    @objc dynamic var timestamp = 0.0
    @objc dynamic var luckPer = -1.0
    @objc dynamic var shareDifficulty = -1.0
    @objc dynamic var rewards = -1.0
    dynamic var matured: Bool? = nil
    dynamic var orphan: Bool? = nil
    
    convenience init(json: NSDictionary) {
        self.init()
        self.paidOn = json.value(forKey: "paidOn") as? Double ?? -1.0
        
        self.id = (json.value(forKey: "id") as? Double)?.getString() ?? nil
        self.type = json.value(forKey: "type") as? String
        
        if let block = json.value(forKey: "block") as? Double {
            self.block = block.getString()
        } else if json.value(forKey: "startBlock") is Double || json["endBlock"] is Double {
            var message = ""
            
            if let startBlock = json.value(forKey: "startBlock") as? Double {
                message = startBlock.getString() + " "
            }
            message += "-"
            if let endBlock = json["endBlock"] as? Double {
                message += " " + endBlock.getString()
            }
            self.block = message
        }
        
        if let amount = json.value(forKey: "amount") as? Double {
            self.amount = amount
        } else if let amount = json.value(forKey: "amount") as? Int {
            self.amount = Double(amount)
        } else {
            self.amount = -1
        }
        self.coinId = json.value(forKey: "cId") as? String
        self.currency = json.value(forKey: "cur") as? String
        self.txHash = json.value(forKey: "txHash") as? String
        self.txId = json.value(forKey: "txId") as? String
        self.mixin = json.value(forKey: "mixin") as? Double ?? -1.0
        self.confirmations = json.value(forKey: "confirmations") as? Double ?? -1.0
        self.coinAddress = json.value(forKey: "coinAddress") as? String
        self.networkFee = json.value(forKey: "networkFee") as? Double ?? -1.0
        self.networkFeePer = json.value(forKey: "networkFeePer") as? Double ?? -1.0
        self.coinPrice = json.value(forKey: "coinPrice") as? Double ?? -1.0
        self.txFee = json.value(forKey: "txFee") as? Double ?? -1.0
        self.txFeePer = json.value(forKey: "txFeePer") as? Double ?? -1.0
        self.dateUnix = json.value(forKey: "dateUnix") as? Double ?? 0.0
        self.sharePer = json.value(forKey: "sharePer") as? Double ?? -1
        self.blockNumber = json.value(forKey: "blockNumber") as? Double ?? -1
        self.immature = json.value(forKey: "immature") as? Int ?? -1
        self.status = json.value(forKey: "status") as? String
        self.cfms = json.value(forKey: "cfms") as? Double ?? -1.0
        self.rewards = json.value(forKey: "rewards") as? Double ?? -1
        self.height = json.value(forKey: "height") as? Double ?? 0.0
        self.timestamp = json.value(forKey: "timestamp") as? Double ?? 0.0
        self.luckPer = json.value(forKey: "luckPer") as? Double ?? -1
        self.shareDifficulty = json.value(forKey: "shareDifficulty") as? Double ?? -1
        self.worker = json.value(forKey: "worker") as? String
        self.matured = json.value(forKey: "matured") as? Bool
        self.orphan = json.value(forKey: "orphan") as? Bool
    }
    
    var dataDescription: PoolPaymentDescription {
        return PoolPaymentDescription(model: self)
    }
}

class PoolPaymentDescription {
    
    var paidOn: String?
    
    var id: String?
    var type: String?
    
    var block: String?
    var duration: String?
    
    var amount: String?
    var coinId: String?
    var currency: String?
    var txHash: String?
    
    var txId: String?
    var mixin: Double?
    var confirmations: Double?
    var coinAddress: String?
    
    var networkFee: Double?
    var networkFeePer: Double?
    var txFee: Double?
    var txFeePer: Double?
    
    var date: String?
    var sharePer: Double?
    var blockNumber: Double?
    var immature: Int?
    var status: String?
    var cfms: Double?

    var worker: String?
    var height: Double?
    var timestamp: Double?
    var luckPer: Double?
    var shareDifficulty: Double?
    var rewards: Double?
    var matured: Bool?
    var orphan: Bool?
    
    init(model: PoolPaymentModel) {
        self.paidOn = model.paidOn.getDateFromUnixTime()
        self.id = model.id
        self.type = model.type
        self.block = model.block
        self.duration = model.duration
        self.amount = model.amount.getFormatedString() + " " + Locale.appCurrencySymbol
        self.coinId = model.coinId
        self.currency = model.currency
        self.txHash = model.txHash
        self.txId = model.txId
        self.mixin = model.mixin
        self.confirmations = model.confirmations
        self.coinAddress = model.coinAddress
        self.networkFee = model.networkFee
        self.networkFeePer = model.networkFeePer
        self.txFee = model.txFee
        self.txFeePer = model.txFeePer
        self.date = model.dateUnix.getDateFromUnixTime()
        self.sharePer = model.sharePer
        self.blockNumber = model.blockNumber
        self.immature = model.immature
        self.status = model.status
        self.cfms = model.cfms
        self.worker = model.worker
        self.height = model.height
        self.timestamp = model.timestamp
        self.luckPer = model.luckPer
        self.shareDifficulty = model.shareDifficulty
        self.rewards = model.rewards
        self.matured = model.matured
        self.orphan = model.orphan
    }
}
