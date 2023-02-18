//
//  CoinDetailsDataModel.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 11/4/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class CoinDetailsDataModel {
    var key: String = ""
    var value: String = ""
    
    init(key: String, value: String) {
        self.key = key.localized()
        self.value = value.localized()
    }
    
}
