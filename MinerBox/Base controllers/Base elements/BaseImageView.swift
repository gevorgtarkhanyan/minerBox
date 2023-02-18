//
//  BaseImageView.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/19/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class BaseImageView: UIImageView {

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        awakeFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Awake from NIB
    override func awakeFromNib() {
        super.awakeFromNib()
        startupSetup()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Startup sefault setup
extension BaseImageView {
    @objc public func startupSetup() {
        changeColors()
        addObservers()
    }

    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: Notification.Name(Constants.themeChanged), object: nil)
    }

    @objc fileprivate func themeChanged() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.changeColors()
        }
    }

    @objc public func changeColors() {
        tintColor = darkMode ? .white : .textBlack
    }
}
