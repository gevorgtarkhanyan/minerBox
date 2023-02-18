//
//  MainHeaderDataSource.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/23/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import Foundation

class MainHeaderDataSource {

    static func headerModel(_ model: CoinModel) -> MainHeaderDataModel {
        return MainHeaderDataModel(headerName: model.name, headerSymbol: model.symbol, headerImageName: model.iconPath)
    }
}
