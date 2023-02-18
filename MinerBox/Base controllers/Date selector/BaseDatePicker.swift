//
//  BaseDatePicker.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/3/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import Localize_Swift

class BaseDatePicker: UIDatePicker {

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
extension BaseDatePicker {
    fileprivate func startupSetup() {
        addObservers()
        timeZone = .current
        datePickerMode = .dateAndTime
        changeColors()
        languageChanged()
        setStyle()
    }
    
    private func setStyle() {
        if #available(iOS 14.0, *) {
            preferredDatePickerStyle = .inline
            overrideUserInterfaceStyle = darkMode ? .dark : .light
            tintColor = .barSelectedItem
        } else if #available(iOS 13.4, *) {
            preferredDatePickerStyle = .wheels
            setValue(false, forKey: "highlightsToday")
        }
    }

    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: Notification.Name(Constants.themeChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: Notification.Name(LCLLanguageChangeNotification), object: nil)
    }

    @objc fileprivate func themeChanged() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.changeColors()
            }
        }
    }

    fileprivate func changeColors() {
        if #available(iOS 14.0, *) {
            backgroundColor = .clear
        } else {
            backgroundColor = darkMode ? .barDark : .barLight
        }
        layoutSubviews()
    }

    @objc fileprivate func languageChanged() {
        locale = Locale(identifier: Localize.currentLanguage())
    }
}
