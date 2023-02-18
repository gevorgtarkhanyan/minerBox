//
//  DetailsViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/2/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

protocol DetailsViewControllerDelegate: AnyObject {
    func saveAccountInfo(mail: String?, lastSeen: String?, nextPayoutTime: Double?, nextPayoutTimeDur: Double?, subAccount: String?, paymentMethod: String?, isloaded: Bool?, isAccountloadEnd : Bool?, invalideCredential: Bool?)
    func saveCurrentValues(hashrate: Double, workersCount: Int, reportedHashrate: Double)
    func saveEstimationRewardsInfo(rewards: [Reward], estimations: [Estimation], currency: String, priceUSD: Double, priceBTC: Double)
    func sendCurrentCoinId(_ coinId: String)
    func statrtLoading()
    func endLoading()
}

class DetailsViewController: BaseViewController {
    
    @IBOutlet weak var detailsTableView: BaseTableView!
    
    weak var delegate: DetailsViewControllerDelegate?
    
    private var account: PoolAccountModel!
    
    private var accountSettings = PoolSettingsModel(json: NSDictionary())
    
    private var sections = [(section: DetailsTableSectionEnum, expandable: Bool)]()
    private var rows = [[(key: String, value: String)]]()
    
    private var email: String?
    private var isLoaded: Bool?
    private var lastSeen: String?
    private var nextPayoutTime: Double?
    private var nextPayoutTimeDur: Double?
    private var subAccount: String?
    private var paymentMethod: String?
    private var alertType: AccountAlertType = .hashrate
    private var selectedGraphType: GraphTypeEnum = .hashrate
    
    private var converterImageView: UIImageView?
    private var isCreditShown = false
    private var refreshPoolTimer: Timer?
    private var refreshTime = 0
    public var isAccountloadEnd:Bool = false
    private var requestTime:Double = 0.0
    var coinId: String?
    private var currency = ""
    
    static func initializeStoryboard() -> DetailsViewController? {
        return UIStoryboard(name: "AccountDetails", bundle: nil).instantiateViewController(withIdentifier: DetailsViewController.name) as? DetailsViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getAccountSettings()
        addRefreshControl()
    }
    
    func setupTableView() {
        detailsTableView.register(UINib(nibName: "DetailTableViewCell", bundle: nil), forCellReuseIdentifier: "detailsCell")
    }
    
    private func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(getAccountSettings(_:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            detailsTableView.refreshControl = refreshControl
        } else {
            detailsTableView.backgroundView = refreshControl
        }
    }
    
    @objc private func getAccountSettings(_ refreshControl: UIRefreshControl? = nil) {
        if refreshControl == nil {
            Loading.shared.startLoading(for: self.view)
        }
        delegate?.statrtLoading()
        PoolRequestService.shared.getAccountSettings(poolId: account.id, poolType: account.poolType, success: { (accountSettings) in
            self.accountSettings = accountSettings
            self.startPoolTimer()
            if let coinId = accountSettings.coins.first?.coinId {
                self.coinId = coinId
            }
            if let currency = accountSettings.coins.first?.currency {
                self.currency = currency
            }
            DispatchQueue.main.async {
                self.requestEnded(refreshControl)
            }
        }) { (error) in
            refreshControl?.endRefreshing()
            Loading.shared.endLoading(for: self.view)
            self.showAlertView("", message: error, completion: nil)
        }
    }
    
    
    private func requestEnded(_ refreshControl: UIRefreshControl? = nil) {
        self.configAccountInfo(account: accountSettings)
        detailsTableView.reloadData()
        delegate?.endLoading()
        Loading.shared.endLoading(for: self.view)
        refreshControl?.endRefreshing()
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
    
    @objc private func checkAccountLoad(_ refreshControl: UIRefreshControl? = nil) {
        if refreshTime > Constants.poolDetailsRequestTimeInterval {
            self.isAccountloadEnd = true
            self.configAccountInfo(account: accountSettings)
            self.detailsTableView.reloadData()
            self.refreshTime = 0
            self.stopPoolTimer()
            return
        }
        guard isLoaded! else {
            PoolRequestService.shared.getAccountSettings(poolId: account.id, poolType: account.poolType, success: { (accountsettings) in
                self.accountSettings = accountsettings
                self.isLoaded = self.accountSettings.isloaded
            }) { (error) in
                Loading.shared.endLoading(for: self.view)
                self.showAlertView("", message: error, completion: nil)
            }
            self.startPoolTimer()
            return
        }
        self.refreshTime = 0
        self.isAccountloadEnd = false
        self.stopPoolTimer()
        self.configAccountInfo(account: accountSettings)
        detailsTableView.reloadData()
        delegate?.endLoading()
    }
    private func configAccountInfo(account: PoolSettingsModel) {
        email = accountSettings.email
        isLoaded = accountSettings.isloaded
        subAccount = accountSettings.subAccount
        paymentMethod = accountSettings.paymentMethod
        if accountSettings.lastSeen > 0 {
            self.lastSeen = accountSettings.lastSeen.getDateFromUnixTime()
        }
        for coin in accountSettings.coins {
            if accountSettings.coins.count == 1 {
                if coin.nextPayoutTime != -1 {
                    self.nextPayoutTime = coin.nextPayoutTime
                }
                if coin.nextPayoutTimeDur != -1 {
                    self.nextPayoutTimeDur = coin.nextPayoutTimeDur
                }
            }
        }
        delegate?.saveAccountInfo(mail: email, lastSeen: lastSeen, nextPayoutTime: nextPayoutTime, nextPayoutTimeDur: nextPayoutTimeDur, subAccount: subAccount, paymentMethod: paymentMethod,isloaded: isLoaded, isAccountloadEnd: isAccountloadEnd,invalideCredential: accountSettings.invalidCredentials )
        if let coinId = coinId {
            delegate?.sendCurrentCoinId(coinId)
        }
        
        // Clear previous data
        rows.removeAll()
        sections.removeAll()
        
        // Config hashrate
        var hashrate = [(String, String)]()
        if account.currentHashrate != -1 {
            hashrate.append(("current", account.currentHashrate.textFromHashrate(account: self.account)))
        }
        if account.averageHashrate != -1 { hashrate.append(("average", account.averageHashrate.textFromHashrate(account: self.account))) }
        if account.reportedHashrate != -1 { hashrate.append(("reported", account.reportedHashrate.textFromHashrate(account: self.account))) }
        if account.realHashrate != -1 { hashrate.append(("real", account.realHashrate.textFromHashrate(account: self.account))) }
        if hashrate.count > 0 {
            sections.append((section: .hashrate, expandable: account.extHashrate))
            rows.append(hashrate)
        }
        
        // Config workers
        var workers = [(String, String)]()
        if account.extGroupWorkers {
            workers.append(("groups", "\(account.workerGroups.count)"))
        }
        if account.allWorkers != -1 {
            workers.append(("all", account.allWorkers.getString()))
        }
        if account.activeWorkers != -1 {
            workers.append(("active", account.activeWorkers.getString()))
        }
        if workers.count > 0 {
            if account.extGroupWorkers {
                let expandable = account.workerGroups.count > 0 || account.allWorkers > 0
                sections.append((section: .groupWorker, expandable: expandable))
            } else {
                let expandable = account.allWorkers != -1 ? account.allWorkers > 0: account.activeWorkers > 0
                sections.append((section: .workers, expandable: expandable))
            }
            rows.append(workers)
        }
        
        delegate?.saveCurrentValues(hashrate: max(account.currentHashrate, 0), workersCount: Int(max(account.activeWorkers, 0)), reportedHashrate: max(account.reportedHashrate, 0))
        
        // Config balance
        var balance = [(String, String)]()
        if account.coinsCount == 1 { // For Single Coin
            balance = setBalanceItems(coin: account.coins.first)
            if balance.count > 0 {
                sections.append((section: .balance, expandable: accountSettings.extBalance))
                rows.append(balance)
            }
        } else if account.coinsCount > 1 {
            balance = setBalanceItems(coin: account.balanceTotal)
            
            if account.coinsCount != -1 { balance.append(("coins", "\(account.coinsCount)")) }
            sections.append((section: .balance, expandable: true))
            rows.append(balance)
        }
        
        // Config shares
        var shares = [(String, String)]()
        if account.sharePer != -1 { shares.append(("shares", account.sharePer.getString())) }
        if let validSharesStr = account.validSharesStr { shares.append(("valid", validSharesStr)) }
        if let invalidSharesStr = account.invalidSharesStr { shares.append(("invalid", invalidSharesStr)) }
        
        if let staleSharesStr = account.staleSharesStr { shares.append(("stale", staleSharesStr)) }
        if let roundSharesStr = account.roundSharesStr { shares.append(("round", roundSharesStr)) }
        if let roundSharesStr = account.expiredSharesStr { shares.append(("expired", roundSharesStr)) }
        if shares.count > 0 {
            sections.append((section: .shares, expandable: account.extShares))
            rows.append(shares)
        }
        
        // Config Blocks
        var blocks = [(String, String)]()
        if account.period != -1 { blocks.append(("period", account.period.secondsToDayHr())) }
        if account.block != -1 { blocks.append(("block", account.block.getString())) }
        if let luckStr = account.luckStr { blocks.append(("luck", luckStr)) }
        if account.amount != -1 { blocks.append(("amount", account.amount.getString() + " \(currency)")) }

        if blocks.count > 0 {
            sections.append((section: .blocks, expandable: account.extBlocks))
            rows.append(blocks)
        }
        
        delegate?.saveEstimationRewardsInfo(rewards: account.rewards,
                                            estimations: account.estimations,
                                            currency: currency,
                                            priceUSD: account.coins.first?.priceUSD ?? 0.0 ,
                                            priceBTC: account.coins.first?.priceBTC ?? 0.0)
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
//            self.startRequests()
            self.getAccountSettings()
        }
    }
    
    func setBalanceItems(coin: CoinState?) ->  [(String, String)] {
        
        var balance = [(String, String)]()
        
        if coin != nil {
            if coin!.credit != -1 {
                balance.append(("credit".localized(), coin!.credit.textFromCredit()))
                isCreditShown = true
            }
            if coin!.orphaned != -1 { balance.append(("orphaned", (coin!.orphaned.getString()) + " \(currency)")) }
            if coin!.unconfirmed != -1 { balance.append(("unconfirmed", (coin!.unconfirmed.getString()) + " \(currency)")) }
            if coin!.confirmed != -1 { balance.append(("confirmed", (coin!.confirmed.getString()) + " \(currency)")) }
            if coin!.unpaid != -1 { balance.append(("unpaid", (coin!.unpaid.getString()) + " \(currency)")) }
            if coin!.paid != -1 { balance.append(("paid", (coin!.paid.getString()) + " \(currency)")) }
            if coin!.paid24h != -1 { balance.append(("paid24h", (coin!.paid24h.getString()) + " \(currency)")) }
            if coin!.reward24h != -1 { balance.append(("reward24h", (coin!.reward24h.getString()) + " \(currency)")) }
            if coin!.immatureReward != -1 { balance.append(("immatureReward", (coin!.immatureReward.getString()) + " \(currency)")) }
            if coin!.totalBalance != -1 { balance.append(("totalBalance", (coin!.totalBalance.getString()) + " \(currency)")) }
            if coin!.payoutThreshold != -1 { balance.append(("payoutThreshold", (coin!.payoutThreshold.getString()) + " \(currency)")) }
//            if coin!.nextPayoutTime != -1 { balance.append(("next_payout_time",coin!.nextPayoutTime.textFromUnixTime()))}
//            if coin!.nextPayoutTimeDur != -1 { balance.append(("next_payout_time",coin!.nextPayoutTimeDur.secondsToDayHr()))}
        }
        return balance
    }
    
    //MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newVC = segue.destination as? AccountAddAlertViewController {
            var currentValue = 0.0
            var currentValue2 = 0.0
            switch alertType {
            case .hashrate:
                 currentValue = accountSettings.currentHashrate
                 currentValue2 = accountSettings.reportedHashrate
            case .worker:
                 currentValue = accountSettings.activeWorkers
            case .reportedHashrate:
                 currentValue = accountSettings.reportedHashrate
                 currentValue2 = accountSettings.reportedHashrate
            }
            newVC.setData(account: account, alertType: alertType, currentAlert: nil, currentValue: currentValue, currentValue2: currentValue2)
        } else if let newVC = segue.destination as? WorkersViewController {
            newVC.setAccount(account)
        } else if let newVC = segue.destination as? GroupWorkersViewController {
            newVC.setAccount(account)
            newVC.setGroups(accountSettings.workerGroups)
        }
        else if let newVC = segue.destination as? PoolPaymentViewController {
            if segue.identifier == "recentCreditsSegue" {
                newVC.setCurrentPage(.resentCredit)
            } else {
                newVC.setCurrentPage(.block)
            }
            let currency = self.currency == "" ? nil : self.currency
          //  newVC.setCredits(accountSettings.recentCredits)
            newVC.setData(currency: currency, account: self.account, coinId: coinId ?? "")
        } else if let newVC = segue.destination as? GraphViewController {
            newVC.setAccount(account)
            newVC.setGraphType(selectedGraphType)
    //        newVC.setAccountInfoData(mail: email, lastSeen: lastSeen)
        } else if let newVC = segue.destination as? AccounBalanceViewController {
            newVC.setCoins(accountSettings.coins)
        }
    }
    
    public func setAccount(_ account: PoolAccountModel) {
        self.account = account
    }
    
}

// MARK: - Section header delegate
extension DetailsViewController: DetailsHeaderViewDelegate {
    func sectionSelected(type: DetailsTableSectionEnum) {
        switch type {
        case .workers:
            performSegue(withIdentifier: "workersSegue", sender: self)
        case .groupWorker:
            if accountSettings.workerGroups.count != 0 {
                performSegue(withIdentifier: "groupWrkersSegue", sender: self)
            } else {
                performSegue(withIdentifier: "workersSegue", sender: self)
            }
        case .balance:
            if accountSettings.coinsCount > 1 {
                performSegue(withIdentifier: "coinStateSegue", sender: self)
            } else {
                performSegue(withIdentifier: "recentCreditsSegue", sender: self)
            }
        case .hashrate:
            selectedGraphType = .hashrate
            performSegue(withIdentifier: "graphSegue", sender: self)
        case .shares:
            selectedGraphType = .share
            performSegue(withIdentifier: "graphSegue", sender: self)
        case .blocks:
            performSegue(withIdentifier: "rewardsSegue", sender: self)
        
        }
    }
    
    func alertButtonSelected(type: DetailsTableSectionEnum) {
        switch type {
        case .hashrate:
            alertType = .hashrate
        case .workers:
            alertType = .worker
        default:
            break
        }
        performSegue(withIdentifier: "addAlertSegue", sender: self)
    }
}

// MARK: - TableView methods
extension DetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return DetailsHeaderView.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = DetailsHeaderView(frame: .zero)
        let item = sections[section]
        
        header.delegate = self
        header.setData(sectionType: item.section, expandable: item.expandable)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "detailsCell") as? DetailTableViewCell {
            let list = Array(rows[indexPath.section])
            
            if sections[indexPath.section].section == .balance ||
                (sections[indexPath.section].section == .blocks && list[indexPath.row].key == "amount") {
                cell.setData(list: list, coinId: coinId, indexPath: indexPath, isIconShow: !isCreditShown)
            } else {
                cell.setData(list: list, coinId: coinId, indexPath: indexPath)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = sections[indexPath.section]
        if item.expandable == true {
            sectionSelected(type: item.section)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0.0
        }
        
        return 5
    }
}

// MARK: - Helpers
enum DetailsTableSectionEnum: String {
    case hashrate = "hashrates"
    case groupWorker = "groups_workers"
    case workers = "workers"
    case shares = "shares"
    case balance = "balance"
    case blocks = "blocks"
}

