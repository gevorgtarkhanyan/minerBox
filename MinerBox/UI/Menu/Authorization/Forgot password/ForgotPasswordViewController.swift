//
//  ForgotPasswordViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/22/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: BaseViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var emailTextField: BaseTextField!
    @IBOutlet private weak var receiveCodeButton: BackgroundButton!
    @IBOutlet private weak var verificaitonCodeTextField: BaseTextField!
    @IBOutlet private weak var verifyButton: BackgroundButton!
    @IBOutlet private weak var passwordTextField: BaseTextField!
    @IBOutlet private weak var retypePasswordTextField: BaseTextField!

    @IBOutlet private weak var updateButton: BackgroundButton!

    private var userId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
        
        if let email = UserDefaults.standard.value(forKey: "email_received") as? String {
            emailTextField.text = email
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        disablePageRotate()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        enablePageRotate()
    }
}

extension ForgotPasswordViewController {
    private func startupSetup() {
        addGestureRecognizers()

        setupUI()
    }

    override func languageChanged() {
        title = "login_forgot_password".localized()
    }

    fileprivate func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tap.delegate = self
        scrollView.addGestureRecognizer(tap)
    }
}

extension ForgotPasswordViewController {
    private func setupUI() {
        configTextFields()
        configButtons()
    }

    private func configTextFields() {
        emailTextField.delegate = self
        emailTextField.setPlaceholder("login_email")

        verificaitonCodeTextField.delegate = self
        verificaitonCodeTextField.setPlaceholder("verification_code")

        passwordTextField.delegate = self
        passwordTextField.setPlaceholder("password")

        retypePasswordTextField.delegate = self
        retypePasswordTextField.setPlaceholder("retype_password")
    }

    private func configButtons() {
        [receiveCodeButton, verifyButton, updateButton].forEach { (button) in
            button?.clipsToBounds = true
            button?.layer.cornerRadius = 15
            button?.changeFontSize(to: 17)
            button?.changeFont(to: Constants.semiboldFont)
        }
        receiveCodeButton.setLocalizedTitle("receive_code")
        verifyButton.setLocalizedTitle("verify")
        updateButton.setLocalizedTitle("update")

        receiveCodeButton.addTarget(self, action: #selector(receiveCodeButtonAction(_:)), for: .touchUpInside)
        verifyButton.addTarget(self, action: #selector(verifyButtonAction(_:)), for: .touchUpInside)
        updateButton.addTarget(self, action: #selector(updateButtonAction(_:)), for: .touchUpInside)
    }
}

// MARK: - TextField delegate
extension ForgotPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            receiveCodeButtonAction(receiveCodeButton)
        case verificaitonCodeTextField:
            verifyButtonAction(verifyButton)
        case passwordTextField:
            retypePasswordTextField.becomeFirstResponder()
        case retypePasswordTextField:
            updateButtonAction(updateButton)
        default:
            break
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField {
            if let text = textField.text, text.count > 4 {
                UserDefaults.standard.setValue(emailTextField.text, forKeyPath: "email_received")
            }
        }
    }
}

// MARK: - Actions
extension ForgotPasswordViewController {
    @objc fileprivate func receiveCodeButtonAction(_ sender: BackgroundButton) {
        view.endEditing(true)
        guard checkEmail(), let emailText = emailTextField.text else { return }

        Loading.shared.startLoading(ignoringActions: true, for: self.view)
        UserRequestsService.shared.passwordReset(email: emailText, success: {
            self.showAlertView("", message: "email_sended", completion: nil)
            Loading.shared.endLoading(for: self.view)
        }, failer: { (error) in
            Loading.shared.endLoading(for: self.view)
            self.showAlertView("", message: error, completion: nil)
        })
    }

    @objc fileprivate func verifyButtonAction(_ sender: BackgroundButton) {
        view.endEditing(true)
        
        if let emailText = emailTextField.text, checkEmail() {
            if let passcode = verificaitonCodeTextField.text, passcode.count > 5 {
                Loading.shared.startLoading(ignoringActions: true, for: self.view)
                UserRequestsService.shared.checkPassCode(email: emailText, passCode: passcode, userId: { (successIdString) in
                    if successIdString != "" {
                        self.updateButton.alpha = 1.0
                        self.updateButton.isEnabled = true
                        self.passwordTextField.alpha = 1.0
                        self.passwordTextField.isEnabled = true
                        self.retypePasswordTextField.alpha = 1.0
                        self.retypePasswordTextField.isEnabled = true
                        
                        self.userId = successIdString
                        sender.backgroundColor = . workerGreen
                        Loading.shared.endLoading(for: self.view)
                    } else {
                        Loading.shared.endLoading(for: self.view)
                    }
                }, failer: { (error) in
                    sender.backgroundColor = . workerRed
                    Loading.shared.endLoading(for: self.view)
                    self.showAlertView("", message: error, completion: nil)
                })
            } else {
                showAlertView("", message: "incorrect_pass_code", completion: nil)
            }
        }
    }

    @objc fileprivate func updateButtonAction(_ sender: BackgroundButton) {
        view.endEditing(true)
        guard let email = emailTextField.text, let passCode = verificaitonCodeTextField.text, let password = passwordTextField.text, let retypePassword = retypePasswordTextField.text, let userId = self.userId else {
            return
        }
        guard password == retypePassword else {
            showAlertView("", message: "incorrect_repeat_password".localized(), completion: nil)
            return
        }

        Loading.shared.startLoading(ignoringActions: true, for: self.view)
        UserRequestsService.shared.updatePasswordPost(email: email, passCode: passCode, userID: userId, newPassword: password, successString: { (successString) in
            self.showToastAlert("", message: successString, finished: {
                self.navigationController?.popToRootViewController(animated: true)
            })
            Loading.shared.endLoading(for: self.view)
        }, failer: { (error) in
            Loading.shared.endLoading(for: self.view)
            self.showAlertView("", message: error, completion: nil)
        })
    }

    @objc fileprivate func tapAction(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    override func keyboardFrameChanged(_ sender: Notification) {
        guard let userInfo = sender.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let bottomInset = view.frame.height - keyboardFrame.origin.y
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
    }
}

// MARK: - Tap gesture delegate
extension ForgotPasswordViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (touch.view is BaseTextField) == false && (touch.view is BackgroundButton) == false
    }
}

// MARK: - Checking
extension ForgotPasswordViewController {
    fileprivate func checkEmail() -> Bool {
        
        // Check for valid email
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        if emailTest.evaluate(with: emailTextField.text) == false {
            showAlertView("login_email", message: "incorrect_email", completion: nil)
            return false
        }
        return true
    }
}
