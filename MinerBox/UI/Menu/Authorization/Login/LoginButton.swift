//
//  LoginButton.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/1/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class LoginButton: BackgroundButton {
    
    override func changeColors() {
        setTitleColor(.barSelectedItem, for: .normal)
    }
    
}
