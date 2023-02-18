//
//  PoolWorkerModel.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 1/11/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import RealmSwift

class PoolWorkerModel: Object {
    @objc dynamic var lastSeen: Double = 0

    @objc dynamic var name: String? = nil
    @objc dynamic var worker: String? = nil
    @objc dynamic var password: String? = nil

    @objc dynamic var realHashrate: String? = nil
    @objc dynamic var currentHashrate: String? = nil
    @objc dynamic var reportedHashrate: String? = nil
    @objc dynamic var averageHashrate: String? = nil

    @objc dynamic var validShares: String? = nil
    @objc dynamic var staleShares: String? = nil
    @objc dynamic var invalidShares: String? = nil
    @objc dynamic var roundShares: String? = nil
    @objc dynamic var expiredShares: String? = nil
    
    @objc dynamic var difficulty: String? = nil
    
    @objc dynamic var luck: String? = nil
    
    @objc dynamic var paid: String? = nil
    
    @objc dynamic var balance: String? = nil

    @objc dynamic var monitor: String? = nil
    @objc dynamic var isActive: Bool = true
    
    @objc dynamic var groupId: String? = nil
    @objc dynamic var firstConnection: String? = nil

    @objc dynamic var algorithm: String? = nil
    @objc dynamic var referral: String? = nil
    
    @objc dynamic var temperature: String? = nil
    @objc dynamic var loadPer: Double = -1
    
    @objc dynamic var luckStr: String? = nil
    @objc dynamic var mode: String? = nil
    @objc dynamic var participationStr: String? = nil
    @objc dynamic var efficiencyStr: String? = nil
    
    @objc dynamic var workerId: String? = nil



    convenience init(json: NSDictionary) {
        self.init()
        self.lastSeen = json.value(forKey: "lastSeen") as? Double ?? 0

        if let worker = json.value(forKey: "worker") as? String, let password = json.value(forKey: "password") as? String {
            self.name = worker + " / " + password
        } else if let worker = json.value(forKey: "worker") as? String {
            self.name = worker
        } else {
            self.name = json.value(forKey: "password") as? String
        }

        if let realHashrate = json.value(forKey: "realHashrate") as? Double {
            self.realHashrate = realHashrate.getFormatedString()
        }

        if let currentHashrate = json.value(forKey: "currentHashrate") as? Double {
            self.currentHashrate = currentHashrate.getFormatedString()
        }
        if let averageHashrate = json["averageHashrate"] as? Double {
            self.averageHashrate = averageHashrate.getFormatedString()
        }
        if let reportedHashrate = json.value(forKey: "reportedHashrate") as? Double {
            self.reportedHashrate = reportedHashrate.getFormatedString()
        }
        if let validShares = json.value(forKey: "validShares") as? Double, let validSharesPer = json.value(forKey: "validSharesPer") as? Double {
            self.validShares = validShares.getString() + " (" + validSharesPer.getString() + "%)"
        } else if let validShares = json.value(forKey: "validShares") as? Double {
            self.validShares = validShares.getString()
        } else if let validSharesPer = json.value(forKey: "validSharesPer") as? Double {
            self.validShares = validSharesPer.getString() + "%"
        }

        if let invalidShares = json.value(forKey: "invalidShares") as? Double, let invalidSharesPer = json.value(forKey: "invalidSharesPer") as? Double {
            self.invalidShares = invalidShares.getString() + " (" + invalidSharesPer.getString() + "%)"
        } else if let invalidShares = json.value(forKey: "invalidShares") as? Double {
            self.invalidShares = invalidShares.getString()
        } else if let invalidSharesPer = json.value(forKey: "invalidSharesPer") as? Double {
            self.invalidShares = invalidSharesPer.getString() + "%"
        }
        
        if let roundShares = json.value(forKey: "roundShares") as? Double, let roundSharesPer = json.value(forKey: "roundSharesPer") as? Double {
            self.roundShares = roundShares.getString() + " (" + roundSharesPer.getString() + "%)"
        } else if let roundShares = json.value(forKey: "roundShares") as? Double {
            self.roundShares = roundShares.getString()
        } else if let roundSharesPer = json.value(forKey: "roundSharesPer") as? Double {
            self.roundShares = roundSharesPer.getString() + "%"
        }

        if let staleShares = json.value(forKey: "staleShares") as? Double, let staleSharesPer = json.value(forKey: "staleSharesPer") as? Double {
            self.staleShares = staleShares.getString() + " (" + staleSharesPer.getString() + "%)"
        } else if let staleShares = json.value(forKey: "staleShares") as? Double {
            self.staleShares = staleShares.getString()
        } else if let staleSharesPer = json.value(forKey: "staleSharesPer") as? Double {
            self.staleShares = staleSharesPer.getString() + "%"
        }
        
        if let expiredShares = json.value(forKey: "expiredShares") as? Double, let expiredSharesPer = json.value(forKey: "expiredSharesPer") as? Double {
            self.expiredShares = expiredShares.getString() + " (" + expiredSharesPer.getString() + "%)"
        } else if let expiredShares = json.value(forKey: "expiredShares") as? Double {
            self.expiredShares = expiredShares.getString()
        } else if let expiredSharesPer = json.value(forKey: "expiredSharesPer") as? Double {
            self.expiredShares = expiredSharesPer.getString() + "%"
        }
        
        if let difficulty = json.value(forKey: "diff") as? Int {
            self.difficulty = difficulty.getFormatedString()
        }
        
        if let luck = json.value(forKey: "luckHours") as? Double {
            self.luck = luck.getFormatedString()
        }
        
        if let paid = json.value(forKey: "paid") as? Double {
            self.paid = paid.getFormatedString()
        }
        
        if let balance = json.value(forKey: "balance") as? Double {
            self.balance = balance.getFormatedString()
        }
        
        if let monitor = json.value(forKey: "monitor") as? Double {
            self.monitor = monitor == 1.0 ? "enabled" : "disabled"
        }

        self.isActive = json.value(forKey: "active") as? Bool ?? true

        if let groupId = json.value(forKey: "groupId") as? String {
            self.groupId =  groupId
        } else if let groupId = json.value(forKey: "groupId") as? Int  {  // For  Old Users
            self.groupId = "\(groupId)"
        }

        if let firstConnection = json["firstConnect"] as? Double {
            self.firstConnection = firstConnection.getDateFromUnixTime()
        }
        
        self.referral = json["referral"] as? String
        self.algorithm = json["algo"] as? String
        
        if let temperature = json["temperature"] as? Double {
            self.temperature = temperature.getTemperature()
        }
        
        self.loadPer = json["loadPer"] as? Double ?? -1
        
        if let luckPer = json.value(forKey: "luckPer") as? Double {
            self.luckStr = luckPer.getString() + " %"
        }
        self.mode = json["mode"] as? String
        
        if let participationPer = json.value(forKey: "participationPer") as? Double {
            self.participationStr = participationPer.getString() + " %"
        }
        
        self.workerId = json.value(forKey: "workerId") as? String ?? nil
        
        if let efficiencyPer = json.value(forKey: "efficiencyPer") as? Double {
            self.efficiencyStr = efficiencyPer.getString() + " %"
        }
    }
}
