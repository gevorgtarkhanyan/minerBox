//
//  SingleCoinWidgetModel.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 27.09.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift


class KitCoinModel: Object {
    
    @objc dynamic var _id = UUID().uuidString
    @objc dynamic var change1h: Double = 0
    @objc dynamic var change24h: Double = 0
    @objc dynamic var change7d: Double = 0
    @objc dynamic var icon = ""
    @objc dynamic var coinId = ""
    @objc dynamic var name = "-"
    @objc dynamic var symbol = "-"
    @objc dynamic var marketPriceUSD: Double = 0
    @objc dynamic var currencyMultiplier: Double = 1

    
    open override class func primaryKey() -> String? {
        return "_id"
    }
    
    convenience init(json: NSDictionary) {
        self.init()
        
        self.coinId = json.value(forKey: "coinId") as? String ?? ""
        self.change1h = json.value(forKey: "change1h") as? Double ?? 0
        self.change24h = json.value(forKey: "change24h") as? Double ?? 0
        self.change7d = json.value(forKey: "change7d") as? Double ?? 0
        self.name = json.value(forKey: "name") as? String ?? "-"
        self.symbol = json.value(forKey: "symbol") as? String ?? "-"
        self.marketPriceUSD = json.value(forKey: "marketPriceUSD") as? Double ?? 0
        
        if let icon = json.value(forKey: "icon") as? String, let path = icon.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            self.icon = path
        }
    }
}
