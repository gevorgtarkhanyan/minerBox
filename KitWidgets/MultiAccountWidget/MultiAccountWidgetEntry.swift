//
//  MultiCoinWidgetEntry.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 04.10.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation
import WidgetKit
import SwiftUI

struct MultiAccountWidgetEntry: TimelineEntry {
    var date: Date
    var configuration: MultiAccountConfigurationIntent
    var isLogin: Bool = true
    var darkMode:Bool = true
    var accounts: [SingleAccountForMulti] = []
    var isSubscribted: Bool?
    var noAccount: Bool = false
    var widgetSize: CGSize
    var noSelectedAccount: Bool = false
}

struct SingleAccountForMulti: Hashable {
   
    var poolIcon: String = ""
    var poolId: String = ""
    var poolAccountName: String = ""
    var poolType = ""
    var subType = ""
    var workersCount: Int
    var currentHashrate: String = ""
    var balance: Balance?
    var numberAccount: Int
    
    static func == (lhs: SingleAccountForMulti, rhs: SingleAccountForMulti) -> Bool {
        if lhs.poolId == rhs.poolId { return  true }
        return false
    }
    
}
