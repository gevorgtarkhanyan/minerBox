//
//  CoinDatePrice.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 07.12.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation

class CoinDatePrice {
    let currencyPrice: Double
    let price: Double
    
    init(json: NSDictionary) {
        let rates = json.value(forKey: "rates") as? NSDictionary
        currencyPrice = rates?.value(forKey: Locale.appCurrency) as? Double ?? 0.0
        price = json.value(forKey: "price") as? Double ?? 0.0
    }
    
    var convertedPrice: Double {
        return price * currencyPrice
    }
}
