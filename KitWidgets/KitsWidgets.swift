//
//  KidsWidgets.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 13.09.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import WidgetKit
import SwiftUI


@available(iOSApplicationExtension 14.0, *)
@main

struct KidsWidgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        
        SingleCoinWidget()
        SingleAccountWidget()
        AccountBalanceWidget()
        MultiCoinWidget()
        MultiAccountWidget()

    }
}
