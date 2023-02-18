//
//  UIBarButtonItem extension.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 02.06.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation
import UIKit

extension UIBarButtonItem {
    static func customButton(_ target: Any?, action: Selector, imageName: String, tag: Int = -1, renderingMode: UIImage.RenderingMode = .alwaysTemplate ) -> UIBarButtonItem {
        let constant: CGFloat = 25
        let insetValue: CGFloat = 3
        if #available(iOS 11, *) {
            let button = UIButton(type: .system)
            button.backgroundColor = .clear
            button.imageView?.contentMode = .scaleAspectFit
            button.setImage(UIImage(named: imageName)?.withRenderingMode(renderingMode), for: .normal)
            button.addTarget(target, action: action, for: .touchUpInside)
            button.imageEdgeInsets = UIEdgeInsets(top: constant, left: constant, bottom: constant, right: constant)
            // coin, worker filter plus
            if tag == 1 {
                button.imageEdgeInsets = UIEdgeInsets(top: insetValue, left: insetValue, bottom: insetValue, right: insetValue)
            // notification filter
            } else if tag == 2 {
                button.imageEdgeInsets = UIEdgeInsets(top: insetValue, left: 4 * insetValue, bottom: insetValue, right: -2 * insetValue)
            // notification search
            } else if tag == 3 {
                button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 3 * insetValue, bottom: 0, right: -3 * insetValue)
            }
            
            let customBarItem = UIBarButtonItem(customView: button)
            customBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
            customBarItem.customView?.heightAnchor.constraint(equalToConstant: constant).isActive = true
            customBarItem.customView?.widthAnchor.constraint(equalToConstant: constant).isActive = true
            
            return customBarItem
        } else {
            let button = UIButton(type: .custom)
            button.backgroundColor = .clear
            button.frame = CGRect(x: 0.0, y: 0.0, width: constant, height: constant)
            let image = UIImage(named: imageName)?.withRenderingMode(renderingMode)
            button.setImage(image, for: .normal)
            button.addTarget(target, action: action, for: .touchUpInside)
            // coin, worker filter
            if tag == 1 {
                button.imageEdgeInsets = UIEdgeInsets(top: insetValue, left: insetValue, bottom: insetValue, right: insetValue)
            // notification filter
            } else if tag == 2 {
                button.imageEdgeInsets = UIEdgeInsets(top: insetValue, left: 4 * insetValue, bottom: insetValue, right: -2 * insetValue)
            // notification search
            } else if tag == 3 {
                button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 3 * insetValue, bottom: 0, right: -3 * insetValue)
            }

            return UIBarButtonItem(customView: button)
        }
    }
}
