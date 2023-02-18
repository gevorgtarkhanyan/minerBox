//
//  MiningPulHubPoolSettingsModel.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 11/22/18.
//  Copyright © 2018 WitPlex. All rights reserved.
//

import Foundation
import RealmSwift

class MiningPulHubPoolSettingsModel: Object {
    @objc dynamic var activeWorkers = 0
    @objc dynamic var confirmed = 0.0
    @objc dynamic var currentHashrate = 0.0
    @objc dynamic var invalidShares = 0
    @objc dynamic var invalidSharesPer = 0
    @objc dynamic var previousHashrate = 0.0
    @objc dynamic var previousWorkers = 0
    @objc dynamic var recentCredits24h = 0.0
    @objc dynamic var unconfirmed = 0.0
    @objc dynamic var validShares = 0
    var recentCreditItems = List<RecentCredits>()
    
    var recentCredits: [RecentCredits] {
        if recentCreditItems.count == 0 {
            return [RecentCredits]()
        }
        return recentCreditItems.sorted {
            return $0.date > $1.date
        }
    }
    func addRecentCredit(_ r_credit: RecentCredits) {
        self.recentCreditItems.append(r_credit)
    }
    
    convenience init(json: JSON) {
        self.init()
        self.activeWorkers = json["activeWorkers"] as? Int ?? 0
        self.confirmed = json["confirmed"] as? Double ?? 0.0
        self.currentHashrate = json["currentHashrate"] as? Double ?? 0.0
        self.invalidShares = json["invalidShares"] as? Int ?? 0
        self.invalidSharesPer = json["invalidSharesPer"] as? Int ?? 0
        self.previousHashrate = json["previousHashrate"] as? Double ?? 0.0
        self.previousWorkers = json["previousWorkers"] as? Int ?? 0
        self.recentCredits24h  = json["recentCredits24h"] as? Double ?? 0.0
        self.unconfirmed = json["unconfirmed"] as? Double ?? 0.0
        self.validShares = json["validShares"] as? Int ?? 0

    }
}

class RecentCredits: Object {
    @objc dynamic var amount = 0.0
    @objc dynamic var date = ""
    
    convenience init(json: JSON) {
        self.init()
        self.amount = json["amount"] as? Double ?? 0.0
        self.date = json["date"] as? String ?? ""
    }
}
