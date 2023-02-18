//
//  PoolStatsModel.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 1/8/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import RealmSwift

class PoolStatsModel {
    
    var coinsStats: [PoolStateCoinOrAlgoModel] = []
    var algosStats: [PoolStateCoinOrAlgoModel] = []
    var lastSeen = 0.0
    convenience init(json: NSDictionary) {
        self.init()
        
        if let coins = json.value(forKey: "coins") as? [NSDictionary] {
            coins.forEach { coinsStats.append((PoolStateCoinOrAlgoModel(json: $0)))}
        }
        
        if let algos = json.value(forKey: "algos") as? [NSDictionary] {
            algos.forEach { algosStats.append((PoolStateCoinOrAlgoModel(json: $0)))}
        }
        
        if let lastSeen = json.value(forKey: "lastSeen") as? Double {
            self.lastSeen = lastSeen
        }
    }
}

class PoolStateCoinOrAlgoModel: Object {

    @objc dynamic var coinName: String? = nil
    @objc dynamic var currency: String? = nil
    @objc dynamic var hashrate: String? = nil
    @objc dynamic var activeMiners: String? = nil
    @objc dynamic var activeWorkers: String? = nil
    @objc dynamic var lastMinedBlockTime: String? = nil
    @objc dynamic var lastMinedBlock: String? = nil
    @objc dynamic var currentNetBlock: String? = nil
    @objc dynamic var nextNetBlock: String? = nil
    @objc dynamic var blocksPerHour: String? = nil
    @objc dynamic var priceUSD: Double = -1.0
    @objc dynamic var priceBTC: String? = nil
    @objc dynamic var netHashrate: String? = nil
    @objc dynamic var netDifficulty: String? = nil
    @objc dynamic var netNextDifficulty: String? = nil
    @objc dynamic var netBlockTime: String? = nil
    @objc dynamic var netRetargetTime: String? = nil
    @objc dynamic var netTime: String? = nil
    @objc dynamic var rewardType: String? = nil
    @objc dynamic var confirmations: String? = nil
    @objc dynamic var minApThreshold: String? = nil
    @objc dynamic var maxApThreshold: String? = nil
    @objc dynamic var totalBlocksFound: String? = nil
    @objc dynamic var blocksFound24h: String? = nil
    @objc dynamic var totalAltBlocksFound: String? = nil
    @objc dynamic var luck: String?
    @objc dynamic var luckPer: String?
    @objc dynamic var luckHours: String?
    @objc dynamic var blocksPending: String?
    @objc dynamic var blocksOrphaned: String?
    @objc dynamic var blocksConfirmed: String?
    @objc dynamic var totalPaid: String?
    @objc dynamic var blockTime: String?
    @objc dynamic var minerReward: String?
    @objc dynamic var blockReward: String?
    @objc dynamic var curRoundTimeDur: String?
    @objc dynamic var icon: String? = nil
    @objc dynamic var hsUnit = ""
    
    var netDifficultyInt64: UInt64?
    var netNextDifficultyInt64: UInt64?
    var netDifficultyDouble: Double?
    var netNextDifficultyDouble: Double?
    
    var miningModes: [MiningModes] = []
    
    //Algos Property
    @objc dynamic var algo: String? = nil
    @objc dynamic var coins = -1.0
    
    var difficultyPerDouble: Double? {
        if let netDifficultyDouble = netDifficultyDouble, let netNextDifficultyDouble = netNextDifficultyDouble {
            return ((netNextDifficultyDouble / netDifficultyDouble) * 100) - 100
        }
        return nil
    }

    convenience init(json: NSDictionary) {
        self.init()

        self.coinName = json.value(forKey: "coinName") as? String
        self.algo = json.value(forKey: "algo") as? String
        self.currency = json.value(forKey: "currency") as? String
        self.rewardType = json.value(forKey: "rewardType") as? String
        self.icon = json.value(forKey: "icon") as? String
        self.hsUnit = json.value(forKey: "hsUnit") as? String ?? ""

        // for the big number
        if let hashrate = json.value(forKey: "hashrate") as? UInt64 {
            self.hashrate =  hashrate.getFormatedString()
        }
        
        if let hashrate = json.value(forKey: "hashrate") as? Double {
            self.hashrate =  hashrate.getFormatedString()
        }

        if let activeMiners = json.value(forKey: "activeMiners") as? Double {
            self.activeMiners = activeMiners.getString()
        }

        if let activeWorkers = json.value(forKey: "activeWorkers") as? Double {
            self.activeWorkers = activeWorkers.getString()
        }

        if let lastMinedBlockTime = json.value(forKey: "lastMinedBlockTime") as? Double {
            let time = Double(Date().timeIntervalSince1970) - lastMinedBlockTime
            self.lastMinedBlockTime = time.secondsToHrMinSec() + " " + "ago".localized()
        }

        if let lastMinedBlock = json.value(forKey: "lastMinedBlockNumber") as? Double {
            self.lastMinedBlock = lastMinedBlock.getString()
        }

        if let currentNetBlock = json.value(forKey: "currentNetBlockNumber") as? Double {
            self.currentNetBlock = currentNetBlock.getString()
        }

        if let nextNetBlock = json.value(forKey: "nextNetBlockNumber") as? Double {
            self.nextNetBlock = nextNetBlock.getString()
        }

        if let blocksPerHour = json.value(forKey: "blocksPerHour") as? Double {
            self.blocksPerHour = blocksPerHour.getString()
        }

        self.priceUSD = json.value(forKey: "priceUSD") as? Double ?? -1.0

        if let priceBTC = json.value(forKey: "priceBTC") as? Double {
            self.priceBTC = "฿ " + priceBTC.getString()
        }

        // for the big number
        if let netHashrate = json.value(forKey: "netHashrate") as? UInt64 {
            self.netHashrate = netHashrate.getFormatedString()
        }

        if let netHashrate = json.value(forKey: "netHashrate") as? Double {
            self.netHashrate = netHashrate.getFormatedString()
        }
        
        // for the big number
        if let netDifficulty = json.value(forKey: "netDifficulty") as? UInt64 {
            self.netDifficultyInt64 = netDifficulty
            self.netDifficulty = netDifficulty.textFromHashrate(difficulty: true)
        }

        if let netDifficulty = json.value(forKey: "netDifficulty") as? Double {
            self.netDifficultyDouble = netDifficulty
            self.netDifficulty = netDifficulty.textFromHashrate(difficulty: true)
        }
        
        // for the big number
        if let netNextDifficulty = json.value(forKey: "netNextDifficulty") as? UInt64 {
            self.netNextDifficultyInt64 = netNextDifficulty
            self.netNextDifficulty = netNextDifficulty.textFromHashrate(difficulty: true)
        }

        if let netNextDifficulty = json.value(forKey: "netNextDifficulty") as? Double {
            self.netNextDifficultyDouble = netNextDifficulty
            self.netNextDifficulty = netNextDifficulty.textFromHashrate(difficulty: true)
        }

        if let netBlockTime = json.value(forKey: "netBlockTime") as? Double {
            self.netBlockTime = netBlockTime.secondsToHrMinSec()
        }

        if let netRetargetTime = json.value(forKey: "netRetargetTime") as? Double {
            self.netRetargetTime = netRetargetTime.secondsToHrMinSec()
        }

        if let netTime = json.value(forKey: "netTime") as? Double {
            self.netTime = netTime.textFromUnixTime()
        }
        
        if let confirmations = json.value(forKey: "confirmations") as? Double {
            self.confirmations = confirmations.getString()
        }

        if let minApThreshold = json.value(forKey: "minApThreshold") as? Double {
            self.minApThreshold = minApThreshold.getString()
        }

        if let maxApThreshold = json.value(forKey: "maxApThreshold") as? Double {
            self.maxApThreshold = maxApThreshold.getString()
        }

        if let totalBlocksFound = json.value(forKey: "totalBlocksFound") as? Double {
            self.totalBlocksFound = totalBlocksFound.getString()
        }
        if let blocksFound24h = json.value(forKey: "blocksFound24h") as? Double {
            self.blocksFound24h = blocksFound24h.getString()
        }

        if let totalAltBlocksFound = json.value(forKey: "totalAltBlocksFound") as? Double {
            self.totalAltBlocksFound = totalAltBlocksFound.getString()
        }
        
        if let luck = json.value(forKey: "luck") as? Double {
            self.luck = luck.getString()
        }
        
        if let luckPer = json.value(forKey: "luckPer") as? Double {
            self.luckPer = luckPer.getString()
        }
        
        if let curRoundTimeDur = json.value(forKey: "curRoundTimeDur") as? Double {
            self.curRoundTimeDur = curRoundTimeDur.getString()
        }
        if let coins = json.value(forKey: "coins") as? Double {
            self.coins = coins
        }
        if let miningModes = json.value(forKey: "miningModes") as? [NSDictionary] {
            miningModes.forEach { self.miningModes.append((MiningModes(json: $0)))}
        }
        if let luckHours = json.value(forKey: "luckHours" ) as? Double {
            self.luckHours = luckHours.getString()
        }
        if let blocksPending = json.value(forKey: "blocksPending") as? Double {
            self.blocksPending = blocksPending.getString()
        }
        if let blocksOrphaned = json.value(forKey: "blocksOrphaned") as? Double {
            self.blocksOrphaned = blocksOrphaned.getString()
        }
        if let blocksConfirmed = json.value(forKey: "blocksConfirmed") as? Double {
            self.blocksConfirmed = blocksConfirmed.getString()
        }
        if let totalPaid = json.value(forKey: "totalPaid") as? Double {
            self.totalPaid = totalPaid.getString()
        }
        if let blockTime = json.value(forKey: "blockTime" ) as? Double {
            self.blockTime = blockTime.getString()
        }
        if let minerReward = json.value(forKey: "minerReward") as? Double {
            self.minerReward = minerReward.getString()
        }
        if let blockReward = json.value(forKey: "blockReward") as? Double {
            self.blockReward = blockReward.getString()
        }
    }
}

class MiningModes {
    
   var system: String?
   var feePer: Double?
   var fee: Double?
   var feeStr: String?
   var txFee: Double?
   var txFeeStr: String?
   var txFeePer: Double?
   var txFeeManual: Double?
   var txFeeAuto: Double?
    
    
    convenience init(json: NSDictionary) {
        self.init()
        
        self.system = json.value(forKey: "system") as? String

        if let fees = json.value(forKey: "fee") as? Double, let feesPer = json.value(forKey: "feePer") as? Double {
            self.fee = fees
            self.feePer = feesPer
            self.feeStr = fees.getString() + " (" + feesPer.getString() + " %)"
        } else if let fees = json.value(forKey: "fee") as? Double {
            self.fee = fees
            self.feeStr = fees.getString()
        } else if let feesPer = json.value(forKey: "feePer") as? Double {
            self.feePer = feesPer
            self.feeStr = feesPer.getString() + " %"
        }
        
        if let fees = json.value(forKey: "txFee") as? Double, let feesPer = json.value(forKey: "txFeePer") as? Double {
            self.txFee = fees
            self.txFeePer = feesPer
            self.txFeeStr = fees.getString() + " (" + feesPer.getString() + " %)"
        } else if let fees = json.value(forKey: "txFee") as? Double {
            self.txFee = fees
            self.txFeeStr = fees.getString()
        } else if let feesPer = json.value(forKey: "txFeePer") as? Double {
            self.txFeePer = feesPer
            self.txFeeStr = feesPer.getString() + " %"
        }
        
        self.txFeeManual = json.value(forKey: "txFeeManual") as? Double
        self.txFeeAuto = json.value(forKey: "txFeeAuto") as? Double
    }
    
}
