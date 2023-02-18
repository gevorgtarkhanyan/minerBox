//
//  AccounBalanceViewController.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 17.08.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

class AccounBalanceViewController: BaseViewController {
    
    // MARK: - Views
    @IBOutlet weak var accountBalanceTableView: BaseTableView!
    
    //MARK: - Properties
    private var coins = [CoinState]()
    fileprivate var headerRow = ExpandableRows(expanded: false, rows: [])
    fileprivate var rows = [(name: String, value: String)]()
    fileprivate var allRows = [ExpandableRows]()
    
    private var lastSection: Int?
    private var sectionExpanded = true
    private var lastCell: CoinHeaderTableViewCell?
    fileprivate var payments = [PoolPaymentModel]()
    fileprivate var hideRightArrowButton = false
    private var nextPayoutTimeState = false


    private var indexPaths: [IndexPath] = []
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getPoolPayments()
    }
    
    override func languageChanged() {
        title = "balance".localized()
    }
    
    func getPoolPayments() {
        guard let account = Cacher.shared.account else {return}
        
        PoolRequestService.shared.getAccountPayments(poolId: account.id, poolType: account.poolType, type: PoolPaymentType.resentCredit,successArray: { (payments) in
            self.hideRightArrowButton = false
            self.setupTableViewData()
            Loading.shared.endLoading(for: self.view)
            self.payments = payments
        }) { (error) in
            self.hideRightArrowButton = true
            self.setupTableViewData()
            Loading.shared.endLoading(for: self.view)
        }
    }
    
    
    func setupTableViewData() {
        self.accountBalanceTableView.register(UINib(nibName: CoinHeaderTableViewCell.name , bundle: nil), forCellReuseIdentifier: CoinHeaderTableViewCell.name)
        self.accountBalanceTableView.register(UINib(nibName: CoinStateTableViewCell.name , bundle: nil), forCellReuseIdentifier: CoinStateTableViewCell.name)
        
        self.allRows.removeAll()
        for coin in self.coins {
            configData(coin: coin)
        }
        self.accountBalanceTableView.reloadData()
    }
    
    func configData(coin: CoinState) {
        rows.removeAll()
        headerRow = ExpandableRows(expanded: false, rows: rows)
        
        if coin.credit != -1 {
            rows.append(("credit", coin.credit.getString()))
        }
        if coin.orphaned != -1 {
            rows.append(("orphaned", coin.orphaned.getString()))
        }
        if coin.unconfirmed != -1 {
            rows.append(("unconfirmed", coin.unconfirmed.getString()))
        }
        if coin.confirmed != -1 {
            rows.append(("confirmed", coin.confirmed.getString()))
        }
        if coin.unpaid != -1 {
            rows.append(("unpaid", coin.unpaid.getString()))
        }
        if coin.paid != -1 {
            rows.append(("paid", coin.paid.getString()))
        }
        if coin.paid24h != -1 {
            rows.append(("paid24h", (coin.paid24h.getString())))
        }
        if coin.reward24h != -1 {
            rows.append(("reward24h", (coin.reward24h.getString())))
        }
        if coin.totalBalance != -1 {
            rows.append(("totalBalance", (coin.totalBalance.getString())))
        }
        if coin.payoutThreshold != -1 {
            rows.append(("payoutThreshold", coin.payoutThreshold.getString()))
        }
        if coin.nextPayoutTimeDur != -1 {
            rows.append(("next_payout_time", coin.nextPayoutTimeDur.secondsToDayHr()))
            nextPayoutTimeState = true
        }
        if coin.nextPayoutTime != -1 {
            rows.append(("next_payout_time", coin.nextPayoutTime.textFromUnixTime()))
            nextPayoutTimeState = true
        }

        headerRow.coinImagePath = coin.icon ?? ""
        headerRow.coinId = coin.coinId ?? ""
        headerRow.coinName = coin.coinName ?? ""
        headerRow.coinCurrency = coin.currency ?? ""
        
        headerRow.rows = self.rows
        allRows.append(headerRow)
    }
    
}

// MARK: - Set data
extension AccounBalanceViewController {
    public func setCoins(_ coins: [CoinState]) {
        self.coins = coins
    }
}

// MARK: - TableView methods
extension AccounBalanceViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.allRows.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return allRows[section].isExpanded ? allRows[section].rows.count + 1   : 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0  {
            if let cell = tableView.dequeueReusableCell(withIdentifier: CoinHeaderTableViewCell.name, for: indexPath) as? CoinHeaderTableViewCell {
                let coin = allRows[indexPath.section]
                cell.setData(rows: coin, IndexPath: indexPath, hideRightArrowButton: hideRightArrowButton)
                cell.delegate = self
                
                return cell
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CoinStateTableViewCell.name) as! CoinStateTableViewCell
        
        cell.setCoinData(list: allRows[indexPath.section], indexPath: indexPath)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? CoinHeaderTableViewCell {
            
            expandSection(for: indexPath)
            cell.animateArrow(expanded: sectionExpanded)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return CoinHeaderTableViewCell.height
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

//MARK: - CoinHeaderTableViewCellDelegate
extension AccounBalanceViewController: CoinHeaderTableViewCellDelegate {
    func rightArrowTapped(index: Int) {
        guard let vc = PoolPaymentViewController.initializeStoryboard() else { return }
        
        let allCurrency = (Cacher.shared.accountSettings?.coins.map { $0.currency }) ?? []
        let containsCurrency = allCurrency.contains(allRows[index].coinCurrency)
        let currency = containsCurrency ? allRows[index].coinCurrency : nil
        vc.setCurrentPage(.resentCredit)
        vc.openFromBalance(currency: currency,payments: payments )
        navigationItem.setRightBarButtonItems(vc.rightBarButtonItms, animated: true)
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: -- Expandable part of code
class ExpandableRows: NSObject {
    public var isExpanded = false
    public var rows = [(name: String, value: String)]()
    var coinName = ""
    var coinId = ""
    var coinCurrency = ""
    var coinImagePath = ""
    var isSystemExist = false
    
    init(expanded: Bool, rows: [(name: String, value: String)]) {
        self.isExpanded = expanded
        self.rows = rows
    }
}

extension AccounBalanceViewController {
    func expandSection(for indexPath: IndexPath) {
        if indexPath.row == 0 {
            var existExpandableData = false
            let data = allRows[indexPath.section]
            
            let indexPaths = data.rows.indices.map { IndexPath(row: $0 + 1, section: indexPath.section) }
            self.indexPaths = indexPaths
            let isExpanded = data.isExpanded
            data.isExpanded = !isExpanded
            
            if lastCell == nil {
                lastCell = accountBalanceTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CoinHeaderTableViewCell
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
            lastCell = accountBalanceTableView.cellForRow(at: indexPath) as? CoinHeaderTableViewCell
            lastSection = indexPath.section
            sectionExpanded = !isExpanded
            
            hideKeyboard()
        }
    }
    
    func sectionExpande(_ bool: Bool, for indexPaths: [IndexPath], close: Bool = false, closingPaths: [IndexPath] = [], indexPath: IndexPath) {
        accountBalanceTableView.beginUpdates()
        if close, closingPaths.count != 0 {
            accountBalanceTableView.deleteRows(at: closingPaths, with: .fade)
        }
        if bool {
            accountBalanceTableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            accountBalanceTableView.insertRows(at: indexPaths, with: .fade)
        }
        accountBalanceTableView.endUpdates()
        accountBalanceTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        UIView.animate(withDuration: 0) {
            self.view.layoutIfNeeded()
        }
    }
}
