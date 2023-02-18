//
//  LaunchScreenView.swift
//  MinerBox
//
//  Created by Vazgen Hovakinyan on 22.04.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

class LaunchScreenView: BaseView {
    override func changeColors() {
        backgroundColor = darkMode ? .barDark : .barLight
    }
}
