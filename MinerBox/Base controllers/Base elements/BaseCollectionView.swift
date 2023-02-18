//
//  BaseCollectionView.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 10.12.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit
import Localize_Swift

class BaseCollectionView: UICollectionView {

    // MARK: - Init
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
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
extension BaseCollectionView {
    @objc public func startupSetup() {
        changeColors()
        addObservers()
    }

    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: Notification.Name(Constants.themeChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: Notification.Name(LCLLanguageChangeNotification), object: nil)
    }

    @objc fileprivate func themeChanged() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.changeColors()
        }
    }

    @objc public func changeColors() {
        backgroundColor = darkMode ? .viewDarkBackground : .viewLightBackground
    }

    @objc public func languageChanged() { }
}

