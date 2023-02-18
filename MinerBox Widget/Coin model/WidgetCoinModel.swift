//
//  CoinModel.swift
//  MinerBox Widget
//
//  Created by Vazgen Hovakinyan on 2/18/21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit
import RealmSwift

class WidgetCoinModel: NSObject, Codable {
    var id = "-"
    var change1h: Double = 0
    var change24h: Double = 0
    var lastUpdated: Double = 0
    var change7d: Double = 0
    var icon = ""
    var coinId = ""
 
    var marketPriceBTC: Double = 0
    var marketPriceUSD: Double = 0
    var marketCapUsd: Double = 0
    var name = "-"
    var previousPriceUSD: Double = 0
    var rank: Int = 0
    var symbol = "-"
    var isFavorite = false

    var changeAblePrice: Double = 0
    static var isSuccessfullyDownloaded: Bool?
    

    convenience init(json: NSDictionary) {
        self.init()
        self.id = json.value(forKey: "_id") as? String ?? ""
        self.coinId = json.value(forKey: "coinId") as? String ?? ""
        self.change1h = json.value(forKey: "change1h") as? Double ?? 0
        self.change24h = json.value(forKey: "change24h") as? Double ?? 0
        self.change7d = json.value(forKey: "change7d") as? Double ?? 0
        self.lastUpdated = json.value(forKey: "lastUpdated") as? Double ?? 0
        self.marketPriceBTC = json.value(forKey: "marketPriceBTC") as? Double ?? 0
        self.marketPriceUSD = json.value(forKey: "marketPriceUSD") as? Double ?? 0
        self.marketCapUsd = json.value(forKey: "marketCapUsd") as? Double ?? 0
        self.name = json.value(forKey: "name") as? String ?? "-"
        self.previousPriceUSD = json.value(forKey: "previousPriceUSD") as? Double ?? 0
        self.rank = json.value(forKey: "rank") as? Int ?? 0
        self.symbol = json.value(forKey: "symbol") as? String ?? "-"

        if let icon = json.value(forKey: "icon") as? String, let path = icon.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            self.icon = path
        }
    }
    
}
