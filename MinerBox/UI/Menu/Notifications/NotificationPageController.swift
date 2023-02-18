//
//  NotificationPageController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/17/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

protocol NotificationPageControllerDelegate: AnyObject {
    func deleteAllNotifications() -> Void
    func setCategory(_ category: NotificationSegmentTypeEnum) -> Void
    func filterNotification(by poolType: String)
    func cancelTask()
}

class NotificationPageController: BaseViewController {

    // MARK: - Views
    @IBOutlet fileprivate weak var searchBar: BaseSearchBar!
    @IBOutlet fileprivate weak var segmentControl: BaseSegmentControl!
    @IBOutlet fileprivate weak var containerView: UIView!
    @IBOutlet fileprivate weak var filterSegmentControl: BaseSegmentControl!
    @IBOutlet fileprivate weak var filterParentView: UIStackView!
    @IBOutlet fileprivate weak var searchBarHeightConstraint: NSLayoutConstraint!
    
    private let notificationCategories = NotificationSegmentTypeEnum.allCases

    private var currentIndex: Int?
    private var previewFilterIndex: Int?
    private var currentController: NotificationsViewController?

    private var trashButton: UIBarButtonItem!
    private var filterButton: UIBarButtonItem!
    private var searchButton: UIBarButtonItem!
    private var alertModel = NotificationAlertDataSource.alertDataModel
    
//    private var filteredPoolType: String?
    
    private var firstAppear = true
    
    private var isRefreshed = false
    
    weak var delegate: NotificationPageControllerDelegate?
    
    // MARK: - Static
    static func initializeStoryboard() -> NotificationPageController? {
        return UIStoryboard(name: "Menu", bundle: nil).instantiateViewController(withIdentifier: NotificationPageController.name) as? NotificationPageController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
//      setupSegmentControl()
        addObservers()
        getNewNotificaitonsCount()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSearchBar()
        if firstAppear {
            setupSegmentControl()
            firstAppear = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCacher.shared.removeData()
        self.currentIndex = nil
        delegate?.cancelTask()
    }
    
    override func languageChanged() {
        title = "notifications".localized()
        alertModel = NotificationAlertDataSource.alertDataModel
    }
    
    @objc public func refreshPage(_ sender: Any?) {
        isRefreshed = true
        segmentSelected(segmentControl, index: 0)
    }
    
    //MARK: -- Navigation Setup
    private func setupNavigation() {
        navigationController?.navigationBar.shadowImage = UIImage()
        trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteNotifications))
        filterButton = UIBarButtonItem.customButton(self, action: #selector(filterPools), imageName: "filter-list", tag: 2)
        searchButton = UIBarButtonItem.customButton(self, action: #selector(searchButtonAction(_:)), imageName: "bar_search", tag: 3)

        trashButton.isEnabled = false
        filterButton.isEnabled = false
        searchButton.isEnabled = false
    }
    
    @objc func filterPools() {
        UIView.animate(withDuration: Constants.animationDuration ) {
            self.filterParentView.isHidden.toggle()
            self.view.layoutIfNeeded()
        }
        if filterParentView.isHidden {
            resetFilterSegmen()
        }
    }
    
    @objc func deleteNotifications() {
        if let delegate = delegate {
            delegate.deleteAllNotifications()
        }
    }
    
    @objc private func searchButtonAction(_ sender: UIBarButtonItem) {
        showSearchBar()
    }
    
    //search
    private func hideSearchBar() {
        if !searchBar.isHidden {
            searchBar.text = ""
            view.endEditing(true)
            let buttons: [UIBarButtonItem] = currentIndex == 1 ? [trashButton, filterButton, searchButton] : [trashButton, searchButton]
            navigationItem.setRightBarButtonItems(buttons, animated: false)
            
            UIView.animate(withDuration: Constants.animationDuration, animations: {
                self.searchBarHeightConstraint.constant = 0
                self.view.layoutIfNeeded()
            }) { (_) in
                self.searchBar.isHidden = true
            }
        }
    }

    private func showSearchBar() {
        if searchBar.isHidden {
            searchBar.isHidden = false
            let buttonItems: [UIBarButtonItem] = currentIndex == 1 ? [trashButton, filterButton] : [trashButton]
            navigationItem.setRightBarButtonItems(buttonItems, animated: true)
            
            UIView.animate(withDuration: Constants.animationDuration) {
                self.searchBarHeightConstraint.constant = 40
                self.searchBar.becomeFirstResponder()
                self.view.layoutIfNeeded()
            }
        }
    }

    //MARK: -- SegmentControl Setup
    private func setupSegmentControl() {
        let segmentTitles = notificationCategories.map { $0.rawValue }
        let filterTitles = NotificationFilter.allCases.map { $0.rawValue }

        segmentControl.delegate = self
        filterSegmentControl.delegate = self
                
        segmentControl.setSegments(segmentTitles)
        filterSegmentControl.setRoundedSpacingSegment(filterTitles)
        
        selectCurrentPage()
        filterSegmentControl.unselect()
    }
    
    //MARK: -- Observers code part
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(getNewNotificaitonsCount), name: Notification.Name(Constants.notificationCountChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(selectCurrentPage(_:)), name: .goToNotifationPage, object: nil)
    }

    @objc private func selectCurrentPage(_ notification: Notification? = nil) {
        segmentControl.selectSegment(index: NotificationRuningPage.shared.selectedPage.rawValue)
    }
    
    @objc private func getNewNotificaitonsCount() {
        guard let userId = self.user?.id, let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") else { return }
        
        let coinCount = userDefaults.integer(forKey: "\(userId)coinNotificationsCount")
        let hashrateCount = userDefaults.integer(forKey: "\(userId)hashrateNotificationsCount")
        let reportedHashrateCount = userDefaults.integer(forKey: "\(userId)repHashrateNotificationsCount")
        let workerCount = userDefaults.integer(forKey: "\(userId)workerNotificationsCount")
        let infoCount = userDefaults.integer(forKey: "\(userId)infoNotificationsCount")
        let payoutCount = userDefaults.integer(forKey: "\(userId)payoutNotificationsCount")

        segmentControl.setBadgeNumber(coinCount, for: 0)
        segmentControl.setBadgeNumber(hashrateCount + workerCount + payoutCount + reportedHashrateCount, for: 1)
        segmentControl.setBadgeNumber(infoCount, for: 2)
    }
    
    //MARK: -- Change child VC
    private func changeChildVC(to controller: NotificationsViewController, toRight: Bool?) {
        addChild(controller)
        searchBar.text = nil
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
                controllerView.frame = toFrame
            }) { (_) in
                from?.willMove(toParent: nil)
                from?.view.removeFromSuperview()
                from?.removeFromParent()
            }
        } else { // Change without animation. Just replace
            controllerView.frame = containerView.bounds

            from?.willMove(toParent: nil)
            from?.view.removeFromSuperview()
            from?.removeFromParent()
        }

        controller.didMove(toParent: self)
        currentController = controller
    }

}

//MARK: -NotificationsViewControllerDelegate
extension NotificationPageController: NotificationsViewControllerDelegate {
    func searchBarCancelClicked() {
        hideSearchBar()
    }
    
    func searchBarSearchClicked() {
        endEditing()
        searchBar.setCancelButtonEnabled(true)
    }
    
    func showSearchBar(searchText: String) {
        print("showSearchBar")
    }
    
    func disableButton(_ bool: Bool) {
        trashButton.isEnabled = !bool
        filterButton.isEnabled = !bool
        searchButton.isEnabled = !bool
        view.layoutIfNeeded()
    }
    
    func endEditing() {
        view.endEditing(true)
        searchBar.setCancelButtonEnabled(true)
    }
    
    func startLoading() {
        Loading.shared.startLoading(ignoringActions: true, for: view)
    }
    
    func endLoading() {
        Loading.shared.endLoading(for: view)
    }
}

// MARK: - Segment control delegate
extension NotificationPageController: BaseSegmentControlDelegate {
    func segmentSelected(_ sender: BaseSegmentControl, index: Int) {
        if sender == segmentControl {
            segmentAction(with: index)
        } else if sender == filterSegmentControl {
            filterSegmentAction(with: index)
        }
    }
}

// MARK: - Actions
extension NotificationPageController {
    private func segmentAction(with index: Int) {
        if isRefreshed {
            isRefreshed = false
            currentIndex = nil
            segmentControl.selectSegment(index: 0)
        }
        
        if index != currentIndex, let newVC = NotificationsViewController.initializeStoryboard() {
            delegate = newVC
            newVC.delegate = self
            searchBar.delegate = newVC
            navigationItem.setRightBarButton(nil, animated: false)
            let notificationType = notificationCategories[index]
            
            filterParentView.isHidden = true
            filterSegmentControl.unselect()
            previewFilterIndex = nil
            
            delegate?.setCategory(notificationType)
            let toRight = currentIndex == nil ? nil : index > currentIndex!
            changeChildVC(to: newVC, toRight: toRight)
            
            
            let buttons: [UIBarButtonItem] = index == 1 ? [trashButton, filterButton, searchButton] : [trashButton, searchButton]
            navigationItem.setRightBarButtonItems(buttons, animated: false)
            currentIndex = index
            segmentControl.setBadgeNumber(0, for: index)
            navigationController?.popToRootViewController(animated: true)

        }
    }
    
    private func filterSegmentAction(with index: Int) {
        if previewFilterIndex == index {
            resetFilterSegmen()
        } else {
            let filterType = NotificationFilter.filter(with: index)
            delegate?.filterNotification(by: filterType)
            previewFilterIndex = index
        }
    }
    
    private func resetFilterSegmen() {
        delegate?.filterNotification(by: "all")
        filterSegmentControl.unselect()
        previewFilterIndex = nil
    }
}

fileprivate enum NotificationFilter: String, CaseIterable {
    case workers = "worker"
    case hashrate = "hashrate"
    case payouts = "account_payouts"
    case reportedHashrate = "reported"
    static func filter(with index: Int) -> String {
        switch index {
        case 0:
            return "worker_alert"
        case 1:
            return "hashrate_alert"
        case 2:
            return "payout_alert"
        case 3:
            return "repHash_alert"
        default:
            return "all"
        }
    }
}
