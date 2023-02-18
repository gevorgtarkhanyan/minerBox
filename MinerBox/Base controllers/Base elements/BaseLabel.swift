//
//  BaseLabel.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/25/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import Localize_Swift

class BaseLabel: UILabel {

    // MARK: - Properties
    fileprivate var localizableString = ""
    fileprivate var secondString = ""

    fileprivate var baseFont = Constants.regularFont

    public var labelIsTime: Bool = false

    fileprivate var xxx = ""
    fileprivate var yyy = ""

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
        defaultSetup()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Default setup
extension BaseLabel {
    fileprivate func defaultSetup() {
        addObservers()

        changeColors()
        changeFontSize(to: font.pointSize)

        adjustsFontSizeToFitWidth = true
    }

    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: Notification.Name(Constants.themeChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: Notification.Name(LCLLanguageChangeNotification), object: nil)
    }

    @objc public func themeChanged() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.changeColors()
            }
        }
    }

    @objc public func changeColors() {
        textColor = darkMode ? .white : UIColor.black.withAlphaComponent(0.85)
    }

    @objc fileprivate func languageChanged() {
        text = localizableString.localized() + secondString.localized()
        if xxx != "" {
            text = text?.replacingOccurrences(of: "xxx", with: xxx)
        }
        if yyy != "" {
            text = text?.replacingOccurrences(of: "yyy", with: yyy)
        }
    }
}

// MARK: - Set data
extension BaseLabel {
    public func setLocalizableText(_ localizableString: String) {
        self.localizableString = localizableString
        languageChanged()
    }

    public func changeFontSize(to value: CGFloat) {
        font = baseFont.withSize(value)
        adjustsFontSizeToFitWidth = true
    }

    public func addSymbolAfterText(_ symbol: String) {
        secondString = symbol
        languageChanged()
    }

    public func changeFont(to font: UIFont) {
        baseFont = font
        changeFontSize(to: self.font.pointSize)
    }

    public func setOldAndCurrentValues(xxx: String, yyy: String) {
        self.xxx = xxx
        self.yyy = yyy
        languageChanged()
    }
}
