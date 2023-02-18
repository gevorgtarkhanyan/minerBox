//
//  BaseSearchBar.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/10/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import Localize_Swift

class BaseSearchBar: UISearchBar {
    
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

// MARK: - Default setup
extension BaseSearchBar {
    fileprivate func startupSetup() {
        changeColors()
        addObservers()
    }

    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: NSNotification.Name(Constants.themeChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc fileprivate func themeChanged() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.changeColors()
            }
        }
    }
    
    @objc fileprivate func keyboardWillHide(_ sender: Notification) {
        setCancelButtonEnabled(true)
    }

    fileprivate func changeColors() {
        barStyle = darkMode ? .black : .default
        isTranslucent = false
        barTintColor = darkMode ? .barDark : .barLight
        backgroundColor = darkMode ? .barDark : .barLight
        tintColor = .barSelectedItem
        layoutIfNeeded()

        setBackgroundImage(UIImage(), for: .top, barMetrics: .default)

        languageChanged()
    }

    @objc fileprivate func languageChanged() {
        showsCancelButton = false
        self.setValue("cancel".localized(), forKey: "cancelButtonText")
        showsCancelButton = true

        guard let searchTextField = value(forKey: "searchField") as? UITextField else { return }

        searchTextField.textColor = darkMode ? .white : .textBlack
        searchTextField.keyboardAppearance = darkMode ? .dark : .default

        searchTextField.backgroundColor = .textFieldBackgorund
        searchTextField.layer.shadowColor = UIColor.darkGray.cgColor
        searchTextField.attributedPlaceholder = NSAttributedString(string: "search".localized(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.placeholder])
    }
}

// MARK: - Public func
extension BaseSearchBar {
    public func addBarButtomSeparator() {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        imageView.isUserInteractionEnabled = false
        imageView.backgroundColor = UIColor.white.withAlphaComponent(0.15)

        imageView.heightAnchor.constraint(equalToConstant: 0.33).isActive = true
        imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
    }
}
