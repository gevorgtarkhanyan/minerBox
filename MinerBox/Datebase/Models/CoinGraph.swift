//
//  CoinGraph.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 3/28/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class CoinGraphModel: Codable {
    let date: Double
    let usd: Double

    init(date: Double, usd: Double) {
        self.date = date
        self.usd = usd
    }
}
