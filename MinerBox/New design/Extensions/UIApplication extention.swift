//
//  UIApplication extention.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 04.08.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

extension UIApplication {
    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
            
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
    
    static var pageName: String {
        return String(describing: UIApplication.getTopViewController())
    }
}
