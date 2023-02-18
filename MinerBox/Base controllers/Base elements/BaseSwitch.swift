//
//  BaseSwitch.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/4/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class BaseSwitch: UISwitch {

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
extension BaseSwitch {
    @objc public func startupSetup() {
        changeColors()
        addObservers()
    }

    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeColors), name: Notification.Name(Constants.themeChanged), object: nil)
    }

    @objc public func changeColors() {
        onTintColor = .barSelectedItem
    }
}
