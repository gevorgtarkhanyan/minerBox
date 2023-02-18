//
//  ChangePasswordViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/9/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class ChangePasswordViewController: BaseViewController {

    // MARK: - Views
    @IBOutlet fileprivate weak var scrollView: UIScrollView!

    @IBOutlet fileprivate weak var oldPasswordTextField: BaseTextField!
    @IBOutlet fileprivate weak var newPasswordTextField: BaseTextField!
    @IBOutlet fileprivate weak var retypePasswordTextField: BaseTextField!

    // MARK: - Properties
    fileprivate var saveButton: UIBarButtonItem!

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
    }

    override func languageChanged() {
        saveButton?.title = "save".localized()
        title = "change_password".localized()
    }

    // MARK: - Keyboard notifications
    override func keyboardFrameChanged(_ sender: Notification) {
        guard let userInfo = sender.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let bottomInset = view.frame.height - keyboardFrame.origin.y
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
    }
}

// MARK: - Startup default setup
extension ChangePasswordViewController {
    fileprivate func startupSetup() {
        configTextFields()

        saveButton = UIBarButtonItem(title: "save".localized(), style: .done, target: self, action: #selector(saveButtonAction(_:)))
        navigationItem.setRightBarButton(saveButton, animated: true)
    }

    fileprivate func configTextFields() {
        oldPasswordTextField.setPlaceholder("old_password")
        newPasswordTextField.setPlaceholder("new_password")
        retypePasswordTextField.setPlaceholder("retype_password")

        oldPasswordTextField.isSecureTextEntry = true
        newPasswordTextField.isSecureTextEntry = true
        retypePasswordTextField.isSecureTextEntry = true
    }
}

// MARK: - Actions
extension ChangePasswordViewController {

    fileprivate func checkTextFields() -> Bool {
        guard
            let oldPassword = oldPasswordTextField.text,
            let retypePassword = retypePasswordTextField.text,
            let newPassword = newPasswordTextField.text else {
                return false
        }

        if oldPassword.count < 6 || newPassword.count < 6 {
            showAlertView("", message: "input_6_and_more_characters".localized(), completion: nil)
            return false
        }

        if newPassword != retypePassword {
            self.showToastAlert("incorrect_repeat_password".localized(), message: nil)
            return false
        }

        return true
    }

    // MARK: - UI actions
    @objc fileprivate func saveButtonAction(_ sender: Any?) {
        self.view.endEditing(true)
        guard
        checkTextFields(),
            let _ = newPasswordTextField.text,
            let oldPassword = oldPasswordTextField.text,
            let retypePassword = retypePasswordTextField.text
            else { return }

        Loading.shared.startLoading(ignoringActions: true, for: self.view)
        UserRequestsService.shared.changePassword(oldPassword: oldPassword, newPassword: retypePassword, success: {
            Loading.shared.endLoading(for: self.view)
            self.showToastAlert("", message: "successfully_updated".localized(), finished: {
                self.navigationController?.popViewController(animated: true)
            })
        }) { (error) in
            Loading.shared.endLoading(for: self.view)
            self.showAlertView("", message: error, completion: nil)
        }
    }
}

// MARK: TextField delegate
extension ChangePasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case oldPasswordTextField:
            newPasswordTextField.becomeFirstResponder()
        case newPasswordTextField:
            retypePasswordTextField.becomeFirstResponder()
        case retypePasswordTextField:
            saveButtonAction(nil)
        default:
            break
        }
        return true
    }
}
