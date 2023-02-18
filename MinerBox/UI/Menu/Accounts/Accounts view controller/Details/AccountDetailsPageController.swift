//
//  AccountDetailsPageController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/2/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import FirebaseCrashlytics

class AccountDetailsPageController: BaseViewController {
    
    // MARK: - Views
    @IBOutlet fileprivate weak var segmentControl: BaseSegmentControl!
    @IBOutlet fileprivate weak var containerView: UIView!
    
    @IBOutlet weak var detailsHeaderTableView: BaseTableView!
    @IBOutlet weak var detailsHeaderTableViewHeightConstraits: NSLayoutConstraint!
    
    var selectedCoinId: String?
    
    fileprivate var refreshButton: UIBarButtonItem?
    
    // MARK: - Properties
    
    fileprivate var account: PoolAccountModel!
    fileprivate var urlParamAsId = ""
    
    fileprivate var detailHeaders: [DetailsHeader] = []
    
    fileprivate var emailText: String?
    fileprivate var isLoaded: Bool = false
    fileprivate var invalidCredentials: Bool = false
    fileprivate var lastUpdatedText: String?
    fileprivate var lastUpdatedTextPoolInfo: String?
    fileprivate var nextPayoutTime: Double?
    fileprivate var nextPayoutTimeDur: Double?
    
    fileprivate var subAccountText: String?
    fileprivate var paymentMethodText: String?
    
    fileprivate var menuItems = [DetailsMenuEnum]()
    
    fileprivate var currentIndex: Int?
    fileprivate var currentController: BaseViewController?
    
    fileprivate var rewards = [Reward]()
    fileprivate var estimations = [Estimation]()
    fileprivate var priceUSD = 0.0
    fileprivate var priceBTC = 0.0
    
    fileprivate var currency = ""
    
    fileprivate var currentHashrate = 0.0
    fileprivate var currentReportedHashrate = 0.0
    fileprivate var currentWorkersCount = 0
    public var isAccountLoadEnd:Bool = false
    private var accountSettings = PoolSettingsModel()
    static func initializeStoryboard() -> AccountDetailsPageController? {
        return UIStoryboard(name: "AccountDetails", bundle: nil).instantiateViewController(withIdentifier: "AccountDetailsPageController") as? AccountDetailsPageController
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        openedViaLink()
    }
}


// MARK: - Startup default setup
extension AccountDetailsPageController {
    fileprivate func startupSetup() {
        configNavBar()
        configMenuItems()
        configTableViews()
        setTitle()
        containerView.backgroundColor = .clear
    }
    
    fileprivate func configNavBar() {
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    
    fileprivate func configMenuItems() {
        guard let pool = DatabaseManager.shared.getPool(id: account.poolType) else { return }
        
        var extEstimations = pool.extEstimations;
        var extRewards = pool.extRewards;
        
        if (pool.subItems.count > 0){
            if(pool.subItems[account.poolSubItem].extEstimations != -1) {
                extEstimations = (pool.subItems[account.poolSubItem].extEstimations == 1)
            }
            
            if(pool.subItems[account.poolSubItem].extRewards != -1) {
                extRewards = (pool.subItems[account.poolSubItem].extRewards == 1)
            }
        }
        
        self.urlParamAsId = pool.urlParamAsId
        
        var items: [DetailsMenuEnum] = [.details]
        if pool.extPayouts { items.append(.payouts) }
        if extEstimations { items.append(.estimations) }
        if extRewards { items.append(.rewards) }
        items += [.alerts, .poolInfo]
        
        self.menuItems = items
        
        let titles = items.map { $0.rawValue }
        segmentControl.setSegmentsWithImage(titles)
        segmentControl.delegate = self
        segmentSelected(index: 0)
    }
    
    fileprivate func configTableViews() {
        detailsHeaderTableView.register(UINib(nibName: AccountDetailsHeaderTableViewCell.name, bundle: nil), forCellReuseIdentifier: AccountDetailsHeaderTableViewCell.name)
        detailsHeaderTableView.roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10)
    }
    
    fileprivate func setTitle() {
        var titles = [account.poolAccountLabel]
        let subItem = account.poolSubItemName
        let subtitle = subItem != "" ? "\(account.poolTypeName) / \(subItem)" : account.poolTypeName
        titles.append(subtitle)
        setCustomTitles(titles)
    }
    
    fileprivate func openedViaLink() {
        if UserDefaults.standard.value(forKey: Constants.url_open_account_alert) != nil {
            segmentSelected(index: menuItems.count - 2)
            segmentControl.selectSegment(index: menuItems.count - 2)
        }
        UserDefaults.standard.removeObject(forKey: Constants.url_open_account_alert)
    }
    
    fileprivate func websiteSetup(_ newVC: PoolInfoViewController) {
        guard let poolType = DatabaseManager.shared.getPool(id: account.poolType) else { return }
        
        var webUrl = poolType.webUrl
        if poolType.subItems.count != 0 {
            let subItem = poolType.subItems.first { $0.id == account.poolSubItem }
            webUrl = subItem?.webUrl ?? poolType.webUrl
        }
        
        guard let url = webUrl else { return }
        
        newVC.setWebUrl(url)
        let websiteButton = UIBarButtonItem(image: UIImage(named: "website_outh"), style: .done, target: newVC, action: #selector(newVC.websiteButtonAction))
        navigationItem.rightBarButtonItem = websiteButton
    }
}

// MARK: - Segment control delegate
extension AccountDetailsPageController: BaseSegmentControlDelegate {
    func segmentSelected(index: Int) {
        guard index != currentIndex else { return }
        let toRight = currentIndex == nil ? nil : index > currentIndex!
        navigationItem.rightBarButtonItem = nil
        let item = menuItems[index]
        
        reloadHeaderView(item: item)
        
        switch item {
        case .details:
            guard let newVC = DetailsViewController.initializeStoryboard() else { break }
            newVC.delegate = self
            newVC.setAccount(account)
            changeChildVC(to: newVC, toRight: toRight)
        case .payouts:
            guard let newVC = PoolPaymentViewController.initializeStoryboard() else { break }
            newVC.setCurrentPage(.payout)
            let currency = self.currency == "" ? nil : self.currency
            newVC.setData(currency: currency, account: account, coinId: selectedCoinId)
            changeChildVC(to: newVC, toRight: toRight)
            // Add refresh button
            navigationItem.setRightBarButtonItems(newVC.rightBarButtonItms, animated: true)
            //            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "bar_refresh"), style: .done, target: newVC, action: #selector(newVC.refreshButtonAction(_:)))
        case .estimations:
            guard let newVC = EstimationsViewController.initializeStoryboard() else { break }
            newVC.setData(estimations: estimations, currency: currency, coinId: selectedCoinId ?? "", priceUSD: priceUSD, priceBTC: priceBTC)
            changeChildVC(to: newVC, toRight: toRight)
        case .rewards:
            guard let newVC = RewardsViewController.initializeStoryboard() else { break }
            newVC.setData(rewards: rewards, currency: currency, coinId: selectedCoinId ?? "",priceUSD: priceUSD)
            changeChildVC(to: newVC, toRight: toRight)
        case .alerts:
            guard let newVC = AccountAlertsViewController.initializeStoryboard() else { break }
            newVC.setAccount(account)
            newVC.setCurrentValues(hashrate: currentHashrate, workersCount: currentWorkersCount, reportedHashrate: currentReportedHashrate)
            changeChildVC(to: newVC, toRight: toRight)
            
            // Add addAlert button
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "bar_plus"), style: .done, target: newVC, action: #selector(newVC.addAlertButtonAction(_:)))
        case .poolInfo:
            guard let newVC = PoolInfoViewController.initializeStoryboard() else { break }
            newVC.setAccount(account)
            changeChildVC(to: newVC, toRight: toRight)
            newVC.delegate = self
            websiteSetup(newVC)
        }
        currentIndex = index
    }
    
    func reloadHeaderView(item: DetailsMenuEnum) {
        self.detailHeaders.removeAll()
        self.detailHeaders.append(DetailsHeader(name: "id", value: account.poolAccountId, isButtonShow: true,isloaded: isLoaded))
        
        for extra in account.accountExtras {
            self.detailHeaders.append(DetailsHeader(name: extra.extraName, value: extra.extraValue, isButtonShow: true,isloaded: true))
        }
        
        if item == .details  {
            if emailText != nil {
                self.detailHeaders.append(DetailsHeader(name: "login_email", value: emailText, isButtonShow: false, isloaded: true))
            }
            if subAccountText != nil {
                self.detailHeaders.append(DetailsHeader(name: "Account", value: subAccountText, isButtonShow: false,isloaded: true))
            }
        }
        
        if paymentMethodText != nil {
            if item == .payouts && paymentMethodText != nil {
                self.detailHeaders.append(DetailsHeader(name: "payment_method", value: paymentMethodText, isButtonShow: false,isloaded: true))
            }
        }
        
        if item == .payouts  {
            if nextPayoutTime != nil {
                self.detailHeaders.append(DetailsHeader(name: "next_payout_time", value: nextPayoutTime?.textFromUnixTime(), isButtonShow: false,isloaded: true))
            }
            if nextPayoutTimeDur != nil {
                self.detailHeaders.append(DetailsHeader(name: "next_payout_time", value: nextPayoutTimeDur?.secondsToDayHr(), isButtonShow: false,isloaded: true))
            }
        }

        if item != .poolInfo && item != .alerts {
            if lastUpdatedText != nil {
                self.detailHeaders.append(DetailsHeader(name: "last_updated", value: lastUpdatedText, isButtonShow: false,isloaded: isLoaded))
            }
        }
        
        if item == .poolInfo {
            if lastUpdatedTextPoolInfo != nil {
                self.detailHeaders.append(DetailsHeader(name: "last_updated", value: lastUpdatedTextPoolInfo, isButtonShow: false,isloaded: isLoaded))
            }
        }
        
        self.detailsHeaderTableViewHeightConstraits.constant = CGFloat(self.detailHeaders.count * 28)
        self.detailsHeaderTableView.reloadData()
    }
}

// MARK: - Actions
extension AccountDetailsPageController {
    fileprivate func changeChildVC(to controller: BaseViewController, toRight: Bool?) {
        addChild(controller)
        
        guard let controllerView = controller.view else { return }
        let from = currentController
        
        containerView.addSubview(controllerView)
        
        controllerView.frame = containerView.frame
        if let right = toRight { // Change with animation
            controllerView.frame.origin = CGPoint(x: containerView.frame.width * (right ? 1 : -1), y: 0)
            
            let toFrame = containerView.bounds
            var fromFrame = containerView.bounds
            fromFrame.origin = CGPoint(x: containerView.frame.width * (right ? -1 : 1), y: 0)
            
            UIView.animate(withDuration: 1.5 * Constants.animationDuration, animations: {
                from?.view.frame = fromFrame
            }) { (_) in
                from?.willMove(toParent: nil)
                from?.view.removeFromSuperview()
                from?.removeFromParent()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 * Constants.animationDuration) {
                UIView.animate(withDuration: 1.5 * Constants.animationDuration, animations: {
                    controllerView.frame = toFrame
                })
            }

        } else { // Change without animation. Just replace
            controllerView.frame = containerView.bounds

            from?.willMove(toParent: nil)
            from?.view.removeFromSuperview()
            from?.removeFromParent()
        }

        controller.didMove(toParent: self)
        currentController = controller
        
        //For the update containerView frame
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 * Constants.animationDuration) {
            controllerView.removeFromSuperview()
            self.containerView.addSubview(controllerView)
            controllerView.frame = self.containerView.bounds
        }
    }
}
// MARK: - Info page delegate
extension AccountDetailsPageController: PoolInfoViewControllerDelegate {
    func saveLastUpdate(lastSeen: String?) {
        if let lastUpdate = lastSeen {
            lastUpdatedTextPoolInfo = lastUpdate
        }
        let item = menuItems[currentIndex ?? 0]
        reloadHeaderView(item: item)
    }
}
    

// MARK: - Details page delegate
extension AccountDetailsPageController: DetailsViewControllerDelegate {
    func setRightBarButtonItems(_ barItems: [UIBarButtonItem]) {
        self.navigationItem.setRightBarButtonItems(barItems, animated: true)
    }
    
    func sendCurrentCoinId(_ coinId: String) {
        selectedCoinId = coinId
    }
    
    func saveAccountInfo(mail: String?, lastSeen: String?, nextPayoutTime: Double?, nextPayoutTimeDur: Double?, subAccount: String?, paymentMethod: String?, isloaded: Bool? , isAccountloadEnd : Bool?, invalideCredential: Bool?) {
        
        if let isloaded = isloaded {
            isLoaded = isloaded
            
        }
        if let invalid = invalideCredential {
            invalidCredentials = invalid
            
        }
        if let isAccountloadEnd = isAccountloadEnd {
            isAccountLoadEnd = isAccountloadEnd
        }
        if (mail != nil) && mail != "" {
            emailText = mail
        }
        if let lastUpdate = lastSeen {
            lastUpdatedText = lastUpdate
        }
        if let nextPayoutTime = nextPayoutTime {
            self.nextPayoutTime = nextPayoutTime
        }
        if let nextPayoutTimeDur = nextPayoutTimeDur {
            self.nextPayoutTimeDur = nextPayoutTimeDur
        }
        if let subAccount = subAccount {
            subAccountText = subAccount
        }
        if let paymentMethod = paymentMethod {
            paymentMethodText = paymentMethod
        }
        self.detailsHeaderTableView.isHidden = false
        let item = menuItems[currentIndex ?? 0]
        
        reloadHeaderView(item: item)
    }
    
    func saveCurrentValues(hashrate: Double, workersCount: Int, reportedHashrate: Double) {
        currentHashrate = hashrate
        currentWorkersCount = workersCount
        currentReportedHashrate = reportedHashrate
    }
    
    func saveEstimationRewardsInfo(rewards: [Reward], estimations: [Estimation], currency: String,priceUSD: Double,priceBTC: Double) {
        self.rewards = rewards
        self.estimations = estimations
        self.priceUSD = priceUSD
        self.priceBTC = priceBTC
        self.currency = currency
    }
    
    func statrtLoading() {
        segmentControl.setEnabledIndexes(false, indexes: [0, 1, 2])
    }
    
    func endLoading() {
        segmentControl.setEnabledIndexes(true, indexes: [0, 1, 2])
    }
    
    
}
// MARK: - Set data
extension AccountDetailsPageController {
    public func setAccount(_ account: PoolAccountModel) {
        self.account = account
        Cacher.shared.account = account
        title = account.poolAccountLabel
    }
}

// MARK: - TableView methods
extension AccountDetailsPageController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.detailHeaders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: AccountDetailsHeaderTableViewCell.name) as! AccountDetailsHeaderTableViewCell
        cell.setData(data: self.detailHeaders[indexPath.row], indextPath: indexPath, urlParamAsId: self.urlParamAsId, isloadedEnd: isLoaded ? false : self.isAccountLoadEnd, model: accountSettings , invalidCredentials: invalidCredentials)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AccountDetailsHeaderTableViewCell.height
    }
    
}

// MARK: - Helpers
enum DetailsMenuEnum: String {
    case details = "account_details"
    case payouts = "account_payouts"
    case estimations = "account_estimations"
    case rewards = "account_rewards"
    case alerts = "account_alerts"
    case poolInfo = "account_pool_info"
}

struct DetailsHeader {
    
    var name: String?
    var value: String?
    var isButtonShow = true
    var isloaded:Bool
}
