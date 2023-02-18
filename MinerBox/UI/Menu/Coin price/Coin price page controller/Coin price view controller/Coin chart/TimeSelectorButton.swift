//
//  TimeSelectorButton.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/18/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class TimeSelectorButton: BackgroundButton {
    override func changeColors() {
        if isSelected {
            setTitleColor(.barSelectedItem, for: .normal)
        } else {
            setTitleColor(darkMode ? .white : .black, for: .normal)
        }
    }
    
    public func setSelected(selected: Bool) {
        isSelected = selected
        UIView.animate(withDuration: Constants.animationDuration) {
            self.changeColors()
        }
    }
}
