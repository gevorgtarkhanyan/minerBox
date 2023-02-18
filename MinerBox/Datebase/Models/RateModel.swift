//
//  RateModel.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 07.10.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation
import RealmSwift


class RateModel: Object {
    
    @objc dynamic var currency = ""
    @objc dynamic var value = 1.0
    
    override class func primaryKey() -> String? {
        return "_id"
    }
    
    override init() {
        super.init()
    }
    
    init(currency: String, value: Double) {
        self.currency = currency
        self.value = value

    }
}
