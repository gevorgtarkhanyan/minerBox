//
//  CoinAlertSectionDataModel.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 11/22/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class CoinAlertCellAsSectionDataModel {
     var isExpanded = false
     var models: [AlertModel] = []
     var rank: String
     var url: String
     var coinSymbolName: String
     var coinName: String
     var price: String
     var alertPrice: String


    init(isExpanded: Bool, models: [AlertModel], rank: String, url: String, coinSymbolName: String, coinName: String, price: String, alertPrice: String) {
        self.rank = rank
        self.url = url
        self.coinSymbolName = coinSymbolName
        self.coinName = coinName
        self.price = price
        self.alertPrice = alertPrice
        self.models = models
    }
}
