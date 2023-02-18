//
//  MultiCoinWidgetEntry.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 28.09.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation
import WidgetKit
import SwiftUI

struct MultiCoinWidgetEntry: TimelineEntry {
    var date: Date
    var configuration: MultiCoinConfigurationIntent
    var isLogin: Bool = true
    var darkMode:Bool = true
    var coins: [SingleCoinForMulti] = []
    var widgetSize: CGSize
    var noSelectedCoins: Bool = false
}

struct SingleCoinForMulti: Hashable {
    var icon: String
    var id: String
    var marketPriceUSD: String
    var name: String = ""
    var symbol: String = ""
    var change1h: Double
    var change24h: Double
    var change7d: Double
    var numberCoin: Int

}
