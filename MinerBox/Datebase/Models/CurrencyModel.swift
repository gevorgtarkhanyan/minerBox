//
//  CurrencyModel.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 30.09.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit
import RealmSwift

class CurrencyModel: Object {
    
    @objc dynamic var _id = UUID().uuidString
    @objc dynamic var currency: String? = nil
    @objc dynamic var symbol: String? = nil
    @objc dynamic var cost: Double = -1.0
    
    
    convenience init(json: NSDictionary) {
        self.init()
        
        self.currency = json.value(forKey: "cur") as? String ?? nil
        self.symbol = json.value(forKey: "symbol") as? String ?? nil
        self.cost = json.value(forKey: "cost") as? Double ?? -1.0
    }
}

