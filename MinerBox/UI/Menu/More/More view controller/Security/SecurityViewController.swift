//
//  SecurityViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/19/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import LocalAuthentication
import TOPasscodeViewController

class SecurityViewController: BaseViewController {

    // MARK: - Views
    @IBOutlet fileprivate weak var tableView: BaseTableView!

    // MARK: - Properties
    fileprivate var tableData = SecurityTableEnum.getTableData()
    fileprivate var enteredPin: String?

    // MARK: - Static
    static func initializeStoryboard() -> SecurityViewController? {
        return UIStoryboard(name: "More", bundle: nil).instantiateViewController(withIdentifier: SecurityViewController.name) as? SecurityViewController
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func languageChanged() {
        title = MoreSettingsEnum.security.rawValue.localized()
    }
}

// MARK: - Actions
extension SecurityViewController {
    func showPassCode() {
        let pinController = TOPasscodeViewController(style: .translucentDark, passcodeType: .fourDigits)
        pinController.passcodeView.titleLabel.text = PasscodeTitleEnum.create.rawValue.localized()
        pinController.delegate = self
        present(pinController, animated: true, completion: nil)
    }
}

// MARK: - TableView methods
extension SecurityViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SecurityTableViewCell.name) as! SecurityTableViewCell

        let item = tableData[indexPath.row]
        let switchOn = UserDefaults.standard.bool(forKey: "security_use_\(item.rawValue)")

        cell.delegate = self
        cell.setData(str: item.rawValue, switchOn: switchOn, indexPath: indexPath)

        return cell
    }
}

// MARK: - Cell delegate
extension SecurityViewController: SecurityTableViewCellDelegate {
    func switchTapped(indexPath: IndexPath, sender: BaseSwitch) {
        let item = tableData[indexPath.row]

        switch item {
        case .usePin:
            if sender.isOn {
                showPassCode()
            } else {
                UserDefaults.standard.set(false, forKey: "security_use_\(SecurityTableEnum.usePin.rawValue)")
                UserDefaults.standard.set(false, forKey: "security_use_\(SecurityTableEnum.useBiometry.rawValue)")
                UserDefaults.standard.removeObject(forKey: "pin_code")
                tableView.reloadData()
            }
        case .useBiometry:
            if sender.isOn {
                if UserDefaults.standard.bool(forKey: "security_use_\(SecurityTableEnum.usePin.rawValue)") == false {
                UserDefaults.standard.set(sender.isOn, forKey: "security_use_\(SecurityTableEnum.useBiometry.rawValue)")
                UserDefaults.standard.set(sender.isOn, forKey: "security_use_\(SecurityTableEnum.usePin.rawValue)")
                showPassCode()
                } else {
                    UserDefaults.standard.set(sender.isOn, forKey: "security_use_\(SecurityTableEnum.useBiometry.rawValue)")
                }
            } else {
                UserDefaults.standard.set(false, forKey: "security_use_\(SecurityTableEnum.useBiometry.rawValue)")
                UserDefaults.standard.removeObject(forKey: "pin_code")
            }
            
      }
   }
}

// MARK: - Passcode Controller delegate
extension SecurityViewController: TOPasscodeViewControllerDelegate {
    func didTapCancel(in passcodeViewController: TOPasscodeViewController) {
        enteredPin = nil
        if let index = tableData.firstIndex(of: .usePin), let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? SecurityTableViewCell {
            cell.changeSwitchState(to: false)
        }
        if let index = tableData.firstIndex(of: .useBiometry), let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? SecurityTableViewCell {
            UserDefaults.standard.set(false, forKey: "security_use_\(SecurityTableEnum.usePin.rawValue)")
            UserDefaults.standard.set(false, forKey: "security_use_\(SecurityTableEnum.useBiometry.rawValue)")
            UserDefaults.standard.removeObject(forKey: "pin_code")
            cell.changeSwitchState(to: false)
            
        }
        passcodeViewController.dismiss(animated: true, completion: nil)
    }

    func passcodeViewController(_ passcodeViewController: TOPasscodeViewController, isCorrectCode code: String) -> Bool {
        switch passcodeViewController.passcodeView.titleLabel.text {
        case PasscodeTitleEnum.create.rawValue.localized():
            enteredPin = code
            return true
        case PasscodeTitleEnum.retype.rawValue.localized():
            if enteredPin == code {
                UserDefaults.standard.set(code, forKey: "pinCode")
                UserDefaults.standard.set(true, forKey: "security_use_\(SecurityTableEnum.usePin.rawValue)")
                self.enteredPin = nil
                tableView.reloadData()
                return true
            } else {
                return false
            }
        default:
            return true
        }
    }

    func didInputCorrectPasscode(in passcodeViewController: TOPasscodeViewController) {
        switch passcodeViewController.passcodeView.titleLabel.text {
        case PasscodeTitleEnum.create.rawValue.localized():
            passcodeViewController.passcodeView.titleLabel.text = PasscodeTitleEnum.retype.rawValue.localized()
            passcodeViewController.passcodeView.resetPasscode(animated: false, playImpact: true)
        case PasscodeTitleEnum.retype.rawValue.localized():
            self.dismiss(animated: true, completion: nil)
        default:
            return
        }
    }
}

// MARK: - Helpers
enum SecurityTableEnum: String {
    case usePin = "pin_lock"
    case useBiometry = "use_biometry_type"
    
    static func getTableData() -> [SecurityTableEnum] {
        if SecurityBiometryType.shared.getBiometryType() == .none {
            return [.usePin]
        }
        return [.usePin, .useBiometry]
    }
 }

enum PasscodeTitleEnum: String {
    case create = "create_pin"
    case retype = "retype_pin"
}
