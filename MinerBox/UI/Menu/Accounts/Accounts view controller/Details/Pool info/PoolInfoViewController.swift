//
//  PoolInfoViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/3/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import Localize_Swift

protocol PoolInfoViewControllerDelegate:AnyObject {
    func saveLastUpdate(lastSeen:String?)
}

class PoolInfoViewController: BaseViewController {
    
    // MARK: - Views
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    
    @IBOutlet weak var sortParentView: BarCustomView?
    @IBOutlet weak var sortLayerView: UIView!
    @IBOutlet weak var sortNameButton: BackgroundButton!
    @IBOutlet weak var sortUpDownButton: UIButton!
    @IBOutlet weak var sortParentViewHeigthConstraits: NSLayoutConstraint?
    
    @IBOutlet weak var chooseSegmentControl: BaseSegmentControl!
    @IBOutlet weak var segmentHeightConstraits: NSLayoutConstraint!
    
    // MARK: - Properties
    fileprivate var account: PoolAccountModel!
    fileprivate var headerRow = ExpandableRowsForPoolInfo(expanded: false, rows: [])
    fileprivate var rows = [(name: String, value: String,systemTyoe: String)]()
    fileprivate var allRows = [ExpandableRowsForPoolInfo]()
    fileprivate var info: PoolStatsModel?
    fileprivate var currentMiningModes: [MiningModes] = []
    fileprivate var lastCellWitoutMiningModes = 0
    
    fileprivate var sortedNames: [String] = []
    fileprivate var sortedAlgoName: String?
    fileprivate var sortedCoinName: String?
    fileprivate var isUp: Bool = true
    var delegate: PoolInfoViewControllerDelegate?
    private let pageTypes = PoolStateEnum.allCases
    private var currentPage = PoolStateEnum.coins
    private var isSingleCoin = true
    private var webUrl = ""
    private var lastSeen: String?
    private var lastSection: Int?
    private var sectionExpanded = true
    private var lastCell: PoolInfoSecionView?
    
    private var indexPaths: [IndexPath] = []
    
    // MARK: - Static
    static func initializeStoryboard() -> PoolInfoViewController? {
        return UIStoryboard(name: "AccountDetails", bundle: nil).instantiateViewController(withIdentifier: PoolInfoViewController.name) as? PoolInfoViewController
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
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
            self.getPoolStatistics()
        }
    }
}

// MARK: - Startup default setup
extension PoolInfoViewController {
    fileprivate func startupSetup() {
        addRefreshControl()
        
        getPoolStatistics()
        setupSegmentControl()
        setupTableView()
        setupSort()
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "PoolInfoSecionView", bundle: nil), forCellReuseIdentifier: "PoolInfoSecionView")
        tableView.register(UINib(nibName: "MiningModesTableViewCell", bundle: nil), forCellReuseIdentifier: "MiningModesTableViewCell")
    }
    
    fileprivate func setupSort() {
        
        self.sortedAlgoName = "name"
        self.sortedCoinName = "name"
        
        if let sortedName = UserDefaults.standard.value(forKey: "sortedAlgosString (\(DatabaseManager.shared.currentUser?.id ?? "") \(account.keyPath)") as? String {
            self.sortedAlgoName = sortedName
        }
        if let sortedName = UserDefaults.standard.value(forKey: "sortedCoinsString (\(DatabaseManager.shared.currentUser?.id ?? "") \(account.keyPath)") as? String {
            self.sortedCoinName = sortedName
        }
        
        if currentPage == .algos {
            sortNameButton.setTitle(sortedAlgoName != nil ? sortedAlgoName?.localized() :"name".localized(), for: .normal)
            
        } else {
            sortNameButton.setTitle(sortedCoinName != nil ? sortedCoinName?.localized() :"name".localized(), for: .normal)
        }
        
        sortParentView?.backgroundColor = .clear
        sortParentView?.removeLayer()
        sortLayerView.roundCorners(radius: 15)
        sortLayerView.backgroundColor = .tableCellBackground
        sortNameButton.roundCorners(radius: 11)
        sortNameButton.addTarget(self, action: #selector(sortNameButtonAction), for: .touchUpInside)
        sortUpDownButton.addTarget(self, action: #selector(sortUpDownButtonAction), for: .touchUpInside)
        setSortTitle()
    }
    
    fileprivate func setSortTitle() {
        let imageName = isUp ? "arrow_up" : "arrow_down"
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        sortUpDownButton.setImage(image, for: .normal)
        sortUpDownButton.tintColor = darkMode ? .white : .black
    }
    
    fileprivate func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(getPoolStatistics(_:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.backgroundView = refreshControl
        }
    }
    
    private func setupSegmentControl() {
        chooseSegmentControl.delegate = self
        let titles = pageTypes.map { $0.rawValue.localized() }
        chooseSegmentControl.setSegments(titles)
    }
}

// MARK: - Actions
extension PoolInfoViewController {
    @objc func websiteButtonAction() {
        openURL(urlString: webUrl)
    }
    
    @objc func getPoolStatistics(_ refreshControl: UIRefreshControl? = nil) {
        if refreshControl == nil {
            Loading.shared.startLoading(ignoringActions: true, for: self.view)
        }
        PoolRequestService.shared.getPoolStatistics(poolType: account.poolType, poolSubItem: account.poolSubItem, success: { (statistics) in
            self.info = statistics
            self.reloadSegmentData()
            Loading.shared.endLoading(for: self.view)
            refreshControl?.endRefreshing()
        }, failer: { (error) in
            Loading.shared.endLoading(for: self.view)
            refreshControl?.endRefreshing()
            self.showAlertView("", message: error, completion: nil)
        })
    }
    
    func reloadSegmentData() {
        guard self.info != nil else { return }
        allRows.removeAll()
        sortedNames.removeAll()
        currentMiningModes.removeAll()
        
        if self.info!.coinsStats.isEmpty && self.info!.algosStats.isEmpty { return }
        
        if !self.info!.coinsStats.isEmpty && !self.info!.algosStats.isEmpty {
            self.chooseSegmentControl.isHidden = false
        } else {
            self.segmentHeightConstraits.constant = 0
        }
        if self.info!.coinsStats.isEmpty && !self.info!.algosStats.isEmpty {
            self.currentPage = .algos
        }
        
        if info!.lastSeen > 0 {
            delegate?.saveLastUpdate(lastSeen: info!.lastSeen.getDateFromUnixTime())
        }
        
        switch currentPage {
        case .algos:
            for algoInfo in self.info!.algosStats {
                configData(info: algoInfo)
            }
            if self.info!.algosStats.count != 1 {
                self.isSingleCoin = false
                self.sortParentView?.isHidden = false
                
                guard sortedAlgoName == nil else {
                    sortAllRow(sortingName: sortedAlgoName!)
                    sortNameButton.setTitle(sortedAlgoName != nil ? sortedAlgoName?.localized() :"name".localized(), for: .normal)
                    return
                }
            }
        case .coins:
            let rates = UserDefaults.standard.value(forKey: "\(DatabaseManager.shared.currentUser?.id ?? "" )/rates") as? [String:Double]
            let currencyMultiplier: Double = rates?[Locale.appCurrency] ?? 1.0
            
            for coinInfo in self.info!.coinsStats {
                
                configData(info: coinInfo, price: currencyMultiplier)
            }
            if self.info!.coinsStats.count != 1 {
                self.isSingleCoin = false
                self.sortParentView?.isHidden = false
                
                guard sortedCoinName == nil else {
                    sortAllRow(sortingName: sortedCoinName!)
                    sortNameButton.setTitle(sortedCoinName != nil ? sortedCoinName?.localized() :"name".localized(), for: .normal)
                    return
                }
            }
        }
        if isSingleCoin {
            sortParentView?.removeFromSuperview()
        } 
        tableView.reloadData()
    }
    
    func configData(info: PoolStateCoinOrAlgoModel, price: Double = 1) {
        let hsUnit = info.hsUnit == "" ? account.hsUnit : info.hsUnit
        rows.removeAll()
        //  sortedNames.removeAll()
        if !sortedNames.contains("name") { sortedNames.append("name") }
        
        headerRow = ExpandableRowsForPoolInfo(expanded: false, rows: rows)
        
        if let coinName = info.coinName {
            if isSingleCoin { rows.append(("coin_name", coinName,"")) }
            headerRow.coinName = coinName
        }
        if let currency = info.currency {
            if isSingleCoin { rows.append(("currency", currency,"")) }
            headerRow.coinCurrency = currency
        }
        if let algoName = info.algo {
            if isSingleCoin { rows.append(("algorithm", algoName,"")) }
            if currentPage == .algos {  headerRow.coinName = algoName }
        }
        
        let priceUSD = info.priceUSD
        
        if priceUSD != -1.0, let priceBTC = info.priceBTC {
            rows.append(("price",  "\(Locale.appCurrencySymbol) " + (priceUSD * price).getString() + " | \(priceBTC)",""))
        } else if priceUSD != -1.0 {
            let priceCurrency = "price".localized() + Locale.appCurrency
            rows.append((priceCurrency, "\(Locale.appCurrencySymbol) " + (priceUSD * price).getString(),""))//("price_usd", priceUSD,""))
        } else if let priceBTC = info.priceBTC {
            rows.append(("price_btc", priceBTC,""))
        }
        if let icon = info.icon {
            headerRow.coinImagePath = icon
        }
        if let activeMiners = info.activeMiners {
            rows.append(("active_miners", activeMiners,""))
            if !sortedNames.contains("active_miners") { sortedNames.append("active_miners") }
        }
        if let activeWorkers = info.activeWorkers {
            rows.append(("active_workers", activeWorkers,""))
            if !sortedNames.contains("active_workers") { sortedNames.append("active_workers") }
        }
        
        if info.hsUnit == "" {
            if let hashrate = info.hashrate?.toDouble()?.textFromHashrate(account: account) {
                rows.append(("hashrate", hashrate,""))
                if !sortedNames.contains("hashrate") { sortedNames.append("hashrate") }
                
            } else if let hashrate = info.hashrate?.toUInt64()?.textFromHashrate(account: account) {
                rows.append(("hashrate", hashrate,""))
                if !sortedNames.contains("hashrate") { sortedNames.append("hashrate") }
            } // For HsUnit
        } else {
            if let hashrate = info.hashrate?.toDouble()?.textFromHashrate(hsUnit: info.hsUnit) {
                rows.append(("hashrate", hashrate,""))
                if !sortedNames.contains("hashrate") { sortedNames.append("hashrate") }
            } else if let hashrate = info.hashrate?.toUInt64()?.textFromHashrate(hsUnit: info.hsUnit) {
                rows.append(("hashrate", hashrate,""))
                if !sortedNames.contains("hashrate") { sortedNames.append("hashrate") }
            } // For HsUnit
        }
        
        if let lastMinedBlockTime = info.lastMinedBlockTime, let lastMinedBlock = info.lastMinedBlock {
            rows.append(("last_mined_block", "\(lastMinedBlock) (\(lastMinedBlockTime))",""))
        } else if let lastMinedBlockTime = info.lastMinedBlockTime {
            rows.append(("last_mined_block_time", lastMinedBlockTime,""))
        } else if let lastMinedBlock = info.lastMinedBlock {
            rows.append(("last_mined_block", lastMinedBlock,""))
        }
        
        if let currentNetBlock = info.currentNetBlock { rows.append(("current_block", currentNetBlock,"")) }
        if let nextNetBlock = info.nextNetBlock { rows.append(("next_block", nextNetBlock,"")) }
        
        if let blocksPerHour = info.blocksPerHour { rows.append(("blocks_per_hour", blocksPerHour,"")) }
        
        if let netHashrate = info.netHashrate?.toDouble()?.textFromHashrate(hsUnit: hsUnit) {
            rows.append(("network_hashrate", netHashrate,""))
            if !sortedNames.contains("network_hashrate") { sortedNames.append("network_hashrate") }
        }
        if let netDifficulty = info.netDifficulty {
            rows.append(("network_difficulty", netDifficulty,""))
            if !sortedNames.contains("network_difficulty") { sortedNames.append("network_difficulty") }
        }
        if let netNextDifficulty = info.netNextDifficulty, let _ = info.netDifficulty {
            var str = ""
            if let per = info.difficultyPerDouble {
                str = String(per.getFormatedString())
            }
            let value = netNextDifficulty + " (\(str) %)"
            rows.append(("network_next_difficulty", value,""))
            
        }
        if let netBlockTime = info.netBlockTime { rows.append(("network_block_time", netBlockTime,"")) }
        if let netRetargetTime = info.netRetargetTime { rows.append(("network_retarget_time", netRetargetTime,"")) }
        if let netTime = info.netTime { rows.append(("network_time", netTime,"")) }
        
        if let rewardType = info.rewardType { rows.append(("reward_type", rewardType,"")) }
        
        if let confirmations = info.confirmations {
            rows.append(("confirmations", confirmations,""))
            if !sortedNames.contains("confirmations") { sortedNames.append("confirmations") }
            
        }
        if let minApThreshold = info.minApThreshold { rows.append(("min_ap_threshold", minApThreshold,"")) }
        if let maxApThreshold = info.maxApThreshold { rows.append(("max_ap_threshold", maxApThreshold,"")) }
        
        if let totalBlocksFound = info.totalBlocksFound { rows.append(("total_blocks_found", totalBlocksFound,"")) }
        if let blocksFound24h = info.blocksFound24h { rows.append(("blocksFound24h", blocksFound24h,"")) }
        if let totalAltBlocksFound = info.totalAltBlocksFound { rows.append(("total_alt_blocks_found", totalAltBlocksFound,"")) }
        if let curRoundTimeDur = info.curRoundTimeDur { rows.append(("current_round_duration", curRoundTimeDur,"")) }
        if let luckHours = info.luckHours { rows.append(("luckHours", luckHours + " " + "hr".localized(), "" )) }
        if let blocksPending = info.blocksPending { rows.append(("blocksPending", blocksPending ,"")) }
        if let blocksOrphaned = info.blocksOrphaned { rows.append(("blocksOrphaned", blocksOrphaned,"")) }
        if let blocksConfirmed = info.blocksConfirmed { rows.append(("blocksConfirmed", blocksConfirmed,"")) }
        if let totalPaid = info.totalPaid { rows.append(("totalPaid", totalPaid,"")) }
        if let blockTime = info.blockTime { rows.append(("blockTime"  , blockTime + " " + "sec".localized(), "")) }
        if let minerReward = info.minerReward { rows.append(("minerReward", minerReward,"")) }
        if let blockReward = info.blockReward { rows.append(("blockReward", blockReward,"")) }
        
        if let luck = info.luck, let luckPer = info.luckPer {
            rows.append(("luck", "\(luck) (\(luckPer) %)",""))
            if !sortedNames.contains("luck") { sortedNames.append("luck") }
        } else if let luck = info.luck {
            rows.append(("luck", luck,""))
            if !sortedNames.contains("luck") { sortedNames.append("luck") }
        } else if let luckPer = info.luckPer {
            rows.append(("luck", luckPer + " %",""))
            if !sortedNames.contains("luck") { sortedNames.append("luck") }
        }
        if info.coins != -1.0 {
            rows.append(("coins", info.coins.getString(),""))
            if !sortedNames.contains("coins") { sortedNames.append("coins") }
        }
        self.checkingMiningModes(miningModes: info.miningModes)
        
        headerRow.rows = self.rows
        allRows.append(headerRow)
    }
    
    func checkingMiningModes(miningModes:[MiningModes]) {
        
        if miningModes.contains(where: {$0.system == nil}) {
            for minigMode in miningModes {
                if let feeStr = minigMode.feeStr {
                    rows.append((Fee.fee.rawValue, feeStr,""))
                    if !sortedNames.contains(Fee.fee.rawValue.localized()) { sortedNames.append(Fee.fee.rawValue.localized()) }
                }
                if let txFeeStr = minigMode.txFeeStr {
                    rows.append((Fee.txFee.rawValue, txFeeStr,""))
                    if !sortedNames.contains(Fee.txFee.rawValue.localized()) { sortedNames.append(Fee.txFee.rawValue.localized()) }
                }
                if let txFeeAuto = minigMode.txFeeAuto {
                    rows.append((Fee.txFeeAuto.rawValue, txFeeAuto.getString(),""))
                    if !sortedNames.contains(Fee.txFeeAuto.rawValue.localized()) { sortedNames.append(Fee.txFeeAuto.rawValue.localized()) }
                }
                if let txFeeManual = minigMode.txFeeManual { rows.append((Fee.txFeeManual.rawValue, txFeeManual.getString(),""))
                    if !sortedNames.contains(Fee.txFeeManual.rawValue.localized()) { sortedNames.append(Fee.txFeeManual.rawValue.localized()) }
                }
            }
        } else {
            for minigMode in miningModes {
                if let system = minigMode.system {
                    rows.append(("payout_system", system,""))
                    headerRow.isSystemExist = true
                }
                if let feeStr = minigMode.feeStr {
                    rows.append((Fee.fee.rawValue, feeStr, minigMode.system!))
                    if !sortedNames.contains("\(minigMode.system!) \(Fee.fee.rawValue.localized())") { sortedNames.append("\(minigMode.system!) \(Fee.fee.rawValue.localized())") }
                }
                if let txFeeStr = minigMode.txFeeStr {
                    rows.append((Fee.txFee.rawValue, txFeeStr,minigMode.system!))
                    if !sortedNames.contains("\(minigMode.system!) \(Fee.txFee.rawValue.localized())") { sortedNames.append("\(minigMode.system!) \(Fee.txFee.rawValue.localized())") }
                }
                if let txFeeAuto = minigMode.txFeeAuto {
                    rows.append((Fee.txFeeAuto.rawValue, txFeeAuto.getString(),minigMode.system!))
                    if !sortedNames.contains("\(minigMode.system!) \(Fee.txFeeAuto.rawValue.localized())") { sortedNames.append("\(minigMode.system!) \(Fee.txFeeAuto.rawValue.localized())") }
                }
                if let txFeeManual = minigMode.txFeeManual {
                    rows.append((Fee.txFeeManual.rawValue, txFeeManual.getString(),minigMode.system!))
                    if !sortedNames.contains("\(minigMode.system!) \(Fee.txFeeManual.rawValue.localized())") { sortedNames.append("\(minigMode.system!) \(Fee.txFeeManual.rawValue.localized())") }
                }
            }
        }
    }
}

// MARK: - TableView methods
extension PoolInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.allRows.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSingleCoin { return  allRows[section].rows.count } // For Single Coin
        
        return allRows[section].isExpanded ? allRows[section].rows.count + 1  : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 && !isSingleCoin {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PoolInfoSecionView", for: indexPath) as? PoolInfoSecionView {
                let coin = allRows[indexPath.section]
                let sortedName = currentPage == .algos ? self.sortedAlgoName ?? "" : self.sortedCoinName ?? ""
                
                cell.setData(rows: coin, IndexPath: indexPath,isAlgos: currentPage == .algos,sortedName: sortedName)
                return cell
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailsTableViewCell.name) as! DetailsTableViewCell
        
        cell.setInfoData(list: allRows[indexPath.section], indexPath: indexPath,isSingelCoin: isSingleCoin)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? PoolInfoSecionView {
            
            expandSection(for: indexPath)
            cell.animateArrow(expanded: sectionExpanded)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return PoolInfoSecionView.height
        } else {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
}

// MARK: - Set data
extension PoolInfoViewController {
    public func setAccount(_ account: PoolAccountModel) {
        self.account = account
    }
    
    public func setWebUrl(_ webUrl: String) {
        self.webUrl = webUrl
    }
}

// MARK: - Segment control delegate
extension PoolInfoViewController: BaseSegmentControlDelegate {
    func segmentSelected(index: Int) {
        
        switch pageTypes[index] {
        
        case .algos:
            self.currentPage = .algos
            self.lastSection = 0
            self.reloadSegmentData()
            
        case .coins:
            self.currentPage = .coins
            self.lastSection = 0
            self.reloadSegmentData()
        }
    }
}

//MARK: - Helpers -

private enum PoolStateEnum: String, CaseIterable {
    case coins = "Coin"
    case algos = "Algorithm"
}

enum Fee: String, CaseIterable {
    case fee = "fee"
    case txFee = "txFee"
    case txFeeAuto = "txFee_auto"
    case txFeeManual = "txFee_manual"
}


//MARK: -- Expandable part of code

extension PoolInfoViewController {
    func expandSection(for indexPath: IndexPath) {
        if indexPath.row == 0 {
            var existExpandableData = false
            let data = allRows[indexPath.section]
            
            let indexPaths = data.rows.indices.map { IndexPath(row: $0 + 1, section: indexPath.section) }
            self.indexPaths = indexPaths
            let isExpanded = data.isExpanded
            data.isExpanded = !isExpanded
            
            if lastCell == nil {
                lastCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PoolInfoSecionView
            }
            
            if let lastSection = lastSection {
                if lastSection != indexPath.section {
                    let restData = allRows[lastSection]
                    let restIndexPaths = restData.rows.indices.map { IndexPath(row: $0 + 1, section: lastSection) }
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
            lastCell = tableView.cellForRow(at: indexPath) as? PoolInfoSecionView
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

class ExpandableRowsForPoolInfo: NSObject {
    public var isExpanded = false
    public var rows = [(name: String, value: String,systemTyoe: String)]()
    var coinName = ""
    var coinId = ""
    var coinCurrency = ""
    var coinImagePath = ""
    var isSystemExist = false
    
    init(expanded: Bool, rows: [(name: String, value: String,systemTyoe: String)]) {
        self.isExpanded = expanded
        self.rows = rows
    }
}

//MARK: -- Sorting Part

extension PoolInfoViewController {
    
    @objc func sortNameButtonAction() {
        showActionShit(self, type: .simple, items: sortedNames)
    }
    
    @objc func sortUpDownButtonAction() {
        animateArrow(isUp: self.isUp)
        sortAllRow(sortingName: currentPage == .algos ? self.sortedAlgoName ?? "" : self.sortedCoinName ?? "")
    }
    
    func sortAllRow(sortingName: String) {
        
        let components = sortingName.components(separatedBy: " ")
        var rowsForSorting: ExpandableRowsForPoolInfo?
        
        guard sortingName != "name" else {
            allRows.sort {
                let item1 = $0.coinName
                let item2 = $1.coinName
                return isUp ? item1 < item2 : item1 > item2
            }
            tableView.reloadData()
            return
        }
        
        if components.count < 2 {
            if let rows =  allRows.filter({$0.rows.filter({$0.name == sortingName }).first != nil}).first {
                rowsForSorting = rows
            }
        }
        else {
            if let rows =  allRows.filter({$0.rows.filter({$0.name.localized() == components[1] && $0.systemTyoe == components[0] }).first != nil}).first {
                rowsForSorting = rows
            }
        }
        guard rowsForSorting != nil else { return }
        
        for row in rowsForSorting!.rows {
            if row.name == sortingName {
                if sortingName == "hashrate" {
                    allRows.sort {
                        let item1 = $0.rows.filter({$0.name == sortingName}).first?.value.textHashrateToDouble() ?? 0
                        let item2 = $1.rows.filter({$0.name == sortingName}).first?.value.textHashrateToDouble() ?? 0
                        return isUp ? item1 < item2 : item1  > item2
                    }
                } else {
                    allRows.sort {
                        let item1 = $0.rows.filter({$0.name == sortingName}).first?.value.toDouble() ?? 0
                        let item2 = $1.rows.filter({$0.name == sortingName}).first?.value.toDouble() ?? 0
                        return isUp ? item1 < item2 : item1 > item2
                    }
                }
            } else if row.systemTyoe == components[0] && row.name.localized() == components[1]  {
                allRows.sort {
                    
                    if let item1 = $0.rows.filter({$0.name.localized() == components[1] && $0.systemTyoe == components[0] }).first?.value.toDouble() {
                        let item2 = $1.rows.filter({$0.name.localized() == components[1] && $0.systemTyoe == components[0] }).first?.value.toDouble() ?? 0
                        return isUp ? item1 < item2 : item1 > item2
                    }
                    return false
                }
            }
        }
        tableView.reloadData()
    }
    
    func rotateArrow(angle: CGFloat) {
        self.isUp.toggle()
        if sortUpDownButton.transform != CGAffineTransform(rotationAngle: angle) {
            DispatchQueue.main.async {
                UIView.animate(withDuration: Constants.animationDuration) {
                    self.sortUpDownButton.transform = CGAffineTransform(rotationAngle: angle)
                }
            }
        }
    }
    func animateArrow(isUp: Bool) {
        rotateArrow(angle: isUp ? .pi : 0)
    }
}


//MARK: -- Alert VC Delegate
extension PoolInfoViewController: ActionSheetViewControllerDelegate {
    func actionShitSelected(index: Int) {
        switch currentPage {
        case .algos:
            UserDefaults.standard.setValue( sortedNames[index], forKey: "sortedAlgosString (\(DatabaseManager.shared.currentUser?.id ?? "") \(account.keyPath)")
            sortedAlgoName = sortedNames[index]
            sortAllRow(sortingName: sortedAlgoName!)
        case .coins:
            UserDefaults.standard.setValue( sortedNames[index], forKey: "sortedCoinsString (\(DatabaseManager.shared.currentUser?.id ?? "") \(account.keyPath)")
            sortedCoinName = sortedNames[index]
            sortAllRow(sortingName: sortedCoinName!)
        }
        self.sortNameButton.setTitle(sortedNames[index].localized(), for: .normal)
    }
}
