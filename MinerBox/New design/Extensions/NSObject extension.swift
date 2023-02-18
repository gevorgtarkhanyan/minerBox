//
//  NSObject extension.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/26/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import WidgetKit

extension NSObject {
    public var darkMode: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "darkMode")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.themeChanged), object: nil)
            
            if let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") {
                userDefaults.set(newValue, forKey: "darkMode")
                if #available(iOS 14.0, *) {
                    #if arch(arm64) || arch(i386) || arch(x86_64)
                    WidgetCenter.shared.reloadAllTimelines()
                    #endif
                }
            }
            
        }
        get {
            return (UserDefaults.standard.value(forKey: "darkMode") != nil) ? UserDefaults.standard.bool(forKey: "darkMode") : true
        }
    }
    
    //    public var safeInsets: (top: CGFloat, left: CGFloat, right: CGFloat, bottom: CGFloat) {
    //        var top: CGFloat = 0
    //        var left: CGFloat = 0
    //        var right: CGFloat = 0
    //        var bottom: CGFloat = 0
    //
    //        if #available(iOS 11.0, *), let insets = UIApplication.shared.keyWindow?.safeAreaInsets {
    //            top = insets.top
    //            left = insets.left
    //            right = insets.right
    //            bottom = insets.bottom
    //        }
    //        return (top: top, left: left, right: right, bottom: bottom)
    //    }
    //
    //    public var safeFrame: (width: CGFloat, height: CGFloat) {
    //        var width = UIScreen.main.bounds.width
    //        var height = UIScreen.main.bounds.height
    //
    //        if #available(iOS 11.0, *), let frame = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame {
    //            width = frame.width
    //            height = frame.height
    //        }
    //
    //        return (width: width, height: height)
    //    }
}

