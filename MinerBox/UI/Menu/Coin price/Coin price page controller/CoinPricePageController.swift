//
//  CoinPricePageController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/26/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

enum CoinPricePageEnum: String, CaseIterable {
    case all = "coin_price_all"
    case favorites = "coin_price_favorites"
    case alerts = "coin_price_alerts"
}

class CoinPricePageController: BaseViewController {
    
    // MARK: - Views
    @IBOutlet weak var searchBar: BaseSearchBar!
    @IBOutlet weak var segmentControl: BaseSegmentControl!
    @IBOutlet weak var coinSortView: CoinPriceSort!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    
    private var coinPriceVC: CoinPriceViewController?
    private var addButton = UIBarButtonItem()
    private var searchButton = UIBarButtonItem()
    private var filterBarButtonItem = BagedBarButtonItem()
    private let pageTypes = CoinPricePageEnum.allCases
    private var currentIndex: Int?
    private var currentController: BaseViewController?
    private var alerts = [AlertModel]()
    private var currentPage = CoinPricePageEnum.all
    private var previewPage = CoinPricePageEnum.all
    var isRefreshed = false
    var isFirstLaunch = true
    
    // MARK: - Static
    static func initializeStoryboard() -> CoinPricePageController? {
        return UIStoryboard(name: "Menu", bundle: nil).instantiateViewController(withIdentifier: CoinPricePageController.name) as? CoinPricePageController
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startupSetup()
        addObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.goToUserDeafaultPage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addBackgroundNotificaitonObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeBackgroundNotificaitonObserver()
    }
    
    override func languageChanged() {
        title = "coin_price".localized()
        noDataButton?.setTransferButton(text: "add_favorite", subText: "", view: self.view)
    }
    
    override func applicationEnteredToBackground(_ sender: Notification) {
        super.applicationEnteredToBackground(sender)
        UserDefaults.standard.set(false, forKey: "alertsIsDownloaded")
    }
    override func configNoDataButton() {
        super.configNoDataButton()
        noDataButton!.setTransferButton(text: "add_favorite", subText: "", view: self.view)
        noDataButton!.addTarget(self, action: #selector(addFavoriteCoin), for: .touchUpInside)
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(addAlert(_:)), name: .addAlert, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openedCoinDetail), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addFavorite(_:)), name: .addFavorite, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteFavorite(_:)), name: .deleteFavorite, object: nil)
    }
    
    @objc func addAlert(_ notification: NSNotification) {
        if let alert = notification.userInfo?["alert"] as? AlertModel {
            self.alerts.append(alert)
        }
    }
    
    @objc func addFavorite(_ notification: NSNotification) {
        if let coin = notification.userInfo?["favoriteCoin"] as? CoinModel {
            coinPriceVC?.setFavoriteCoin(with: coin)
        }
    }
    
    @objc func deleteFavorite(_ notification: NSNotification) {
        if let coin = notification.userInfo?["deleteFavorite"] as? CoinModel {
            coinPriceVC?.removeFavoriteCoin(with: coin)
        }
    }
    
    private func startupSetup() {
        coinPriceVC = CoinPriceViewController.initializeStoryboard()
        setupNavigation()
        setupSegmentControl()
        segmentSelected(index: 0)
        self.openedCoinDetail()
    }
    
    private func setupNavigation() {
        navigationController?.navigationBar.shadowImage = UIImage()
        addButton = UIBarButtonItem.customButton(self, action: #selector(addButtonAction(_:)), imageName: "bar_plus", tag: 1)
        searchButton = UIBarButtonItem.customButton(self, action: #selector(searchButtonAction(_:)), imageName: "bar_search")
        filterBarButtonItem = BagedBarButtonItem(target: self, action: #selector(filterButtonAction))
    }
    
    private func setupSegmentControl() {
        segmentControl.delegate = self
        let titles = pageTypes.map { $0.rawValue }
        segmentControl.setSegments(titles)
    }
    
    @objc private func searchButtonAction(_ sender: UIBarButtonItem) {
        showSearchBar()
    }
    
    @objc private func filterButtonAction() {
        guard let controller = CoinFilterViewController.initializeStoryboard() else { return }
        
        controller.delegate = coinPriceVC
        navigationController?.setViewControllers([self, controller], animated: true)
    }
    
    @objc private func addButtonAction(_ sender: UIBarButtonItem) {
        if currentPage == .favorites {
            self.addFavoriteCoin()
        } else {
            guard let controller = currentController as? CoinPriceAlertViewController else { return }
            
            controller.delegate = self
            controller.addAlertButtonAction()
        }
    }
    
    @objc func addFavoriteCoin() {
        guard let controller = AddCoinAlertViewController.initializeStoryboard(), coinPriceVC != nil else { return }
        
        controller.delegate = self
        controller.setFavoriteState(true, favoriteCoins: coinPriceVC!.favoriteCoins)
        navigationController?.setViewControllers([self, controller], animated: true)
    }
    
    @objc public func refreshPage(_ sender: Any?) {
        UserDefaults.standard.set(false, forKey: "alertsIsDownloaded")
        self.alerts.removeAll()
        self.coinPriceVC = nil
        guard let coinPriceVC = CoinPriceViewController.initializeStoryboard() else { return }
        
        self.coinPriceVC = coinPriceVC
        hideSearchBar()
        if currentIndex == 0 {
            setupCoinPriceVC(toRight: nil)
        } else {
            currentIndex = nil
            segmentControl.selectSegment(index: 0)
            setupCoinPriceVC(toRight: true)
        }
    }
    
    //sort
    private func hideSortButtons() {
        if !coinSortView.isHidden {
            UIView.animate(withDuration: Constants.animationDuration, animations: {
                self.coinSortView.alpha = 0
                self.coinSortView.isHidden = true
                self.view.layoutIfNeeded()
            })
        }
    }
    
    private func showSortButtons() {
        if coinSortView.isHidden {
            self.coinSortView.isHidden = false
            
            UIView.animate(withDuration: Constants.animationDuration) {
                self.coinSortView.alpha = 1
                self.view.layoutIfNeeded()
            }
        }
    }
    
    //search
    private func hideSearchBar() {
        if !searchBar.isHidden {
            searchBar.text = ""
            view.endEditing(true)
            let buttonItems = currentPage == .favorites ? [addButton, filterBarButtonItem,searchButton] : [filterBarButtonItem,searchButton]
            navigationItem.setRightBarButtonItems(buttonItems, animated: true)
            
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
            let buttonItems = currentPage == .favorites ? [addButton, filterBarButtonItem] : [filterBarButtonItem]
            navigationItem.setRightBarButtonItems(buttonItems, animated: true)
            
            UIView.animate(withDuration: Constants.animationDuration) {
                self.searchBarHeightConstraint.constant = 40
                self.searchBar.becomeFirstResponder()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func setupCoinPriceVC(toRight: Bool?, justFavorites: Bool = false) {
        guard let coinPriceVC = coinPriceVC else { return }
        
        coinPriceVC.delegate = self
        coinPriceVC.justFavorites = justFavorites
        coinPriceVC.checkUserForAds()
        searchBar.delegate = coinPriceVC
        coinSortView.delegate = coinPriceVC
        coinPriceVC.setSortView(coinSortView)
        changeChildVC(to: coinPriceVC, toRight: toRight)
        coinPriceVC.changeSegmented(with: justFavorites, at: previewPage)
        
    }
    
    private func setupCoinPriceAlertVC(toRight: Bool?) {
        guard let newVC = CoinPriceAlertViewController.initializeStoryboard() else { return }
        
        currentPage = CoinPricePageEnum.alerts
        Loading.shared.endLoading()
        newVC.delegate = self
        if UserDefaults.standard.bool(forKey: "alertsIsDownloaded") {
            newVC.alerts = alerts
        }
        changeChildVC(to: newVC, toRight: toRight)
    }
    
    func goToUserDeafaultPage() {
        if UserDefaults.standard.value(forKey: Constants.url_open_coinAlert) != nil  {
            segmentSelected(index: 2)
            segmentControl.selectSegment(index: 2)
            guard let controller = currentController as? CoinPriceAlertViewController else { return }
            controller.addAlertButtonAction()
            UserDefaults.standard.removeObject(forKey: Constants.url_open_coinAlert)
        }
        if UserDefaults.standard.value(forKey: Constants.url_open_add_favorite) != nil  {
            segmentSelected(index: 1)
            segmentControl.selectSegment(index: 1)
            
            addFavoriteCoin()
            UserDefaults.standard.removeObject(forKey: Constants.url_open_coinAlert)
        }
    }
    
    @objc private func openedCoinDetail()  {
        if let selectedCoinID = WidgetCointManager.shared.getSelectedCoinIds() {
            WidgetCointManager.shared.removeSelectedCoin(selectedCoinID)
            if let vc = CoinChartViewController.initializeStoryboard() {
                vc.setCoinId(selectedCoinID)
                navigationController?.setViewControllers([self, vc], animated: true)
            }
        }
        // Coin From WidgetKit
        if let selectedCoinID  =  UserDefaults.standard.value(forKey: "selected_widget_coin") {
            UserDefaults.standard.removeObject(forKey: "selected_widget_coin")
            if let vc = CoinChartViewController.initializeStoryboard() {
                vc.setCoinId(selectedCoinID as! String)
                navigationController?.setViewControllers([self, vc], animated: true)
            }
        }
    }
    
}

// MARK: - Segment control delegate

extension CoinPricePageController: BaseSegmentControlDelegate {
    func segmentSelected(index: Int) {
        guard index != currentIndex else { return }
        let toRight = currentIndex == nil ? nil : index > currentIndex!
        previewPage = currentPage
        
        switch pageTypes[index] {
        case .all:
            currentPage = CoinPricePageEnum.all
            noDataButton?.isHidden = true
            setupCoinPriceVC(toRight: toRight)
        case.favorites:
            currentPage = CoinPricePageEnum.favorites
            setupCoinPriceVC(toRight: toRight, justFavorites: true)
            Loading.shared.endLoading()
        case .alerts:
            noDataButton?.isHidden = true
            setupCoinPriceAlertVC(toRight: toRight)
        }
        
        switch pageTypes[index] {
        case .all:
            showSortButtons()
            navigationItem.setRightBarButtonItems([filterBarButtonItem,searchButton], animated: true)
        case .favorites:
            showSortButtons()
            navigationItem.setRightBarButtonItems([addButton, filterBarButtonItem,searchButton], animated: true)
        case .alerts:
            hideSearchBar()
            //            hideFilter()
            hideSortButtons()
            navigationItem.setRightBarButtonItems([addButton], animated: true)
        }
        
        currentIndex = index
    }
    
    private func changeChildVC(to controller: BaseViewController, toRight: Bool?) {
        addChild(controller)
        
        guard let controllerView = controller.view else { return }
        let from = currentController
        controllerView.tag = 10
        
        if let viewWithTag = self.containerView.viewWithTag(10) {
            viewWithTag.removeFromSuperview()
        }
        
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
                if controller !== self.currentController {
                    from?.willMove(toParent: nil)
                    from?.view.removeFromSuperview()
                    from?.removeFromParent()
                }
            }
        } else { // Change without animation. Just replace
            controllerView.frame = containerView.bounds
            if controller !== self.currentController {
                from?.willMove(toParent: nil)
                from?.view.removeFromSuperview()
                from?.removeFromParent()
            }
        }
        
        controller.didMove(toParent: self)
        currentController = controller
    }
}

// MARK: - CoinPrice page delegate
extension CoinPricePageController: CoinPriceViewControllerDelegate {
    func ignoreUserActions(_ bool: Bool) {
        coinSortView.isUserInteractionEnabled = bool
        searchButton.isEnabled = bool
        filterBarButtonItem.isEnabled = bool
        segmentControl.isUserInteractionEnabled = bool
        containerView.isUserInteractionEnabled = bool
    }
    
    func searchBarCancelClicked() {
        hideSearchBar()
    }
    
    func showSearchBar(searchText: String) {
        searchBar.text = searchText
        showSearchBar()
    }
    
    func viewLoaded(controller: CoinPriceViewController) {
        guard let text = searchBar.text else { return }
        controller.searchBar(searchBar, textDidChange: text)
    }
    
    func startLoading() {
        Loading.shared.startLoading(ignoringActions: true, views: [containerView, coinSortView, segmentControl], barButtons: [filterBarButtonItem,searchButton])
    }
    
    func endLoading() {
        Loading.shared.endLoading(views: [self.containerView, self.coinSortView, self.segmentControl], barButtons: [searchButton,filterBarButtonItem])
        self.view.isUserInteractionEnabled = true
    }
    
    func changeSegmentedControlState() {
        if self.currentPage == CoinPricePageEnum.all {
            self.segmentSelected(index: 0)
        }
        if TabBarRuningPage.shared.lastSelectedPage.rawValue == 1 {
            Loading.shared.endLoading(views: [self.containerView, self.coinSortView, self.segmentControl], barButtons: [filterBarButtonItem,searchButton])
        }
    }
    
    func setFilterState(isHidden: Bool) {
        DispatchQueue.main.async {
            self.filterBarButtonItem.setBageIsHidden(isHidden)
        }
    }
    
    func isFavoriteEnpty(isEmpty: Bool){
        noDataButton?.isHidden = !isEmpty
    }
    
    func endEditing(_ bool: Bool) {
        view.endEditing(bool)
    }
    
}


// MARK: - CoinPrice Alert delegate
extension CoinPricePageController: CoinPriceAlertViewControllerDelegate, AddCoinAlertViewControllerDelegate{
    func editAlert(with editableAlert: AlertModel) {
        guard !alerts.isEmpty else { return }
        
        for (index, alert) in alerts.enumerated() {
            if alert.id == editableAlert.id {
                alerts[index] = editableAlert
            }
        }
    }
    
    func setAlerts(alerts: [AlertModel]) {
        self.alerts = alerts
    }
    
    func deleteAlert(with alert: AlertModel) {
        self.alerts.removeAll { $0.isEqual(alert) }
        AlertCacher.shared.alerts = self.alerts
    }
    
    func deleteAlerts(with coinId: String) {
        self.alerts.removeAll { $0.coinID == coinId }
        AlertCacher.shared.alerts = self.alerts
    }
    
    func ignorUIEnabled(_ bool: Bool) {
        ignoreUserActions(bool)
    }
    
    //AddCoinAlertViewControllerDelegate
    func addFavorite(with favoriteCoin: CoinModel) {
        coinPriceVC?.setFavoriteCoin(with: favoriteCoin)
    }
}


