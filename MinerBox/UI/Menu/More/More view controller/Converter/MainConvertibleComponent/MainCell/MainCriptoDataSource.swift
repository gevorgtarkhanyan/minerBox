//
//  MainCoinDataModel.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/23/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import Foundation

class MainCriptoDataSource {
        
    static let coinDataCount = 3
    static let fiatDataCount = 1

    static func coinModel(_ model: CoinModel) -> [MainCriptoDataModel] {
        var dataModel: [MainCriptoDataModel] = []
        let market_cap_usd = "market_cap_usd".localized().replacingOccurrences(of: "USD", with: Locale.appCurrency)
        let rates = UserDefaults.standard.value(forKey: "\(DatabaseManager.shared.currentUser?.id ?? "" )/rates") as? [String:Double]

        dataModel.append(MainCriptoDataModel(mainInfo: market_cap_usd,
                                             mainValue:"\(Locale.appCurrencySymbol) " + (model.marketCapUsd * (rates?[Locale.appCurrency] ?? 1.0)).formatUsingAbbrevation() ))
        dataModel.append(MainCriptoDataModel(mainInfo: "price".localized(),
                                             mainValue: "\(Locale.appCurrencySymbol) " + (model.marketPriceUSD * (rates?[Locale.appCurrency] ?? 1.0)).getString() + " | ฿ " + model.marketPriceBTC.getString()))
        dataModel.append(MainCriptoDataModel(mainInfo: "last_updated".localized(),
                                             mainValue: model.lastUpdated.getDateFromUnixTime()))
        
        return dataModel
    }
    
    static func fiatModel(_ model: FiatModel, at marketPriceBTC: Double) -> [MainCriptoDataModel] {
        var dataModel: [MainCriptoDataModel] = []
        let priceUsd = 1 / model.price
        let priceBTC = priceUsd / marketPriceBTC
        
        dataModel.append(MainCriptoDataModel(mainInfo: "price".localized(),
                                             mainValue: "\(Locale.appCurrencySymbol) " + priceUsd.getString() + " | ฿ " + priceBTC.getString()))
        return dataModel
    }
    
}
