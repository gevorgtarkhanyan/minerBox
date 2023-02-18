//
//  SingleCoinWidget.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 30.08.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import WidgetKit
import SwiftUI

struct SingleCoinWidgetEntry: TimelineEntry {
    var date: Date
    var icon: String
    var id: String
    var marketPriceUSD: String
    var name: String
    var change1h: Double
    var change24h: Double
    var change7d: Double
    var darkMode:Bool?
    var configuration: SingleCoinConfigurationIntent
    var isLogin: Bool?
    var widgetSize: CGSize
    var noSelectedCoin: Bool = false
    
}
