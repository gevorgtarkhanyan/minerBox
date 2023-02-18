//
//  FavoriteCoin.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 11.11.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit
import RealmSwift

class FavoriteCoinModel: Object {

    @objc dynamic var _id = UUID().uuidString
    @objc dynamic var coinId = ""
    @objc dynamic var name = "-"
    @objc dynamic var symbol = "-"

    open override class func primaryKey() -> String? {
        return "_id"
    }
    override init() {
        super.init()
    }
    
    convenience init(json: NSDictionary) {
        self.init()
        self.coinId = json.value(forKey: "coinId") as? String ?? ""
        self.name = json.value(forKey: "name") as? String ?? "-"
        self.symbol = json.value(forKey: "symbol") as? String ?? "-"
    }
    
}
