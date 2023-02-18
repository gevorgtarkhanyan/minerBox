//
//  BaseNavigationController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/24/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    // Change status bar text color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return darkMode ? .lightContent : .default
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
    }
}

// MARK: - Startup default setup
extension BaseNavigationController {
    fileprivate func startupSetup() {
        changeFont()
        changeColors()
        addObservers()
    }

    fileprivate func changeFont() {
        let attributes: [NSAttributedString.Key: Any] = [.font: Constants.semiboldFont.withSize(20), .foregroundColor: UIColor.barSelectedItem]
        navigationBar.titleTextAttributes = attributes
    }

    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: Notification.Name(Constants.themeChanged), object: nil)
    }
    
    private func setupNavigationBar() {
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor =  darkMode ? .barDark : .barLight
            appearance.shadowColor = .clear
            appearance.titleTextAttributes = [.font:
            UIFont.boldSystemFont(ofSize: 20.0),
                                              .foregroundColor: #colorLiteral(red: 0.1176470588, green: 0.5960784314, blue: 0.6078431373, alpha: 1)] // barSelectedItem
            // Customizing our navigation bar
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        }
    }

    @objc fileprivate func themeChanged() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.changeColors()
        }
    }
}

// MARK: - Actions
extension BaseNavigationController {
    fileprivate func changeColors() {
        setupNavigationBar()
        navigationBar.barStyle = darkMode ? .black : .default
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = darkMode ? .barDark : .barLight
        navigationBar.tintColor = .barSelectedItem
        navigationBar.layoutIfNeeded()
        view.backgroundColor = darkMode ? .barDark : .barLight

        if #available(iOS 11.0, *) {
            navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.barSelectedItem]
        }
    }
}
