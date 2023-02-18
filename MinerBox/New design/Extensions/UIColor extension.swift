//
//  UIColor extension.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/24/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

extension UIColor {

    class var badge: UIColor {
        return UIColor(red: 1, green: 0.23, blue: 0.19, alpha: 1)
    }

//    class var graphFillColors: [[UIColor]] {
//        let left = getColor(red: 61, green: 138, blue: 239)
//        let right = getColor(red: 161, green: 225, blue: 191)
//
//        let lhs = getColor(red: 143, green: 189, blue: 41)
//        let rhs = getColor(red: 224, green: 234, blue: 201)
//        return [[left, right], [lhs, rhs]]
//    }

    class var graphLineColors: [UIColor] {
        let one = getColor(red: 30, green: 152, blue: 155)
        let two = getColor(red: 143, green: 189, blue: 41)
        let tree = getColor(red: 21, green: 196, blue: 6)
        let four = getColor(red: 189, green: 98, blue: 196)
        let five = getColor(red: 255, green: 204, blue: 0)

        return [two, one, four, five, tree]
    }

    class var graphLineGradientColors: [[UIColor]] {
        let firstLeft = getColor(red: 61, green: 138, blue: 239)
        let firstRight = getColor(red: 161, green: 225, blue: 191)

        let secondLeft = getColor(red: 143, green: 189, blue: 41)
        let secondRight = getColor(red: 224, green: 234, blue: 201)

        let thirdLeft = getColor(red: 21, green: 196, blue: 196)
        let thirdRight = getColor(red: 196, green: 240, blue: 240)

        let fourthLeft = getColor(red: 189, green: 98, blue: 196)
        let fourthRight = getColor(red: 251, green: 200, blue: 255)

        let fifthLeft = getColor(red: 255, green: 204, blue: 0)
        let fifthRight = getColor(red: 255, green: 243, blue: 196)

        return [[firstLeft, firstRight], [secondLeft, secondRight], [thirdLeft, thirdRight], [fourthLeft, fourthRight], [fifthLeft, fifthRight]]
    }

    class var workerRed: UIColor {
        return getColor(red: 224, green: 32, blue: 32)
    }

    class var workerGreen: UIColor {
        return getColor(red: 92, green: 189, blue: 56)
    }
    
    class var appGreen: UIColor {
        return getColor(red: 30, green: 152, blue: 155)
    }

    class var activeSubscription: UIColor {
        return getColor(red: 21, green: 196, blue: 6)
    }

    class var placeholder: UIColor {
        return getColor(red: 125, green: 125, blue: 125)
    }

    class var textFieldBackground: UIColor {
        return getColor(red: 118, green: 118, blue: 118).withAlphaComponent(0.24)
    }

    class var switchOnTint: UIColor {
        return getColor(red: 120, green: 120, blue: 128).withAlphaComponent(0.16)
    }

    class var whiteTransparented: UIColor {
        return getColor(red: 255, green: 255, blue: 255).withAlphaComponent(0.9)
    }

    class var blackTransparented: UIColor {
        return getColor(red: 0, green: 0, blue: 0).withAlphaComponent(0.7)
    }

    class var grayButton: UIColor {
        return getColor(red: 109, green: 114, blue: 120)
    }

    class var detailsSectionHeader: UIColor {
        return getColor(red: 143, green: 189, blue: 41)
    }

    class var viewDarkBackground: UIColor {
        return getColor(red: 58, green: 58, blue: 60)
    }

    class var viewLightBackground: UIColor {
        return getColor(red: 245, green: 245, blue: 245)
    }
    
    class var viewDarkBackgroundWithAlpha: UIColor {
        return getColor(red: 58, green: 58, blue: 60).withAlphaComponent(0.8)
    }

    class var viewLightBackgroundWithAlpha: UIColor {
        return getColor(red: 245, green: 245, blue: 245).withAlphaComponent(0.9)
    }

    class var textFieldPlaceholder: UIColor {
        return getColor(red: 235, green: 235, blue: 245).withAlphaComponent(0.6)
    }

    class var textFieldBackgorund: UIColor {
        return getColor(red: 118, green: 118, blue: 128).withAlphaComponent(0.24)
    }

    class var textBlack: UIColor {
        return getColor(red: 0, green: 0, blue: 0).withAlphaComponent(0.85)
    }

    class var sectionHeaderDark: UIColor {
        return getColor(red: 45, green: 45, blue: 45)
    }
    
    class var sectionHeaderLight: UIColor {
        return getColor(red: 225, green: 225, blue: 225)
    }

    class var accountDisabled: UIColor {
        return getColor(red: 224, green: 32, blue: 32)
    }

    class var accountEnabled: UIColor {
        return getColor(red: 92, green: 189, blue: 56)
    }

    class var separator: UIColor {
        return getColor(red: 125, green: 125, blue: 125).withAlphaComponent(0.4)
    }

    class var tableCellBackground: UIColor {
        return getColor(red: 125, green: 125, blue: 125).withAlphaComponent(0.1)
    }
    
    class var tableSectionDark: UIColor {
        return getColor(red: 58, green: 58, blue: 60).withAlphaComponent(0.9)
    }
    
    class var tableSectionLight: UIColor {
        return getColor(red: 245, green: 245, blue: 245).withAlphaComponent(0.9)
    }

    class var cellTrailingFirst: UIColor {
        return getColor(red: 30, green: 152, blue: 155)
    }

    class var cellTrailingSecond: UIColor {
        return getColor(red: 143, green: 189, blue: 41)
    }
    
    class var cellTrailingThird: UIColor {
        return getColor(red: 255, green: 204, blue: 0)
    }
    
    class var blackBackground: UIColor {
        return getColor(red: 38, green: 38, blue: 38)
    }

    class var barDark: UIColor {
        return getColor(red: 28, green: 28, blue: 28)
    }

    class var barLight: UIColor {
        return getColor(red: 249, green: 249, blue: 249).withAlphaComponent(0.94)
    }

    class var barDeselectedItem: UIColor {
        return getColor(red: 153, green: 153, blue: 153)
    }

    class var barSelectedItem: UIColor {
        return getColor(red: 30, green: 152, blue: 155)
    }

    class var segmentBackground: UIColor {
        return getColor(red: 118, green: 118, blue: 128).withAlphaComponent(0.12)
    }

    class var nextSubscription: UIColor {
        return getColor(red: 247, green: 181, blue: 0)
    }

    // MARK: - What to mine
    class var whiteTextColor: UIColor {
        return UIColor(red: 220 / 255, green: 221 / 255, blue: 221 / 255, alpha: 1)
    }

    class var darkGrayColor: UIColor {
        return UIColor(red: 48 / 255, green: 49 / 255, blue: 52 / 255, alpha: 1.0)
    }

    class var lightGrayColor: UIColor {
        return UIColor(red: 240 / 255, green: 240 / 255, blue: 240 / 255, alpha: 1.0)
    }

    class var blackBackgroundColor: UIColor {
        return UIColor(red: 30 / 255, green: 32 / 255, blue: 34 / 255, alpha: 1)
    }
}

// MARK: - Actions
extension UIColor {
    fileprivate class func getColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        if #available(iOS 10.0, *) {
            return UIColor(displayP3Red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
        } else {
            return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
        }
    }
}
