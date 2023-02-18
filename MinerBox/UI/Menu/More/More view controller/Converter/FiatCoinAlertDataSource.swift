//
//  FiatCoinAlertDataSource.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/22/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class FiatCoinAlertDataSource {
    static var alertDataModel: [CustomAlertModel] {
        var dataModel: [CustomAlertModel] = []
        
        dataModel.append(CustomAlertModel(imageName: "", actionTitle: "coin_sort_coin".localized(), filter: "coin"))
        dataModel.append(CustomAlertModel(imageName: "", actionTitle: "fiat".localized(), filter: "fiat"))
        return dataModel
    }
}
