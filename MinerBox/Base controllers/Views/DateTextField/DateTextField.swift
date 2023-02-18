//
//  DateTextField.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 26.11.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit
import Foundation

protocol DateTextFieldDelegate: AnyObject {
    func dateDidChange(dateTextField: DateTextField)
}

class DateTextField: BaseTextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cornerRadius(radius: bounds.height / 2)
        layoutIfNeeded()
        rightViewMode = .always
    }

    @IBInspectable open var rightImage: String? {
        didSet {
            if (rightImage != nil) {
                self.applyRightImage(rightImage!)
            }
        }
    }

    @objc func refresh(_ sender: Any) {
        delegate?.textFieldDidBeginEditing?(self)
    }
    
    fileprivate func applyRightImage(_ image: String) {
        let button = UIButton(type: .custom)
        let imageHeight = frame.size.height * 0.8
        let imageY = frame.size.height - imageHeight
        let imageX = frame.size.width - imageHeight - (2 * imageY)
        button.setImage(UIImage(named: image), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -70, bottom: 0, right: 0)
        button.frame = CGRect(x: imageX, y: imageY, width: imageHeight, height: imageHeight)
        button.addTarget(self, action: #selector(refresh), for: .touchUpInside)
        rightView = button
        rightViewMode = .always
    }
}
