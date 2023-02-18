//
//  AddAlertDataSource.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 11/25/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import Foundation

enum CoinAlertType: String {
    case lessThan = "comparision_less_than"
    case greatherThan = "comparision_greather_than"
}

class AddAlertDataSource {
    static var coinAlertDataModel: [CustomAlertModel] {
        var dataModel: [CustomAlertModel] = []
        dataModel.append(CustomAlertModel(imageName: "", actionTitle: CoinAlertType.lessThan.rawValue.localized()))
        dataModel.append(CustomAlertModel(imageName: "", actionTitle: CoinAlertType.greatherThan.rawValue.localized()))
        return dataModel
    }
}
