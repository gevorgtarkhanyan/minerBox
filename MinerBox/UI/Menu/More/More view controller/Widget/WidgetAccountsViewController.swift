//
//  WidgetAccountsViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/18/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class WidgetAccountsViewController: BaseViewController {
    
    private enum WidgetEnum: String, CaseIterable {
        case account = "Account"
        case coins = "coin_sort_coin"
    }
    
    // MARK: - Views
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    @IBOutlet weak var chooseSegmentTypeControl: BaseSegmentControl!
    
    
    // MARK: - Proeprties
    fileprivate var accounts: [PoolAccountModel] = []
    fileprivate var widgetBalances: [WidgetBalanceModel] = []
    private var filteredBalance = [ExpandableBalance]()
    
    fileprivate var FVCoins:  [CoinModel] = []
    private var isAccount = true
    private var currentIndex: Int?
    private let pageTypes = WidgetEnum.allCases
    private var currentPage = WidgetEnum.account
    
    private var isAccountBalanceRequestIsDone = false
    private var isAccountRequestIsDone = false
    
    private var lastSection: Int?
    private var sectionExpanded = true
    private var lastCell: WidgetSectionTableViewCell?
    
    private var indexPaths: [IndexPath] = []

    
    
    // MARK: - Static
    static func initializeStoryboard() -> WidgetAccountsViewController? {
        return UIStoryboard(name: "More", bundle: nil).instantiateViewController(withIdentifier: WidgetAccountsViewController.name) as? WidgetAccountsViewController
    }
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.startupSetup()
        self.setupNavigation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addBackgroundNotificaitonObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeBackgroundNotificaitonObserver()
    }
    
    override func applicationOpenedFromBackground(_ sender: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.currentPage == WidgetEnum.account {
                self.getAccounts()
            } else {
                self.getFVCoins()
            }
        }
    }
    
    override func languageChanged() {
        title = MoreSettingsEnum.widget.rawValue.localized()
    }
    override func configNoDataButton() {
        super.configNoDataButton()
    }
    @IBAction func goToCoinPricePage(_ sender: Any) {
        NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.coin.rawValue)
    }
    private func setupTableView() {
        tableView.register(UINib(nibName: "WidgetSectionTableViewCell", bundle: nil), forCellReuseIdentifier: "Widgetcell")
        tableView.separatorColor = .clear
    }
}

// MARK: - Startup
extension WidgetAccountsViewController {
    fileprivate func startupSetup() {
        
        guard WidgetCointManager.shared.isAccount else {
            self.setupSegmentControl()
            self.chooseSegmentTypeControl.selectSegment(index: 1)
            WidgetCointManager.shared.isAccount = true
            return
        }
        
        getAccountsBalances()
        getAccounts()
        self.setupSegmentControl()
        
    }
    private func setupNavigation() {
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func setupSegmentControl() {
        chooseSegmentTypeControl.delegate = self
        let titles = pageTypes.map { $0.rawValue }
        chooseSegmentTypeControl.setSegments(titles)
    }
    
    //MARK: - Request From Backend
    
    fileprivate func getAccountsBalances() {
        Loading.shared.startLoading(ignoringActions: true, for: self.view)
        
        PoolRequestService.shared.getBalanceForWidgetFromServer { (widgetBalances) in
            self.widgetBalances = widgetBalances
            self.isAccountBalanceRequestIsDone = true
            if self.isAccountRequestIsDone {
                self.appendingBallance()
                Loading.shared.endLoading(for: self.view)
            }
        } failer: { (error) in
            Loading.shared.endLoading(for: self.view)
        }
    }
    
    fileprivate func getAccounts() {
        Loading.shared.startLoading(ignoringActions: true, for: self.view)
        self.chooseSegmentTypeControl.isUserInteractionEnabled = false
        
        PoolRequestService.shared.getAccounts(success: { (accounts) in
            self.accounts = accounts
            self.isAccountRequestIsDone = true
            if self.isAccountBalanceRequestIsDone {
                self.appendingBallance()
                Loading.shared.endLoading(for: self.view)
            }
            self.selectEnabledAccounts()
            self.chooseSegmentTypeControl.isUserInteractionEnabled = true
            guard !accounts.isEmpty else {
                self.noDataButton?.isHidden = false
                self.noDataButton!.setTransferButton(text: "add_pool_account",subText: "", view: self.view)
                self.noDataButton!.addTarget(self, action: #selector(self.goToPoolAddPage), for: .touchUpInside)
                return
            }
        }, failer: { (error) in
            Loading.shared.endLoading(for: self.view)
        })
    }
    fileprivate func getFVCoins() {
        Loading.shared.startLoading(ignoringActions: true, for: self.view)
        self.chooseSegmentTypeControl.isUserInteractionEnabled = false
        
        CoinRequestService.shared.getFavoritesCoins { (coins) in
            
            self.FVCoins = coins
            self.tableView.reloadData()
            self.selectEnabledCoins()
            self.chooseSegmentTypeControl.isUserInteractionEnabled = true
            Loading.shared.endLoading(for: self.view)
            guard !coins.isEmpty else {
                self.noDataButton?.isHidden = false
                self.noDataButton!.setTransferButton(text: "You need to add something in favorites",subText: "", view: self.view)
                self.noDataButton!.addTarget(self, action: #selector(self.goToFavoriteAddPage), for: .touchUpInside)
                return
            }
            
        } failer: { (error) in
            Loading.shared.endLoading(for: self.view)
        }
        
    }
    //MARK:- Filtring Methods
    
    fileprivate func selectEnabledAccounts() {
        let accountsFromDB = WidgetAccountManager.shared.getAccounts()
        
        for  account in accounts {
            for accountFromDB in accountsFromDB {
                if account.id == accountFromDB.accountId {
                    account.selected = true
                    account.selectedBalanceType = accountFromDB.selectedBalanceType
                }
            }
        }
    }
    fileprivate func selectEnabledCoins() {
        for coins in FVCoins {
            guard WidgetCointManager.shared.getCoinsIds().contains(coins.coinId) else { continue }
            coins.fvSelected = true
        }
    }
    fileprivate func appendingBallance() {
        for account in self.accounts {
            for balance in widgetBalances{
                if account.id == balance.poolId {
                    account.balances = balance.params
                }
            }
        }
        filteredBalance = self.accounts.map { ExpandableBalance(expanded: false, model: $0) }
        self.tableView.reloadData()
    }
}

// MARK: - TableView Delegate and DataSource methods

extension WidgetAccountsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard isAccount else { return FVCoins.count}
        return filteredBalance.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard isAccount else { return 1 }
        
        return filteredBalance[section].isExpanded ? filteredBalance[section].model.balances.count + 1 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Widgetcell", for: indexPath) as? WidgetSectionTableViewCell {
                guard isAccount else {
                    guard FVCoins.count > indexPath.section else { return cell }
                    let coin = FVCoins[indexPath.section]
                    cell.delegate = self
                    cell.setData(coin: coin, IndexPath: indexPath)
                    return cell
                    
                }
                guard filteredBalance.count > indexPath.section else { return cell }
                let account = filteredBalance[indexPath.section].model
                cell.delegate = self
                cell.setData(account: account, IndexPath: indexPath, isSubscribe: self.user!.isSubscribted)
                return cell
            }
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: WidgetAccountsTableViewCell.name) as! WidgetAccountsTableViewCell
            
            guard isAccount else {
                //let coin = FVCoins[indexPath.row]
                return cell
                
            }
            let balances = self.accounts[indexPath.section].balances
            let balancesType = self.accounts[indexPath.section].selectedBalanceType
            cell.delegate = self
            cell.setData(balances: balances,indexPath: indexPath, selectedBalanceType: balancesType )
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard isAccount else { return } // Coin havn't expanded Row
        
        guard let user = self.user else { return }
        guard user.isPremiumUser || user.isStandardUser else {
            goToSubscriptionPage()
            return
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? WidgetSectionTableViewCell {
            
            expandSection(for: indexPath)
            cell.animateArrow(expanded: sectionExpanded)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return WidgetSectionTableViewCell.height
        } else {
            return WidgetAccountsTableViewCell.height
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
}

// MARK: - Segment control delegate

extension WidgetAccountsViewController: BaseSegmentControlDelegate {
    func segmentSelected(index: Int) {
        
        switch pageTypes[index] {
        case .account:
            
            self.noDataButton?.isHidden = true
            self.currentPage = WidgetEnum.account
            self.isAccount = true
            self.getAccountsBalances()
            self.getAccounts()
            
        case .coins:
            self.noDataButton?.isHidden = true
            self.currentPage = WidgetEnum.coins
            self.isAccount = false
            self.getFVCoins()
        }
    }
}

//MARK: -- Expandable part of code

extension WidgetAccountsViewController {
    func expandSection(for indexPath: IndexPath) {
        if indexPath.row == 0 {
            var existExpandableData = false
            let data = filteredBalance[indexPath.section]
            
            let indexPaths = data.model.balances.indices.map { IndexPath(row: $0 + 1, section: indexPath.section) }
            self.indexPaths = indexPaths
            let isExpanded = data.isExpanded
            data.isExpanded = !isExpanded
            
            if lastCell == nil {
                lastCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? WidgetSectionTableViewCell
            }
            
            if let lastSection = lastSection {
                if lastSection != indexPath.section {
                    let restData = filteredBalance[lastSection]
                    let restIndexPaths = restData.model.balances.indices.map { IndexPath(row: $0 + 1, section: lastSection) }
                    if restData.isExpanded {
                        existExpandableData = true
                        let expanded = restData.isExpanded
                        restData.isExpanded = !expanded
                        if lastCell != nil {
                            lastCell!.animateArrow(expanded: !sectionExpanded)
                        }
                        sectionExpande(isExpanded, for: indexPaths, close: true, closingPaths: restIndexPaths, indexPath: indexPath)
                    }
                    if !existExpandableData {
                        sectionExpande(isExpanded, for: indexPaths, indexPath: indexPath)
                    }
                } else {
                    sectionExpande(isExpanded, for: indexPaths, indexPath: indexPath)
                }
            } else {
                sectionExpande(isExpanded, for: indexPaths, indexPath: indexPath)
            }
            lastCell = tableView.cellForRow(at: indexPath) as? WidgetSectionTableViewCell
            lastSection = indexPath.section
            sectionExpanded = !isExpanded
            
            hideKeyboard()
        }
    }
    
    func sectionExpande(_ bool: Bool, for indexPaths: [IndexPath], close: Bool = false, closingPaths: [IndexPath] = [], indexPath: IndexPath) {
        tableView.beginUpdates()
        if close, closingPaths.count != 0 {
            tableView.deleteRows(at: closingPaths, with: .fade)
        }
        if bool {
            tableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            tableView.insertRows(at: indexPaths, with: .fade)
        }
        tableView.endUpdates()
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        UIView.animate(withDuration: 0) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Expandable table helper class

class ExpandableBalance: NSObject {
    public var isExpanded = false
    public var model = PoolAccountModel(json: NSDictionary())
    
    init(expanded: Bool, model: PoolAccountModel) {
        self.isExpanded = expanded
        self.model = model
    }
}

//MARK: - WidgetSectionTableViewDelegate and WidgetAccountsTableViewDelegate -

extension WidgetAccountsViewController: WidgetSectionTableViewDelegate , WidgetAccountsTableViewDelegate {
    
    func selectBalanceRow(IndexPath: IndexPath, selectedBalance: String) {
        for _indexpath in self.indexPaths {
            if _indexpath.row != IndexPath.row {
                if let cell = tableView.cellForRow(at: _indexpath) as? WidgetAccountsTableViewCell {
                    cell.isSelectedBalance = false
                    cell.deselectButton()
                }
            }
        }
        let _account = self.accounts[IndexPath.section]
        _account.selectedBalanceType = selectedBalance
        _account.selected = true
        WidgetAccountManager.shared.removeAccount(_account)
        WidgetAccountManager.shared.updateAccount(_account)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.tableView.reloadSections(IndexSet(integer: IndexPath.section), with: .none)
        }
    }
    
    func selectSection(IndexPathFromCel: IndexPath, selected: Bool) {
        guard isAccount else {
            let coin = FVCoins[IndexPathFromCel.section]
            guard selected else {
                WidgetCointManager.shared.addCoin(coin)
                return
            }
            WidgetCointManager.shared.removeCoin(coin.coinId)
            return
        }
        let account = accounts[IndexPathFromCel.section]
        guard selected else {
            if account.selectedBalanceType == "" && account.balances.first != nil {
                account.selectedBalanceType = account.balances.first!
                let indexPathForReload = IndexPath(row: 1, section: IndexPathFromCel.section)
                if tableView.numberOfRows(inSection: IndexPathFromCel.section) > 1 {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                        self.tableView.reloadRows(at: [indexPathForReload], with: .none)
                    }
                }
            }
            WidgetAccountManager.shared.removeAccount(account)
            WidgetAccountManager.shared.updateAccount(account)
            return
        }
        var IndextPathsForReload:[IndexPath] = []
        account.selectedBalanceType = ""
        for (row,_) in account.balances.enumerated() {
            let indexPathForReload = IndexPath(row: row + 1, section: IndexPathFromCel.section)
            IndextPathsForReload.append(indexPathForReload)
        }
        if tableView.numberOfRows(inSection: IndexPathFromCel.section) > 1 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                self.tableView.reloadRows(at: IndextPathsForReload, with: .none)
            }
        }
        WidgetAccountManager.shared.removeAccount(account)
    }
}


