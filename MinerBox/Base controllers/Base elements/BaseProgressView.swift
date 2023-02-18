//
//  BaseProgressView.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/3/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class BaseProgressView: UIProgressView {

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

// MARK: - Startup default setup
extension BaseProgressView {
    fileprivate func startupSetup() {
        addObservers()
        
        changeColors()
    }

    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: Notification.Name(Constants.themeChanged), object: nil)
    }

    @objc public func themeChanged() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.changeColors()
            }
        }
    }

    fileprivate func changeColors() {
        progressTintColor = .barDeselectedItem
    }
}
