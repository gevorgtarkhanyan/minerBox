//
//  UIResponder extension.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/30/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

extension UIResponder {
    class var name: String {
        return String(describing: self)
    }
}

