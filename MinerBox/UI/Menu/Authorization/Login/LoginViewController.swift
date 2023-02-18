//
//  LoginViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/27/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import WidgetKit

class LoginViewController: BaseViewController {
    
    // MARK: - Views
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    
    @IBOutlet fileprivate weak var emailTextField: CustomTextField!
    @IBOutlet fileprivate weak var passwordTextField: CustomTextField!
    
    @IBOutlet fileprivate weak var loginButton: BackgroundButton!
    
    @IBOutlet fileprivate weak var signupButton: LoginButton!
    @IBOutlet fileprivate weak var forgotPasswordButton: LoginButton!
    
    @IBOutlet fileprivate weak var skipButton: LoginButton!
    
    @IBOutlet var logo: UIImageView!
    public var isSignUpState = false
    
    // MARK: - Static
    static func initializeStoryboard() -> LoginViewController? {
        return UIStoryboard(name: "Authorization", bundle: nil).instantiateViewController(withIdentifier: LoginViewController.name) as? LoginViewController
    }
    
    static func initializeNavigationStoryboard() -> BaseNavigationController? {
        return UIStoryboard(name: "Authorization", bundle: nil).instantiateViewController(withIdentifier: "LoginNavigationController") as? BaseNavigationController
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
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

// MARK: - Startup default setup
extension LoginViewController {
    fileprivate func startupSetup() {
        addGestureRecognizers()
        setupUI()
    }
    
    override func languageChanged() {
        title = "login_login".localized()
    }
    
    fileprivate func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
}

// MARK: - Setup UI
extension LoginViewController {
    fileprivate func setupUI() {
        configTextFields()
        configButtons()
        configSkipButton()
        configLogo()
    }
    
    fileprivate func configLogo() {
        let iconName = Date().isChristmasDay ? "christmasLogo" : "logo"
        logo.image = UIImage(named: iconName)
    }
    
    fileprivate func configTextFields() {
        emailTextField.delegate = self
        emailTextField.changeKeyboardType(to: .email)
        emailTextField.changeDoneButton(to: .next)
        emailTextField.setPlaceholder("login_email")
        
        passwordTextField.delegate = self
        passwordTextField.changeKeyboardType(to: .password)
        passwordTextField.changeDoneButton(to: .done)
        passwordTextField.setPlaceholder("password")
    }
    
    fileprivate func configButtons() {
        loginButton.clipsToBounds = true
        loginButton.layer.cornerRadius = 15
        loginButton.changeFontSize(to: 17)
        loginButton.changeFont(to: Constants.semiboldFont)
        
        // Title
        skipButton.setLocalizedTitle("login_skip")
        loginButton.setLocalizedTitle("login_login")
        signupButton.setLocalizedTitle("login_sign_up")
        forgotPasswordButton.setLocalizedTitle("login_forgot_password")
        
        // Target
        loginButton.addTarget(self, action: #selector(loginButtonAction(_:)), for: .touchUpInside)
        signupButton.addTarget(self, action: #selector(signUpButtonAction(_:)), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipButtonAction(_:)), for: .touchUpInside)
        
        skipButton.changeFontSize(to: 15)
        forgotPasswordButton.changeFontSize(to: 15)
        signupButton.changeFontSize(to: 15)
    }
    
    fileprivate func configSkipButton() {
        if navigationController?.viewControllers.first != self && !isSignUpState {
            skipButton.isHidden = true
        } else if navigationController?.viewControllers.count ?? 0 > 2 && isSignUpState {
            skipButton.isHidden = true
        }
    }
}

// MARK: - TextField methods
extension LoginViewController: BaseTextFieldDelegate {
    func textFieldShouldReturn(_ textField: CustomTextField) {
        switch textField {
        case emailTextField:
            passwordTextField.startEditing()
        case passwordTextField:
            loginButtonAction(loginButton)
        default:
            break
        }
    }
}

// MARK: - Actions
extension LoginViewController {
    @objc fileprivate func tapAction(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    override func keyboardFrameChanged(_ sender: Notification) {
        guard let userInfo = sender.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let bottomInset = view.frame.height - keyboardFrame.origin.y
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
    }
    
    // MARK: UI actions
    @objc fileprivate func loginButtonAction(_ sender: BackgroundButton) {
        // Hide keyboard
        view.endEditing(true)
        
        // Check textfields for valid info
        guard checkFields() else { return }
        
        Loading.shared.startLoading(ignoringActions: true, for: self.view)
        UserRequestsService.shared.login(email: emailTextField.text, password: passwordTextField.text, success: {
            self.skipButtonAction(self.skipButton)
            UserDefaults.standard.set(true, forKey: "isSignUp")
            if #available(iOS 14.0, *) {
                #if arch(arm64) || arch(i386) || arch(x86_64)
                WidgetCenter.shared.reloadAllTimelines()
                #endif
            }
            Loading.shared.endLoading(for: self.view)
        }) { (error) in
            Loading.shared.endLoading(for: self.view)
            self.showAlertView("", message: error, completion: nil)
        }
    }
    
    @objc fileprivate func signUpButtonAction(_ sender: BackgroundButton) {
        if isSignUpState {
            navigationController?.popViewController(animated: true)
        } else {
            guard let controller = SignupViewController.initializeStoryboard() else { return }
            controller.isLoginState = true
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc fileprivate func skipButtonAction(_ sender: BackgroundButton) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let storyboard = UIStoryboard(name: "Animation", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: AnimationViewController.name) as! BaseViewController
        
        if #available(iOS 11.0, *) {
            controller.view.animateSnapshotView()
        }
        
        UserDefaults.standard.set(true, forKey: "isSkip")
        appDelegate.window?.rootViewController = controller
    }
}

// MARK: - Checking
extension LoginViewController {
    fileprivate func checkFields() -> Bool {
        
        // Check for valid email
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        if emailTest.evaluate(with: emailTextField.text) == false {
            showAlertView("", message: "incorrect_email".localized(), completion: nil)
            
            return false
        }
        
        if passwordTextField.text.count < 6 {
            showAlertView("", message: "input_6_and_more_characters".localized(), completion: nil)
            return false
        }
        return true
    }
}

// MARK: - GestureRecognizer methods
extension LoginViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (touch.view is UIButton) == false && (touch.view is UITextField) == false
    }
}
