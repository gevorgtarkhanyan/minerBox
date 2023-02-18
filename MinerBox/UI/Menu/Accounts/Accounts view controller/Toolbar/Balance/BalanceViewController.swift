//
//  BanalceViewController.swift
//  MinerBox
//
//  Created by Vazgen Hovakinyan on 12.05.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

class BalanceViewController: BaseViewController {
    
    //MARK: - Property -
    
    @IBOutlet weak var balanceTableView: BaseTableView!
    @IBOutlet weak var totalBackgroundView: UIView!
    @IBOutlet weak var totalTableView: FlexibleTableView!
    
    @IBOutlet weak var totalHeaderView: UIView!
    @IBOutlet weak var headerLabel: BaseLabel!
    @IBOutlet weak var resizeButton: UIButton!
    
    @IBOutlet weak var collectionBackgroundView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var hideOrShowView: UIView!
    @IBOutlet weak var hideOrShowButton: UIButton!
    @IBOutlet weak var coinSettingView: UIView!
    @IBOutlet weak var coinLabel: BaseLabel!
    @IBOutlet weak var amountLabel: BaseLabel!
    @IBOutlet weak var btcLabel: BaseLabel!
    @IBOutlet weak var convertorTotalBackgroundView: BaseView!
    
    @IBOutlet weak var totalBackgroundViewHeightConstraits: NSLayoutConstraint!
    @IBOutlet weak var alphaView: BaseView!
    @IBOutlet weak var totalLabel: BaseLabel!
    @IBOutlet weak var totalConvertorButton: ConverterButton!
    
    fileprivate var rows = [[(key: BalanceType, value: String , coinId:String)]]()
    
    fileprivate var allAccounts: [PoolAccountModel] = []
    
    fileprivate var poolsBalances: [PoolBalanceModel] = []
    fileprivate var last = false
    fileprivate var acountCurrencies: [String:AccountCurrencie] = [:]
    fileprivate var acountCurrenciesKeys: [String] = []
    fileprivate var acountCurrence = AccountCurrencie(value: 0.0, convertBTC: 0.0,coinId: "")
    fileprivate var btcTotal: Double = 0.0
    fileprivate var isHideZero = true
    fileprivate var firstLaunch = true
    fileprivate var isSortedBalanceTypes = true
    
    fileprivate var selectedBalanceTypeNames: [BalanceSelectedType] = []
    fileprivate var filteredSelectedBalanceTypeNames : [BalanceSelectedType] = []
    
    
    var totalTableViewFrame: CGRect?
    
    fileprivate var userID: String? {
        return DatabaseManager.shared.currentUser?.id
    }
    
    private var currentUser: UserModel? {
        return DatabaseManager.shared.currentUser
    }
    
    // MARK: - Static
    
    static func initializeStoryboard() -> BalanceViewController? {
        return UIStoryboard(name: "Menu", bundle: nil).instantiateViewController(withIdentifier: BalanceViewController.name) as? BalanceViewController
    }
    
    //MARK: - Live Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.getPoolsBalance()
        self.getAllAccounts()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.05) {
                self.collectionView.flashScrollIndicators()
            }
        }
    }
    
    override func languageChanged() {
        title = "income".localized()
    }
    //MARK: - Methods -
    func setupTableView() {
        balanceTableView.register(UINib(nibName: "BalanceTableViewCell", bundle: nil), forCellReuseIdentifier: "balanceCell")
        totalBackgroundView.backgroundColor = .clear
        totalTableView.register(UINib(nibName: "BalanceTableViewCell", bundle: nil), forCellReuseIdentifier: "balanceCell")
        totalTableView.delaysContentTouches = true
        
        self.setupTotalBackgroundViews()
        self.configCollectionLayout()
        
    }
    
    func setupTotalBackgroundViews() {
        totalHeaderView.backgroundColor = .barSelectedItem
        totalHeaderView.roundCorners([.topRight,.topLeft], radius: 10)
        headerLabel.setLocalizableText("Total")
        resizeButton.setImage(UIImage(named: "arrowUpDown")!.withRenderingMode(.alwaysTemplate), for: .normal)
        resizeButton.tintColor = darkMode ? .sectionHeaderLight : .viewDarkBackground
        resizeButton.isUserInteractionEnabled = false
        collectionBackgroundView.backgroundColor = .tableCellBackground
        hideOrShowView.backgroundColor = .tableCellBackground
        coinSettingView.backgroundColor = .tableCellBackground
        self.totalBackgroundViewHeightConstraits.constant =  self.view.frame.height / 4
        let pan = UIPanGestureRecognizer(target: self, action: #selector(detectPan(_:)))
        pan.cancelsTouchesInView = false
        totalHeaderView.addGestureRecognizer(pan)
        totalHeaderView.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(totalHeaderViewAction)))
        
        self.hideOrShowButton.addTarget(self, action: #selector(hideOrShowButtonTapped), for: .touchUpInside)
        self.hideOrShowButton.setTitle(isHideZero ? "show_0".localized() : "hide_0".localized() , for: .normal)
        self.hideOrShowButton.setTitleColor(.barSelectedItem, for: .normal)
        
        self.coinLabel.setLocalizableText("coin_sort_coin")
        self.amountLabel.setLocalizableText("amount")
        self.btcLabel.setLocalizableText("BTC")
        self.coinLabel.changeFontSize(to: 13)
        self.amountLabel.changeFontSize(to: 13)
        self.btcLabel.changeFontSize(to: 13)
        self.coinLabel.changeFont(to: Constants.semiboldFont)
        self.btcLabel.changeFont(to: Constants.semiboldFont)
        self.amountLabel.changeFont(to: Constants.semiboldFont)
        
    }
    
    func configCollectionLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 200, height: 50)
        flowLayout.minimumLineSpacing = 2.0
        flowLayout.minimumInteritemSpacing = 5.0
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.backgroundColor = .clear
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        // Register the xib for collection view cell
        let cellNib = UINib(nibName: SubCollectionViewCelll.name, bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: SubCollectionViewCelll.name)
        
    }
    
    //MARK: -- Get all acounts
    func getAllAccounts() {
        if self.isLogedIn == false {
            self.hideTotalView()
            self.noDataButton!.isHidden = false
        } else {
            if let accounts = DatabaseManager.shared.allPoolAccounts {
                self.allAccounts = accounts
                if self.allAccounts.count >= 0 {
                    self.hideTotalView()
                }
            } else {
                Loading.shared.startLoading(for: self.view)
                PoolRequestService.shared.getAccounts(success: { (accounts) in
                    self.allAccounts = accounts
                }) { (error) in
                    self.showAlertView("", message: error.localized(), completion: nil)
                    Loading.shared.endLoading(for: self.view)
                }
            }
        }
    }
    
    func getPoolsBalance() {
        if self.isLogedIn == false{
            self.hideTotalView()
            self.noDataButton!.isHidden = false
        } else {
            Loading.shared.startLoading()
            PoolRequestService.shared.getPoolsBalance(success: { (accounts) in
                if self.allAccounts.count > 0 {
                    self.showTotalView()
                    self.noDataButton!.isHidden = true
                }
                self.poolsBalances = accounts
                let _ = self.poolsBalances.map({$0.userId = self.userID ?? "" })
                self.configTableViewies()
                self.totalTableView.isHidden = false
                self.alphaView.isHidden = false
                self.totalConvertorButton.isHidden = false
                
                Loading.shared.endLoading()
                
                if accounts.count == 0 {
                    self.noDataButton!.isHidden = false
                    self.hideTotalView()
                }
            }) { (error) in
                Loading.shared.endLoading()
                self.showAlertView("", message: error, completion: nil)
            }
        }
    }
    
    override func configNoDataButton() {
        super.configNoDataButton()
        noDataButton!.setTransferButton(text: "add_pool_account", subText: "", view: self.view)
        noDataButton!.addTarget(self, action: #selector(goToPoolAddPage), for: .touchUpInside)
        
    }
    
    private func hideTotalView() {
        totalBackgroundView.isHidden = true
        alphaView.backgroundColor = .clear
        convertorTotalBackgroundView.isHidden = true
        totalTableView.isHidden = true
        totalHeaderView.isHidden = true
        
    }
    
    private func showTotalView() {
        totalBackgroundView.isHidden = false
        alphaView.backgroundColor = darkMode ? .viewDarkBackground : .viewLightBackground
        convertorTotalBackgroundView.isHidden = false
        totalTableView.isHidden = false
        totalHeaderView.isHidden = false
    }
    
    func configTableViewies() {
        var allCoin = [BalanceCoin]()
        self.acountCurrencies.removeAll()
        
        self.checkSelectedAccount()
        self.checkSelectedBalanceTypes()
        
        //_ =  filtredBalances.map({$0.coins?.map({allCoin.append($0)})})
        for filtredBalance in poolsBalances {
            guard  filtredBalance.isSelected else { continue }
            _ = filtredBalance.coins?.map { allCoin.append($0) }
        }
        
        let currencies = allCoin.map { $0.currency }
        for currencie in currencies.removingDuplicates() {
            self.acountCurrencies[currencie] =  self.acountCurrence
        }
        
        self.configPoolPaids()
        
        self.btcTotal = 0.0
        
        let selectedType = selectedBalanceTypeNames.filter({$0.isSelected == true}).map({$0.balanceName})
        for balance in self.poolsBalances {
            if balance.isSelected {
                for currencieValue in balance.coins! {
                    
                    self.acountCurrencies[currencieValue.currency]?.coinId = currencieValue.coinId
                    
                    if selectedType.contains(BalanceType.orphaned.rawValue) && currencieValue.orphaned != -1 {
                        self.acountCurrencies[currencieValue.currency]?.value += currencieValue.orphaned
                    }
                    if selectedType.contains(BalanceType.unconfirmed.rawValue) && currencieValue.unconfirmed != -1 {
                        self.acountCurrencies[currencieValue.currency]?.value += currencieValue.unconfirmed
                    }
                    if selectedType.contains(BalanceType.confirmed.rawValue) && currencieValue.confirmed != -1 {
                        self.acountCurrencies[currencieValue.currency]?.value += currencieValue.confirmed
                    }
                    
                    if selectedType.contains(BalanceType.unpaid.rawValue) && currencieValue.unpaid != -1 {
                        self.acountCurrencies[currencieValue.currency]?.value += currencieValue.unpaid
                    }
                    
                    if selectedType.contains(BalanceType.paid.rawValue) && currencieValue.paid != -1 {
                        self.acountCurrencies[currencieValue.currency]?.value += currencieValue.paid
                    }
                    if selectedType.contains(BalanceType.paid24h.rawValue) && currencieValue.paid24h != -1 {
                        self.acountCurrencies[currencieValue.currency]?.value += currencieValue.paid24h
                    }
                    if selectedType.contains(BalanceType.reward24h.rawValue) && currencieValue.reward24h != -1 {
                        self.acountCurrencies[currencieValue.currency]?.value += currencieValue.reward24h
                    }
                    if selectedType.contains(BalanceType.totalBalance.rawValue) && currencieValue.totalBalance != -1 {
                        self.acountCurrencies[currencieValue.currency]?.value += currencieValue.totalBalance
                    }
                    if let priceBTC = self.acountCurrencies[currencieValue.currency]?.value {
                        self.acountCurrencies[currencieValue.currency]?.convertBTC = priceBTC * currencieValue.marketPriceBTC
                    }
                }
            }
        }
        if let isHideZero = UserDefaults.shared.value(forKey: "BalanceViewController_isHideZero") as? Bool {
            self.isHideZero = isHideZero
        }
        self.hideOrShowButton.setTitle(isHideZero ? "show_0".localized() : "hide_0".localized() , for: .normal)
        if isHideZero {
            for accountCurrence in acountCurrencies {
                if accountCurrence.value.value == 0 {
                    acountCurrencies.removeValue(forKey: accountCurrence.key)
                }
            }
        }
        
        for currency in self.acountCurrencies {
            self.btcTotal += currency.value.convertBTC
        }
        self.totalLabel.setLocalizableText(self.btcTotal.getString() + " BTC")
        self.totalConvertorButton.setData("bitcoin", amount: btcTotal)
        
        self.acountCurrenciesKeys = acountCurrencies.map({$0.key})
        self.acountCurrenciesKeys = self.acountCurrenciesKeys.sorted(by: < )
        self.totalTableView.reloadData()
    }
    
    func sortAccountAndSelectedBalances(){
        self.poolsBalances.sort(by: >)
    }
    
    func checkSelectedBalanceTypes() {
        if isSortedBalanceTypes {
            isSortedBalanceTypes = false
            for poolBalance in poolsBalances {
                for coin in poolBalance.coins! {
                
                    if coin.orphaned != -1 {
                        if  selectedBalanceTypeNames.contains(where: {$0.balanceName == BalanceType.orphaned.rawValue}) {
                            let balanceSelectedType = selectedBalanceTypeNames.filter({$0.balanceName == BalanceType.orphaned.rawValue}).first!
                            if poolBalance.isSelected { balanceSelectedType.count += 1 }
                            PoolBalanceManager.shared.ubdateBalanceCount(balanceSelectedType)
                        } else {
                            selectedBalanceTypeNames.append(compareWithDbObject(type: .orphaned, isSelected: poolBalance.isSelected))
                        }
                    }
                    if coin.unconfirmed != -1 {
                        if  selectedBalanceTypeNames.contains(where: {$0.balanceName == BalanceType.unconfirmed.rawValue}) {
                            let balanceSelectedType = selectedBalanceTypeNames.filter({$0.balanceName == BalanceType.unconfirmed.rawValue}).first!
                            if poolBalance.isSelected { balanceSelectedType.count += 1 }
                            PoolBalanceManager.shared.ubdateBalanceCount(balanceSelectedType)
                        } else {
                            selectedBalanceTypeNames.append(compareWithDbObject(type: .unconfirmed, isSelected: poolBalance.isSelected))
                        }
                    }
                    if coin.confirmed != -1 {
                        if  selectedBalanceTypeNames.contains(where: {$0.balanceName == BalanceType.confirmed.rawValue})  {
                            let balanceSelectedType = selectedBalanceTypeNames.filter({$0.balanceName == BalanceType.confirmed.rawValue}).first!
                            if poolBalance.isSelected { balanceSelectedType.count += 1 }
                            PoolBalanceManager.shared.ubdateBalanceCount(balanceSelectedType)
                        } else {
                            selectedBalanceTypeNames.append(compareWithDbObject(type: .confirmed, isSelected: poolBalance.isSelected))
                        }
                    }
                    if coin.unpaid != -1 {
                        if  selectedBalanceTypeNames.contains(where: {$0.balanceName == BalanceType.unpaid.rawValue}) {
                            let balanceSelectedType = selectedBalanceTypeNames.filter({$0.balanceName == BalanceType.unpaid.rawValue}).first!
                            if poolBalance.isSelected { balanceSelectedType.count += 1 }
                            PoolBalanceManager.shared.ubdateBalanceCount(balanceSelectedType)
                        } else {
                            selectedBalanceTypeNames.append(compareWithDbObject(type: .unpaid, isSelected: poolBalance.isSelected))
                        }
                    }
                    if coin.paid != -1 {
                        if  selectedBalanceTypeNames.contains(where: {$0.balanceName == BalanceType.paid.rawValue}) {
                            let balanceSelectedType = selectedBalanceTypeNames.filter({$0.balanceName == BalanceType.paid.rawValue}).first!
                            if poolBalance.isSelected { balanceSelectedType.count += 1 }
                            PoolBalanceManager.shared.ubdateBalanceCount(balanceSelectedType)
                        } else {
                            selectedBalanceTypeNames.append(compareWithDbObject(type: .paid, isSelected: poolBalance.isSelected))
                        }
                    }
                    
                    if coin.paid24h != -1 {
                        if  selectedBalanceTypeNames.contains(where: {$0.balanceName == BalanceType.paid24h.rawValue})  {
                            let balanceSelectedType = selectedBalanceTypeNames.filter({$0.balanceName == BalanceType.paid24h.rawValue}).first!
                            if poolBalance.isSelected { balanceSelectedType.count += 1 }
                            PoolBalanceManager.shared.ubdateBalanceCount(balanceSelectedType)
                        } else {
                            selectedBalanceTypeNames.append(compareWithDbObject(type: .paid24h, isSelected: poolBalance.isSelected))
                        }
                    }
                    if coin.reward24h != -1 {
                        if  selectedBalanceTypeNames.contains(where: {$0.balanceName == BalanceType.reward24h.rawValue})  {
                            let balanceSelectedType = selectedBalanceTypeNames.filter({$0.balanceName == BalanceType.reward24h.rawValue}).first!
                            if poolBalance.isSelected { balanceSelectedType.count += 1 }
                            PoolBalanceManager.shared.ubdateBalanceCount(balanceSelectedType)
                        } else {
                            selectedBalanceTypeNames.append(compareWithDbObject(type: .reward24h, isSelected: poolBalance.isSelected))
                        }
                    }
                    if coin.totalBalance != -1 {
                        if  selectedBalanceTypeNames.contains(where: {$0.balanceName == BalanceType.totalBalance.rawValue})  {
                            let balanceSelectedType = selectedBalanceTypeNames.filter({$0.balanceName == BalanceType.totalBalance.rawValue}).first!
                            if poolBalance.isSelected { balanceSelectedType.count += 1 }
                            PoolBalanceManager.shared.ubdateBalanceCount(balanceSelectedType)
                        } else {
                            selectedBalanceTypeNames.append(compareWithDbObject(type: .totalBalance, isSelected: poolBalance.isSelected))
                        }
                    }
                    if coin.credit != -1 {
                        if  selectedBalanceTypeNames.contains(where: {$0.balanceName == BalanceType.credit.rawValue})  {
                            let balanceSelectedType = selectedBalanceTypeNames.filter({$0.balanceName == BalanceType.credit.rawValue}).first!
                            if poolBalance.isSelected { balanceSelectedType.count += 1 }
                            PoolBalanceManager.shared.ubdateBalanceCount(balanceSelectedType)
                        } else {
                            selectedBalanceTypeNames.append(compareWithDbObject(type: .credit, isSelected: poolBalance.isSelected))
                        }
                    }
                    
                }
            }
            selectedBalanceTypeNames.sort(by: > )
            for filteredSelected in selectedBalanceTypeNames {
                if filteredSelected.count != 0 {
                    filteredSelectedBalanceTypeNames.append(filteredSelected)
                }
            }
        } else {
            filteredSelectedBalanceTypeNames.removeAll()
            for filteredSelected in selectedBalanceTypeNames {
                if filteredSelected.count != 0 {
                    filteredSelectedBalanceTypeNames.append(filteredSelected)
                }
            }
        }
        self.collectionView.reloadData()
    }
    
    func compareWithDbObject(type: BalanceType, isSelected: Bool) -> BalanceSelectedType {
        let selectedBalanceTypesFromDb = PoolBalanceManager.shared.getSelectedBalancies()
        
        let balanceSelectedType = BalanceSelectedType(name: type, userId: userID ?? "")
        if let balanceType = selectedBalanceTypesFromDb.filter({$0.balanceName == type.rawValue}).first {
            balanceSelectedType.isSelected = balanceType.isSelected
        }
        if isSelected { balanceSelectedType.count += 1 }
        PoolBalanceManager.shared.ubdateBalanceCount(balanceSelectedType)
        return balanceSelectedType
    }
    
    func checkSelectedAccount() {
        
        var _balance = PoolBalanceModel()
        let selectedBalances = PoolBalanceManager.shared.getBalancies()
        
        // self.filtredBalances.removeAll()
        var filteredBalances :[PoolBalanceModel] = []
        
        for balance  in  poolsBalances {
            
            var balanceNoExistProperty = false
            
            _balance = balance
            for  selectedBalance in  selectedBalances {
                if balance.poolId == selectedBalance.poolId  {
                    _balance = selectedBalance
                }
            }
            
            for coin in _balance.coins! {
                if coin.orphaned != -1 || coin.unconfirmed != -1 || coin.confirmed != -1 || coin.unpaid != -1 || coin.paid != -1 || coin.paid24h != -1 || coin.reward24h != -1 || coin.credit != -1  {
                    balanceNoExistProperty = true
                }
            }
            
            if balanceNoExistProperty {
                filteredBalances.append(_balance)
            }
        }
        poolsBalances = filteredBalances
        
        if firstLaunch {
            firstLaunch = false
            sortAccountAndSelectedBalances()
        }
    }
    
    func configPoolPaids() {
        
        self.rows.removeAll()
        
        for pool in poolsBalances {
            
            var paids = [(BalanceType, String,String)]()
            
            for coin in pool.coins! {
                
                
                if coin.orphaned != -1 {
                    paids.append((.orphaned, "\(coin.unconfirmed.getString()) \(coin.currency)",coin.coinId))
                }
                if coin.unconfirmed != -1 {
                    paids.append((.unconfirmed, "\(coin.unconfirmed.getString()) \(coin.currency)",coin.coinId))
                }
                if coin.confirmed != -1{
                    paids.append((.confirmed, "\(coin.confirmed.getString()) \(coin.currency)",coin.coinId))
                }
                
                if coin.unpaid != -1 {
                    paids.append((.unpaid, "\(coin.unpaid.getString()) \(coin.currency)",coin.coinId))
                }
               
                if coin.paid != -1 {
                    paids.append((.paid, "\(coin.paid.getString()) \(coin.currency)", coin.coinId))
                }
                if coin.paid24h != -1 {
                    paids.append((.paid24h, "\(coin.paid24h.getString()) \(coin.currency)", coin.coinId))
                }
                if coin.reward24h != -1 {
                    paids.append((.reward24h, "\(coin.reward24h.getString()) \(coin.currency)", coin.coinId))
                }
                if coin.totalBalance != -1 {
                    paids.append((.totalBalance, "\(coin.totalBalance.getString()) \(coin.currency)", coin.coinId))
                }
                if coin.credit != -1 {
                    paids.append((.credit, "\(coin.credit.textFromCredit())", coin.coinId))
                }
            }
            if !paids.isEmpty  {
                rows.append(paids)
            }
            
//            if pool.isSelected {
//                poolsBalances = poolsBalances.filter() {$0 != pool}
//                poolsBalances.insert(pool, at: 0)
//            }
        }
        self.balanceTableView.reloadData()
    }
}

// MARK: - TableView methods

extension BalanceViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView {
        case balanceTableView:
            return rows.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case balanceTableView:
            return rows[section].count
        default:
            return acountCurrencies.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = BalanceSectionView(frame: .zero)
        switch tableView {
        case self.balanceTableView:
            header.delegate = self
            header.setData(pool: poolsBalances[section],section: section)
            if poolsBalances[section].isSelected {
                header.contentView.roundCorners([.topLeft, .topRight], radius: 10)
            } else {
                header.contentView.roundCorners([.topLeft, .topRight,.bottomLeft,.bottomRight], radius: 10)
            }
            return header
            
        default:
            return nil
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableView {
        case self.balanceTableView:
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "balanceCell") as? BalanceTableViewCell {
                cell.delegate = self
                
                
                cell.setData(paid: rows[indexPath.section][indexPath.row], indexPath: indexPath,isConvertorIconShow: true,last: indexPath.row == rows[indexPath.section].indices.last ? true : false)
             
                return cell
            }
        default:
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "balanceCell") as? BalanceTableViewCell {
                let intIndex = indexPath.row
                let index = acountCurrenciesKeys[intIndex]
                let coinName = index
                let amount =  acountCurrencies[index]!.value
                let btcTotal =  acountCurrencies[index]!.convertBTC
                cell.delegate = self
                cell.setData(coinName: coinName, amount: amount.getString() , btcTotal: btcTotal.getString(),indexPath: indexPath,isConvertorIconShow: true,isAmmountConvertorIconShow: true)
                
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView {
        case self.balanceTableView:
            if poolsBalances[indexPath.section].isSelected {
                return BalanceTableViewCell.height
            } else {
                return 0
            }
        default:
            return BalanceTableViewCell.heightForTotal
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0.0
        }
        switch tableView {
        case self.balanceTableView:
            return BalanceSectionView.height
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch tableView {
        case self.balanceTableView:
            return 5
        default:
            return  0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }
    
}

//MARK: - Helpers -

struct AccountCurrencie {
    
    var value: Double
    var convertBTC: Double
    var coinId: String
}


//MARK: - BalanceTableViewCellDelegate -

extension BalanceViewController: BalanceTableViewCellDelegate {
    func converterIconTapped(indexPath: IndexPath, isBtcTotal: Bool, isAmmounValue:Bool ) {
        
        let sb = UIStoryboard(name: "More", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ConverterViewController") as! ConverterViewController
        
        
        guard !isAmmounValue  else {
            
            let index = acountCurrenciesKeys[indexPath.row]

            let coinId = acountCurrencies[index]!.coinId
            vc.headerCoinId = coinId
            vc.multiplier = acountCurrencies[index]!.value
            
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        guard !isBtcTotal  else {
            let index = acountCurrenciesKeys[indexPath.row]

            vc.headerCoinId = "bitcoin"
            
            if indexPath.row == acountCurrencies.count {
                vc.multiplier = btcTotal
                
            } else {
                vc.multiplier = acountCurrencies[index]!.convertBTC
            }
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        let currentItem = rows[indexPath.section][indexPath.row]
        
        if !poolsBalances.isEmpty {
            vc.headerCoinId = currentItem.coinId
            if let num = currentItem.value.toDouble() {
                vc.multiplier = num
            }
            navigationController?.pushViewController(vc, animated: true)
        } else {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension BalanceViewController: BalanceSectionViewDelegate {
    func selectedButtonTapped(for section: Int) {
        
        PoolBalanceManager.shared.ubdateAccount(poolsBalances[section])
        
        self.increaseOrDecrease(pool: poolsBalances[section],isIncrease: poolsBalances[section].isSelected)
        
        self.configTableViewies()
    }
    
    func increaseOrDecrease(pool: PoolBalanceModel, isIncrease: Bool ) {
        
        for coin in pool.coins! {
            
            
            if coin.orphaned != -1 {
                mapIngSelectedBalanceTypeNames(type: .orphaned, isIncrease: !isIncrease)
            }
            if coin.unconfirmed != -1 {
                mapIngSelectedBalanceTypeNames(type: .unconfirmed, isIncrease: !isIncrease)
            }
            if coin.confirmed != -1{
                mapIngSelectedBalanceTypeNames(type: .confirmed, isIncrease: !isIncrease)
            }
            if coin.unpaid != -1 {
                mapIngSelectedBalanceTypeNames(type: .unpaid, isIncrease: !isIncrease)
            }
            if coin.paid != -1 {
                mapIngSelectedBalanceTypeNames(type: .paid, isIncrease: !isIncrease)
            }
            if coin.paid24h != -1 {
                mapIngSelectedBalanceTypeNames(type: .paid24h, isIncrease: !isIncrease)
            }
            if coin.reward24h != -1 {
                mapIngSelectedBalanceTypeNames(type: .reward24h, isIncrease: !isIncrease)
            }
            if coin.totalBalance != -1 {
                mapIngSelectedBalanceTypeNames(type: .totalBalance, isIncrease: !isIncrease)
            }
            if coin.credit != -1 {
                mapIngSelectedBalanceTypeNames(type: .credit, isIncrease: !isIncrease)
            }
        }
    }
    
    func mapIngSelectedBalanceTypeNames (type: BalanceType, isIncrease: Bool) {
        _ = selectedBalanceTypeNames.map({ filtredBalance in
            if filtredBalance.balanceName == type.rawValue {
                if isIncrease { filtredBalance.count -= 1 } else { filtredBalance.count += 1 }
            }
        })
    }
    
    func goToDetalPage(section: Int) {
        guard let newVC = AccountDetailsPageController.initializeStoryboard() else { return }
        let poolId = poolsBalances[section].poolId
        for account in self.allAccounts {
            if poolId == account.id {
                newVC.setAccount(account)
                navigationController?.pushViewController(newVC, animated: true)
            }
        }
    }
    
    @objc func totalHeaderViewAction() {
        guard let totalBackgroundViewFrame = totalTableViewFrame else { return }
        let fullHeigthTableView = CGFloat(acountCurrencies.count ) * BalanceTableViewCell.heightForTotal + 157
        if totalBackgroundViewFrame.height <= 184 {
            UIView.animate(withDuration: 0.1) {
                self.totalBackgroundView.frame.origin.y = fullHeigthTableView
                self.totalBackgroundViewHeightConstraits.constant = fullHeigthTableView
                self.totalBackgroundView.updateConstraints()
                self.totalBackgroundView.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.1) {
                self.totalBackgroundView.frame.origin.y = 61
                self.totalBackgroundViewHeightConstraits.constant = 61
                self.totalBackgroundView.updateConstraints()
                self.totalBackgroundView.layoutIfNeeded()
            }
        }
    }
}


//MARK: - Total Backgorun Animation  -
extension BalanceViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let topFrame = totalBackgroundView.bounds
        
        if let touch = touches.first {
            let p = touch.location(in: totalBackgroundView)
            totalTableViewFrame = topFrame.contains(p) ? totalBackgroundView.frame : nil
        }
    }
    
    @objc func detectPan(_ recognizer: UIPanGestureRecognizer) {
        
        let translation  = recognizer.translation(in: totalBackgroundView.superview)
        guard let totalBackgroundViewFrame = totalTableViewFrame else { return }
        
        let fullHeigthTableView = CGFloat(acountCurrencies.count ) * BalanceTableViewCell.heightForTotal + 157
        
        if totalBackgroundViewFrame.height + -translation.y  > fullHeigthTableView + 10 {
            return
        }
        
        if totalBackgroundViewFrame.height + -translation.y > self.view.frame.height * 0.8 {
            return
        }
        
        if totalBackgroundViewFrame.height - translation.y  < 56 {
            return
        }
        
        UIView.animate(withDuration: 0.01) {
            self.totalBackgroundView.frame.origin.y = totalBackgroundViewFrame.origin.y + translation.y
            self.totalBackgroundViewHeightConstraits.constant = totalBackgroundViewFrame.height - translation.y
            self.totalBackgroundView.updateConstraints()
            self.totalBackgroundView.layoutIfNeeded()
        }
    }
    
    @objc func hideOrShowButtonTapped() {
        self.isHideZero.toggle()
        UserDefaults.shared.setValue(isHideZero, forKey: "BalanceViewController_isHideZero")
        self.configTableViewies()
    }
}

//MARK: - UICollectionViewDelegate -

extension BalanceViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout   {
    func collectionView(collectionviewcell: SubCollectionViewCelll?, index: Int, didTappedInTableViewCell: BaseTableViewCell) {
        PoolBalanceManager.shared.ubdateSelectedBalance(filteredSelectedBalanceTypeNames[index])
        filteredSelectedBalanceTypeNames[index].isSelected.toggle()
        self.configTableViewies()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredSelectedBalanceTypeNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SubCollectionViewCelll.name, for: indexPath) as? SubCollectionViewCelll {
            cell.setDate(balance: filteredSelectedBalanceTypeNames[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        PoolBalanceManager.shared.ubdateSelectedBalance(filteredSelectedBalanceTypeNames[indexPath.item])
        filteredSelectedBalanceTypeNames[indexPath.item].isSelected.toggle()
        self.configTableViewies()
    }
}





