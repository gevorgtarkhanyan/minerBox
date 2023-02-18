//
//  AlertControllerButton.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/24/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class AlertControllerButton: BackgroundButton {
    override func startupSetup() {
        super.startupSetup()
        changeFontSize(to: 17)
    }

    override func changeColors() {
        setTitleColor(.barSelectedItem, for: .normal)
        backgroundColor = darkMode ? .viewDarkBackground : .viewLightBackground
    }
}

extension UIAlertController{
       open override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
          self.view.tintColor = .barSelectedItem
       }
   }
