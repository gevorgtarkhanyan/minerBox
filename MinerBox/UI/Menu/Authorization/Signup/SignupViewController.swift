//
//  SignupViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/22/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class SignupViewController: BaseViewController {

    // MARK: - Views
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    @IBOutlet fileprivate weak var usernameTextField: BaseTextField!
    @IBOutlet fileprivate weak var emailTextField: BaseTextField!

    @IBOutlet fileprivate weak var passwordTextField: BaseTextField!
    @IBOutlet fileprivate weak var retypePasswordTextField: BaseTextField!

    @IBOutlet fileprivate weak var registerButton: BackgroundButton!
    @IBOutlet fileprivate weak var loginButton: LoginButton!
    @IBOutlet fileprivate weak var skipButton: LoginButton!
    @IBOutlet var logo: UIImageView!
    
    public var isLoginState = false
    public var skipIsHidden = false
    
    // MARK: - Static
    static func initializeStoryboard() -> SignupViewController? {
        return UIStoryboard(name: "Authorization", bundle: nil).instantiateViewController(withIdentifier: SignupViewController.name) as? SignupViewController
    }
    
    static func initializeNavigationStoryboard() -> BaseNavigationController? {
        guard let controller = SignupViewController.initializeStoryboard() else { return nil }
        return BaseNavigationController(rootViewController: controller)
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
extension SignupViewController {
    fileprivate func startupSetup() {
        addGestureRecognizers()

        setupUI()
    }

    override func languageChanged() {
        title = "login_sign_up".localized()
    }

    fileprivate func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tap.delegate = self
        scrollView.addGestureRecognizer(tap)
    }
}

// MARK: - Setup UI
extension SignupViewController {
    fileprivate func setupUI() {
        configTextFields()
        configButtons()
        configLogo()
    }
    
    fileprivate func configLogo() {
        let iconName = Date().isChristmasDay ? "christmasLogo" : "logo"
        logo.image = UIImage(named: iconName)
    }

    fileprivate func configTextFields() {
        usernameTextField.delegate = self
        usernameTextField.setPlaceholder("username_optional")
        emailTextField.delegate = self
        emailTextField.setPlaceholder("login_email")

        passwordTextField.delegate = self
        passwordTextField.setPlaceholder("password")

        retypePasswordTextField.delegate = self
        retypePasswordTextField.setPlaceholder("retype_password")
    }

    fileprivate func configButtons() {
        registerButton.clipsToBounds = true
        registerButton.layer.cornerRadius = 15
        registerButton.changeFontSize(to: 17)
        registerButton.changeFont(to: Constants.semiboldFont)
        skipButton.changeFontSize(to: 15)
        loginButton.changeFontSize(to: 15)

        // Title
        registerButton.setLocalizedTitle("register")
        loginButton.setLocalizedTitle("login_login")
        skipButton.setLocalizedTitle("login_skip")
        
        // Target
        registerButton.addTarget(self, action: #selector(registerButtonAction(_:)), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonAction(_:)), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipButtonAction(_:)), for: .touchUpInside)
        
        if navigationController?.viewControllers.first != self && !isLoginState {
            skipButton.isHidden = true
        } else if navigationController?.viewControllers.count ?? 0 > 2 && isLoginState {
            skipButton.isHidden = true
        }
    }
}

// MARK: - Actions
extension SignupViewController {
    override func keyboardFrameChanged(_ sender: Notification) {
        guard let userInfo = sender.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let bottomInset = view.frame.height - keyboardFrame.origin.y
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
    }

    @objc fileprivate func registerButtonAction(_ sender: BackgroundButton) {
        // Hide keyboard
        view.endEditing(true)

        // Check textfields for valid info
        guard checkFields() else { return }

        Loading.shared.startLoading(ignoringActions: true, for: self.view)
        UserRequestsService.shared.register(email: emailTextField.text ?? "", name: usernameTextField.text ?? "", password: passwordTextField.text ?? "", success: {
            Loading.shared.endLoading(for: self.view)
            self.successRegister()
        }) { (error) in
            Loading.shared.endLoading(for: self.view)
            self.showAlertView("", message: error, completion: nil)
        }
    }
    
    @objc fileprivate func loginButtonAction(_ sender: LoginButton) {
        if isLoginState {
            navigationController?.popViewController(animated: true)
        } else {
            guard let controller = LoginViewController.initializeStoryboard() else { return }
            
            controller.isSignUpState = true
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc fileprivate func skipButtonAction(_ sender: LoginButton) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let storyboard = UIStoryboard(name: "Animation", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: AnimationViewController.name) as! BaseViewController
        
        if #available(iOS 11.0, *) {
            controller.view.animateSnapshotView()
        }
        
        UserDefaults.standard.set(true, forKey: "isSkip")
        appDelegate.window?.rootViewController = controller
    }
    
    @objc fileprivate func tapAction(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    fileprivate func successRegister() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let storyboard = UIStoryboard(name: "Animation", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: AnimationViewController.name) as! BaseViewController

        if #available(iOS 11.0, *) {
            controller.view.animateSnapshotView()
        }
        
        UserDefaults.standard.set(true, forKey: "isSignUp")
        appDelegate.window?.rootViewController = controller
    }
    
}

// MARK: - TextField delegate
extension SignupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            retypePasswordTextField.becomeFirstResponder()
        case retypePasswordTextField:
            registerButtonAction(registerButton)
        default:
            break
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                           replacementString string: String) -> Bool
    {
        if textField == usernameTextField  {
            let maxLength = 64
            let currentString: NSString = usernameTextField.text! as NSString
            let newString: NSString =  currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        } else {
            return true
        }
       
    }
}

// MARK: - Tap gesture delegate
extension SignupViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (touch.view is BaseTextField) == false && (touch.view is BackgroundButton) == false
    }
}

// MARK: - Checking
extension SignupViewController {
    fileprivate func checkFields() -> Bool {

        // Email
        guard emailTextField.text != "" else {
            emailTextField.animateWithShake()
            return false
        }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        if emailTest.evaluate(with: emailTextField.text) == false {
            showAlertView("", message: "incorrect_email", completion: nil)
            return false
        }
        if let usernameText = usernameTextField.text, usernameText.count < 1  {
            let index = emailTextField.text!.firstIndex(of: "@")
            usernameTextField.text = String(emailTextField.text![..<index!])
        }
        //Password
        
        guard let passwordText = passwordTextField.text, passwordText != "" else {
            passwordTextField.animateWithShake()
            return false
        }
        
        guard passwordText.count > 5 else {
            showAlertView("", message: "input_6_and_more_characters", completion: nil)
            return false
        }
        
        guard let retypePasswordText = retypePasswordTextField.text, retypePasswordText != ""  else {
            retypePasswordTextField.animateWithShake()
            return false
        }
        
        guard retypePasswordText == passwordText  else {
            showAlertView("", message: "incorrect_repeat_password", completion: nil)
            return false
        }
        
        guard retypePasswordText.count > 5  else {
            showAlertView("", message: "input_6_and_more_characters", completion: nil)
            return false
        }

        return true
    }
}
