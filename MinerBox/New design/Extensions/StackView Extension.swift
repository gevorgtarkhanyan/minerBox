//
//  StackView Extension.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 14.04.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation
import UIKit


extension UIStackView {
    func addCustomSpacing(_ spacing: CGFloat, after arrangedSubview: UIView) {
        if #available(iOS 11.0, *) {
            self.setCustomSpacing(spacing, after: arrangedSubview)
        } else {
            let separatorView = UIView(frame: .zero)
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            switch axis {
            case .horizontal:
                separatorView.widthAnchor.constraint(equalToConstant: spacing).isActive = true
            case .vertical:
                separatorView.heightAnchor.constraint(equalToConstant: spacing).isActive = true
            @unknown default:
                break
            }
            if let index = self.arrangedSubviews.firstIndex(of: arrangedSubview) {
                insertArrangedSubview(separatorView, at: index + 1)
            }
        }
    }
    
    func addBackground(color: UIColor?) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
    func roundCornerStackView(backgroundColor: UIColor = .clear, radiusSize: CGFloat = 0) {
            let subView = UIView(frame: bounds)
            subView.backgroundColor = backgroundColor
            subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            insertSubview(subView, at: 0)

            subView.layer.cornerRadius = radiusSize
            subView.layer.masksToBounds = true
            subView.clipsToBounds = true
        }
}
