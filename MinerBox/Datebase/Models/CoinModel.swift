//
//  CoinModel.swift
//  MinerBox
//
//  Created by Haykaz Melikyan on 7/10/18.
//  Copyright © 2018 WitPlex. All rights reserved.
//

import Foundation
import UIKit

class CoinModel: CoinPrice, Codable {
    var id = "-"
    var change1h: Double = 0
    var change24h: Double = 0
    var change7d: Double = 0
    var icon = ""
    var coinId = ""
 
    var name = "-"
    var previousPriceUSD: Double = 0
    var rank: Int = 0
    var symbol = "-"
    var isFavorite = false
    
    var volumeUSD: Double?
    var availableSupply: Int?
    var totalSupply: Int?
    
    var websiteUrl: String?
    var redditUrl: String?
    var twitterUrl: String?
    var explorerLinks: [String]?
    
    var fvSelected = false
    
    var changeAblePrice: Double = 0
    var currentAlertCurrency: String = "" // For Alerts Editing
    
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
        
        // for the big number
        if let marketPriceUSD = json.value(forKey: "marketPriceUSD") as? UInt64 {
            self.marketPriceUSD = Double(marketPriceUSD)
        }
        if let marketPriceUSD = json.value(forKey: "marketPriceUSD") as? Double {
            self.marketPriceUSD = marketPriceUSD
        }
        self.marketCapUsd = json.value(forKey: "marketCapUsd") as? Double ?? 0
        self.name = json.value(forKey: "name") as? String ?? "-"
        self.previousPriceUSD = json.value(forKey: "previousPriceUSD") as? Double ?? 0
        self.rank = json.value(forKey: "rank") as? Int ?? 0
        self.symbol = json.value(forKey: "symbol") as? String ?? "-"

        if let icon = json.value(forKey: "icon") as? String, let path = icon.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            self.icon = path
        }
        
        self.volumeUSD = json.value(forKey: "volumeUSD") as? Double
        self.availableSupply = json.value(forKey: "availableSupply") as? Int
        self.totalSupply = json.value(forKey: "totalSupply") as? Int
        
        self.websiteUrl = json.value(forKey: "websiteUrl") as? String
        self.redditUrl = json.value(forKey: "redditUrl") as? String
        self.twitterUrl = json.value(forKey: "twitterUrl") as? String
        self.explorerLinks = json.value(forKey: "explorerLinks") as? [String]
    }
    
    convenience init(coinId: String, marketPriceUSD: Double, name: String, rank: Int, symbol: String, iconPath: String, currentAlertCurrency: String) {
        self.init()
        self.coinId = coinId
        self.marketPriceUSD = marketPriceUSD
        self.name = name
        self.rank = rank
        self.symbol = symbol
        self.currentAlertCurrency = currentAlertCurrency

        if let path = iconPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            self.icon = path
        }
    }
      
    var iconPath: String {
        return icon.contains("http") ? icon : Constants.HttpUrlWithoutApi + "images/coins/" + icon
    }
}

class CoinPrice: NSObject  {
    var lastUpdated: Double = 0
    var marketPriceBTC: Double = 0
    var marketPriceUSD: Double = 0
    var marketCapUsd: Double = 0
    
    convenience init(json: NSDictionary) {
        self.init()
        self.marketPriceBTC = json.value(forKey: "marketPriceBTC") as? Double ?? 0
        self.marketPriceUSD = json.value(forKey: "marketPriceUSD") as? Double ?? 0
        self.marketCapUsd = json.value(forKey: "marketCapUsd") as? Double ?? 0
    }
}
