//
//  NSLayoutDimension_Extension.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 11.02.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit


extension NSLayoutDimension {

@discardableResult
func set(
        to constant: CGFloat,
        priority: UILayoutPriority = .required
        ) -> NSLayoutConstraint {

        let cons = constraint(equalToConstant: constant)
        cons.priority = priority
        cons.isActive = true
        return cons
    }
}
