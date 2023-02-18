//
//  NotificationsViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/26/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

protocol NotificationsViewControllerDelegate: AnyObject {
    func disableButton(_ bool: Bool) -> Void
    
    func searchBarCancelClicked()
    func searchBarSearchClicked()
    func showSearchBar(searchText: String)
    func endEditing()
    func startLoading()
    func endLoading()
}

class NotificationsViewController: BaseViewController {
    
    // MARK: - Views
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    @IBOutlet weak var scrollTopImageView: UIImageView!
    
    var notificationCategory: NotificationSegmentTypeEnum = .coin
    var allAccounts: [PoolAccountModel] = []
    
    private var filterType: String = "all"
    private var searchText: String?
    private var isClearCount = false
    private var timer = Timer()
    
    public var workItem: DispatchWorkItem?
    
    weak var delegate: NotificationsViewControllerDelegate?
    
    private var notifications = [NotificationModel]() {
        didSet {
            if notifications.count == 0 {
                noDataButton?.isHidden = false
                self.delegate?.endLoading()
                self.noCoinNotifications()
            } else {
                noDataButton?.isHidden = true
            }
        }
    }
    private var localNotifications = [LocalNotification]()
    
    private var filteredNotifications: [NotificationModel] = []
    private var filteredLocalNotifications: [LocalNotification] = []
//    private let viewForMask = BaseView()
    

    
    // MARK: - Static
    static func initializeStoryboard() -> NotificationsViewController? {
        return UIStoryboard(name: "Menu", bundle: nil).instantiateViewController(withIdentifier: NotificationsViewController.name) as? NotificationsViewController
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationManager.shared.clearNotificationsCount(for: notificationCategory)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationManager.shared.clearNotificationsCount(for: notificationCategory)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        setupScrollImageView()
        addObservers()
        notificationsSetup()
        delegate?.disableButton(self.notifications.count == 0)
    }
    
    deinit {
        print("deinit NotificationsViewController")
    }
    
    override func configNoDataButton() {
        super.configNoDataButton()
    }
    
    override func hideKeyboard() {
        super.hideKeyboard()
//        self.viewForMask.removeFromSuperview()
    }
    
    private func setUpTableView() {
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadLocalNotifications), name: NSNotification.Name(Constants.notificationReceived), object: nil)
        //must be modified
//        NotificationCenter.default.addObserver(self, selector: #selector(stopTask), name: .stopNotificationTask, object: nil)
    }
    
    //MARK: - Notifications Setup
    private func notificationsSetup() {
        switch notificationCategory {
        case .coin:
            if let coinNotification = NotificationCacher.shared.coinNotification {
                updateNotifications(with: coinNotification)
            } else {
                reloadNotifications()
            }
        case .pool:
            if let poolNotification = NotificationCacher.shared.poolNotification {
                updateNotifications(with: poolNotification)
            } else {
                reloadNotifications()
            }
        case .info:
            if let infoNotification = NotificationCacher.shared.infoNotification {
                self.getWelcomeNotification()
                updateNotifications(with: infoNotification)
            } else {
                reloadNotifications()
                WelcomeMessageManager.shared.getWelcomeMessageWithURL()
            }
        }
    }
    
    func setupScrollImageView() {
        let tapDesture = UITapGestureRecognizer(target: self, action: #selector(scrollTop))
        scrollTopImageView.isHidden = true
        scrollTopImageView.isUserInteractionEnabled = true
        scrollTopImageView.addGestureRecognizer(tapDesture)
        scrollTopImageView.layer.cornerRadius = scrollTopImageView.frame.size.height / 2
        scrollTopImageView.image = UIImage(named: "arrow_up")?.withRenderingMode(.alwaysTemplate)
        
        scrollTopImageView.tintColor = darkMode ? .white : .black
        scrollTopImageView.backgroundColor = darkMode ? UIColor.viewDarkBackgroundWithAlpha : UIColor.viewLightBackgroundWithAlpha
    }
    
    @objc private func scrollTop() {
        self.tableView.scroll(to: .top, animated: true)
    }
    
    private func updateNotifications(with notifications: [NotificationModel]) {
        self.notifications = notifications
        self.filteredNotifications = self.notifications
        self.filteredLocalNotifications = localNotifications
        
        if searchText == nil {
            tableView.reloadData()
        } else {
            checkNoDataLabelStatus()
        }
    }
    
    @objc private func reloadLocalNotifications(_ notification: NSNotification) {
        if  let stringType = notification.userInfo?["notificationType"] as? String {
            switch stringType {
            case NotificationType.coin.rawValue,NotificationType.payout.rawValue:
                if let _ = NotificationCacher.shared.coinNotification {
                    if !NotificationCacher.shared.coinNotification!.isEmpty {
                        self.getLocalNotificationByType(type: .coin)
                    } else {
                        reloadNotifications()
                    }
                } else {
                    reloadNotifications()
                }
            case NotificationType.reportedHashrate.rawValue,NotificationType.hashrate.rawValue,NotificationType.worker.rawValue:
                if let _ = NotificationCacher.shared.poolNotification {
                    if !NotificationCacher.shared.poolNotification!.isEmpty {
                        self.getLocalNotificationByType(type: .pool)
                    } else {
                        reloadNotifications()
                    }
                } else {
                    reloadNotifications()
                }
            case NotificationType.info.rawValue:
                if let _ = NotificationCacher.shared.infoNotification {
                    if !NotificationCacher.shared.infoNotification!.isEmpty {
                        self.getLocalNotificationByType(type: .info)
                    } else {
                        reloadNotifications()
                    }
                } else {
                    reloadNotifications()
                }
            default:
                break
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.notificationCountChanged), object: nil)
        }
    }
    
    @objc private func reloadNotifications() {
        delegate?.startLoading()
        NotificationManager.shared.getNotifications(for: self.notificationCategory) { [weak self] (notifications) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.notifications = notifications
                
                self.filteredNotifications = self.notifications
                self.delegate?.disableButton(self.notifications.count == 0)
                
                //must be modified //old
                switch self.notificationCategory {
                case .coin:
                    NotificationCacher.shared.coinNotification = notifications
                case .pool:
                    NotificationCacher.shared.poolNotification = notifications
                case .info:
                    NotificationCacher.shared.infoNotification = notifications
                }
                
                if !self.isClearCount {
                    NotificationManager.shared.clearNotificationsCount(for: self.notificationCategory)
                }
                self.getWelcomeNotification()
                
                self.delegate?.endLoading()
                if self.searchText == nil {
                    self.isClearCount = false
                    self.tableView.reloadData()
                }
            }
        } failer: { (error) in
            DispatchQueue.main.async {
                self.delegate?.endLoading()
                self.showAlertView("", message: error, completion: nil)
            }
        }
    }
    
//    @objc private func stopTask() {
//        print("stopTask")
//        NotificationManager.shared.stopTask()
//    }
    
    private func getNotifications() {
        NotificationManager.shared.getNotifications(for: self.notificationCategory) { (notifications) in
            self.notifications = notifications
            
            self.filteredNotifications = self.notifications
            self.delegate?.disableButton(self.notifications.count == 0)
            
            //must be modified //old
            switch self.notificationCategory {
            case .coin:
                NotificationCacher.shared.coinNotification = notifications
            case .pool:
                NotificationCacher.shared.poolNotification = notifications
            case .info:
                NotificationCacher.shared.infoNotification = notifications
            }
            
            if !self.isClearCount {
                NotificationManager.shared.clearNotificationsCount(for: self.notificationCategory)
            }
            self.getWelcomeNotification()
            DispatchQueue.main.async {
                self.delegate?.endLoading()
                if self.searchText == nil {
                    self.isClearCount = false
                    self.tableView.reloadData()
                }
            }
        } failer: { (error) in
            DispatchQueue.main.async {
                self.delegate?.endLoading()
                self.showAlertView("", message: error, completion: nil)
            }
        }
    }
    
    func getLocalNotificationByType(type: NotificationSegmentTypeEnum) {
        NotificationManager.shared.getLocalSavedNotifications(type: type) { (notifications) in
            
            //must be modified //old
            switch type {
            case .coin:
                NotificationCacher.shared.coinNotification = notifications
            case .pool:
                NotificationCacher.shared.poolNotification = notifications
                self.delegate?.disableButton(self.notifications.count == 0)
            case .info:
                NotificationCacher.shared.infoNotification = notifications
                self.delegate?.disableButton(self.notifications.count == 0)
            }
            NotificationManager.shared.clearNotificationsCount(for: self.notificationCategory)
            self.notificationsSetup()
        }
    }
    
    private func getWelcomeNotification() {
        LocalNotificationManager.shared.getLocalSavedLocalNotifications { (localNotifications) in
            DispatchQueue.main.async {
                self.localNotifications.removeAll()
                self.localNotifications.append(contentsOf: localNotifications)
                self.filteredLocalNotifications = self.localNotifications
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        tableView?.setEditing(false, animated: false)
        tableView?.reloadData()
    }

}

//MARK: -- NotificPageC Delegate
extension NotificationsViewController: NotificationPageControllerDelegate {
    func cancelTask() {
        self.delegate?.endLoading()
        workItem?.cancel()
    }
    
    func deleteAllNotifications() {
        let message = notificationCategory.rawValue.localized() + " " + "notifications_will_delete".localized()
        self.showAlertViewController(message, message: nil, otherButtonTitles: ["ok"], cancelButtonTitle: "cancel") { (responce) in
            if responce == "ok" {
                NotificationManager.shared.deleteAllNotifications(for: self.notificationCategory, success: {
                    self.reloadNotifications()
                    self.delegate?.disableButton(true)
                    // badge change hier
                    
                }, failer: { (error) in
                    self.showAlertView(nil, message: error, completion: nil)
                })
            }
        }
    }
    
    func setCategory(_ category: NotificationSegmentTypeEnum) {
        self.notificationCategory = category
    }
    
    func filterNotification(by poolType: String) {
        self.filterType = poolType
        if let searchText = searchText {
            searchNotification(with: searchText)
        } else {
            filter(with: poolType)
            tableView.reloadData()
        }
    }
    
    private func filter(with filter: String) {
        if filter == "all" {
            filteredNotifications = notifications
        } else {
            filteredNotifications = notifications.filter { $0.data.notificationType == filter }
//            for notification in notifications {
//                if notification.data.notificationType == filter {
//                    filteredNotifications.append(notification)
//                }
//            }
        }
    }
}

// MARK: - TableView Methods
extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if notificationCategory == .info {
            return filteredNotifications.count + filteredLocalNotifications.count
        }
        return filteredNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationsTableViewCell.name) as! NotificationsTableViewCell
        
        if !filteredLocalNotifications.isEmpty && indexPath.row == filteredNotifications.count && notificationCategory == .info {
            cell.setLocalData(notification: filteredLocalNotifications.first!)
        } else {
            let model = filteredNotifications[indexPath.row]
                cell.setData(notification: model)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch notificationCategory {
        case .coin:
            coinSelectionAction(with: indexPath)
        case .pool:
            poolSelectionAction(with: indexPath)
        case .info:
            print("info")
        }
    }
    
    // Cell swipe method for less than iOS 11
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let remove = UITableViewRowAction(style: .normal, title: "delete".localized()) { (_, indexPath) in
            self.deleteNotification(indexPath: indexPath)
            self.delegate?.disableButton(self.notifications.count == 0)
        }
        remove.backgroundColor = .red
        return [remove]
    }
    
    // Cell swipe method for greather than iOS 11
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if !localNotifications.isEmpty && indexPath.row == filteredNotifications.count && notificationCategory == .info {
            return UISwipeActionsConfiguration(actions: [])
        }
        let remove = UIContextualAction(style: .normal, title: "") { (_, _, completion) in
            self.deleteNotification(indexPath: indexPath)
            self.delegate?.disableButton(self.notifications.count == 0)
            completion(false)
        }
        
        remove.image = UIImage(named: "cell_delete")
        remove.backgroundColor = .red
        
        let swipeAction = UISwipeActionsConfiguration(actions: [remove])
        swipeAction.performsFirstActionWithFullSwipe = false // This is the line which disables full swipe
        return swipeAction
    }
    
    //MARK: - Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if !justFavorites {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                guard let indexPathsForVisibleRows = self.tableView.indexPathsForVisibleRows, !indexPathsForVisibleRows.isEmpty else { return }
//                self.indexPathForVisibleRow = indexPathsForVisibleRows.first
//            }
//        }
//
        let position = scrollView.contentOffset.y
        scrollTopImageView.isHidden = position < 100
    }
    
    //MARK: -Actions
    private func coinSelectionAction(with indexPath: IndexPath) {
        guard let newVC = CoinChartViewController.initializeStoryboard() else { return }
        
        let currentNotification = notifications[indexPath.row]
        let coinId = currentNotification.data.coinId
        if coinId != "" {
                newVC.setCoinId(coinId)
                self.navigationController?.pushViewController(newVC, animated: true)
        } else {
            tabBarController?.selectedIndex = 1
        }
    }
    
    private func poolSelectionAction(with indexPath: IndexPath) {
        let notification = filteredNotifications[indexPath.row]
        let poolId = notification.data.poolId
        let title = notification.title
        
        guard let account = DatabaseManager.shared.allPoolAccounts?.first(where: { $0.id == poolId }),
              let poolType = PoolTypeModel.getPoolType(from: title) else { return }
        
        if poolType.pool.isEnabled {
            if let subPool = poolType.subPool {
                if subPool.enabled {
                    showAccountDetailsPC(with: account)
                } else {
                    NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.accounts.rawValue)
                }
            } else {
                showAccountDetailsPC(with: account)
            }
        } else {
            NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.accounts.rawValue)
        }
    }
    
    private func showAccountDetailsPC(with account: PoolAccountModel) {
        guard let newVC = AccountDetailsPageController.initializeStoryboard() else {return}
        
        newVC.setAccount(account)
        navigationController?.pushViewController(newVC, animated: true)
    }
    
    private func deleteNotification(indexPath: IndexPath) {
        delegate?.startLoading()
        
        NotificationManager.shared.deleteNotification(notification: notifications[indexPath.row], success: {
            self.filteredNotifications.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.delegate?.disableButton(self.notifications.count == 0)
            self.delegate?.endLoading()
            self.notifications.remove(at: indexPath.row)
            NotificationCacher.shared.removeNotification(for: self.notificationCategory, with: indexPath.row)
            
        }, failer: { (error) in
            self.delegate?.endLoading()
            self.showAlertView(nil, message: error, completion: nil)
        })
    }
    
    private func checkNoDataLabelStatus() {
        if self.filteredNotifications.count == 0 && self.filteredLocalNotifications.count == 0 {
            self.showNoDataLabel()
        } else {
            self.hideNoDataLabel()
        }
    }
    
}

// MARK: - Search delegate
extension NotificationsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchText.trimmingCharacters(in: .whitespaces)

        guard searchText != "" else {
            self.searchText = nil
            isClearCount = false
            NotificationManager.shared.clearNotificationsCount(for: self.notificationCategory)
            updateNotifications(with: notifications)
            return
        }
        
        self.searchText = searchText
        isClearCount = true
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: Constants.searchTimeInterval, target: self, selector: #selector(self.searching), userInfo: nil, repeats: true)
    }

    @objc private func searching() {
        timer.invalidate()
        if let searchText = searchText {
            searchNotification(with: searchText)
        }
    }
    
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        self.view.addSubview(viewForMask)
//        viewForMask.frame = self.view.bounds
//        viewForMask.backgroundColor = .clear
//        viewForMask.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
//    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        delegate?.searchBarSearchClicked()
        searchBar.setCancelButtonEnabled(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchText = nil
        isClearCount = false
        delegate?.searchBarCancelClicked()
        NotificationManager.shared.clearNotificationsCount(for: self.notificationCategory)
        updateNotifications(with: notifications)
//        viewForMask.removeFromSuperview()
    }
    
    //
    private func searchNotification(with searchText: String) {
        filter(with: filterType)
        self.filteredNotifications = self.filteredNotifications.filter({ (notification) -> Bool in
            let title = self.notificationCategory == .pool ? notification.title + notification.poolType + notification.data.name : notification.title + notification.data.name
            
            return notification.customContent.lowercased().contains(searchText.lowercased()) || title.lowercased().contains(searchText.lowercased())
        })
        
        self.filteredLocalNotifications = self.localNotifications.filter({ (notification) -> Bool in
            let title = notification.title + notification.body
            
            return title.lowercased().contains(searchText.lowercased())
        })
        
        checkNoDataLabelStatus()
        tableView.reloadDataScrollUp()
    }
    
}

//MARK: - No Items Methods
extension NotificationsViewController {
    func noCoinNotifications() {
        switch notificationCategory {
        case .coin:
            noDataButton!.setTransferButton(text: "add_coin_alert",subText: "for_coin_alert", view: self.view)
            noDataButton!.addTarget(self, action: #selector(goToCoinAlertPage), for: .touchUpInside)
            
        case .pool:
            guard DatabaseManager.shared.allPoolAccounts!.isEmpty else {
                noDataButton!.setTransferButton(text: "add_pool_account_alerts", subText: "for_receiving_notifications", view: self.view)
                noDataButton!.addTarget(self, action: #selector(goToSelectPage), for: .touchUpInside)
                return
            }
            noDataButton!.setTransferButton(text: "add_pool_account", subText: "for_pool_notifications", view: self.view)
            noDataButton!.addTarget(self, action: #selector(goToAccountPage), for: .touchUpInside)
        default:
            return
        }
    }
    
    @objc func goToSelectPage() {
        guard let newVC = SelectAccountViewController.initializeStoryboard() else {
            return }
        let navController = BaseNavigationController(rootViewController: newVC)
        navController.modalPresentationStyle = .overFullScreen
        navController.navigationBar.isHidden = true
        navController.view.backgroundColor = .clear
        self.present(navController, animated: true, completion: nil)
    }
}

// MARK: - Helper
class NotificationCacher {
    static let shared = NotificationCacher()
    
    private init(){}

    var coinNotification: [NotificationModel]?
    var poolNotification: [NotificationModel]?
    var infoNotification: [NotificationModel]?
    
    func removeData() {
        coinNotification = nil
        poolNotification = nil
        infoNotification = nil
    }
    
    func removeNotification(for notificationCategory: NotificationSegmentTypeEnum, with index: Int) {
        switch notificationCategory {
        case .coin:
            coinNotification?.remove(at: index)
        case .pool:
            poolNotification?.remove(at: index)
        case .info:
            infoNotification?.remove(at: index)
        }
    }
}
