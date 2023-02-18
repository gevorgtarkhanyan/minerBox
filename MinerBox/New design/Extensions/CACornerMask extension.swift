//
//  CACornerMask extension.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/30/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

extension CACornerMask {
    static var topLeft: CACornerMask {
        return CACornerMask.layerMinXMinYCorner
    }

    static var topRight: CACornerMask {
        return CACornerMask.layerMaxXMinYCorner
    }

    static var bottomLeft: CACornerMask {
        return CACornerMask.layerMinXMaxYCorner
    }

    static var bottomRight: CACornerMask {
        return CACornerMask.layerMaxXMaxYCorner
    }
}
