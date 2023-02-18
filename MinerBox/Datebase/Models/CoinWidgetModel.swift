//
//  CoinWidgetModel.swift
//  MinerBox
//
//  Created by Vazgen Hovakinyan on 25.02.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit
import RealmSwift

class CoinWidgetModel: Object {
    // MARK: - Properties
    @objc dynamic var userId: String = ""
    @objc dynamic var coinId: String = ""
    @objc dynamic var isSelect: Bool = false

    // MARK: - Init
    convenience init(userId: String, coin: CoinModel) {
        self.init()
        self.userId = userId
        self.coinId = coin.coinId
    }
}
