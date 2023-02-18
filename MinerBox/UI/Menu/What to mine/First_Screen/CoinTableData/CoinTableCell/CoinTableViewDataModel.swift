//
//  CoinTableViewDataModel.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 11/4/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class CoinTableViewDataModel {
    var imageName: String = ""
    var coinName: String = ""
    var coinSymbol: String = ""
    var algorithmName: String = ""
    var revenue: Double = 0
    var profit: Double = 0
    var coinId: String = ""
    
    init(imageName: String, coinName: String, coinSymbol: String, algorithmName: String, revenue: Double, profit: Double, coinId: String = "") {
        self.imageName = imageName
        self.coinName = coinName
        self.coinSymbol = coinSymbol
        self.algorithmName = algorithmName
        self.revenue = revenue
        self.profit = profit
        self.coinId = coinId
    }
    
}
