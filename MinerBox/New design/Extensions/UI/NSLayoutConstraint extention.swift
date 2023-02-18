//
//  NSLayoutConstraint extention.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 09.12.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation
import UIKit

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}
