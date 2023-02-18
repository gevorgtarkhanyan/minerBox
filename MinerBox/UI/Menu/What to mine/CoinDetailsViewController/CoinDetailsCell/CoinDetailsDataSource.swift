//
//  CoinDetailsDataSource.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 11/4/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class CoinDetailsDataSource {
    
    static let shared = CoinDetailsDataSource()
    
    func coinDetailsData(_ coin: MiningCoinsModel) -> [CoinDetailsDataModel] {
        var dataModel: [CoinDetailsDataModel] = []
        let sendedDataDictionary = coin.details
        for (key, value) in sendedDataDictionary {
            dataModel.append(CoinDetailsDataModel(key: key, value: value))
        }
        return dataModel
    }
    
}
