//
//  CoinListJSON.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 1/30/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import Foundation

class CoinListJSON: Codable {
    let status: Int
    let description: String
    let data: [CoinListJSONData]
    
    init(status: Int, description: String, data: [CoinListJSONData]) {
        self.status = status
        self.description = description
        self.data = data
    }
}

class CoinListJSONData: Codable {
    let id, coinID: String
    let icon: String
    let lastUpdated: Double
    let marketCapUsd, change7D, change24H, change1H: Double?
    let marketPriceUSD, marketPriceBTC: Double
    let rank: Int
    let name, symbol: String
    let previousPriceUSD: Double
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case coinID = "coinId"
        case icon, lastUpdated, marketCapUsd
        case change7D = "change7d"
        case change24H = "change24h"
        case change1H = "change1h"
        case marketPriceUSD, marketPriceBTC, rank, name, symbol, previousPriceUSD
    }
    
    init(id: String, coinID: String, icon: String, lastUpdated: Double, marketCapUsd: Double?, change7D: Double?, change24H: Double?, change1H: Double?, marketPriceUSD: Double, marketPriceBTC: Double, rank: Int, name: String, symbol: String, previousPriceUSD: Double) {
        self.id = id
        self.coinID = coinID
        self.icon = icon
        self.lastUpdated = lastUpdated
        self.marketCapUsd = marketCapUsd
        self.change7D = change7D
        self.change24H = change24H
        self.change1H = change1H
        self.marketPriceUSD = marketPriceUSD
        self.marketPriceBTC = marketPriceBTC
        self.rank = rank
        self.name = name
        self.symbol = symbol
        self.previousPriceUSD = previousPriceUSD
    }
}
