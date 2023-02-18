//
//  TodayViewController.swift
//  MinerBox Widget
//
//  Created by Ruben Nahatakyan on 12/12/18.
//  Copyright © 2018 WitPlex. All rights reserved.
//

import UIKit
import RealmSwift
import Localize_Swift
import NotificationCenter


@available(iOS 10.0, *)
@available(iOS 10.0, *)
class WidgetViewController: UIViewController, NCWidgetProviding {

    // MARK: - Views
    @IBOutlet fileprivate var widgetTableView: UITableView!
    @IBOutlet fileprivate var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet fileprivate var errorButton: UIButton!

    // MARK: - Properties
    fileprivate var accounts = [WidgetAccountModel]()
    fileprivate var user: UserModel? {
        return DatabaseManager.shared.currentUser
    }
    fileprivate var countEmptyBalanceAccount = 0

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startupSetup()

        extensionContext?.widgetLargestAvailableDisplayMode = .compact
        errorButton.addTarget(self, action: #selector(errorButtonAction(_:)), for: .touchUpInside)
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        Localize.setCurrentLanguage(UserDefaults(suiteName: "group.com.witplex.MinerBox")?.string(forKey: "appLanguage") ?? "en")
        self.checkUser()
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(.newData)
    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {

        let accountWithBalance = self.accounts.count - self.countEmptyBalanceAccount
        let heigthForCel = CGFloat(accountWithBalance) * AccountWidgetTableViewCell.heightWithBalance + CGFloat(self.countEmptyBalanceAccount) * AccountWidgetTableViewCell.height
        let heigForMaxCountCell = (5 - CGFloat(self.countEmptyBalanceAccount)) * AccountWidgetTableViewCell.heightWithBalance + CGFloat(self.countEmptyBalanceAccount) * AccountWidgetTableViewCell.height
        
        let height = self.accounts.count < 6 ? heigthForCel : heigForMaxCountCell
        preferredContentSize = CGSize(width: maxSize.width, height: min(height, maxSize.height))
    }
}

// MARK: - Startup
@available(iOS 10.0, *)
extension WidgetViewController {
    fileprivate func startupSetup() {
        self.setupRealm()
        self.configTable()
    }

    fileprivate func configTable() {
        widgetTableView.estimatedRowHeight = 150
        widgetTableView.rowHeight = UITableView.automaticDimension
    }
}

// MARK: - Actions
@available(iOS 10.0, *)
extension WidgetViewController {
    fileprivate func checkUser() {
        errorButton.setTitle("", for: .normal)
        self.hideTableView()
        guard let user = self.user else {
            errorButton.setTitle(Localized("login_login"), for: .normal)
            return
        }

        guard user.isPremiumUser || user.isPromoUser || user.isStandardUser else {
            errorButton.setTitle(Localized("need_subscription"), for: .normal)
            return
        }

        self.getInfo()
    }

    fileprivate func getInfo() {
        guard WidgetAccountManager.shared.getAccountsIds().count != 0 else {
            errorButton.setTitle(Localized("please_check_acounts") , for: .normal)
            return
        }
        self.getAccounts()
    }

    fileprivate func getAccounts() {
        guard let user = DatabaseManager.shared.currentUser else { return }
        loadingIndicator.startAnimating()
        let userId = user.id
        let endpoint = "widget/\(userId)/info"

        let userEnabledAccounts = WidgetAccountManager.shared.getAccounts()
        let userEnabledAccountsIds = userEnabledAccounts.map({$0.accountId})
        
        let param = ["type": "0", "ids": userEnabledAccountsIds.description ] as [String : Any]

        NetworkManager.shared.request(method: .post, endpoint: endpoint,params: param,success: { (json) in
            guard let data = json["data"] as? [NSDictionary] else { return }
            var receivedAccounts = [WidgetAccountModel]()
            for dictionary in data {
                let poolAccountObject = WidgetAccountModel(json: dictionary)
                receivedAccounts.append(poolAccountObject)
            }
            self.accounts = receivedAccounts
            for  (index,account) in self.accounts.enumerated() {
                for accountFromDB in userEnabledAccounts {
                    if account.poolId == accountFromDB.accountId {
                        account.selectedBalanceType = accountFromDB.selectedBalanceType
                        if accountFromDB.selectedBalanceType == "" && index < 5 {
                            self.countEmptyBalanceAccount += 1
                        }
                    }
                }
            }

            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                self.widgetTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                self.updateWidgetHeight()
                self.showTableView()
            }
        }) { (error) in
            self.loadingIndicator.stopAnimating()
            DispatchQueue.main.async {
                self.errorButton.setTitle(error, for: .normal)
                self.hideTableView()
            }
        }
    }

    fileprivate func updateWidgetHeight() {
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded

        let cellHeight: CGFloat = 80
        let height = self.accounts.count < 6 ? CGFloat(self.accounts.count) * cellHeight : 5 * cellHeight
        preferredContentSize = CGSize(width: widgetTableView.frame.width, height: height)
    }

    @objc fileprivate func errorButtonAction(_ sender: UIButton) {
        guard let title = sender.titleLabel?.text else { return }
        switch title {
        case Localized("login_login"):
            extensionContext?.open(URL(string:"minerbox://localhost/login")!,
                completionHandler: nil)
        case Localized("please_check_acounts"):
            extensionContext?.open(URL(string: "minerbox://localhost/widget")!, completionHandler: nil)
        case Localized("need_subscription"):
            extensionContext?.open(URL(string: "minerbox://localhost/subscription")!, completionHandler: nil)
        default:
            checkUser()
        }
    }
}
 

// MARK: - TableView methods
@available(iOS 10.0, *)
extension WidgetViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.accounts[indexPath.row].selectedBalanceType == "" {
            return AccountWidgetTableViewCell.height
        }
        return AccountWidgetTableViewCell.heightWithBalance
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count < 6 ? accounts.count : 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = widgetTableView.dequeueReusableCell(withIdentifier: AccountWidgetTableViewCell.name) as! AccountWidgetTableViewCell
        let item = accounts[indexPath.row]
        cell.setData(item: item)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let account = accounts[indexPath.row]
        extensionContext?.open(URL(string: "minerbox://localhost/accounts,\(account.poolId)")!, completionHandler: nil)
    }
}

// MARK: - Realm
@available(iOS 10.0, *)
extension WidgetViewController {
    fileprivate func setupRealm() {
        DatabaseManager.shared.migrateRealm()
    }
}

// MARK: - Animations
@available(iOS 10.0, *)
extension WidgetViewController {
    fileprivate func showTableView() {
        guard widgetTableView.isHidden && errorButton.isHidden == false else { return }

        widgetTableView.alpha = 0
        widgetTableView.isHidden = false

        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.widgetTableView.alpha = 1
            self.errorButton.alpha = 0
        }) { (_) in
            self.errorButton.isHidden = true
        }
    }

    fileprivate func hideTableView() {
        guard widgetTableView.isHidden == false && errorButton.isHidden else { return }

        errorButton.alpha = 0
        errorButton.isHidden = false

        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.errorButton.alpha = 1
            self.widgetTableView.alpha = 0
        }) { (_) in
            self.widgetTableView.isHidden = true
        }
    }
}
