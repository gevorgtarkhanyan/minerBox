//
//  SingleAccountEntry.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 17.09.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import WidgetKit
import SwiftUI

struct SingleAccountEntry: TimelineEntry {
    var date: Date
    var poolIcon: String = ""
    var poolId: String = ""
    var poolAccountName: String?
    var poolTypeAndSubType = ""
    var workersCount: Int?
    var currentHashrate: String = ""
    var darkMode: Bool = true
    var balance: Balance?
    var configuration: SingleAccountConfigurationIntent?
    var configurationForBalance: AccountBalanceConfigurationIntent?
    var isLogin: Bool?
    var isSubscribted: Bool?
    var noAccount: Bool = false
    var noSelectedAccount: Bool = false
    var widgetSize: CGSize
    var balances: [Balance]?

}

enum WidgetBalance: String, CaseIterable {
    
    case paid
    case unpaid
    case unconfirmed
    case confirmed
    case orphaned
    case credit
    case totalBalance
    
}

struct Balance: Hashable {
    var value: String
    var type: String
}
