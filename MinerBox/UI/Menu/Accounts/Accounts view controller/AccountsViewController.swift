//
//  AccountsViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/25/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import WebKit
import WidgetKit
import FirebaseCrashlytics

class AccountsViewController: BaseViewController {
    
    @IBOutlet private weak var addAccountButton: UIBarButtonItem!
    @IBOutlet private weak var accountsTableView: BaseTableView!
    
    @IBOutlet weak var totalHashrateView: TotalHashrateView!
    @IBOutlet weak var totalHVHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var chatView: ChatView!
    @IBOutlet weak var chatButton: ChatButton!
    @IBOutlet weak var chatButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatViewHeightConstraint: NSLayoutConstraint!
    private var wkWebView: WKWebView?
    private var touchView: UIView?
    
    private var enabledPoolIDs: [EnabledPoolId] = []
    private var adsViewForAccount: AdsView?
    
    
    private var isReload = false
    private var chatRequestEnded = false
    private var chat: Chat?
    private var pageAppiear = false
    
    var testCount = 0
    
    var chatFrame: CGRect?
    
    private var model = AccountModel()
    private var disabledAccount: PoolAccountModel?
    private var editableAccount: PoolAccountModel?
    private var indexPath:IndexPath = .zero
    private var requestTime:Double = 0.0
    private var refreshPoolTimer: Timer?
    private var refreshTime = 0
    private var isAccountloadEnd:Bool = false
    private var  filteredActiveAccounts:[PoolAccountModel] = []
    var sessionStorageValue: [String: Any]?
    private var units: [String] = []
    var bottomContentInsets: CGFloat = 0 {
        willSet {
            accountsTableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: newValue, right: 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
        enabledPoolIDs = getEnabledPools()
        startupSetup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.openedViaDynamicLink()
        self.checkUserForAds()
        if !pageAppiear {
            getChatInfo()
            pageAppiear = true
            chatSetup()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addBackgroundNotificaitonObserver()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeBackgroundNotificaitonObserver()
        adsViewForAccount?.removeFromSuperview()
        pageAppiear = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        self.toolbarCollectionView.collectionViewLayout.invalidateLayout()
        DispatchQueue.main.async {
            self.wkWebView?.frame = self.chatView.webView.bounds
            self.view.bringSubviewToFront(self.chatView)
            self.chatView.layoutIfNeeded()
        }
    }
    override func configNoDataButton() {
        super.configNoDataButton()
        noDataButton!.setTransferButton(text: "add_pool_account", subText: "", view: self.view)
        noDataButton!.addTarget(self, action: #selector(goToPoolAddPage), for: .touchUpInside)
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(openedViaDynamicLink), name: .openDynamicLinks, object: nil)
        
        model.observe = { [weak self] accounts in
            guard let self = self else { return }
            DispatchQueue.main.async {
                var totalValueError = ""
                do {
                    try self.getAccountTotalVales(accounts)
                } catch  {
                    totalValueError = error.localizedDescription
                }
                
                do {
                    if totalValueError == "Object has been deleted or invalidated"  {
                        try self.getAccountTotalVales(self.model.accounts)
                    }
                } catch {
                    Crashlytics.crashlytics().setCustomValue(error, forKey: "getAccountValueError")
                }
                self.noDataButton?.isHidden = !accounts.isEmpty
            }
        }
    }
    
    // MARK: - Static
    static func initializeStoryboard() -> AccountsViewController? {
        return UIStoryboard(name: "Menu", bundle: nil).instantiateViewController(withIdentifier: AccountsViewController.name) as? AccountsViewController
    }
    
    @objc private func openedViaDynamicLink() {
        let sb = UIStoryboard(name: "Menu", bundle: nil)
        if UserDefaults.standard.value(forKey: Constants.url_open_selectpool) != nil {
            if let vc = sb.instantiateViewController(withIdentifier: "PoolListViewController") as? PoolListViewController {
                navigationController?.setViewControllers([self, vc], animated: true)
            }
        }
        if UserDefaults.standard.value(forKey: Constants.url_open_account_alert) != nil {
            guard let newVC = AccountDetailsPageController.initializeStoryboard() else {
                return }
            guard let firstPool = model.accounts.first else {return}
            newVC.setAccount(firstPool)
            navigationController?.setViewControllers([self, newVC], animated: true)
        }
    }
    
    @objc private func openedWidgetPoolDetailPage() {
        guard let newVC = AccountDetailsPageController.initializeStoryboard() else { return }
        
        if let selectedAccountID = UserDefaults.standard.value(forKey: "selected_widget_account") as? String {
            UserDefaults.standard.removeObject(forKey: "selected_widget_account")
            for account in model.accounts {
                if selectedAccountID == account.id {
                    newVC.setAccount(account)
                    navigationController?.setViewControllers([self, newVC], animated: true)
                }
            }
        }
    }
    
    override func languageChanged() {
        title = "accounts".localized()
        configNoDataButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newVC = segue.destination as? AccountDetailsPageController {
            guard let indexPath = accountsTableView.indexPathForSelectedRow else { return }
            newVC.setAccount(model.accounts[indexPath.row])
        } else if let newVC = segue.destination as? AddPoolViewController, let account = editableAccount {
            newVC.setAccountForEdit(account)
        } else if let newVC = segue.destination as? PoolListViewController {
            newVC.setCurrentAccountCount(model.accounts.count)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        accountsTableView?.setEditing(false, animated: false)
        accountsTableView?.reloadData()
        let isHidden = UIApplication.shared.statusBarOrientation.isPortrait && UIDevice.current.userInterfaceIdiom == .phone && self.viewIfLoaded?.window != nil
        adsViewForAccount?.isHidden = isHidden
        bottomContentInsets = isHidden || adsViewForAccount == nil ? 0 : 200
    }
}

// MARK: - Startup default setup
extension AccountsViewController {
    private func startupSetup() {
        
        addObservers()
        addRefreshControl()
        setupNavigation()
        getAccounts()
        configTable()
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(newPoolAdded(_:)), name: NSNotification.Name(Constants.newPoolAdded), object: nil)
    }
    
    private func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(getAccounts(_:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            accountsTableView.refreshControl = refreshControl
        } else {
            accountsTableView.backgroundView = refreshControl
        }
    }
    
    private func configTable() {
//        configToolbar()
        if #available(iOS 11.0, *) {
            accountsTableView.dragDelegate = self
            accountsTableView.dropDelegate = self
            accountsTableView.dragInteractionEnabled = true
        }
    }
    
    
    
    private func setupNavigation() {
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
}

//MARK: - Chat
extension AccountsViewController: ChatViewDelegate, WKNavigationDelegate, WKUIDelegate {
    //    Chat View Delegate Method
    func mailSelected() {
        MailManager.shared.sendFeedback(with: self)
    }
    
    func touchesBegan(_ touches: Set<UITouch>) {
        if #available(iOS 14.0, *) {
            // use the feature only available in iOS 14
        } else {
            UIView.animate(withDuration: 0.3) {
                self.chatView.webView.alpha = 0
            }
        }
        chatView.superview?.bringSubviewToFront(chatView)
        
        let topFrame = chatView.bounds
        
        if let touch = touches.first {
            let p = touch.location(in: chatView)
            chatFrame = topFrame.contains(p) ? chatView.frame : nil
        }
    }
    
    func touchesEnded() {
        if #available(iOS 14.0, *) {
            // use the feature only available in iOS 14
        } else {
            UIView.animate(withDuration: 0.3) {
                self.chatView.webView.alpha = 1
            }
        }
    }
    
    @objc func detectPan(_ recognizer: UIPanGestureRecognizer) {
        let translation  = recognizer.translation(in: chatView.superview)
        guard let chatFrame = chatFrame else { return }
        
        if chatView.frame.minY < accountsTableView.frame.minY + 20 {
            if translation.y < 0 {
                return
            }
        }
        
        if chatViewHeightConstraint.constant < 300 {
            if translation.y > 0 {
                return
            }
        }
        
        chatView.frame.origin.y = chatFrame.origin.y + translation.y
        chatViewHeightConstraint.constant = chatFrame.height - translation.y
        chatView.webView.frame.size.height = chatView.frame.size.height - 25
        wkWebView?.frame = chatView.webView.bounds
        chatView.updateConstraints()
    }
    
    private func chatSetup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(resetChat))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(detectPan(_:)))
        pan.cancelsTouchesInView = false
        chatView.addGestureRecognizer(pan)
        chatView.headerView.addGestureRecognizer(tap)
        chatView.delegate = self
        chatView.translatesAutoresizingMaskIntoConstraints = false
        chatButtonSetup()
        chatCheckIsOnline()
    }
    
    @objc private func openChat() {
        self.chatButton.isEnubled = false
        if chatView.isHidden {
            if let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox"),
               let chatData = userDefaults.object(forKey: self.user == nil ? "chat" : "\(self.user!.id)chat") as? NSDictionary {
                self.chat = Chat(with: chatData)
                self.updateChat()
            } else {
                self.createChat()
            }
        } else {
            resetChat()
        }
    }
    
    //chat actions
    private func chatCheckIsOnline() {
        ChatRequestService.shared.checkIsOnline(success: { isOnline in
            DispatchQueue.main.async {
                self.chatButton.setup(with: isOnline)
                self.view.bringSubviewToFront(self.chatButton)
            }
        }, failer: { error in
            self.chatButton.setup(with: true)
        })
    }
    
    private func createChat() {
        Loading.shared.startLoadingForView(with: chatView)
        ChatRequestService.shared.createChat { (chat) in
            DispatchQueue.main.async {
                self.chatViewSetup()
                self.chat = chat
                self.chatRequestEnded = true
            }
        } failer: {
            DispatchQueue.main.async {
                self.chatViewErrorSetup()
            }
        }
    }
    
    private func updateChat() {
        Loading.shared.startLoadingForView(with: chatView)
        ChatRequestService.shared.updateChat { (succes) in
            DispatchQueue.main.async {
                if succes {
                    self.chatViewSetup()
                    self.chatRequestEnded = true
                } else {
                    self.createChat()
                }
            }
        } failer: {
            DispatchQueue.main.async {
                self.chatViewErrorSetup()
            }
        }
    }
    
    private func getChatInfo() {
        ChatRequestService.shared.getChatInfo { (hasUnread) in
            DispatchQueue.main.async {
                self.chatButton.setBadgeValue(with: hasUnread)
            }
        }
    }
    
    @objc private func resetChat() {
        self.chatButton.isEnubled = true
        chat = nil
        touchView?.removeFromSuperview()
        touchView = nil
        chatRequestEnded = false
        isReload = false
        Loading.shared.endLoadingForView(with: self.chatView)
        wkWebView?.removeFromSuperview()
        chatView.errorTextView.isHidden = true
        chatView.isHidden = true
        view.endEditing(true)
    }
    
    func createWebView() -> WKWebView? {
        let urlString = ChatRequestService.shared.startChat()
        guard let url = URL(string: urlString) else { return nil }
        
        let urlRequest = URLRequest(url: url)
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        if #available(iOS 8.0, *) {
            let wkWebView = WKWebView(frame: .zero, configuration: configuration)
            wkWebView.navigationDelegate = self
            wkWebView.uiDelegate = self
            wkWebView.load(urlRequest)
            return wkWebView
        }
        return nil
    }
    
    private func chatViewSetup() {
        self.wkWebView = createWebView()
        guard let webView = wkWebView else { return }
        
        touchView = UIView()
        touchView?.backgroundColor = .clear
        view.addSubview(touchView!)
        touchView?.frame = view.bounds
        let tap = UITapGestureRecognizer(target: self, action: #selector(resetChat))
        touchView?.addGestureRecognizer(tap)
        
        chatView.isHidden = false
        chatView.errorTextView.isHidden = true
        chatView.webView.addSubview(webView)
        webView.frame = chatView.webView.bounds
        chatView.layer.masksToBounds = true
        view.bringSubviewToFront(chatView)
        view.bringSubviewToFront(chatButton)
        view.endEditing(chatView.isHidden)
        view.layoutIfNeeded()
    }
    
    private func chatViewErrorSetup() {
        Loading.shared.endLoadingForView(with: self.chatView)
        chatView.isHidden = false
        chatView.layer.masksToBounds = true
        chatView.errorTextView.isHidden = false
        chatView.bringSubviewToFront(chatView.errorTextView)
        chatButton.isEnubled = true
        view.bringSubviewToFront(chatView)
        view.endEditing(chatView.isHidden)
        view.layoutIfNeeded()
    }
    
    private func chatButtonSetup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(openChat))
        chatButton.addGestureRecognizer(tap)
    }
    
    //MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if !chatView.isHidden && !isReload {
            DispatchQueue.global().async {
                while self.chatRequestEnded {
                    self.chatRequestEnded = false
                    guard let chat = self.chat,
                          let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") else { return }
                    
                    userDefaults.set(chat.toAny(), forKey: self.user == nil ? "chat" : "\(self.user!.id)chat")
                    
                    DispatchQueue.main.async {
                        let script = "(function() {window.sessionStorage.setItem('lhc_chat', '" + chat.sessionStorageValue + "')" + "})();"
                        webView.evaluateJavaScript(script) { (data, error) in
                            guard error == nil else { self.resetChat(); return }
                            
                            webView.reload()
                            Loading.shared.endLoadingForView(with: self.chatView)
                            self.chatButton.isEnubled = true
                            self.chatButton.setBadgeValue(with: false)
                            self.isReload = true
                        }
                    }
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated  {
            if let url = navigationAction.request.url,
               UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
    //MARK: - Keyboard
    override func keyboardWillShow(_ sender: Notification) {
        super.keyboardWillShow(sender)
        guard let info = sender.userInfo,
              let keyboardFrameValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardSize = keyboardFrame.size
        
        chatButtonBottomConstraint.constant = keyboardSize.height - 90
    }
    
    override func keyboardWillHide(_ sender: Notification) {
        super.keyboardWillHide(sender)
        chatButtonBottomConstraint.constant = 16
    }
    
}

// MARK: - Actions
extension AccountsViewController {
    
    
    @objc public func getAccounts(_ refreshControl: UIRefreshControl? = nil) {
        self.isAccountloadEnd = false
        self.noDataButton?.isHidden = true
        
        guard let _ = self.user else {
            model.setAccounts([])
            Loading.shared.endLoading(for: self.view)
            refreshControl?.endRefreshing()
            return
        }
        
        if refreshControl == nil {
            Loading.shared.startLoading(ignoringActions: true, for: self.view)
        }
        PoolRequestService.shared.getAccounts(success: { (accounts) in
            
            self.model.setAccounts(accounts)
            self.accountsTableView.reloadData()
            self.startPoolTimer()
            self.openedViaDynamicLink()
            self.openedWidgetPoolDetailPage()
            if TabBarRuningPage.shared.lastSelectedPage.rawValue == 0 {
//                self.getToolbarIconNames()
                Loading.shared.endLoading(for: self.view)
            }
            if #available(iOS 14.0, *) {
                #if arch(arm64) || arch(i386) || arch(x86_64)
                if RealmWrapper.sharedInstance.getAllObjectsOfModel(PoolAccountModel.self) as? [PoolAccountModel] == nil {
                    WidgetCenter.shared.reloadAllTimelines()
                }
                #endif
            }
            refreshControl?.endRefreshing()
        }) { (error) in
            Loading.shared.endLoading(for: self.view)
            refreshControl?.endRefreshing()
            self.showAlertView("", message: error, completion: nil)
        }
    }
    
    @objc private func newPoolAdded(_ sender: Notification) {
        getAccounts()
    }
    
    fileprivate func getAccountTotalVales(_ accounts: [PoolAccountModel]) throws {
        let units = ((accounts.map { $0.poolSubItem == -1 ? $0.poolTypeHsUnit : $0.poolSubItemHsUnit })).uniqued()
        
        var totalAccountValues = [TotalAccountValue]()
        for var unit in units {
            let filteredAccounts = accounts.filter {  $0.poolSubItem == -1 ? $0.poolTypeHsUnit == unit : $0.poolSubItemHsUnit == unit}
            
            var totalHashrateValue = 0.0
            var totalWorkersValue = 0
            
            for (account) in filteredAccounts {
                if let enabledPoolId = enabledPoolIDs.first(where: {$0.poolTypeId == account.poolType}) {
                    if account.poolSubItem == -1 ||
                        account.poolSubItem != -1 && enabledPoolId.subPoolTypeId.contains(account.poolSubItem) {
                        
                        if account.active && !account.invalidCredentials {
                            totalHashrateValue += account.currentHashrate
                            totalWorkersValue += account.workersCount > 0 ? account.workersCount : 0
                        }
                    }
                }
            }
                
            unit = unit == "" ? "H/s" : unit
            let name = "\(unit)" + " " + "accounts".localized() + ": " + "\(filteredAccounts.count)"
            let total = TotalAccountValue(name: name, hashrate: totalHashrateValue, worker: totalWorkersValue, hsUnit: unit)
            totalAccountValues.append(total)
        }
        
        totalAccountValues = totalAccountValues.sorted { $0.name < $1.name }
        totalHashrateView.setData(totalAccountValues)
        totalHVHeightConstraint.constant = TotalHashrateTableViewCell.height * CGFloat(totalAccountValues.count) + 10
        if model.accounts.count == 1 {
            totalHVHeightConstraint.constant = 0
        }
        view.layoutIfNeeded()
    }
    
    func startPoolTimer() {
//        guard refreshPoolTimer == nil else { return }
        if refreshTime == 0 {
            refreshTime += 2
            requestTime = 2.0
        } else if refreshTime == 2 {
            refreshTime += 2
        } else if refreshTime == 4 {
            refreshTime += 5
            requestTime = Constants.singleCallTimeInterval
        } else {
            refreshTime += 5
        }
        self.refreshPoolTimer = Timer.scheduledTimer(timeInterval: requestTime, target: self, selector: #selector(self.checkAccountLoad), userInfo: nil, repeats: false)
    }
    
    func stopPoolTimer() {
        refreshPoolTimer?.invalidate()
        refreshPoolTimer = nil
    }
    
    override func applicationOpenedFromBackground(_ sender: Notification) {
        TabBarRuningPage.shared.changeLastPage(to: .accounts)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.getAccounts()
        }
    }
    
    private func removeAccount(indexPath: IndexPath) {
        let account = model.accounts[indexPath.row]
        let accountId = account.id
        
        Loading.shared.startLoading()
        self.addAccountButton.isEnabled = false
        self.accountsTableView.isUserInteractionEnabled = false
        PoolRequestService.shared.deletePoolAccount(poolId: account.id, success: {
            PoolBalanceManager.shared.removeBalance(accountId)
            self.model.remove(at: indexPath.row)
            self.accountsTableView.deleteRows(at: [indexPath], with: .fade)
            Loading.shared.endLoading()
            self.addAccountButton.isEnabled = true
            self.accountsTableView.isUserInteractionEnabled = true
        }, failer: { (error) in
            Loading.shared.endLoading()
            self.addAccountButton.isEnabled = true
            self.accountsTableView.isUserInteractionEnabled = true
            self.showToastAlert(error, message: nil)
        })
    }
    @objc private func checkAccountLoad() {
        if refreshTime > Constants.poolDetailsRequestTimeInterval {
            self.isAccountloadEnd = true
            self.accountsTableView.reloadData()
            self.refreshTime = 0
            self.stopPoolTimer()
            return
        }
        
        for (account) in model.accounts {
            if let enabledPoolId = enabledPoolIDs.first(where: {$0.poolTypeId == account.poolType}) {
                if account.poolSubItem == -1 || account.poolSubItem != -1 && enabledPoolId.subPoolTypeId.contains(account.poolSubItem) {
                    if account.active {
                        if !account.invalidCredentials {
                            guard account.Isloaded else {
                                PoolRequestService.shared.getAccounts { (account) in
                                    self.model.setAccounts(account)
                                    self.accountsTableView.reloadData()
                                } failer: { (err) in
                                    print(err)
                                }
                                self.startPoolTimer()
                                return
                            }
                        }
                    }
                }
            }
        }
        self.refreshTime = 0
        self.isAccountloadEnd = false
        self.accountsTableView.reloadData()
        self.stopPoolTimer()
    }
    
    @IBAction func noLoadedButtonAction(_ sender: Any) {
        showToastAlert("Out of date!".localized(), message: nil)
    }
    
    // MARK: - Cell trailing actions
    @objc private func editAccount(indexPath: IndexPath) {
        editableAccount = model.accounts[indexPath.row]
        performSegue(withIdentifier: "editAccountSegue", sender: self)
    }
    
    @objc private func deleteAccount(indexPath: IndexPath) {
        self.showAlertViewController(nil, message: "ask_for_delete", otherButtonTitles: ["ok"], cancelButtonTitle: "cancel") { (responce) in
            if responce == "ok" {
                self.removeAccount(indexPath: indexPath)
            }
        }
    }
    
    private func sendNewOrders() {
        var dict: [String: String] = [:]
        for (index, account) in model.accounts.enumerated() {
            dict[account.id] = "\(index)"
        }
        
        PoolRequestService.shared.updateOrders(params: dict) { (error) in
            debugPrint(error)
        }
    }
    
    
    private func getEnabledPools(poolTypes: [PoolTypeModel]? = DatabaseManager.shared.allEnabledPoolTypes) -> [EnabledPoolId] {
        var allEnabledpoolTypesIDs: [EnabledPoolId] = []
        if let typePools = poolTypes {
            for poolType in typePools {
                let enabledpoolType = EnabledPoolId()
                enabledpoolType.poolTypeId = poolType.poolId
                for subPoolType in poolType.subPools {
                    if subPoolType.enabled == true {
                        enabledpoolType.subPoolTypeId.append(subPoolType.id)
                    }
                }
                allEnabledpoolTypesIDs.append(enabledpoolType)
            }
        }
        return allEnabledpoolTypesIDs
    }
    
}

// MARK: - TableView methods
extension AccountsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AccountsTableViewCell.name) as! AccountsTableViewCell
        let account = model.accounts[indexPath.row]
        var isPoolDisabled = true
        
        if let enabledPoolId = enabledPoolIDs.first(where: {$0.poolTypeId == account.poolType}) {
            isPoolDisabled = false
            if account.poolSubItem != -1 {
                if !enabledPoolId.subPoolTypeId.contains(account.poolSubItem){
                    isPoolDisabled = true
                }
            }
        }
        
        self.indexPath = indexPath
        
        cell.setData(model: account, indexPath: indexPath, disabled: isPoolDisabled, loadedEnd: account.Isloaded ? false : self.isAccountloadEnd, invalidCredentials: account.invalidCredentials)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? AccountsTableViewCell {
            if !cell.isDisabled {
                let filteredActiveAccounts = model.accounts.filter {$0.active}
                disabledAccount = model.accounts[indexPath.row]
                
                guard disabledAccount!.active else {
                    let alert = ActivateAlertViewController.initializeStoryboard()
                    alert.modalPresentationStyle = .overCurrentContext
                    alert.activeAccountCount = filteredActiveAccounts
                    alert.delegate = self
                    let controller = tabBarController ?? self
                    controller.present(alert, animated: true, completion: nil)
                    view.layoutIfNeeded()
                    return
                }
                
                performSegue(withIdentifier: "detailsSegue", sender: self)
               navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
            } else {
            self.showAlertView("MAINTENANCE".localized(), message: "", completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        model.moveItem(at: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    // Cell swipe method for less than iOS 11
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let remove = UITableViewRowAction(style: .normal, title: "delete".localized()) { (_, indexPath) in
            self.deleteAccount(indexPath: indexPath)
        }
        
        let edit = UITableViewRowAction(style: .normal, title: "edit".localized()) { (_, indexPath) in
            self.editAccount(indexPath: indexPath)
        }
        
        edit.backgroundColor = .cellTrailingSecond
        remove.backgroundColor = .cellTrailingFirst
        
        return [edit, remove]
    }
    
    // Cell swipe method for greather than iOS 11
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "") { (_, _, completion) in
            self.editAccount(indexPath: indexPath)
            completion(true)
        }
        
        let remove = UIContextualAction(style: .normal, title: "") { (_, _, completion) in
            self.deleteAccount(indexPath: indexPath)
            completion(true)
        }
        
        edit.image = UIImage(named: "cell_edit")
        edit.backgroundColor = .cellTrailingFirst
        
        remove.image = UIImage(named: "cell_delete")
        remove.backgroundColor = .red
        
        let swipeAction = UISwipeActionsConfiguration(actions: [remove, edit])
        swipeAction.performsFirstActionWithFullSwipe = false // This is the line which disables full swipe
        return swipeAction
    }
}


// MARK: - TableView drap drop delegate
@available(iOS 11, *)
extension AccountsViewController: UITableViewDragDelegate, UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let param = UIDragPreviewParameters()
        param.backgroundColor = .clear
        return param
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return []
    }
    
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return model.canHandle(session)
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        // The .move operation is available only for dragging within a single app.
        if tableView.hasActiveDrag {
            if session.items.count > 1 {
                return UITableViewDropProposal(operation: .cancel)
            } else {
                return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
        } else {
            return UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, dragSessionDidEnd session: UIDragSession) {
        self.sendNewOrders()
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // Get last index path of table view.
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        let _ = coordinator.session.loadObjects(ofClass: String.self) { items in
            // Consume drag items.
            let idStrings = self.model.accounts.map { $0.id }
            let stringItems = [idStrings.first { items.contains($0) }!]
            
            var indexPaths = [IndexPath]()
            for (index, item) in stringItems.enumerated() {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                let account = self.model.accounts.first { $0.id == item }
                self.model.addItem(account!, at: indexPath.row)
                indexPaths.append(indexPath)
            }
            
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}

// MARK: - Account activation delegate
extension AccountsViewController: ActivateAlertViewControllerDelegate {
    func activated() {
        guard let account = disabledAccount else { return }
        Loading.shared.startLoading()
        PoolRequestService.shared.activatePoolAccountRequest(poolId: account.id, success: {
            self.getAccounts()
            Loading.shared.endLoading()
        }) { (error) in
            Loading.shared.endLoading()
            self.showAlertView("", message: error, completion: nil)
        }
    }
}

// MARK: - Ads Methods -

extension AccountsViewController {
    
    func checkUserForAds() {
        AdsManager.shared.checkUserForAds(zoneName: .account) {[weak self] adsView in
            guard let self = self else { return }
            self.adsViewForAccount = adsView
            self.setupAds()
        }
        
    }
    func setupAds() {
        guard let adsViewForAccount = adsViewForAccount else { return }
        
        self.view.addSubview(adsViewForAccount)
        
        adsViewForAccount.translatesAutoresizingMaskIntoConstraints = false
        accountsTableView.leftAnchor.constraint(equalTo: adsViewForAccount.leftAnchor, constant: -10).isActive = true
        accountsTableView.rightAnchor.constraint(equalTo: adsViewForAccount.rightAnchor, constant: 10).isActive = true
        chatButton.topAnchor.constraint(equalTo: adsViewForAccount.bottomAnchor,constant: 10).isActive = true
        bottomContentInsets = 200
    }
}
