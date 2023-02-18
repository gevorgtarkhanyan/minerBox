//
//  AlertModel.swift
//  MinerBox
//
//  Created by Haykaz Melikyan on 7/18/18.
//  Copyright © 2018 WitPlex. All rights reserved.
//

import UIKit
import RealmSwift

class AlertModel: Object {
    
    @objc dynamic var id = ""
    @objc dynamic var coinID = ""
    @objc dynamic var coinName = ""
    @objc dynamic var coinIcon = ""
    @objc dynamic var coinSymbol = ""
    @objc dynamic var coinMarketPriceUSD: Double = 0
    @objc dynamic var coinAlertPriceUSD: Double = 0
    @objc dynamic var coinRank: Int = 0
    @objc dynamic var comparison: Bool = false
    @objc dynamic var isEnabled: Bool = false
    @objc dynamic var isRepeat: Bool = false
    @objc dynamic var value: Double = 0.0
    @objc dynamic var cur = ""


    open override class func primaryKey() -> String? {
        return "id"
    }

    convenience init(json: NSDictionary,alertJson: NSDictionary ) {
        self.init()
        self.id = alertJson.value(forKey: "_id") as? String ?? ""
        self.comparison = alertJson.value(forKey: "comparison") as? Bool ?? false
        self.isEnabled = alertJson.value(forKey: "enabled") as? Bool ?? false
        self.isRepeat = alertJson.value(forKey: "repeat") as? Bool ?? false
        self.value = alertJson.value(forKey: "value") as? Double ?? 0.0
        self.cur = alertJson.value(forKey: "cur") as? String ?? ""
        self.coinID = json.value(forKeyPath: "coin.coinId") as? String ?? ""
        self.coinName = json.value(forKeyPath: "coin.name") as? String ?? ""
        self.coinIcon = json.value(forKeyPath: "coin.icon") as? String ?? ""
        self.coinSymbol = json.value(forKeyPath: "coin.symbol") as? String ?? ""
        self.coinMarketPriceUSD = json.value(forKeyPath: "coin.marketPriceUSD") as? Double ?? 0
        self.coinRank = json.value(forKeyPath: "coin.rank") as? Int ?? 0

        let rates = UserDefaults.standard.value(forKey: "\(DatabaseManager.shared.currentUser?.id ?? "" )/rates") as? [String:Double]
        self.coinAlertPriceUSD = self.coinMarketPriceUSD * (rates?[self.cur] ?? 1.0)
        
    }
    
    convenience init(json: NSDictionary, coin: CoinModel) {
        self.init()
        self.id = json.value(forKey: "_id") as? String ?? ""
        self.comparison = json.value(forKey: "comparison") as? Bool ?? false
        self.isEnabled = json.value(forKey: "enabled") as? Bool ?? false
        self.isRepeat = json.value(forKey: "repeat") as? Bool ?? false
        self.value = json.value(forKey: "value") as? Double ?? 0.0
        self.cur = json.value(forKey: "cur") as? String ?? ""

        self.coinID = coin.coinId
        self.coinName = coin.name
        self.coinIcon = coin.icon
        self.coinSymbol = coin.symbol
        self.coinMarketPriceUSD = coin.marketPriceUSD
        self.coinAlertPriceUSD = coin.marketPriceUSD

        self.coinRank = coin.rank
    }
    
    convenience init(json: NSDictionary, alert: AlertModel) {
        self.init()
        self.id = json.value(forKey: "_id") as? String ?? ""
        self.comparison = json.value(forKey: "comparison") as? Bool ?? false
        self.isEnabled = json.value(forKey: "enabled") as? Bool ?? false
        self.isRepeat = json.value(forKey: "repeat") as? Bool ?? false
        self.value = json.value(forKey: "value") as? Double ?? 0.0
        self.cur = json.value(forKey: "cur") as? String ?? ""

        self.coinID = alert.coinID
        self.coinName = alert.coinName
        self.coinIcon = alert.coinIcon
        self.coinSymbol = alert.coinSymbol
        self.coinMarketPriceUSD = alert.coinMarketPriceUSD
        self.coinAlertPriceUSD = alert.coinAlertPriceUSD
        self.coinRank = alert.coinRank
    }
    
    var iconPath: String {
        return coinIcon.contains("http") ? coinIcon : Constants.HttpUrlWithoutApi + "images/coins/" + coinIcon
    }
    
    public func updateCurrency(_ alerPrice: Double) -> AlertModel {
        self.coinAlertPriceUSD *= alerPrice
        return self
    }
    
}

