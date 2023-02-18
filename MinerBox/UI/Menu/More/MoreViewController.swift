//
//  MoreViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/9/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import WidgetKit
//import Crashlytics

class MoreViewController: BaseViewController {
    
    @IBOutlet private weak var tableView: BaseTableView!
    @IBOutlet var manageSubscriptionView: UIView!
    
    // MARK: - Properties
    private var tableData = MoreSettingsEnum.tableData
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        configManageSubscriptionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        openedViaWidget()
        openedViaDynamicLink()
        tableView.reloadData()
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(openedViaWidget), name: .openWidgetPage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openedViaDynamicLink), name: .openDynamicLinks, object: nil)
    }
    
    @objc private func openedViaDynamicLink() {
        var sb = UIStoryboard(name: "More", bundle: nil)
        if UserDefaults.standard.value(forKey: Constants.url_open_analytics) != nil {
            if let vc = sb.instantiateViewController(withIdentifier: "AnalyticsViewController") as? AnalyticsViewController {
                navigationController?.setViewControllers([self, vc], animated: true)
            }
        } else if UserDefaults.standard.value(forKey: Constants.url_open_converter) != nil {
            if let vc = sb.instantiateViewController(withIdentifier: "ConverterViewController") as? ConverterViewController {
                navigationController?.setViewControllers([self, vc], animated: true)
            }
        } else if UserDefaults.standard.value(forKey: Constants.url_open_news) != nil {
            sb = UIStoryboard(name: "Menu", bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "NewsPageController") as? NewsPageController {
                navigationController?.setViewControllers([self, vc], animated: true)
            }
        }
        UserDefaults.standard.removeObject(forKey: Constants.url_open_analytics)
        UserDefaults.standard.removeObject(forKey: Constants.url_open_converter)
        UserDefaults.standard.removeObject(forKey: Constants.url_open_news)
    }
    
    @objc private func openedViaWidget() {
        if UserDefaults.standard.value(forKey: Constants.url_open_widget) != nil {
            if let vc = WidgetAccountsViewController.initializeStoryboard() {
                navigationController?.setViewControllers([self, vc], animated: true)
            }
        } else if UserDefaults.standard.value(forKey: Constants.url_open_coinWidget ) != nil {
            if let vc = WidgetAccountsViewController.initializeStoryboard() {
                WidgetCointManager.shared.isAccount = false
                navigationController?.setViewControllers([self, vc], animated: true)
            }
        }else if UserDefaults.standard.value(forKey: Constants.url_open_subscription) != nil {
            if let vc = ManageSubscriptionViewController.initializeStoryboard() {
                navigationController?.setViewControllers([self, vc], animated: true)
            }
        }
        UserDefaults.standard.removeObject(forKey: Constants.url_open_coinWidget)
        UserDefaults.standard.removeObject(forKey: Constants.url_open_widget)
        UserDefaults.standard.removeObject(forKey: Constants.url_open_subscription)
    }
    
    override func languageChanged() {
        title = "more".localized()
    }
    
    @objc private func openWidgetPage() {
        if let newVC = WidgetAccountsViewController.initializeStoryboard() {
            self.navigationController?.pushViewController(newVC, animated: true)
        }
    }
    
    private func configManageSubscriptionView() {
        manageSubscriptionView.layer.borderWidth = 1.0
        manageSubscriptionView.layer.borderColor = UIColor.barSelectedItem.cgColor
        manageSubscriptionView.roundCorners(radius: 10)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(manageSubscriptionAction))
        manageSubscriptionView.addGestureRecognizer(gesture)
    }
    
    @objc func manageSubscriptionAction() {
        guard let newVC = ManageSubscriptionViewController.initializeStoryboard() else { return }
        navigationController?.pushViewController(newVC, animated: true)
    }
    
    private func currentYear() -> Int {
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        
        return year
    }
    fileprivate func changeControllerToLogin() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let controller = LoginViewController.initializeNavigationStoryboard() else { return }
        UserDefaults.standard.set(false, forKey: "isSkip")
        appDelegate.setInitialController(controller)
    }
}

// MARK: - TableView methods
extension MoreViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    // Cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MoreTableViewCell.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MoreTableViewCell.name) as! MoreTableViewCell
        let item = tableData[indexPath.section][indexPath.row]
        
        cell.delegate = self
        cell.setData(title: item.rawValue, indexPath: indexPath)
        
        if item == .darkMode {
            cell.showSwitch(for: indexPath, isOn: darkMode)
        }
        if item == .adsRemove {
            let removeAds = UserDefaults.standard.bool(forKey: "removeAds\(DatabaseManager.shared.currentUser?.id ?? "")")
            cell.showSwitch(for: indexPath, isOn: removeAds)
        }
        if item == .temperature || item == .currency {
            let info = item == .temperature ? Double.temperatureUnit : "\(Locale.appCurrency) (\(Locale.appCurrencySymbol))"
            cell.showInfoLabel(text: info)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        Crashlytics.sharedInstance().crash()
        let item = tableData[indexPath.section][indexPath.row]
        
        
        switch item {
        case .login:
            goToLoginPage()
        case .profile:
            guard let _ = user else {
                goToLoginPage()
                return
            }
            
            Loading.shared.startLoading(ignoringActions: true, for: self.view)
            UserRequestsService.shared.checkUserState(success: {
                guard let newVC = ProfileViewController.initializeStoryboard() else { return }
                self.navigationController?.pushViewController(newVC, animated: true)
                Loading.shared.endLoading(for: self.view)
            }) { (error) in
                Loading.shared.endLoading(for: self.view)
                self.showAlertView("", message: error, completion: nil)
            }
        case .languages, .temperature, .currency:
            guard let newVC = LanguageViewController.initializeStoryboard() else { break }
            newVC.dataDelegate = self
            newVC.setData(item)
            navigationController?.pushViewController(newVC, animated: true)
        case .toolBar:
            guard let newVC = ToolbarViewController.initializeStoryboard() else { break }
            navigationController?.pushViewController(newVC, animated: true)
        case .joinCommunity:
            guard let newVC = JoinCommunityViewController.initializeStoryboard() else { break }
            navigationController?.pushViewController(newVC, animated: true)
        case .aboutApp:
            guard let newVC = AboutViewController.initializeStoryboard() else { break }
            navigationController?.pushViewController(newVC, animated: true)
        case .widget:
            guard self.user != nil else {
                goToLoginPage()
                return
            }
            openWidgetPage()
        case .security:
            guard let newVC = SecurityViewController.initializeStoryboard() else { break }
            navigationController?.pushViewController(newVC, animated: true)
        case .manageSubscription:
            guard let newVC = ManageSubscriptionViewController.initializeStoryboard() else { break }
            navigationController?.pushViewController(newVC, animated: true)
        case .toolBarPages:
            guard let newVC = ToolBarPagesViewController.initializeStoryboard() else { return }
            navigationController?.pushViewController(newVC, animated: true)
            
        case .logOut:
            Loading.shared.startLoading(ignoringActions: true, for: self.view)
            UserRequestsService.shared.logout(success: {
                TabBarRuningPage.shared.changePage(to: .accounts)
                NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.accounts.rawValue)
                if #available(iOS 14.0, *) {
                    #if arch(arm64) || arch(i386) || arch(x86_64)
                    WidgetCenter.shared.reloadAllTimelines()
                    #endif
                }
                AdsRequestService.shared.getZoneList {
                    debugPrint("Ads List is update")
                } failer: { err in
                    debugPrint(err)
                }
                Loading.shared.endLoading(for: self.view)
                self.changeControllerToLogin()
            }) { (error) in
                Loading.shared.endLoading(for: self.view)
                self.showAlertView("", message: error, completion: nil)
            }
            
        case .help:
            openURL(urlString: DatabaseManager.shared.communityModel?.helpUrl ?? "")
        default:
            break
        }
    }
    
    // Footerß
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 25
    }
}

// MARK: - Cell delegate
extension MoreViewController: MoreTableViewCellDelegate {
    func switchTapped(indexPath: IndexPath, sender: BaseSwitch) {
        let item = tableData[indexPath.section][indexPath.row]
        switch item {
        case .darkMode:
            darkMode = sender.isOn
        case .adsRemove:
            if let user = user {
                guard !user.isSubscribted else {
                    UserDefaults.standard.setValue(sender.isOn, forKey: "removeAds\(DatabaseManager.shared.currentUser?.id ?? "")")
                    return
                }
            }
            if sender.isOn {
                goToSubscriptionPage()
                sender.isOn = false
                sender.onTintColor = .none
            }
        default:
            break
        }
    }
}
// MARK: - DataDelegate
extension MoreViewController: DataDelegate {
    func reloadData() {
        tableView.reloadData()
    }
}

// MARK: - Helpers
enum MoreSettingsEnum: String, CaseIterable {
    
    case login = "more_login_signup"
    case logOut = "profile_log_out"
    case profile = "more_profile"
    case security = "more_security"
    case widget = "more_widget"
    case languages = "more_languages"
    case toolBar = "more_toolbar"
    case toolBarPages = "toolBarPages"
    case news = "news"
    case joinCommunity = "more_join_community"
    case aboutApp = "more_about_app"
    case manageSubscription = "more_manage_subscription"
    case darkMode = "more_darkMode"
    case converter = "more_converter"
    case analytics = "more_analytics"
    case help = "more_help"
    case adsRemove = "remove_ads_more"
    case temperature = "temperature"
    case currency = "currency"
    case wallet = "more_wallet"
    case income = "income"
    
    
    private static var firstSection: [MoreSettingsEnum] {
        let profile: MoreSettingsEnum = DatabaseManager.shared.currentUser == nil ? .login : .profile
        return [profile, .security, .widget, .languages]
    }
    
    private static var secondSection: [MoreSettingsEnum] {
        return [.joinCommunity, .aboutApp, .help]
    }
    
    private static var thirdSection: [MoreSettingsEnum] {
        return [.toolBar, .toolBarPages]
    }
    
    private static var fourthSection: [MoreSettingsEnum] {
        return [.darkMode, .adsRemove, temperature, currency,]
    }
    private static var fiveSection: [MoreSettingsEnum] {
        if DatabaseManager.shared.currentUser != nil {
        return [.logOut]
        }
        return []
    }
    
    static var tableData: [[MoreSettingsEnum]] {
        return [firstSection, secondSection, thirdSection, fourthSection, fiveSection]
    }
}
