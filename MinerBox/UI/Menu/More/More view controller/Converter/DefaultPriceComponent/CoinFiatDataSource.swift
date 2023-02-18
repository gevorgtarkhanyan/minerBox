//
//  CoinFiatDataSource.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/23/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import Foundation

class CoinFiatDataSource {
    
    static func coinModel(_ model: CoinModel) -> CoinFiatDataModel {
        return CoinFiatDataModel(flagName: model.iconPath, criptoName: model.name, criptoValue: model.symbol, changeAblePrice: model.changeAblePrice)
    }
    
    static func fiatModel(_ model: FiatModel) -> CoinFiatDataModel {
        return CoinFiatDataModel(flagName: model.flag, criptoName: model.currency, criptoValue: model.symbol,  changeAblePrice: model.changeAblePrice)
    }
}
