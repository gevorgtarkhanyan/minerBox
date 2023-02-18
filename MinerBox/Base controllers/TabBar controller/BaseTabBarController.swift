//
//  BaseTabBarController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/24/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import Localize_Swift
import FirebaseCrashlytics
import TinyConstraints
import SwiftUI

class BaseTabBarController: UITabBarController {
    var bool: Bool = true
    var height: Constraint?
    let customTabBarView = UIView()
    let customTabBarViewHeader = UIView()
    let miniView = UIView()
    var customTabBarCollectionView: UICollectionView?
    var selectedCustomBarItem = ""
    private var shouldSelectIndex = -1
    private var toolbarIconNames = [String]()
    
    // Change status bar text color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return darkMode ? .lightContent : .default
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        addObservers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addObservers()
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
        delegate = self
        configToolbar()
        getToolbarIconNames()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toolBarVisibleConfig()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        toolBarVisibleConfig()
        self.customTabBarCollectionView?.collectionViewLayout.invalidateLayout()
    }
    
    private func configToolbar() {
        var spacing = CGFloat(0)
        if UIDevice.current.userInterfaceIdiom == .pad {
            spacing = CGFloat(40)
        } else {
            spacing = CGFloat(20)
        }
       
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.itemSize = CGSize(width: 35, height: 35)
        layout.scrollDirection = .horizontal
        
        customTabBarCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)

        let cellNib = UINib(nibName: TabBarCollectionViewCell.name, bundle: nil)
        customTabBarCollectionView?.register(cellNib, forCellWithReuseIdentifier: TabBarCollectionViewCell.name)
        customTabBarView.roundCorners([.topRight, .topLeft], radius: 10)
        
        
        customTabBarCollectionView!.delegate = self
        customTabBarCollectionView!.dataSource = self
        setupLongGestureRecognizerOnCollection()
        
        view.addSubview(customTabBarView)
        view.addSubview(customTabBarViewHeader)
        customTabBarViewHeader.addSubview(miniView)
        miniView.backgroundColor = .barDeselectedItem
        customTabBarCollectionView?.backgroundColor = .clear
        height = customTabBarView.height(0)
        miniView.center(in: customTabBarViewHeader)
        miniView.width(34)
        miniView.height(3)
        customTabBarCollectionView?.isScrollEnabled = false
        miniView.roundCorners(radius: 3)
        customTabBarViewHeader.height(14)
        customTabBarViewHeader.width(155)
        customTabBarViewHeader.centerX(to: view)
        customTabBarViewHeader.roundCorners([.topLeft, .topRight], radius: 10)
        customTabBarViewHeader.edges(to: self.customTabBarView, excluding: [.right, .bottom, .left], insets: TinyEdgeInsets(top: -14, left: 0, bottom: 0, right: 0))
        customTabBarView.edges(to: self.tabBar, excluding: [.bottom,.top], insets: TinyEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        if height?.constant == 50 {
            customTabBarView.bottomToTop(of: tabBar).constant = 50
        }else {
            customTabBarView.bottomToTop(of: tabBar).constant = 0
        }
        
        customTabBarView.addSubview(customTabBarCollectionView!)
        customTabBarCollectionView!.edges(to: customTabBarView, insets: TinyEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(jest))
        swipeGestureRecognizer.direction = .up
        let swipeGestureRecognizerDown = UISwipeGestureRecognizer(target: self, action: #selector(jest))
        swipeGestureRecognizerDown.direction = .down
        let dislikeGetchur = UITapGestureRecognizer.init(target: self, action: #selector(jest))
        
        customTabBarViewHeader.addGestureRecognizer(dislikeGetchur)
        customTabBarViewHeader.addGestureRecognizer(swipeGestureRecognizer)
        customTabBarViewHeader.addGestureRecognizer(swipeGestureRecognizerDown)
    }
    
   private  func toolBarVisibleConfig() {
       if height?.constant == 50{
           customTabBarView.bottomToTop(of: tabBar).constant = 50
           UIApplication.getTopViewController()?.navigationController?.isToolbarHidden = false
           UIApplication.getTopViewController()?.navigationController?.toolbar.isHidden = true
           UIApplication.getTopViewController()?.navigationController?.edgesForExtendedLayout = UIRectEdge.bottom
           UIApplication.getTopViewController()?.navigationController?.extendedLayoutIncludesOpaqueBars = true
       } else {
           customTabBarView.bottomToTop(of: tabBar).constant = 0
           UIApplication.getTopViewController()?.navigationController?.isToolbarHidden = true
           UIApplication.getTopViewController()?.navigationController?.toolbar.isHidden = true
       }
    }
    
    func getTabBarHeight() {
       guard let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") else { return }
       
       let userId = DatabaseManager.shared.currentUser != nil ? DatabaseManager.shared.currentUser!.id : ""
        
        height?.constant =  CGFloat(userDefaults.integer(forKey: "\(userId)tabBarHeight" ))
           
    }
    
     func getToolbarIconNames() {
        guard let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") else { return }
        
        let userId = DatabaseManager.shared.currentUser != nil ? DatabaseManager.shared.currentUser!.id : ""
        if let toolbarIconNames = userDefaults.array(forKey: "\(userId)toolBarItems") as? [String] {
            self.toolbarIconNames = toolbarIconNames
            customTabBarCollectionView!.reloadData()
     
        } else {
            toolbarIconNames = ToolbarTypeEnum.allCases.map { $0.rawValue }
            customTabBarCollectionView!.reloadData()
        }
         
         if toolbarIconNames == [] {
             height?.constant = 0
             customTabBarView.isHidden = true
             customTabBarViewHeader.isHidden = true
             toolBarVisibleConfig()
         } else {
             getTabBarHeight()
             customTabBarView.isHidden = false
             customTabBarViewHeader.isHidden = false
             toolBarVisibleConfig()
         }
         
    }
    
    @objc func jest() {

        self.height?.constant = self.bool ? 50 : 0
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            self.customTabBarView.layoutIfNeeded()
            self.customTabBarViewHeader.layoutIfNeeded()
        }
        bool.toggle()
        saveTabBarHeight()
        
    }
    
    private func saveTabBarHeight() {
        guard let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") else { return }

        if let userId = NetworkManager.shared.currentUser?.id {
            userDefaults.set(height?.constant, forKey: "\(userId)tabBarHeight")
        } else {
            userDefaults.set(height?.constant, forKey: "tabBarHeight")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Startup default setup
extension BaseTabBarController {
    fileprivate func startupSetup() {
        setupUI()
        AppRateManager.shared.setupRateApp()
        checkForUpdate()
        languageChanged()
        setCrashliticsInfo()
        getNotificationsCount()
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(getNotificationsCount), name: NSNotification.Name(Constants.notificationCountChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: Notification.Name(LCLLanguageChangeNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: Notification.Name(Constants.themeChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changePage(_:)), name: .goToTabBarPage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTabBarItems(_:)), name: .reloadTabBarItems, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationOpenedFromBackground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func applicationOpenedFromBackground(_ sender: Notification) {
        if selectedIndex == 1 {
            NotificationCenter.default.removeObserver(viewControllers?[selectedIndex].children.first as Any)
            TabBarRuningPage.shared.changeLastPage(to: .coin)
            guard let coinPricePageVC = CoinPricePageController.initializeStoryboard() else { return }
            let navVC = BaseNavigationController(rootViewController: coinPricePageVC)
            viewControllers?[selectedIndex] = navVC
            tabBar.items?[selectedIndex].image = UIImage(named: "tabBar_coin_price")?.withRenderingMode(.automatic)
        }
        
        if selectedIndex == 2 {
            NotificationCenter.default.removeObserver(viewControllers?[selectedIndex].children.first as Any)
            refreshNotificationPage()
            TabBarRuningPage.shared.changeLastPage(to: .notifications)
        }

//        if selectedIndex == 3 {
//            guard !isNewsContentControllerAppeared() else { return }
//            NotificationCenter.default.removeObserver(viewControllers?[selectedIndex].children.first as Any)
//            TabBarRuningPage.shared.changeLastPage(to: .news)
//            guard let newsVC = NewsPageController.initializeStoryboard() else { return }
//            NewsCacher.shared.removeNewsData()
//            let navVC = BaseNavigationController(rootViewController: newsVC)
//            viewControllers?[selectedIndex] = navVC
//            tabBar.items?[selectedIndex].image = UIImage(named: "tabBar_news")?.withRenderingMode(.automatic)
//        }
//    }
//
//    private func isNewsContentControllerAppeared() -> Bool {
//        guard let newsVC = viewControllers?[3] else { return false }
//        guard let navigation = newsVC as? BaseNavigationController else { return  false }
//        if navigation.viewControllers.count > 1, let vc = navigation.viewControllers.last {
//            if let contentVC = vc as? NewsContentViewController {
//                if contentVC.isViewLoaded {
//                    return true
//                }
//            }
//        }
//        return  false
    }
    
    private func refreshNotificationPage() {
//        NotificationRuningPage.shared.changePage(to: .coin)
        guard let notificationPageC = NotificationPageController.initializeStoryboard() else { return }
        let navVC = BaseNavigationController(rootViewController: notificationPageC)
        viewControllers?[selectedIndex] = navVC
        tabBar.items?[selectedIndex].image = UIImage(named: "tabBar_notifications")?.withRenderingMode(.automatic)
    }
    
    @objc fileprivate func changePage(_ sender: Notification) {
        guard let index = sender.object as? Int else { return }
        selectedIndex = index
        TabBarRuningPage.shared.changeLastPage(to: TabBarRuningPageType(rawValue: index)!)
        checkOpenedFromWidget()
        customTabBarCollectionView?.reloadData()
        toolBarVisibleConfig()
        
    }
    
    @objc fileprivate func reloadTabBarItems(_ sender: Notification) {
        getToolbarIconNames()
        customTabBarCollectionView?.reloadData()
        
    }
    
     fileprivate func checkOpenedFromWidget() {
        if  UserDefaults.standard.value(forKey: "selected_widget_account") as? String != nil  {
            
            if let accountsPage =  viewControllers?[0].children.first as?  AccountsViewController {
                accountsPage.navigationController?.popToRootViewController(animated: true)
                accountsPage.getAccounts()
            }
        }
    }
    
    @objc fileprivate func themeChanged() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.changeColors()
        }
    }
    
    fileprivate func setCrashliticsInfo() {
        if DatabaseManager.shared.currentUser == nil {
            Crashlytics.crashlytics().setUserID("currentUser = nil")
        }
        if let user = DatabaseManager.shared.currentUser {
            Crashlytics.crashlytics().setUserID(user.name + " " + user.email)
        }
    }
}

// MARK: - Setup UI
extension BaseTabBarController {
    fileprivate func setupUI() {
        chengeFont()
        changeColors()
        
        selectedIndex = TabBarRuningPage.shared.selectedPage.rawValue
        TabBarRuningPage.shared.changeLastPage(to: TabBarRuningPageType(rawValue: TabBarRuningPage.shared.selectedPage.rawValue)!)
        tabBar.shadowImage = UIImage()
    }
    
    fileprivate func chengeFont() {
        let fontAttribute = Constants.mediumFont.withSize(10)
        tabBarItem.setTitleTextAttributes([NSAttributedString.Key.font: fontAttribute], for: .normal)
    }
}

// MARK: - Actions
extension BaseTabBarController {
    @objc fileprivate func getNotificationsCount() {
        
        guard
            let userId = DatabaseManager.shared.currentUser?.id,
            let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox")
        else { return }
        
        let coinCount = userDefaults.integer(forKey: "\(userId)coinNotificationsCount")
        let hashrateCount = userDefaults.integer(forKey: "\(userId)hashrateNotificationsCount")
        let reportedHashrateCount = userDefaults.integer(forKey: "\(userId)repHashrateNotificationsCount")
        let workerCount = userDefaults.integer(forKey: "\(userId)workerNotificationsCount")
        let infoCount = userDefaults.integer(forKey: "\(userId)infoNotificationsCount")
        let payoutCount = userDefaults.integer(forKey: "\(userId)payoutNotificationsCount")
        
        let allCount = coinCount + hashrateCount + workerCount + infoCount + payoutCount + reportedHashrateCount
        
        guard let controllers = viewControllers else { return }
        for (index, viewController) in controllers.enumerated() {
            guard
                let navigation = viewController as? BaseNavigationController,
                navigation.viewControllers.first is NotificationPageController,
                let tabItem = tabBar.items?[index]
            else { continue }
            tabItem.badgeValue = allCount > 0 ? "\(allCount)" : nil
        }
    }
    
    @objc fileprivate func languageChanged() {
        let cases = MenuItemEnum.allCases
        guard let barItems = tabBar.items, barItems.count == cases.count else { return }
        
        for i in cases.indices {
            barItems[i].title = cases[i].rawValue.localized()
        }
    }
    
    @objc fileprivate func changeColors() {
        tabBar.barStyle = darkMode ? .black : .default
        tabBar.isTranslucent = false
        customTabBarViewHeader.backgroundColor = darkMode ? .barDark : .barLight
        customTabBarView.backgroundColor = darkMode ? .barDark : .barLight
        tabBar.barTintColor = darkMode ? .barDark : .barLight
        tabBar.tintColor = .barSelectedItem
        tabBar.layoutIfNeeded()
        
        if #available(iOS 10.0, *) {
            tabBar.unselectedItemTintColor = .barDeselectedItem
        }
    }
}

// MARK: - Check for application update
extension BaseTabBarController {
    func checkForUpdate() {
        AppUpdateHelper.checkAndAskForUpdate {
            if let reviewURL = URL(string: "itms-apps://itunes.apple.com/app/minerbox/id1445878254?ls=1&mt=8"), UIApplication.shared.canOpenURL(reviewURL) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(reviewURL)
                }
            }
        }
    }
}

// MARK: - TabBar delegate for animation switch
extension BaseTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        guard let tabViewControllers = tabBarController.viewControllers, let toIndex = tabViewControllers.firstIndex(of: viewController) else {
                return false
            }
            animateToTab(toIndex: toIndex)
            return true
        }

        func animateToTab(toIndex: Int) {
            guard let tabViewControllers = viewControllers,
                let selectedVC = selectedViewController else { return }

            guard let fromView = selectedVC.view,
                let toView = tabViewControllers[toIndex].view,
                  let fromIndex = tabViewControllers.firstIndex(of: selectedVC),
                fromIndex != toIndex else { return }


            // Add the toView to the tab bar view
            fromView.superview?.addSubview(toView)

            // Position toView off screen (to the left/right of fromView)
            let screenWidth = UIScreen.main.bounds.size.width
            let scrollRight = toIndex > fromIndex
            let offset = (scrollRight ? screenWidth : -screenWidth)
            toView.center = CGPoint(x: fromView.center.x + offset, y: toView.center.y)

            // Disable interaction during animation
            view.isUserInteractionEnabled = false

            UIView.animate(withDuration: 0.5,
                           delay: 0.0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 0,
                           options: .curveEaseOut,
                           animations: {
                            // Slide the views by -offset
                            fromView.center = CGPoint(x: fromView.center.x - offset, y: fromView.center.y)
                            toView.center = CGPoint(x: toView.center.x - offset, y: toView.center.y)

            }, completion: { finished in
                // Remove the old view from the tabbar view.
                fromView.removeFromSuperview()
                self.selectedIndex = toIndex
                self.view.isUserInteractionEnabled = true
            })
        }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let navigation = viewController as? BaseNavigationController else { return }
        if navigation.viewControllers.count > 1, let vc = navigation.viewControllers.last {
            vc.navigationController?.popToRootViewController(animated: false)
        }
        guard let newVC = navigation.viewControllers.first else { return }
        
        Loading.shared.endLoading()
    
        guard selectedIndex != TabBarRuningPage.shared.lastSelectedPage.rawValue else {
            return
        }
        
        if TabBarRuningPage.shared.lastSelectedPage == .notifications {
            NotificationCenter.default.post(name: .stopNotificationTask, object: nil, userInfo: nil)
        }

        if let accountsPage = newVC as? AccountsViewController {
            TabBarRuningPage.shared.changeLastPage(to: .accounts)
            if accountsPage.isViewLoaded {
//                accountsPage.refreshPage(nil)
                accountsPage.getAccounts()
            }
            customTabBarCollectionView?.reloadData()
            toolBarVisibleConfig()
        }
        if let coinPrice = newVC as? CoinPricePageController {
            TabBarRuningPage.shared.changeLastPage(to: .coin)
            if coinPrice.isViewLoaded {
                coinPrice.isRefreshed = true
                coinPrice.refreshPage(nil)
            }
            customTabBarCollectionView?.reloadData()
            toolBarVisibleConfig()
        }
        
        if let notificationPageC = newVC as? NotificationPageController {
            TabBarRuningPage.shared.changeLastPage(to: .notifications)
            if notificationPageC.isViewLoaded {
                notificationPageC.refreshPage(nil)
            }
            customTabBarCollectionView?.reloadData()
            toolBarVisibleConfig()
        }
        
        if let WhatToMineVC = newVC as? WhatToMineViewController {
            TabBarRuningPage.shared.changeLastPage(to: .whatToMine)
            if WhatToMineVC.isViewLoaded {
                WhatToMineVC.refreshPage(nil)
            }
            customTabBarCollectionView?.reloadData()
            toolBarVisibleConfig()
        }
        if let _ = newVC as? MoreViewController {
            TabBarRuningPage.shared.changeLastPage(to: .settings)
            customTabBarCollectionView?.reloadData()
            
            toolBarVisibleConfig()
        }
        
    }
}


// MARK: - CollectionView
extension BaseTabBarController : UICollectionViewDelegate, UICollectionViewDataSource,UIGestureRecognizerDelegate,UICollectionViewDelegateFlowLayout
{
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return toolbarIconNames.count
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabBarCollectionViewCell.name, for: indexPath) as! TabBarCollectionViewCell
    
    
    cell.tabBarImageView.image = UIImage(named: toolbarIconNames[indexPath.row])
    if  toolbarIconNames[indexPath.row] == selectedCustomBarItem &&  UIApplication.getTopViewController()?.title == selectedCustomBarItem.localized() {
    cell.tabBarImageView.backgroundColor = .barSelectedItem
    } else {
        cell.tabBarImageView.backgroundColor = .barDeselectedItem
    }
    if  toolbarIconNames[indexPath.row] == selectedCustomBarItem &&  UIApplication.getTopViewController()?.title == "wallets".localized() {
        cell.tabBarImageView.backgroundColor = .barSelectedItem
    }
    return cell
}

func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let item = ToolbarTypeEnum(rawValue: toolbarIconNames[indexPath.row])
    let cell = collectionView.cellForItem(at: indexPath) as! TabBarCollectionViewCell
    guard let AnalyticsVC = AnalyticsViewController.initializeStoryboard() else { return }
    guard let ConverterVC = ConverterViewController.initializeStoryboard() else { return }
    guard let BalanceVC = BalanceViewController.initializeStoryboard() else { return }
    guard let NewsVC = NewsPageController.initializeStoryboard() else { return }
    guard let AddressVC = AddressViewController.initializeStoryboard() else { return }
    switch item {
        
        
    case .analytics:
        
        guard UIApplication.getTopViewController()?.title != "more_analytics".localized() else { return }
        selectedIndex = 4
        UIApplication.getTopViewController()?.navigationController?.popToRootViewController(animated: false)
        UIApplication.getTopViewController()?.navigationController?.pushViewController(AnalyticsVC, animated: false)
        TabBarRuningPage.shared.changeLastPage(to: .customTabBar)
        UIApplication.getTopViewController()?.navigationItem.hidesBackButton = true
        cell.tabBarImageView.backgroundColor = .barSelectedItem
        selectedCustomBarItem = "more_analytics"
    case .converter:
        guard UIApplication.getTopViewController()?.title != "more_converter".localized() else { return }
        selectedIndex = 4
        UIApplication.getTopViewController()?.navigationController?.popToRootViewController(animated: false)
        UIApplication.getTopViewController()?.navigationController?.pushViewController(ConverterVC, animated: false)
        TabBarRuningPage.shared.changeLastPage(to: .customTabBar)
       
        UIApplication.getTopViewController()?.navigationItem.hidesBackButton = true
        cell.tabBarImageView.backgroundColor = .barSelectedItem
        selectedCustomBarItem = "more_converter"
        toolBarVisibleConfig()
        
    case .income:
        
        guard UIApplication.getTopViewController()?.title != "income".localized() else { return }
        selectedIndex = 4
        UIApplication.getTopViewController()?.navigationController?.popToRootViewController(animated: false)
        UIApplication.getTopViewController()?.navigationController?.pushViewController(BalanceVC, animated: false)
        TabBarRuningPage.shared.changeLastPage(to: .customTabBar)
        UIApplication.getTopViewController()?.navigationItem.hidesBackButton = true
        cell.tabBarImageView.backgroundColor = .barSelectedItem
        selectedCustomBarItem = "income"
        toolBarVisibleConfig()
    case .news:
        guard UIApplication.getTopViewController()?.title != "news".localized() else { return }
        selectedIndex = 4
        UIApplication.getTopViewController()?.navigationController?.popToRootViewController(animated: false)
        UIApplication.getTopViewController()?.navigationController?.pushViewController(NewsVC, animated: false)
        TabBarRuningPage.shared.changeLastPage(to: .customTabBar)
        UIApplication.getTopViewController()?.navigationItem.hidesBackButton = true
        cell.tabBarImageView.backgroundColor = .barSelectedItem
        selectedCustomBarItem = "news"
        toolBarVisibleConfig()
        if NewsVC.isViewLoaded {
            NewsCacher.shared.removeNewsData()
            NewsVC.refreshPage(nil)
        }
    case .wallet:
        guard UIApplication.getTopViewController()?.title != "wallets".localized() else { return }
        selectedIndex = 4
        UIApplication.getTopViewController()?.navigationController?.popToRootViewController(animated: false)
        UIApplication.getTopViewController()?.navigationController?.pushViewController(AddressVC, animated: false)
        TabBarRuningPage.shared.changeLastPage(to: .customTabBar)
        UIApplication.getTopViewController()?.navigationItem.hidesBackButton = true
        cell.tabBarImageView.backgroundColor = .barSelectedItem
        selectedCustomBarItem = "more_wallet"
        toolBarVisibleConfig()
    default:
        cell.tabBarImageView.backgroundColor = .barDeselectedItem
    }
}
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let item = ToolbarTypeEnum(rawValue: toolbarIconNames[indexPath.row])
        let cell = collectionView.cellForItem(at: indexPath) as! TabBarCollectionViewCell
        switch item {
        case .analytics:
            cell.tabBarImageView.backgroundColor = .barDeselectedItem
        case .converter:
            cell.tabBarImageView.backgroundColor = .barDeselectedItem
        case .income:
            cell.tabBarImageView.backgroundColor = .barDeselectedItem
        case .news:
            cell.tabBarImageView.backgroundColor = .barDeselectedItem
        case .wallet:
            cell.tabBarImageView.backgroundColor = .barDeselectedItem
        case .none:
            cell.tabBarImageView.backgroundColor = .barDeselectedItem
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let totalCellWidth = 35 * collectionView.numberOfItems(inSection: 0)
        var totalSpacingWidth = 20 * (collectionView.numberOfItems(inSection: 0) - 1)
        if UIDevice.current.userInterfaceIdiom == .pad {
            totalSpacingWidth = 40 * (collectionView.numberOfItems(inSection: 0) - 1)
        } else {
            totalSpacingWidth = 20 * (collectionView.numberOfItems(inSection: 0) - 1)
        }
        let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
        
    }

func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
    return true
}

func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    let item = toolbarIconNames.remove(at: sourceIndexPath.row)
    toolbarIconNames.insert(item, at: destinationIndexPath.row)
    saveToolbarItems()
}
    private func saveToolbarItems() {
        guard let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") else { return }
        
        if let userId = NetworkManager.shared.currentUser?.id {
            userDefaults.set(toolbarIconNames, forKey: "\(userId)toolBarItems")
        } else {
            userDefaults.set(toolbarIconNames, forKey: "toolBarItems")
        }
    }
    private func setupLongGestureRecognizerOnCollection() {
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longPressedGesture.minimumPressDuration = 0.5
        longPressedGesture.delegate = self
        longPressedGesture.delaysTouchesBegan = true
        customTabBarCollectionView!.addGestureRecognizer(longPressedGesture)
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        let position = gestureRecognizer.location(in: customTabBarCollectionView)
        
        switch gestureRecognizer.state {
        case .began:
            guard let indexPath = customTabBarCollectionView!.indexPathForItem(at: position) else  { return }
            
            customTabBarCollectionView!.beginInteractiveMovementForItem(at: indexPath)
        case .changed:
            customTabBarCollectionView!.updateInteractiveMovementTargetPosition(position)
        case .ended:
            customTabBarCollectionView!.endInteractiveMovement()
        default:
            customTabBarCollectionView!.cancelInteractiveMovement()
        }
    }
}
