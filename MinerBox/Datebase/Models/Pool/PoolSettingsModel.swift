//
//  PoolSettingsModel.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 1/8/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import RealmSwift

class PoolSettingsModel {
    var email: String? = nil
    var subAccount: String? = nil
    var paymentMethod: String? = nil
    var lastSeen = 0.0
    var nextPayoutTime = 0.0
    var nextPayoutTimeDur = 0.0
    var isloaded = false
    var invalidCredentials = false
    //Hashrate
    var currentHashrate = 0.0
    var averageHashrate = 0.0
    var reportedHashrate = 0.0
    var realHashrate = 0.0
    var extHashrate = false

    //Workers
    var activeWorkers = 0.0
    var extWorkers = false
    var allWorkers = 0.0
    var extGroupWorkers = false

    //Shares
    var sharePer = 0.0
    var validSharesStr: String? = nil
    var validShares = 0.0
    var validSharesPer = 0.0
    var invalidSharesStr: String? = nil
    var invalidShares = 0.0
    var invalidSharesPer = 0.0
    var staleSharesStr: String? = nil
    var staleShares = 0.0
    var staleSharesPer = 0.0
    var roundSharesStr: String? = nil
    var roundShares = 0.0
    var roundSharesPer = 0.0
    var expiredSharesStr: String? = nil
    var expiredShares = 0.0
    var expiredSharesPer = 0.0
    var extShares = false

    //Balance
    var balanceTotal:CoinState?
    var coins: [CoinState] = []
    var coinsCount = 0
    @objc dynamic var extBalance = false

    
    //Blocks
    var period = 0.0
    var block = 0.0
    var luckStr: String? = nil
    var amount = 0.0
    var extBlocks = false
    
    //Rewards
    var rewardItems = List<Reward>()
       
    var rewards: [Reward] {
       if rewardItems.count == 0 {
           return [Reward]()
       }
       return rewardItems.sorted {
           return $0.period < $1.period
       }
    }

    func addReward(_ reward: Reward) {
       self.rewardItems.append(reward)
    }
       
    //Estimations
    var estimationItems = List<Estimation>()
    var estimations: [Estimation] {
        return estimationItems.map { $0 }
    }
//    @objc dynamic var coinsPerMin = 0.0
//    @objc dynamic var usdPerMin = 0.0
//    @objc dynamic var btcPerMin = 0.0
    
    func addEstimation(_ estimation: Estimation) {
       self.estimationItems.append(estimation)
    }
    
    var workerGroupsItems = List<WorkerGroup>()

    var workerGroups: [WorkerGroup] {
        if workerGroupsItems.count == 0 {
            return [WorkerGroup]()
        }
        return workerGroupsItems.map { $0 }//.sorted { return $0.groupName > $1.groupName }
    }

    func addWorkerGroup(_ w_group: WorkerGroup) {
        self.workerGroupsItems.append(w_group)
    }
    
    convenience init(json: NSDictionary, extHashrate: Bool = false, extWorkers: Bool = false, extShares: Bool = false, extBalance: Bool = false, extGroupWorkers: Bool = false, extBlocks: Bool = false) {
        self.init()
        self.email = json.value(forKey: "email") as? String
        self.isloaded = json.value(forKey: "loaded") as? Bool ?? false
        self.invalidCredentials = json.value(forKey: "invalidCredentials") as? Bool ?? false
        self.subAccount = json.value(forKey: "subAccount") as? String
        self.paymentMethod = json.value(forKey: "paymentMethod") as? String
        self.lastSeen = json.value(forKey: "lastSeen") as? Double ?? -1.0
        self.nextPayoutTime = json.value(forKey: "nextPayoutTime") as? Double ?? -1.0
        self.nextPayoutTimeDur = json.value(forKey: "nextPayoutTimeDur") as? Double ?? -1.0
        self.currentHashrate = json.value(forKey: "currentHashrate") as? Double ?? -1.0
        self.averageHashrate = json.value(forKey: "averageHashrate") as? Double ?? -1.0
        self.reportedHashrate = json.value(forKey: "reportedHashrate") as? Double ?? -1.0
        self.realHashrate = json.value(forKey: "realHashrate") as? Double ?? -1.0
        self.extHashrate = extHashrate
        self.activeWorkers = json.value(forKey: "activeWorkers") as? Double ?? -1.0
        self.extWorkers = extWorkers

        self.allWorkers = json.value(forKey: "allWorkers") as? Double ?? -1.0
        self.extGroupWorkers = extGroupWorkers

        self.sharePer = json.value(forKey: "sharePer") as? Double ?? -1.0
        self.extBalance = extBalance

        // Setup valid shares string
        if let validShares = json.value(forKey: "validShares") as? Double, let validSharesPer = json.value(forKey: "validSharesPer") as? Double {
            self.validShares = validShares
            self.validSharesPer = validSharesPer
            self.validSharesStr = validShares.getString() + " (" + validSharesPer.getString() + " %)"
        } else if let validShares = json.value(forKey: "validShares") as? Double {
            self.validShares = validShares
            self.validSharesStr = validShares.getString()
        } else if let validSharesPer = json.value(forKey: "validSharesPer") as? Double {
            self.validSharesPer = validSharesPer
            self.validSharesStr = validSharesPer.getString() + " %"
        }
        // Setup invalid shares string
        if let invalidShares = json.value(forKey: "invalidShares") as? Double, let invalidSharesPer = json.value(forKey: "invalidSharesPer") as? Double {
            self.invalidShares = invalidShares
            self.invalidSharesPer = invalidSharesPer
            self.invalidSharesStr = invalidShares.getString() + " (" + invalidSharesPer.getString() + " %)"
        } else if let invalidShares = json.value(forKey: "invalidShares") as? Double {
            self.invalidShares = invalidShares
            self.invalidSharesStr = invalidShares.getString()
        } else if let invalidSharesPer = json.value(forKey: "invalidSharesPer") as? Double {
            self.invalidSharesPer = invalidSharesPer
            self.invalidSharesStr = invalidSharesPer.getString() + " %"
        }

        // Setup stale shares string
        if let staleShares = json.value(forKey: "staleShares") as? Double, let staleSharesPer = json.value(forKey: "staleSharesPer") as? Double {
            self.staleSharesStr = staleShares.getString() + " (" + staleSharesPer.getString() + " %)"
            self.staleShares = staleShares
            self.staleSharesPer = staleSharesPer
        } else if let staleShares = json.value(forKey: "staleShares") as? Double {
            self.staleShares = staleShares
            self.staleSharesStr = staleShares.getString()
        } else if let staleSharesPer = json.value(forKey: "staleSharesPer") as? Double {
            self.staleSharesPer = staleSharesPer
            self.staleSharesStr = staleSharesPer.getString() + " %"
        }
        // Setup round shares string
        if let roundShares = json.value(forKey: "roundShares") as? Double, let roundSharesPer = json.value(forKey: "roundSharesPer") as? Double {
            self.roundSharesStr = roundShares.getString() + " (" + roundSharesPer.getString() + " %)"
            self.roundShares = roundShares
            self.roundSharesPer = roundSharesPer
        } else if let roundShares = json.value(forKey: "roundShares") as? Double {
            self.roundShares = roundShares
            self.roundSharesStr = roundShares.getString()
        } else if let roundSharesPer = json.value(forKey: "roundSharesPer") as? Double {
            self.roundSharesPer = roundSharesPer
            self.roundSharesStr = roundSharesPer.getString() + " %"
        }
        // Setup expired shares string
        if let expiredShares = json.value(forKey: "expiredShares") as? Double, let expiredSharesPer = json.value(forKey: "expiredSharesPer") as? Double {
            self.expiredSharesStr = expiredShares.getString() + " (" + expiredSharesPer.getString() + " %)"
            self.expiredShares = expiredShares
            self.expiredSharesPer = expiredSharesPer
        } else if let expiredShares = json.value(forKey: "expiredShares") as? Double {
            self.expiredShares = expiredShares
            self.expiredSharesStr = expiredShares.getString()
        } else if let expiredSharesPer = json.value(forKey: "expiredSharesPer") as? Double {
            self.expiredSharesPer = expiredSharesPer
            self.expiredSharesStr = expiredSharesPer.getString() + " %"
        }
        
        self.extShares = extShares

        self.period = json.value(forKey: "period") as? Double ?? -1.0
        self.block = json.value(forKey: "block") as? Double ?? -1.0
        self.amount = json.value(forKey: "amount") as? Double ?? -1.0
        if let luckPer = json.value(forKey: "luckPer") as? Double {
            self.luckStr = luckPer.getString() + " %"
        }
        self.extBlocks = extBlocks
        

//        self.coinsPerMin = json.value(forKey: "coinsPerMin") as? Double ?? -1.0
//        self.usdPerMin = json.value(forKey: "usdPerMin") as? Double ?? -1.0
//        self.btcPerMin = json.value(forKey: "btcPerMin") as? Double ?? -1.0
         
        
        if let balanceTotal = json.value(forKey: "total") as? NSDictionary {
            self.balanceTotal = CoinState(json: balanceTotal)
        }
        if let coins = json.value(forKey: "coins") as? [NSDictionary] {
            coins.forEach { self.coins.append((CoinState(json: $0)))}
            self.coinsCount = self.coins.count
        }
    }
}

class Reward: Object {
    @objc dynamic var period = 0.0
    @objc dynamic var amount = 0.0
    @objc dynamic var luckPer = -1.0
    dynamic var blocks: Double?

    convenience init(json: NSDictionary) {
        self.init()
        
        self.period = json.value(forKey: "period") as? Double ?? 0.0
        self.amount = json.value(forKey: "amount") as? Double ?? 0.0
        self.luckPer = json.value(forKey: "luckPer") as? Double ?? -1
        self.blocks = json.value(forKey: "block") as? Double
    }
}

class WorkerGroup: Object {
    @objc dynamic var groupId = ""
    @objc dynamic var groupName = ""
    @objc dynamic var activeWorkers = 0
    @objc dynamic var allWorkers = 0
    @objc dynamic var currentHashrate = 0.0
    @objc dynamic var staleSharesPer = -1.0

    var workers = [PoolWorkerModel]()

    convenience init(json: NSDictionary) {
        self.init()
        
        if let groupId = json.value(forKey: "groupId") as? String {
            self.groupId =  groupId
        } else if let groupId = json.value(forKey: "groupId") as? Int  {  // For  Old Users
            self.groupId = "\(groupId)"
        }

        self.groupName = json.value(forKey: "groupName") as? String ?? ""
        self.activeWorkers = json.value(forKey: "activeWorkers") as? Int ?? 0
        self.allWorkers = json.value(forKey: "allWorkers") as? Int ?? 0
        self.currentHashrate = json.value(forKey: "currentHashrate") as? Double ?? 0
        self.staleSharesPer = json.value(forKey: "staleSharesPer") as? Double ?? -1.0
    }
}

class CoinState: Object {
    
    @objc dynamic var coinId: String? = nil
    @objc dynamic var currency: String? = nil
    @objc dynamic var coinName: String? = nil
    @objc dynamic var priceUSD = 0.0
    @objc dynamic var priceBTC = 0.0
    @objc dynamic var confirmed = 0.0
    @objc dynamic var unconfirmed = 0.0
    @objc dynamic var orphaned = 0.0
    @objc dynamic var unpaid = 0.0
    @objc dynamic var paid = 0.0
    @objc dynamic var credit = 0.0
    @objc dynamic var payoutThreshold = 0.0
    @objc dynamic var paid24h = 0.0
    @objc dynamic var reward24h = 0.0
    @objc dynamic var immatureReward = 0.0
    @objc dynamic var totalBalance = 0.0
    @objc dynamic var icon: String? = nil
    @objc dynamic var nextPayoutTimeDur = 0.0
    @objc dynamic var nextPayoutTime = 0.0

    
    func addCoin(coinId: String) {
        self.coinId = coinId
    }

    convenience init(json: NSDictionary) {
        self.init()
        
        self.coinId = json.value(forKey: "coinId") as? String
        self.currency = json.value(forKey: "currency") as? String
        self.coinName = json.value(forKey: "name") as? String
        self.confirmed = json.value(forKey: "confirmed") as? Double ?? -1.0
        self.unconfirmed = json.value(forKey: "unconfirmed") as? Double ?? -1.0
        self.orphaned = json.value(forKey: "orphaned") as? Double ?? -1.0
        self.unpaid = json.value(forKey: "unpaid") as? Double ?? -1.0
        self.paid = json.value(forKey: "paid") as? Double ?? -1.0
        self.credit = json.value(forKey: "credit") as? Double ?? -1.0
        self.payoutThreshold = json.value(forKey: "payoutThreshold") as? Double ?? -1.0
        self.priceUSD = json.value(forKey: "priceUSD") as? Double ?? -1.0
        self.priceBTC = json.value(forKey: "priceBTC") as? Double ?? -1.0
        self.icon = json.value(forKey: "icon") as? String
        self.paid24h = json.value(forKey: "paid24h") as? Double ?? -1.0
        self.reward24h = json.value(forKey: "reward24h") as? Double ?? -1.0
        self.immatureReward = json.value(forKey: "immatureReward") as? Double ?? -1.0
        self.totalBalance = json.value(forKey: "totalBalance") as? Double ?? -1.0
        self.nextPayoutTimeDur = json.value(forKey: "nextPayoutTimeDur") as? Double ?? -1.0
        self.nextPayoutTime = json.value(forKey: "nextPayoutTime") as? Double ?? -1.0

    }
}

class Estimation: Object {
    @objc dynamic var name: String? = nil
    @objc dynamic var type: String? = nil
    @objc dynamic var coinId: String? = nil
    @objc dynamic var coinsPerMin: Double = 0.0
    @objc dynamic var usdPerMin: Double = 0.0
    @objc dynamic var btcPerMin: Double = 0.0

    convenience init(json: NSDictionary) {
        self.init()
        
        self.name = json.value(forKey: "name") as? String
        self.type = json.value(forKey: "type") as? String
        self.coinId = json.value(forKey: "cId") as? String
        self.coinsPerMin = json.value(forKey: "coinsPerMin") as? Double ?? -1.0
        self.btcPerMin = json.value(forKey: "btcPerMin") as? Double ?? -1.0
        self.usdPerMin = json.value(forKey: "usdPerMin") as? Double ?? -1.0
    }
}
