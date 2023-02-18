//
//  CoinPriceAlertViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/27/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import Localize_Swift
import SwiftUI


protocol CoinPriceAlertViewControllerDelegate: AnyObject {
    func setAlerts(alerts: [AlertModel])
    func deleteAlert(with alert: AlertModel)
    func editAlert(with editableAlert: AlertModel)
    func deleteAlerts(with coinId: String)
    func ignorUIEnabled(_ bool: Bool)
}

class CoinPriceAlertViewController: BaseViewController {

    @IBOutlet weak var coinAlertTableView: BaseTableView!
    
    private var account: PoolAccountModel!
    private var editableAlert: AlertModel?
    private var lastSection: Int?
    private var sectionExpanded = true
    private var lastCell: CoinAlertSectionTableViewCell?
    private var currentCell: CoinAlertSectionTableViewCell?
    private var prepareForEdit = false
    public var alerts = [AlertModel]()
    private let rates = UserDefaults.standard.value(forKey: "\(DatabaseManager.shared.currentUser?.id ?? "" )/rates") as? [String:Double]
    var delegate: CoinPriceAlertViewControllerDelegate?
    
    private var doubleArray = [CoinAlertCellAsSectionDataModel]() {
        didSet {
            self.checkAlertContent()
        }
    }
    
    static func initializeStoryboard() -> CoinPriceAlertViewController? {
        return UIStoryboard(name: "CoinPrice", bundle: nil).instantiateViewController(withIdentifier: CoinPriceAlertViewController.name) as? CoinPriceAlertViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getAlerts()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editableAlert = nil
        prepareForEdit = false
        if UserDefaults.standard.bool(forKey: "alertsIsDownloaded") {
            self.checkAlertContent()
        }
    }
    override func configNoDataButton() {
        super.configNoDataButton()
        noDataButton!.setTransferButton(text: "add_coin_alert", subText: "", view: self.view)
        noDataButton!.addTarget(self, action: #selector(addAlertButtonAction), for: .touchUpInside)
    }
    
    func setupTableView() {
        coinAlertTableView.register(UINib(nibName: "CoinAlertSectionTableViewCell", bundle: nil), forCellReuseIdentifier: "alertSection")
        coinAlertTableView.register(UINib(nibName: "CoinAlertTableViewCell", bundle: nil), forCellReuseIdentifier: "alertCell")
        coinAlertTableView.separatorColor = .clear
    }
    
    func checkAlertContent() {
        print("testALertsEn")
        if doubleArray.count == 0 {
            noDataButton?.isHidden = false
        } else {
            noDataButton?.isHidden = true
        }
    }
    
    private func getAlerts() {
        let alertsIsDownloaded = UserDefaults.standard.bool(forKey: "alertsIsDownloaded")
        if user != nil && !alertsIsDownloaded {//alerts.isEmpty {
            delegate?.ignorUIEnabled(false)
            Loading.shared.startLoading()
            AlertRequestService.shared.getCoinAlerts(success: { (alerts) in
                self.alerts = alerts
                AlertCacher.shared.alerts = self.alerts
                self.configArrays(alerts: alerts)
                self.coinAlertTableView.reloadData()
                self.delegate?.setAlerts(alerts: alerts)
                self.delegate?.ignorUIEnabled(true)
                //for the one time download on segmented control
                UserDefaults.standard.set(true, forKey: "alertsIsDownloaded")
                Loading.shared.endLoading()
            }, failer: { (error) in
                Loading.shared.endLoading()
                self.delegate?.ignorUIEnabled(true)
                self.showAlertView("", message: error, completion: nil)
            })
        } else if !alerts.isEmpty {
            AlertCacher.shared.alerts = self.alerts
            self.configArrays(alerts: alerts)
            self.coinAlertTableView.reloadData()
        }
    }

    override func languageChanged() {
        title = "coin_price".localized()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let newVC = segue.destination as? AddCoinAlertViewController else { return }
        newVC.delegate = self
        if prepareForEdit {
            if let alert = editableAlert {
                newVC.setEditableAlert(alert)
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coinAlertTableView.setEditing(false, animated: false)
        coinAlertTableView.reloadData()
    }
    
    // MARK: -- Public methods
    @objc public func addAlertButtonAction() {
        performSegue(withIdentifier: "addAlertSegue", sender: self)
    }
    
    //MARK: -- Expandable part
    func expandSection(for indexPath: IndexPath) {
        if indexPath.row == 0 {
            var existExpandableData = false
            let data = doubleArray[indexPath.section]
            let indexPaths = data.models.indices.map { IndexPath(row: $0 + 1, section: indexPath.section) }
            let isExpanded = data.isExpanded
            data.isExpanded = !isExpanded
            
            if let lastSection = lastSection {
                if lastSection != indexPath.section {
                    let restData = doubleArray.filter {$0.coinName != data.coinName}
                    for currentData in restData {
                        let restIndexPaths = currentData.models.indices.map { IndexPath(row: $0 + 1, section: lastSection) }
                        if currentData.isExpanded {
                            existExpandableData = true
                            let expanded = currentData.isExpanded
                            currentData.isExpanded = !expanded
                            if lastCell != nil {
                                lastCell!.setInitialValues(show: !sectionExpanded)
                            }
                            sectionExpande(isExpanded, for: indexPaths, close: true, closingPaths: restIndexPaths, indexPath: indexPath)
                        }
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
            
            lastCell = coinAlertTableView.cellForRow(at: indexPath) as? CoinAlertSectionTableViewCell
            currentCell = lastCell
            lastSection = indexPath.section
            sectionExpanded = !isExpanded
        }
    }
    
    func sectionExpande(_ bool: Bool, for indexPaths: [IndexPath], close: Bool = false, closingPaths: [IndexPath] = [], indexPath: IndexPath) {
        coinAlertTableView.beginUpdates()
        if close, closingPaths.count != 0 {
            coinAlertTableView.deleteRows(at: closingPaths, with: .fade)
        }
        if bool {
            coinAlertTableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            coinAlertTableView.insertRows(at: indexPaths, with: .fade)
        }
        coinAlertTableView.endUpdates()
    }
}


// MARK: - Actions
extension CoinPriceAlertViewController {
    private func configArrays(alerts: [AlertModel]) {
        let prevArray = doubleArray
        let newAlert = alerts.sorted { $0.coinRank < $1.coinRank }
        var alreadyAppendedAlerts = [AlertModel]()

        doubleArray.removeAll()

        for i in newAlert.indices {
            if alreadyAppendedAlerts.contains(newAlert[i]) {
                continue
            }
            var models = [AlertModel]()
            let coinID = newAlert[i].coinID

            for j in alerts.indices {
                if newAlert[j].coinID == coinID {
                    models.append(newAlert[j])
                    alreadyAppendedAlerts.append(newAlert[j])
                }
            }
            
            let newAlerts = alerts.filter { (item) -> Bool in
                return item.coinID == coinID
            }
            guard let alert = newAlerts.first else { return }
            
            let coinName = alert.coinName
            let coinSymbolName = alert.coinSymbol
            let rank = String(alert.coinRank)
            let url = alert.iconPath
            let currencyMultiplier: Double = rates?[Locale.appCurrency] ?? 1.0
            let alertPrice = "\(Locale.getCurrencySymbol(cur: alert.cur)) " + alert.coinAlertPriceUSD.getString()
            let price = "\(Locale.appCurrencySymbol) " + (alert.coinMarketPriceUSD * currencyMultiplier).getString()
            let isExpanded = (prevArray.filter { (alert) -> Bool in
                return alert.coinName == coinName
            }).first?.isExpanded ?? false

            let model = CoinAlertCellAsSectionDataModel(isExpanded: isExpanded, models: models, rank: rank, url: url, coinSymbolName: coinSymbolName, coinName: coinName, price: price,alertPrice: alertPrice)
            
            if doubleArray.count == 0 {
                doubleArray = [model]
            } else {
                doubleArray.append(model)
            }
        }
    }

    // MARK: - Cell trailing actions
    func editAccount(indexPath: IndexPath) {
        editableAlert = doubleArray[indexPath.section].models[indexPath.row - 1]
        prepareForEdit = true
        performSegue(withIdentifier: "addAlertSegue", sender: self)
    }

    func deleteAccount(indexPath: IndexPath) {
        if indexPath.row != 0 {
           let alert = doubleArray[indexPath.section].models[indexPath.row - 1]
            deleteAlert(for: indexPath, alert: alert)
        } else {
            let alert = doubleArray[indexPath.section].models[indexPath.row]
            doubleArray[indexPath.section].models = []
            if currentCell == lastCell {
                hideSectionVisibleCells()
            }
            deleteAlerts(for: indexPath, coinId: alert.coinID)
        }
    }
    
    func hideSectionVisibleCells() {
         let cells = coinAlertTableView.visibleCells
         var alertCells: [CoinAlertTableViewCell] = []
         
         for cell in cells {
             if let alertCell = cell as? CoinAlertTableViewCell {
                 alertCells.append(alertCell)
             }
         }
        
         for cell in alertCells {
             UIView.animate(withDuration: 0.2) {
                 cell.alpha = 0
             }
         }
    }
    
    func deleteAlert(for indexPath: IndexPath, alert: AlertModel ) {
        Loading.shared.startLoading(ignoringActions: true, for: view)
        AlertRequestService.shared.removeAlertRequest(alertId: alert.id, success: { (string) in
            self.showToastAlert("", message: string.localized())
            self.delegate?.deleteAlert(with: alert)
            if indexPath.row != 0 {
                self.doubleArray[indexPath.section].models.remove(at: indexPath.row - 1)
                self.coinAlertTableView.beginUpdates()
                self.coinAlertTableView.deleteRows(at: [IndexPath(row: indexPath.row - 1, section: indexPath.section)], with: .fade)
                self.coinAlertTableView.reloadRows(at: [indexPath], with: .fade)
                self.coinAlertTableView.endUpdates()
            }
            if self.doubleArray[indexPath.section].models.count == 0 {
                self.doubleArray.remove(at: indexPath.section)
                self.coinAlertTableView.beginUpdates()
                self.coinAlertTableView.deleteSections([indexPath.section], with: .fade)
                self.coinAlertTableView.endUpdates()
                if let cell = self.lastCell {
                    cell.setInitialValues(show: false)
                }
            }
            self.coinAlertTableView.reloadData()
            Loading.shared.endLoading(for: self.view)
        }, failer: { (error) in
            Loading.shared.endLoading(for: self.view)
            self.showToastAlert("", message: error)
        })
    }
    
    func deleteAlerts(for indexPath: IndexPath, coinId: String) {
        Loading.shared.startLoading(ignoringActions: true, for: view)
        AlertRequestService.shared.removeAlertsRequest(coinId: coinId, success: { (string) in
            self.showToastAlert("", message: string.localized())
            
            self.delegate?.deleteAlerts(with: coinId)
            self.doubleArray.remove(at: indexPath.section)
            self.coinAlertTableView.beginUpdates()
            self.coinAlertTableView.deleteSections([indexPath.section], with: .fade)
            self.coinAlertTableView.endUpdates()
            if let cell = self.lastCell {
                cell.setInitialValues(show: false)
            }

            Loading.shared.endLoading(for: self.view)
        }, failer: { (error) in
            Loading.shared.endLoading(for: self.view)
            self.showToastAlert("", message: error)
        })
    }
}

// MARK: -- Table view delegate methods
extension CoinPriceAlertViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return doubleArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doubleArray[section].isExpanded ? doubleArray[section].models.count + 1 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "alertSection") as? CoinAlertSectionTableViewCell {
                let data = doubleArray[indexPath.section]
                cell.setupCell(data, for: indexPath, expanded: !sectionExpanded)
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "alertCell") as? CoinAlertTableViewCell {
                let allAlerts = doubleArray[indexPath.section].models
                if allAlerts.count != 0 {
                    let alert = allAlerts[indexPath.row - 1]
                    if indexPath.row == allAlerts.count {
                        cell.setupCell(alert, last: true)
                    } else {
                        cell.setupCell(alert)
                    }
                }
                return cell
            }
        }
        return UITableViewCell()
       }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CoinAlertSectionTableViewCell {
            expandSection(for: indexPath)
            currentCell = cell
            cell.show = sectionExpanded
            cell.animateArrow(expanded: sectionExpanded)
            cell.controlRoundCorners(expanded: sectionExpanded)
            cell.showSwipeView(false)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:CGFloat = 0
        
        if indexPath.row == 0 {
            height = CoinAlertSectionTableViewCell.height
        } else {
            height = AlertTableViewCell.height
        }
        
        return height
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if let cell = tableView.cellForRow(at: indexPath) as? CoinAlertSectionTableViewCell {
            currentCell = cell
        }
        
        let remove = UITableViewRowAction(style: .normal, title: "delete".localized()) { (_, indexPath) in
            if indexPath.row == 0 {
                self.showAlertViewController(nil, message: "ask_for_delete", otherButtonTitles: ["ok"], cancelButtonTitle: "cancel") { (responce) in
                    if responce == "ok" {
                        self.deleteAccount(indexPath: indexPath)
                    }
                }
            } else {
                self.showAlertViewController(nil, message: "ask_for_delete", otherButtonTitles: ["ok"], cancelButtonTitle: "cancel") { (responce) in
                    if responce == "ok" {
                        self.deleteAccount(indexPath: indexPath)
                    }
                }
            }
        }

        let edit = UITableViewRowAction(style: .normal, title: "edit".localized()) { (_, indexPath) in
            self.editAccount(indexPath: indexPath)
        }

        edit.backgroundColor = .cellTrailingSecond
        remove.backgroundColor = .cellTrailingFirst
        
        if indexPath.row != 0 {
            return [edit, remove]
        } else {
            if let cell = coinAlertTableView.cellForRow(at: indexPath) as? CoinAlertSectionTableViewCell {
                cell.showSwipeView(true)
            }
            return [remove]
        }
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let cell = tableView.cellForRow(at: indexPath) as? CoinAlertSectionTableViewCell {
            currentCell = cell
        }
        
        let edit = UIContextualAction(style: .normal, title: "") { (_, _, completion) in
            self.editAccount(indexPath: indexPath)
            completion(true)
        }

        let remove = UIContextualAction(style: .destructive, title: "") { (_, _, completion) in
            if indexPath.row == 0 {
                self.showAlertViewController(nil, message: "ask_for_delete", otherButtonTitles: ["ok"], cancelButtonTitle: "cancel") { (responce) in
                    if responce == "ok" {
                        self.deleteAccount(indexPath: indexPath)
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            } else {
                self.showAlertViewController(nil, message: "ask_for_delete", otherButtonTitles: ["ok"], cancelButtonTitle: "cancel") { (responce) in
                    if responce == "ok" {
                        self.deleteAccount(indexPath: indexPath)
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        }

        edit.image = UIImage(named: "cell_edit")
        edit.backgroundColor = .cellTrailingFirst

        remove.image = UIImage(named: "cell_delete")
        remove.backgroundColor = .red

        var swipeAction = UISwipeActionsConfiguration()
        
        if indexPath.row != 0 {
            swipeAction = UISwipeActionsConfiguration(actions: [remove, edit])
        } else {
            swipeAction = UISwipeActionsConfiguration(actions: [remove])
            if let cell = coinAlertTableView.cellForRow(at: indexPath) as? CoinAlertSectionTableViewCell {
                cell.showSwipeView(true)
            }
        }
        swipeAction.performsFirstActionWithFullSwipe = true // This is the line which disables full swipe
        return swipeAction
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if indexPath != nil {
            if let cell = coinAlertTableView.cellForRow(at: indexPath!) as? CoinAlertSectionTableViewCell {
                cell.showSwipeView(false)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
}

// MARK: - Add alert delegate
extension CoinPriceAlertViewController: AddCoinAlertViewControllerDelegate {
    func alertAdded(with alert: AlertModel) {
        if let cell = lastCell {
            cell.show = false
            cell.setInitialValues(show: false)
        }
        AlertCacher.shared.alerts.append(alert)
        self.alerts = AlertCacher.shared.alerts
        self.configArrays(alerts: self.alerts)
        coinAlertTableView.reloadData()
    }
    
    func editAlert(with editableAlert: AlertModel) {
        delegate?.editAlert(with: editableAlert)
        self.alerts = AlertCacher.shared.alerts
        
        for (index, alert) in self.alerts.enumerated() {
            if alert.id == editableAlert.id {
                self.alerts[index] = editableAlert
                
            }
        }
        AlertCacher.shared.alerts = self.alerts
        delegate?.setAlerts(alerts: self.alerts)
        self.configArrays(alerts: self.alerts)
        coinAlertTableView.reloadData()
    }
    
}

// MARK: - Helper

class AlertCacher {
    static let shared = AlertCacher()
    var alerts = [AlertModel]()
}
