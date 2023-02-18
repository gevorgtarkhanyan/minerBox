//
//  SegmentButton.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/19/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class SegmentButton: BackgroundButton {
    override func changeColors() {
        setTitleColor(darkMode ? .white : .textBlack, for: .normal)
    }

}
