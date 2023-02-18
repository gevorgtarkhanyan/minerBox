//
//  AnimationView.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/2/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class AnimationView: BaseView {
    override func changeColors() {
        backgroundColor = darkMode ? .barDark : .barLight
    }
}
