//
//  CopyButton.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 1/29/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class CopyButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        setImage(UIImage(named: "copyText"), for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged(notification:)), name: NSNotification.Name(OldConstants.themeChanged), object: nil)
        themeChanged()
    }
    
    @objc func themeChanged(notification: NSNotification? = nil) {
        let darkMode = UserDefaults.standard.bool(forKey: "darkMode")
        
        imageView?.image = imageView?.image?.withRenderingMode(.alwaysTemplate)
        setImage(imageView?.image, for: .normal)
        imageView?.tintColor = darkMode ? .whiteTextColor : .darkGrayColor
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
