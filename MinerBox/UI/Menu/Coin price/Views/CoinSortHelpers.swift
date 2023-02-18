//
//  CoinSortHelpers.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 13.04.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation

struct CoinSortModel {
    let type: CoinSortEnum
    let lowToHigh: Bool
    
    init() {
        self.type = .rank
        self.lowToHigh = true
    }

    init(type: CoinSortEnum, lowToHigh: Bool) {
        self.type = type
        self.lowToHigh = lowToHigh
    }
    
    init(sortDict: [String: Any]) {
        self.type = CoinSortEnum(rawValue: sortDict["rawValue"] as? String ?? "coin_sort_rank") ?? .rank
        self.lowToHigh = sortDict["lowToHigh"] as? Bool ?? true
    }
    
    func toAny() -> [String: Any] {
        return [
            "rawValue": type.rawValue,
            "lowToHigh": lowToHigh
        ]
    }
    
    var requestDescription: String {
        return """
        {"name": "\(type.requestName())","order": \(lowToHigh ? 1 : -1)}
        """
    }
    
}

struct CoinFilterModel: Equatable {
    let type: CoinSortEnum
    let from: Int?
    let to: Int?
    
    init(type: CoinSortEnum, from: Int? = nil, to: Int? = nil) {
        self.type = type
        self.from = from
        self.to = to
    }
    
    init(filterDict: [String: Any]) {
        self.type = CoinSortEnum(rawValue: filterDict["rawValue"] as? String ?? "coin_sort_rank") ?? .rank
        self.from = filterDict["from"] as? Int
        self.to = filterDict["to"] as? Int
    }
    
    func toAny() -> [String: Any] {
        var dict: [String: Any] = ["rawValue": type.rawValue]
        dict["from"] = from
        dict["to"] = to
        return dict
    }
    
    static func ==(lhs: CoinFilterModel, rhs: CoinFilterModel) -> Bool {
        return lhs.type == rhs.type && lhs.from == rhs.from && lhs.to == rhs.to
    }
    
    var requestDescription: String {
        var fromStr = from == nil ?
            "" :
            """
            "from": \(from!),
            """
        if to == nil {
            fromStr.removeLast()
        }
        
        let toStr = to == nil ?
            "" :
            """
            "to": \(to!)
            """
        
        return """
        {"name": "\(type.requestName())",\(fromStr)\(toStr)}
        """
    }
    
}

enum CoinSortEnum: String, CaseIterable {
    case rank = "coin_sort_rank"
    case coin = "coin_sort_coin"
    case price = "coin_sort_price"
    case change = "coin_sort_change"
    
    case name = "coin_name"
    case symbol = "currency"
    
    case marketPriceUSD = "price_usd"
    case marketCapUsd = "market_cap_usd"
    
    case change1h = "change_1_hour"
    case change24h = "change_24_hour"
    case change1w = "change_7_day"

    static func getSegmentCases() -> [CoinSortEnum] {
        return [rank, coin, price, change]
    }
    
    static func getCoinCases() -> [CoinSortEnum] {
        return [name, symbol]
    }
    
    static func getPriceCases() -> [CoinSortEnum] {
        return [marketPriceUSD, marketCapUsd]
    }

    static func getChangeCases() -> [CoinSortEnum] {
        return [change1h, change24h, change1w]
    }
    
    static func getFilterCases() -> [CoinSortEnum] {
        return [rank] + getPriceCases() + getChangeCases()
    }
    
    var localized: String {
        if rawValue.contains("usd") {
            return rawValue.localized().replacingOccurrences(of: "USD", with: Locale.appCurrency)
        }
        return rawValue.localized()
    }
    
    func requestName() -> String {
        switch self {
        case .rank:
            return "rank"
        case .coin, .name:
            return "name"
        case .symbol:
            return "symbol"
        case .price, .marketPriceUSD:
            return "marketPriceUSD"
        case .marketCapUsd:
            return "marketCapUsd"
        case .change, .change1h:
            return "change1h"
        case .change24h:
            return "change24h"
        case .change1w:
            return "change7d"
        }
    }
    
    func getIndex() -> Int {
        switch self {
        case .rank:
            return 0
        case .coin, .name, .symbol:
            return 1
        case .price, .marketCapUsd, .marketPriceUSD:
            return 2
        case .change, .change1h, .change1w, .change24h:
            return 3
        }
    }
    
    // only use when changing sort button
    init(requestName: String) {
        switch requestName {
        case "rank":
            self = .rank
        case "name", "symbol":
            self = .coin
        case "marketPriceUSD", "merketCapUsd":
            self = .price
        case "change1h", "change24h", "change7d":
            self = .change
        default:
            self = .rank
        }
    }
    
}

