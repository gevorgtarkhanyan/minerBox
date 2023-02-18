//
//  CoinFiatDataModel.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/21/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class CoinFiatDataModel {
    var priceName: String
    var flagName: String
    var criptoName: String
    var criptoValue: String
    var changeAblePrice: Double
    
    init(flagName: String,
         criptoName: String,
         criptoValue: String,
         changeAblePrice: Double,
         priceName: String = "price".localized()) {
        
        self.priceName = priceName
        self.flagName = flagName
        self.criptoName = criptoName
        self.criptoValue = criptoValue
        self.changeAblePrice = changeAblePrice
    }
    
}

