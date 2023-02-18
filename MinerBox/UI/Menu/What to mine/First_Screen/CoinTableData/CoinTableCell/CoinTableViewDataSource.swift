//
//  CoinTableViewDataSource.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 11/4/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class CoinTableViewDataSource {
    
    static let shared = CoinTableViewDataSource()
    
    func coinTableDefaultDataForUser(_ defaultsData: MiningDefaultsModel) ->  [CoinTableViewDataModel] {
        var dataModel: [CoinTableViewDataModel] = []
        let sendedDataModel = defaultsData.miningCoins
        
        for coin in sendedDataModel {
            let currentCoin = CoinTableViewDataModel(imageName: coin.coinIcon, coinName: coin.coinName, coinSymbol: coin.symbol,
                                              algorithmName: coin.algorithm, revenue: coin.revenue, profit: coin.profit, coinId: coin.coinId)
            dataModel.append(currentCoin)
        }
        return dataModel
    }
}
