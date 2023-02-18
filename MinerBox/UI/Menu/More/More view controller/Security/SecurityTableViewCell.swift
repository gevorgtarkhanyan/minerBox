//
//  SecurityTableViewCell.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/19/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

protocol SecurityTableViewCellDelegate: AnyObject {
    func switchTapped(indexPath: IndexPath, sender: BaseSwitch)
}

class SecurityTableViewCell: BaseTableViewCell {

    // MARK: - Views
    @IBOutlet fileprivate weak var label: BaseLabel!
    @IBOutlet fileprivate weak var actionSwitch: BaseSwitch!
    // MARK: - Properties
    weak var delegate: SecurityTableViewCellDelegate?
    fileprivate var indexPath: IndexPath = .zero
    fileprivate var cellEnabled: Bool = true

    // MARK: - Startup
    override func startupSetup() {
        super.startupSetup()
        addTapRecognizer()

        actionSwitch.addTarget(self, action: #selector(switchAction(_:)), for: .valueChanged)
    }

    fileprivate func addTapRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        addGestureRecognizer(tap)
    }
}

// MARK: - Actions
extension SecurityTableViewCell {
    @objc fileprivate func switchAction(_ sender: BaseSwitch) {
        delegate?.switchTapped(indexPath: indexPath, sender: sender)
    }

    @objc fileprivate func tapAction(_ sender: UITapGestureRecognizer) {
        actionSwitch.setOn(!actionSwitch.isOn, animated: true)
        switchAction(actionSwitch)
    }

    fileprivate func setCellEnabled(_ enabled: Bool) {
        cellEnabled = enabled
//        UIView.animate(withDuration: Constants.animationDuration) {
//            self.label.alpha = self.cellEnabled ? 1 : 0.5
//            self.actionSwitch.alpha = self.cellEnabled ? 1 : 0.5
//        }
    }
}

// MARK: - Set data
extension SecurityTableViewCell {
    public func setData(str: String, switchOn: Bool, indexPath: IndexPath) {
        self.indexPath = indexPath
        actionSwitch.setOn(switchOn, animated: true)

        if str == "use_biometry_type" {
            label.setLocalizableText("use_pin")
            label.addSymbolAfterText(" " + SecurityBiometryType.shared.getBiometryType().rawValue)

            setCellEnabled(UserDefaults.standard.bool(forKey: "security_use_\(SecurityTableEnum.usePin.rawValue)"))
        } else {
            label.setLocalizableText(str)
            label.addSymbolAfterText("")
            setCellEnabled(true)
        }
    }

    public func changeSwitchState(to state: Bool) {
        actionSwitch.setOn(state, animated: true)
    }
}
