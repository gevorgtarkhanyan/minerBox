//
//  AppDelegate.swift
//  MinerBox
//
//  Created by Haykaz Melikyan on 7/4/18.
//  Copyright © 2018 WitPlex. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDynamicLinks
import UserNotifications
import RealmSwift

// Passcode
import LocalAuthentication
import TOPasscodeViewController


@UIApplicationMain
  class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Properties
    var window: UIWindow?
    let notificationDelegate = SampleNotificationDelegate()
    var restrictRotation: UIInterfaceOrientationMask = .portrait
    var isAppLaunchedFirst = true
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    // MARK: - Application life cycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupRateApp()
        changeAppIcon()
        
        // Check realm migration
        DatabaseManager.shared.migrateRealm()
        // checkRealmMigration()
        
        // Start firebase crash reporting
        FirebaseApp.configure()
        //Fabric.sharedSDK().debug = true
        
        // Register for push notifications
        registerForPushNotifications()
        
        // Send device info to backend
        var appVersion = "Unknown application version"
        if let info = Bundle.main.infoDictionary, let shortVersion = info["CFBundleShortVersionString"] as? String {
            appVersion = shortVersion
        }
        let sendDeviceInfoTimer = TimerManager.shared.isLoadingTime(item: .sendDeviceInfo)
        if sendDeviceInfoTimer || appVersion != UserDefaults.standard.string(forKey: "appVersion"){
            UserRequestsService.shared.sendDeviceInfo(force: true)
        } else {
            UserRequestsService.shared.sendDeviceInfo()
        }
        clearNotifications(application)
        
        // If subscription send to backend is failed, try to resend
        if UserDefaults.standard.bool(forKey: "subscriptionSendFiled"), let subscriptionId = UserDefaults.standard.string(forKey: "arentSendedSubscriptionId") {
            SubscriptionService.shared.addSubsriptionToServer(subscriptionId: subscriptionId, success: { }) { (_) in }
        }
        
        // Config root page if pin enabled or loged in or not
        configRootPage()
        
        // Add listener for logout if user loged in from other device
        NotificationCenter.default.addObserver(self, selector: #selector(userLogout(_:)), name: Notification.Name(rawValue: Constants.userLogout), object: nil)
        
        return true
    }
    
    func changeAppIcon() {
        if #available(iOS 10.3, *) {
            let app = UIApplication.shared
            if app.supportsAlternateIcons {
                let iconName: String? = Date().isChristmasDay ? "ChristmasIcon" : nil
                guard app.alternateIconName != iconName else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    app.setAlternateIconName(iconName, completionHandler: nil)
//                    self.setApplicationIconName(iconName)
                }
            }
        }
    }
    
    func setApplicationIconName(_ iconName: String?) {
        if #available(iOS 10.3, *) {
            if UIApplication.shared.responds(to: #selector(getter: UIApplication.shared.supportsAlternateIcons)) {
                typealias setAlternateIconName = @convention(c) (NSObject, Selector, NSString?, @escaping (NSError) -> ()) -> ()
                
                let selectorString = "_setAlternateIconName:completionHandler:"
                let selector = NSSelectorFromString(selectorString)
                let imp = UIApplication.shared.method(for: selector)
                let method = unsafeBitCast(imp, to: setAlternateIconName.self)
                method(UIApplication.shared, selector, iconName as NSString?, { _ in })
            }
        }
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
               self.handleIncomingDynamicLink(dynamicLink)
           } else {
               let components = url.path.components(separatedBy: ",")
               if components.count < 2 {
                   handleTodayExtension(url)
               } else {
                   handleWidgetKitExtension(urlPathComonents: components)
               }
           }
           return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
      return application(app, open: url,
                         sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                         annotation: "")
    }
    
    private func handleTodayExtension(_ url: URL) {
        switch url.path {
        case "/subscription":
            UserDefaults.standard.set(Constants.url_open_subscription, forKey: Constants.url_open_subscription)
            NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.settings.rawValue)
            TabBarRuningPage.shared.changePage(to: .settings)
        case "/widget":
            UserDefaults.standard.set(Constants.url_open_widget, forKey: Constants.url_open_widget)
            NotificationCenter.default.post(name: .openWidgetPage, object: nil, userInfo: nil)
            NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.settings.rawValue)
            TabBarRuningPage.shared.changePage(to: .settings)
        case "/coinwidget":
            UserDefaults.standard.set(Constants.url_open_coinWidget, forKey: Constants.url_open_coinWidget)
            NotificationCenter.default.post(name: .openWidgetPage, object: nil, userInfo: nil)
            NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.settings.rawValue)
            TabBarRuningPage.shared.changePage(to: .settings)
        case "/accounts":
            TabBarRuningPage.shared.changePage(to: .accounts)
            NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.accounts.rawValue)
        case "/addAccounts":
            UserDefaults.standard.set(Constants.url_open_selectpool, forKey: Constants.url_open_selectpool)
            TabBarRuningPage.shared.changePage(to: .accounts)
            NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.accounts.rawValue)
        case "/coinprice":
            TabBarRuningPage.shared.changePage(to: .coin)
            NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.coin.rawValue)
        case "/login":
    //        UserDefaults.standard.set(false, forKey: "isSkip")
            NotificationCenter.default.post(name: .goToLoginPage, object: nil)
            
        default:
            break
        }
    }
    
    private func handleWidgetKitExtension(urlPathComonents: [String]) {
        switch urlPathComonents[0] {
        case "/subscription":
            UserDefaults.standard.set(Constants.url_open_subscription, forKey: Constants.url_open_subscription)
            NotificationCenter.default.post(name: .openWidgetPage, object: nil, userInfo: nil)
            NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.settings.rawValue)
            TabBarRuningPage.shared.changePage(to: .settings)
        case "/accounts":
            UserDefaults.standard.setValue(urlPathComonents[1], forKey: "selected_widget_account")
            TabBarRuningPage.shared.changePage(to: .accounts)
            NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.accounts.rawValue)
        case "/coinprice":
            UserDefaults.standard.setValue(urlPathComonents[1], forKey: "selected_widget_coin")
            TabBarRuningPage.shared.changePage(to: .coin)
            NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.coin.rawValue)
        case "/login":
           // UserDefaults.standard.set(false, forKey: "isSkip")
            NotificationCenter.default.post(name: .goToLoginPage, object: nil)
            
        default:
            break
        }
    }
    
    private func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        guard let url = dynamicLink.url else {return}
        
        switch url.path {
        case "/accounts":
            TabBarRuningPage.shared.changePage(to: .accounts)
            NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.accounts.rawValue)
        case "/coinprice":
            TabBarRuningPage.shared.changePage(to: .coin)
            NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.coin.rawValue)
        case "/notifications":
            TabBarRuningPage.shared.changePage(to: .notifications)
            NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.notifications.rawValue)
        case "/news":
            UserDefaults.standard.set(Constants.url_open_news, forKey: Constants.url_open_news)
            NotificationCenter.default.post(name: .openDynamicLinks, object: nil, userInfo: nil)
            TabBarRuningPage.shared.changePage(to: .settings)
            NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.settings.rawValue)
        case "/more":
            TabBarRuningPage.shared.changePage(to: .settings)
            NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.settings.rawValue)
        case "/converter":
            UserDefaults.standard.set(Constants.url_open_converter, forKey: Constants.url_open_converter)
            NotificationCenter.default.post(name: .openDynamicLinks, object: nil, userInfo: nil)
            TabBarRuningPage.shared.changePage(to: .settings)
            NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.settings.rawValue)
        case "/analytics":
            UserDefaults.standard.set(Constants.url_open_analytics, forKey: Constants.url_open_analytics)
            NotificationCenter.default.post(name: .openDynamicLinks, object: nil, userInfo: nil)
            TabBarRuningPage.shared.changePage(to: .settings)
            NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.settings.rawValue)
        case "/whattomine":
            UserDefaults.standard.set(Constants.url_open_whatToMine, forKey: Constants.url_open_whatToMine)
            NotificationCenter.default.post(name: .openDynamicLinks, object: nil, userInfo: nil)
            TabBarRuningPage.shared.changePage(to: .whatToMine)
            NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.whatToMine.rawValue)
        case "/selectpool":
            //must be finished
            UserDefaults.standard.set(Constants.url_open_selectpool, forKey: Constants.url_open_selectpool)
            NotificationCenter.default.post(name: .openDynamicLinks, object: nil, userInfo: nil)
            TabBarRuningPage.shared.changePage(to: .accounts)
            NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.accounts.rawValue)
        default:
            break
        }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
                   UIApplication.shared.endBackgroundTask(self!.backgroundTask)
                   self?.backgroundTask = .invalid
               }
        UIApplication.shared.beginBackgroundTask {
            self.backgroundTask = .invalid
        }
        if let incomingURL = userActivity.webpageURL {
            let linkHanlded = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamicLink, error) in
                guard error == nil else {
                    debugPrint("⛔️ problem handling Firebase DynamicLink: \(String(describing: error))")
                    return
                }
                if let dynamicLink = dynamicLink {
                    self.handleIncomingDynamicLink(dynamicLink)
                }
            }
           return linkHanlded
        }
        return false
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        NotificationCenter.default.post(name: .goToBackground, object: nil)
        UserDefaults.standard.removeObject(forKey: "alertsIsDownloaded")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        NotificationCenter.default.post(name: .goToForeground, object: nil)
        UserDefaults.standard.removeObject(forKey: Constants.url_open_coinWidget)
        UserDefaults.standard.removeObject(forKey: Constants.url_open_widget)
        UserDefaults.standard.removeObject(forKey: Constants.url_open_subscription)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UserDefaults.standard.removeObject(forKey: "alertsIsDownloaded")
       
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        clearNotifications(application)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        UserDefaults.standard.setValue(nil, forKeyPath: "email_received")
        UserDefaults.standard.removeObject(forKey: Constants.url_open_widget)
        UserDefaults.standard.removeObject(forKey: Constants.url_open_coinWidget)
        UserDefaults.standard.removeObject(forKey: Constants.url_open_subscription)
        UserDefaults.standard.removeObject(forKey: "alertsIsDownloaded")
    }
    
    // MARK: -- App rate functionality
    private func setupRateApp() {
        if let appOpenedCount = UserDefaults.standard.value(forKey: Constants.appOpenedCount) as? Int {
            if appOpenedCount < Constants.showRateAppOpenedTime {
                UserDefaults.standard.set(appOpenedCount + 1, forKey: Constants.appOpenedCount)
                debugPrint("App opened \(appOpenedCount) time ")
            }
        } else {
            UserDefaults.standard.set(1, forKey: Constants.appOpenedCount)
        }
    }
    
}

extension UIApplication {
    static var appDelegate: AppDelegate {
        return shared.delegate as! AppDelegate
    }
}

// MARK: - Config root page
extension AppDelegate {
    fileprivate func configRootPage() {
        if DatabaseManager.shared.currentUser != nil {
        let usePin = UserDefaults.standard.bool(forKey: "security_use_\(SecurityTableEnum.usePin.rawValue)")
        let useBiometry = UserDefaults.standard.bool(forKey: "security_use_\(SecurityTableEnum.useBiometry.rawValue)")
        
        if useBiometry {
            showPasscodeController()
            accessBiometry()
        } else if usePin {
            showPasscodeController()
        } else {
            checkUserLogin()
        }
        }
    }
    
    fileprivate func showPasscodeController() {
        let pinController = TOPasscodeViewController(style: .translucentDark, passcodeType: .fourDigits)
        pinController.passcodeView.titleLabel.text = "enter_pin".localized()
        pinController.delegate = self
        pinController.cancelButton.isHidden = true
        
        pinController.allowBiometricValidation = false
        let useBiometry = UserDefaults.standard.bool(forKey: "security_use_\(SecurityTableEnum.useBiometry.rawValue)")
        if useBiometry {
            let biometryType = SecurityBiometryType.shared.getBiometryType()
            switch biometryType {
            case .touchID:
                pinController.allowBiometricValidation = true
                pinController.biometryType = TOPasscodeBiometryType.touchID
            case .faceID:
                pinController.allowBiometricValidation = true
                pinController.biometryType = TOPasscodeBiometryType.faceID
            default:
                break
            }
        }
        setInitialController(pinController)
    }
    
    fileprivate func accessBiometry() {
        guard #available(iOS 11.0, *) else { return }
        let title = "use_pin".localized() + SecurityBiometryType.shared.getBiometryType().rawValue
        let context = LAContext()
        context.localizedFallbackTitle = ""
        context.localizedReason = ""
        context.localizedCancelTitle = ""
        context.touchIDAuthenticationAllowableReuseDuration = 5
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else { return }
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: title) { (success, error) in
            DispatchQueue.main.async {
                if success {
                    self.checkUserLogin()
                }
            }
        }
    }
}

// MARK: - Passcode controller methods
extension AppDelegate: TOPasscodeViewControllerDelegate {
    func didPerformBiometricValidationRequest(in passcodeViewController: TOPasscodeViewController) {
        accessBiometry()
    }
    
    func passcodeViewController(_ passcodeViewController: TOPasscodeViewController, isCorrectCode code: String) -> Bool {
        return code == UserDefaults.standard.string(forKey: "pinCode") ?? code
    }
    
    func didInputCorrectPasscode(in passcodeViewController: TOPasscodeViewController) {
        // Check user
        checkUserLogin()
    }
}

// MARK: - User
extension AppDelegate {
    fileprivate func checkUserLogin() {
        if let _ = DatabaseManager.shared.currentUser {
            guard let controller = AnimationViewController.initializeStoryboard() else { return }
            setInitialController(controller)
            debugPrint("\(DatabaseManager.shared.currentUser!.auth) Authentication")
            debugPrint("\(DatabaseManager.shared.currentUser!.id ) userId ")
        } else {
            if UserDefaults.standard.bool(forKey: "isSkip") {
                guard let controller = AnimationViewController.initializeStoryboard() else { return }
                setInitialController(controller)
            } else if UserDefaults.standard.bool(forKey: "isSignUp") {
                guard let controller = LoginViewController.initializeNavigationStoryboard() else { return }
                setInitialController(controller)
            } else {
                guard let controller = SignupViewController.initializeStoryboard() else { return }
                let navVC = BaseNavigationController(rootViewController: controller)
                setInitialController(navVC)
            }
        }
    }
    
    public func setInitialController(_ controller: UIViewController) {
        if #available(iOS 11.0, *) {
            controller.view.animateSnapshotView()
        }
        
        window?.rootViewController = controller
    }
    
    @objc fileprivate func userLogout(_ sender: Notification) {
        ResponceHandler().removeUser()
        guard let controller = LoginViewController.initializeNavigationStoryboard() else { return }
        setInitialController(controller)
    }
}

// MARK: - Rotation
extension AppDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return restrictRotation
    }
}

// MARK: - Remote Notification Methods
extension AppDelegate: UNUserNotificationCenterDelegate {
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .alert, .sound]) { (_, _) in }
            center.delegate = notificationDelegate
            let openAction = UNNotificationAction(identifier: "OpenNotification", title: "Open", options: UNNotificationActionOptions.foreground)
            let deafultCategory = UNNotificationCategory(identifier: "CustomSamplePush", actions: [openAction], intentIdentifiers: [], options: [])
            center.setNotificationCategories(Set([deafultCategory]))
        } else {
            let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
        debugPrint("Device Notification Token: \(deviceTokenString)")
        if deviceTokenString != UserDefaults.standard.string(forKey: "notificationToken") {
            UserRequestsService.shared.sendDeviceInfo(notificationToken: deviceTokenString)
        }
        UserDefaults.standard.set(deviceTokenString, forKey: "notificationToken")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("Device Notification registration failed: \(error)")
    }
    
    func clearNotifications(_ application: UIApplication) {
        if #available(iOS 10, *) {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
            center.removeAllDeliveredNotifications()
        }
        
        application.applicationIconBadgeNumber = 0
    }
}

