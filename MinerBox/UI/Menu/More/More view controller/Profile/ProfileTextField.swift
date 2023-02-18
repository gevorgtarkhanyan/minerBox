//
//  ProfileTextField.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/9/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class ProfileTextField: BaseTextField {
    override func startupSetup() {
        super.startupSetup()
        borderStyle = .none
    }

    override func changeColors() {
        super.changeColors()
        backgroundColor = .clear
    }
}
