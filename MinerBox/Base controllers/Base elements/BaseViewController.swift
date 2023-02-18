//
//  BaseViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 5/30/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import Localize_Swift

class BaseViewController: UIViewController {
    
    // MARK: - Views
    fileprivate var noDataLabel: BaseLabel?
    public var noDataButton: BackgroundButton?
    fileprivate var maskView: MaskView!
    
    // Change status bar text color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return darkMode ? .lightContent : .default
    }
    
    public var user: UserModel? {
        return DatabaseManager.shared.currentUser
    }
    
    public var isLogedIn: Bool {
        return DatabaseManager.shared.currentUser != nil
    }
    
    public var isSubscribed: Bool {
        return user?.isSubscribted ?? false
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    public var isPageRotationEnabled: Bool = true
    fileprivate var viewWillAppear = false
    
    // MARK: - Safe properties
    public var safeCenter: (centerX: NSLayoutXAxisAnchor, centerY: NSLayoutYAxisAnchor) {
        var centerX = view.centerXAnchor
        var centerY = view.centerYAnchor
        
        if #available(iOS 11, *) {
            centerX = view.safeAreaLayoutGuide.centerXAnchor
            centerY = view.safeAreaLayoutGuide.centerYAnchor
        }
        
        return (centerX: centerX, centerY: centerY)
    }
    
    // MARK: - Life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addObservers()
        
        themeChanged()
        languageChanged()
        controllPageRotation()
        
        changeNavigationTitleStyle()

        configNoDataButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !viewWillAppear else { return }
        viewWillAppear = true
        addKeyboardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let backButton = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        removeKeyboardObservers()
        controllPageRotation()
        viewWillAppear = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        controllPageRotation()
    }
    
    func controllPageRotation() {
        if !isPageRotationEnabled {
            if UIDevice.current.orientation.isLandscape {
                disablePageRotate(.landscape)
            } else {
                disablePageRotate(.portrait)
            }
        } else {
            enablePageRotate()
        }
    }
    
    func configNoDataButton() {
        noDataButton =  BackgroundButton(type: .system)
        noDataButton?.isHidden = true
    }
    
    @objc func openLoginPage(_ sender: Notification) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        if UserDefaults.standard.bool(forKey: "isSignUp") {
            guard let controller = LoginViewController.initializeNavigationStoryboard() else { return }
            appDelegate.setInitialController(controller)
        } else {
            guard let controller = SignupViewController.initializeNavigationStoryboard() else { return }
            appDelegate.setInitialController(controller)
        }
    }
    
    public func disablePageRotate(_ orientationMask: UIInterfaceOrientationMask = .portrait) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.restrictRotation = orientationMask
        
        if orientationMask == .landscape {
            switch orientationMask {
            case .landscapeRight:
                let value = UIInterfaceOrientation.landscapeRight.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
            case .landscapeLeft:
                let value = UIInterfaceOrientation.landscapeLeft.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
            default:
                break
            }
        } else if orientationMask == .portrait {
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
        
        
    }
    
    public func enablePageRotate() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.restrictRotation = .all
    }
    
    public func changeNavigationTitleStyle() {
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Default actions
extension BaseViewController {
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: Notification.Name(LCLLanguageChangeNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: Notification.Name(Constants.themeChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionStatusChanged), name: Notification.Name(Constants.subscriptionStatusChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openLoginPage(_:)), name: .goToLoginPage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goToSubscriptionPage), name: .goToSubscriptionPage, object: nil)
    }
    
    fileprivate func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    fileprivate func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc public func languageChanged() { }
    @objc public func subscriptionStatusChanged() { }
    
    // Keyboard
    @objc public func keyboardFrameChanged(_ sender: Notification) { }
    
    @objc public func keyboardWillShow(_ sender: Notification) {
        DispatchQueue.main.async {
            self.showMaskView()
        }
    }
    
    @objc public func keyboardWillHide(_ sender: Notification) {
        hideKeyboard()
    }
    
    @objc public func themeChanged() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.changeColors()
        }
    }
    
    @objc public func addBackgroundNotificaitonObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationOpenedFromBackground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationEnteredToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc public func applicationOpenedFromBackground(_ sender: Notification) { }
    @objc public func applicationEnteredToBackground(_ sender: Notification) { }
    @objc public func applicationWillResignActive(_ sender: Notification) { }
    
    @objc public func removeBackgroundNotificaitonObserver() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc public func hideKeyboard() {
        view.endEditing(true)
        DispatchQueue.main.async {
            self.removeMaskView()
        }
    }
    
    @objc public func goToSubscriptionPage() {
        guard let vc = ManageSubscriptionViewController.initializeStoryboard() else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    public func goToLoginPage() {
        if UserDefaults.standard.bool(forKey: "isSignUp") {
            guard let vc = LoginViewController.initializeStoryboard() else { return }
            navigationController?.pushViewController(vc, animated: true)
        } else {
            guard let vc = SignupViewController.initializeStoryboard() else { return }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc public func goToPoolAddPage() {
        guard let vc = PoolListViewController.initializeStoryboard() else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    public func getCurrentThread() -> String {
        return String(cString: __dispatch_queue_get_label(nil), encoding: .utf8) ?? "Unknown thread"
    }
    
    public func setCustomTitles(_ titles: [String]) {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.alignment = .fill
        
        for (index, title) in titles.enumerated() {
            let titleLabel = NavigationTitle()
            titleLabel.changeFontSize(to: index == 0 ? 20 : 12)
            titleLabel.textAlignment = .center
            titleLabel.setLocalizableText(title)
            stackView.addArrangedSubview(titleLabel)
        }
        navigationItem.titleView = stackView
    }
    
    public func setCoinChartTitle(coin: CoinModel?) {
        guard let coin = coin else {
            navigationItem.titleView = nil
            title = "coin_settings_graph".localized()
            return
        }
        
        let hStackView = UIStackView(frame: .zero)
        hStackView.spacing = 5
        hStackView.axis = .horizontal
        hStackView.alignment = .fill
        hStackView.distribution = .fill
        
        // ImageView
        let view = UIView()
        hStackView.addArrangedSubview(view)
        
        let whiteView = UIView()
        whiteView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(whiteView)
        
        whiteView.clipsToBounds = true
        whiteView.layer.cornerRadius = 6
        whiteView.backgroundColor = .white
        
        whiteView.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
        whiteView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5).isActive = true
        whiteView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5).isActive = true
        whiteView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5).isActive = true
        
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        whiteView.addSubview(imageView)
        
        imageView.layer.cornerRadius = 6
        imageView.clipsToBounds = true
        imageView.addEqualRatioConstraint()
        imageView.contentMode = .scaleAspectFit
//        let imagePath = coin.icon.contains("http") ? coin.icon : Constants.HttpUrlWithoutApi + "images/coins/" + coin.icon
        imageView.sd_setImage(with: URL(string: coin.iconPath), completed: nil)
        
        imageView.topAnchor.constraint(equalTo: whiteView.topAnchor, constant: 1).isActive = true
        imageView.leftAnchor.constraint(equalTo: whiteView.leftAnchor, constant: 1).isActive = true
        imageView.rightAnchor.constraint(equalTo: whiteView.rightAnchor, constant: -1).isActive = true
        imageView.bottomAnchor.constraint(equalTo: whiteView.bottomAnchor, constant: -1).isActive = true
        
        // Stack
        let vStackView = UIStackView(frame: .zero)
        vStackView.axis = .vertical
        vStackView.alignment = .fill
        vStackView.distribution = .fillEqually
        hStackView.addArrangedSubview(vStackView)
        
        let titles = [coin.name, coin.symbol]
        for (index, title) in titles.enumerated() {
            let titleLabel = NavigationTitle()
            titleLabel.changeFontSize(to: index == 0 ? 20 : 12)
            titleLabel.textAlignment = .center
            titleLabel.setLocalizableText(title)
            vStackView.addArrangedSubview(titleLabel)
        }
        
        navigationItem.titleView = hStackView
    }
    
    func openURL(urlString: String) {
        if let copyRightURL = URL(string: urlString), UIApplication.shared.canOpenURL(copyRightURL) {
            openUrl(url: copyRightURL)
        }
    }
    
    func openUrl(url: URL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    public func showNoDataLabel(with text: String = "no_items_available", forView: UIView? = nil) {
        DispatchQueue.main.async {
            self.addNoDataLabelToView(text: text, forView: forView)
        }
    }
    
    public func hideNoDataLabel() {
        DispatchQueue.main.async {
            self.noDataLabel?.removeFromSuperview()
            self.noDataLabel = nil
        }
    }
    
    fileprivate func addNoDataLabelToView(text: String, forView: UIView? = nil) {
        guard noDataLabel == nil else { return }
        noDataLabel = BaseLabel(frame: .zero)
        noDataLabel?.translatesAutoresizingMaskIntoConstraints = false
        
        if forView != nil {
            forView!.addSubview(noDataLabel!)
            noDataLabel?.centerXAnchor.constraint(equalTo: forView!.centerXAnchor).isActive = true
            noDataLabel?.centerYAnchor.constraint(equalTo: forView!.centerYAnchor).isActive = true
        } else {
           view.addSubview(noDataLabel!)
            noDataLabel?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            noDataLabel?.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        }
        
        noDataLabel?.setLocalizableText(text)
        noDataLabel?.changeFontSize(to: 14)
    }

    @objc func goToCoinAlertPage() {
        if TabBarRuningPage.shared.lastSelectedPage == .coin {
            guard let vc = AddCoinAlertViewController.initializeStoryboard() else { return }
            navigationController?.pushViewController(vc, animated: true)
        }
        UserDefaults.standard.set(Constants.url_open_coinAlert, forKey: Constants.url_open_coinAlert)
        TabBarRuningPage.shared.changePage(to: .coin)
        NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.coin.rawValue)
    }
    @objc func goToFavoriteAddPage() {
        UserDefaults.standard.set(Constants.url_open_coinAlert, forKey: Constants.url_open_add_favorite)
        TabBarRuningPage.shared.changePage(to: .coin)
        NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.coin.rawValue)
    }
    
    @objc func goToAccountPage() {
        UserDefaults.standard.set(Constants.url_open_selectpool, forKey: Constants.url_open_selectpool)
        TabBarRuningPage.shared.changePage(to: .accounts)
        NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.accounts.rawValue)
    }
    
    //MARK: - Mask View
    fileprivate func showMaskView() {
        guard !view.containsTextField else { return }
        
        view.addSubview(maskView!)
        maskView.frame = view.bounds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.moveInputViewsTopLayer(self.view)
        }
    }
    
    fileprivate func removeMaskView() {
        self.maskView.removeFromSuperview()
    }
    
    private func moveInputViewsTopLayer(_ view: UIView) {
        view.subviews.forEach {
            if $0 is UISearchBar || $0 is UITextField {
                self.view.bringSubviewToFront($0)
            }
            moveInputViewsTopLayer($0)
        }
    }
    
}

// MARK: - Setup UI
extension BaseViewController {
    fileprivate func setupUI() {
        changeColors()
        maskView = MaskView(target: self, action: #selector(hideKeyboard))
    }
    
    fileprivate func changeColors() {
        view.backgroundColor = darkMode ? .blackBackground : .white
    }
}
