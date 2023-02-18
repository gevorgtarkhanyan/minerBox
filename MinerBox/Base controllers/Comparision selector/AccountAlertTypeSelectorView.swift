//
//  AccountAlertTypeSelectorView.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/8/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import Localize_Swift

protocol AccountAlertTypeSelectorViewDelegate: AnyObject {
    func accountAlertTypeSelected(_ type: AccountAlertType)
}

class AccountAlertTypeSelectorView: BaseView {

    // MARK: - Views
    fileprivate var stackView: UIStackView!

    // MARK: - Properties
    weak var delegate: AccountAlertTypeSelectorViewDelegate?
    
    fileprivate let types = AccountAlertType.allCases

    // MARK: - Startup default setup
    override func startupSetup() {
        super.startupSetup()
        setupUI()
    }
    
    override func languageChanged() {
        stackView = nil
        setupUI()
    }
}

// MARK: - Setup UI
extension AccountAlertTypeSelectorView {
    fileprivate func setupUI() {
        addStack()
        addButtons()
    }

    fileprivate func addStack() {
        stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        stackView.spacing = 1
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually

        stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 1).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
    }

    fileprivate func addButtons() {
        for (index, type) in types.enumerated() {
            let button = UIButton(frame: .zero)
            button.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(button)

            button.tag = index
            button.backgroundColor = darkMode ? .barDark : .barLight
            button.setTitleColor(darkMode ? .white : .textBlack, for: .normal)
            button.setTitle(type.rawValue.localized(), for: .normal)
            button.titleLabel?.font = Constants.regularFont.withSize(23)
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        }
    }
}

// MARK: - Actions
extension AccountAlertTypeSelectorView {
    @objc fileprivate func buttonAction(_ sender: UIButton) {
        guard types.indices.contains(sender.tag) else { return }
        delegate?.accountAlertTypeSelected(types[sender.tag])
    }
}
