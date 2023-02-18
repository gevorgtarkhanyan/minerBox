//
//  AccountAlertsViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/3/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class AccountAlertsViewController: BaseViewController {
    
    // MARK: - Views
    @IBOutlet fileprivate weak var segmentControl: BaseSegmentControl!
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    
    // MARK: - Properties
    fileprivate var account: PoolAccountModel!
    
    fileprivate var selectedItem: PoolAlertModel?
    
    fileprivate let alertButton = ActionSheetButton()
    fileprivate var alertType: AccountAlertType = .hashrate
    fileprivate var hashrateTypes: AddAccountHashrateTypes = .reported
    private var lastSection: Int?
    private var sectionExpanded = true
    private var lastCell: AccountAlertSectionTableViewCell?
    private var currentCell: AccountAlertSectionTableViewCell?
    
    fileprivate var workersList = [PoolAlertModel]()
    fileprivate var hashrateList = [PoolAlertModel]()
    fileprivate var reportedHashrateList = [PoolAlertModel]()
    fileprivate var workersArray = [PoolAlertModel]()
    fileprivate var hashrateArray = [PoolAlertModel]()
    fileprivate var reportedHashrateArray = [PoolAlertModel]()
    fileprivate var doubleArray = [ExpandableAccountAlerts]() {
        didSet {
            if doubleArray.count == 0 && selectedAlertCategory == .manual {
                noDataButton?.isHidden = false
            } else {
                noDataButton?.isHidden = true
            }
        }
    }
    
    fileprivate var usePayout: Bool {
        guard let pool = DatabaseManager.shared.getPool(id: account.poolType) else { return false }
        return pool.extPayouts
    }
    
    fileprivate var useReportedHashrate: Bool {
        guard let pool = DatabaseManager.shared.getPool(id: account.poolType) else { return false }
        
        if pool.subItems.count > 0 && pool.subItems[account.poolSubItem].extRepHash != -1  {
            return true
        } else {
            return pool.extRepHash
        }
        
    }
    fileprivate var payoutAlert: PoolAlertModel?
    
    fileprivate var alertCategories = AlertCategoryEnum.allCases
    fileprivate var selectedAlertCategory: AlertCategoryEnum = .manual
    fileprivate var currentValue: (hashrate: Double, worker: Int, reportedHashrate: Double) = (hashrate: 0, worker: 0, reportedHashrate : 0)
    
    // MARK: - Static
    static func initializeStoryboard() -> AccountAlertsViewController? {
        return UIStoryboard(name: "AccountDetails", bundle: nil).instantiateViewController(withIdentifier: AccountAlertsViewController.name) as? AccountAlertsViewController
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let newVC = segue.destination as? AccountAddAlertViewController else { return }
        var currentValue:Double = 0.0
        var currentValue2:Double = 0.0
        switch alertType {
        case .hashrate:
            currentValue = self.currentValue.hashrate
            currentValue2 = self.currentValue.reportedHashrate
        case .worker:
            currentValue = Double(self.currentValue.worker)
        case .reportedHashrate:
            currentValue = self.currentValue.reportedHashrate
            currentValue2 = self.currentValue.reportedHashrate
        }
        newVC.setData(account: account, alertType: alertType, currentAlert: selectedItem, currentValue: currentValue, currentValue2: currentValue2)
        selectedItem = nil
    }
    
    override func subscriptionStatusChanged() {
        getAlerts()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        tableView.setEditing(false, animated: false)
        tableView.reloadData()
    }
    override func configNoDataButton() {
        super.configNoDataButton()
        noDataButton!.setTransferButton(text: "add_pool_account_alerts", subText: "", view: self.view)
        noDataButton!.addTarget(self, action: #selector(addAlertButtonAction), for: .touchUpInside)
    }
}

// MARK: - Startup default setup
extension AccountAlertsViewController {
    fileprivate func startupSetup() {
        configSegmentControl()
        
        getAlerts()
        addObservers()
        
        // Register table cell
        self.tableView.register(UINib(nibName: AlertTableViewCell.name, bundle: nil), forCellReuseIdentifier: AlertTableViewCell.name)
        self.tableView.register(UINib(nibName: AccountAlertSectionTableViewCell.name, bundle: nil), forCellReuseIdentifier: AccountAlertSectionTableViewCell.name)
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(alertAdded(_:)), name: Notification.Name(Constants.accountAlertAdded), object: nil)
    }
    
    fileprivate func configSegmentControl() {
        segmentControl.delegate = self
        let titles = alertCategories.map { $0.rawValue }
        segmentControl.setSegments(titles)
        segmentSelected(index: 0)
    }
    
    fileprivate func getAlerts() {
        Loading.shared.startLoading(ignoringActions: true, for: self.view)
        PoolRequestService.shared.getPoolAccountAlerts(poolType: account.poolType, poolId: account.id, success: { (alerts) in
            self.hashrateArray = alerts.filter { $0.alertType == 0 }
            self.workersArray = alerts.filter { $0.alertType == 1 }
            self.reportedHashrateArray = alerts.filter { $0.alertType == 3 }
            let payout = alerts.filter { $0.alertType == 2 }
            if let payoutAlert = payout.first {
                self.payoutAlert = payoutAlert
            }
            Loading.shared.endLoading(for: self.view)
            self.updateTable()
        }) { (error) in
            Loading.shared.endLoading(for: self.view)
            
#if DEBUG
            self.showAlertView("ERROR FOUND!!!", message: error, completion: nil)
#endif
        }
    }
}

// MARK: - Set data
extension AccountAlertsViewController {
    public func setAccount(_ account: PoolAccountModel) {
        self.account = account
    }
    
    public func setCurrentValues(hashrate: Double, workersCount: Int, reportedHashrate: Double) {
        self.currentValue = (hashrate: hashrate, worker: workersCount, reportedHashrate : reportedHashrate)
    }
}

// MARK: - SegmentControl delegate
extension AccountAlertsViewController: BaseSegmentControlDelegate {
    func segmentSelected(index: Int) {
        selectedAlertCategory = alertCategories[index]
        updateTable()
    }
}

// MARK: - Actions
extension AccountAlertsViewController {
    @objc fileprivate func alertAdded(_ sender: Notification) {
        getAlerts()
    }
    
    fileprivate func updateTable() {
        let hash = doubleArray.filter { $0.type == .hashrate }
        let work = doubleArray.filter { $0.type == .worker }
        let repHash = doubleArray.filter { $0.type == .reportedHashrate }
        let hashIsExpanded = hash.count > 0 ? hash[0].isExpanded : false
        let workIsExpanded = work.count > 0 ? work[0].isExpanded : false
        let repHashIsExpanded = repHash.count > 0 ? repHash[0].isExpanded : false
        
        workersList = workersArray.filter { $0.isAuto == (selectedAlertCategory == .automat) }
        hashrateList = hashrateArray.filter { $0.isAuto == (selectedAlertCategory == .automat) }
        reportedHashrateList = reportedHashrateArray.filter { $0.isAuto == (selectedAlertCategory == .automat) }
        
        let workItem = ExpandableAccountAlerts(isExpanded: workIsExpanded, type: .worker, model: workersList)
        let hashItem = ExpandableAccountAlerts(isExpanded: hashIsExpanded, type: .hashrate, model: hashrateList)
        let repHashItem = ExpandableAccountAlerts(isExpanded: repHashIsExpanded, type: .reportedHashrate, model: reportedHashrateList)
        
        doubleArray.removeAll()
        if hashItem.model.count > 0 {
            doubleArray.append(hashItem)
        }
        if workItem.model.count > 0 {
            doubleArray.append(workItem)
        }
        if repHashItem.model.count > 0 {
            doubleArray.append(repHashItem)
        }
        
        tableView.reloadData()
    }
    
    // MARK: - UI actions
    @objc public func addAlertButtonAction(_ sender: UIBarButtonItem) {
        alertButton.delegate = self
        alertButton.reportedHashrate(Bool: useReportedHashrate)
        alertButton.setData(controller: tabBarController ?? self, type: .alert)
        alertButton.selectButton()
    }
    
    @objc fileprivate func editAlertAction(indexPath: IndexPath) {
        let item = doubleArray[indexPath.section].model[indexPath.row - 1]
        
        self.selectedItem = item
        if item.alertType == 0 {
            self.alertType = .hashrate
        } else if item.alertType == 1 {
            self.alertType = .worker
        } else if item.alertType == 3 {
            self.alertType = .reportedHashrate
        }
        self.performSegue(withIdentifier: "addAlertSegue", sender: self)
    }
    
    //    MARK: -- Expandable part
    
    func expandSection(for indexPath: IndexPath) {
        if indexPath.row == 0 {
            var existExpandableData = false
            let data = doubleArray[indexPath.section]
            let indexPaths = data.model.indices.map { IndexPath(row: $0 + 1, section: indexPath.section) }
            let isExpanded = data.isExpanded
            data.isExpanded = !isExpanded
            
            if let lastSection = lastSection {
                if lastSection != indexPath.section {
                    let restData = doubleArray.filter {$0.model != data.model
                    }
                    for currentData in restData {
                        let restIndexPaths = currentData.model.indices.map { IndexPath(row: $0 + 1, section: lastSection) }
                        if currentData.isExpanded {
                            existExpandableData = true
                            let expanded = currentData.isExpanded
                            currentData.isExpanded = !expanded
                            if lastCell != nil {
                                lastCell!.setInitialValuesArrow(show: !sectionExpanded)
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
            
            lastCell = tableView.cellForRow(at: indexPath) as?
            AccountAlertSectionTableViewCell
            currentCell = lastCell
            lastSection = indexPath.section
            sectionExpanded = !isExpanded
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
        }
    }
    
    @objc fileprivate func deleteAlertAction(indexPath: IndexPath) {
        let item = doubleArray[indexPath.section].model[indexPath.row - 1 ]
        
        
        Loading.shared.startLoading(ignoringActions: true, for: self.view)
        PoolRequestService.shared.deleteAccountAllert(poolId: item.id, poolType: account.poolType, success: { (string) in
            self.showToastAlert("", message: string.localized())
            self.deleteAlert(at: indexPath)
            Loading.shared.endLoading(for: self.view)
        }, failer: { (error) in
            Loading.shared.endLoading(for: self.view)
            self.showAlertView("", message: error, completion: nil)
        })
    }
    
    func hideSectionVisibleCells() {
        let cells = tableView.visibleCells
        var alertCells: [AccountAlertSectionTableViewCell] = []
        
        for cell in cells {
            if let alertCell = cell as? AccountAlertSectionTableViewCell {
                alertCells.append(alertCell)
            }
        }
        
        for cell in alertCells {
            UIView.animate(withDuration: 0.2) {
                cell.alpha = 0
            }
        }
    }
    
    fileprivate func deleteAlert(at indexPath: IndexPath) {
        self.doubleArray[indexPath.section].model.remove(at: indexPath.row - 1 )
        
        switch self.doubleArray[indexPath.section].type {
        case .hashrate:
            self.hashrateArray.removeAll { $0.id == self.hashrateList[indexPath.row - 1].id }
            self.hashrateList.remove(at: indexPath.row - 1)
        case .worker:
            self.workersArray.removeAll { $0.id == self.workersList[indexPath.row - 1].id }
            self.workersList.remove(at: indexPath.row - 1)
        case .reportedHashrate:
            self.reportedHashrateArray.removeAll { $0.id == self.reportedHashrateList[indexPath.row - 1].id }
            self.reportedHashrateList.remove(at: indexPath.row - 1)
        }
        
        tableView.deleteRows(at: [indexPath], with: .fade)
        if self.doubleArray[indexPath.section].model.count == 0 {
            self.doubleArray.remove(at: indexPath.section)
            tableView.deleteSections([indexPath.section], with: .fade)
            for i in self.doubleArray.indices {
                tableView.reloadSections([i], with: .fade)
            }
        } else {
            tableView.reloadSections([indexPath.section], with: .fade)
        }
    }
    
    func deleteAlerts(for indexPath: IndexPath) {
        
        let item = doubleArray[indexPath.section]
        Loading.shared.startLoading(ignoringActions: true, for: view)
        print("\(account.poolType) Pool Type")
        PoolRequestService.shared.deleteByAlertType(poolType: account.poolType, poolId: account.id, alertType: item.type.getRawValue() , success: { (string) -> Void in
            self.showToastAlert("", message: string.localized())
            
            //            self.delegate?.deleteAlerts(with: alertType)
            self.doubleArray.remove(at: indexPath.section)
            self.tableView.beginUpdates()
            self.tableView.deleteSections([indexPath.section], with: .fade)
            self.tableView.endUpdates()
            if let cell = self.lastCell {
                cell.setInitialValuesArrow(show: false)
            }
            
            Loading.shared.endLoading(for: self.view)
        }, failer: { (error) in
            Loading.shared.endLoading(for: self.view)
            self.showToastAlert("", message: error)
        })
    }
    
}

// MARK: - TableView methods
extension AccountAlertsViewController: UITableViewDataSource, UITableViewDelegate {
    
    // Cell
    func numberOfSections(in tableView: UITableView) -> Int {
        return selectedAlertCategory == .automat ? 1 : doubleArray.count
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard selectedAlertCategory != .automat else {
            if usePayout && useReportedHashrate  {
                return 4
            } else if usePayout || useReportedHashrate {
                return 3
            } else {
                return 2
            }
        }
        return doubleArray[section].isExpanded ? doubleArray[section].model.count + 1 : 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:CGFloat = 0
        
        if indexPath.row == 0 {
            height = AccountAlertSectionTableViewCell.height
        } else {
            height = AlertTableViewCell.height
        }
        
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch selectedAlertCategory {
        case .automat:
            let cell = tableView.dequeueReusableCell(withIdentifier: AutoAlertsTableViewCell.name) as! AutoAlertsTableViewCell
            cell.delegate = self
            switch indexPath.row {
            case 0:
                let hashIsOn = hashrateList.first?.isEnabled ?? false
                cell.setData(name: "hashrate_change_state", indexPath: indexPath, switchIsOn: hashIsOn, last: false)
            case 1:
                if useReportedHashrate {
                let reportedIsOn = reportedHashrateList.first?.isEnabled ?? false
                cell.setData(name: "reportedHashrate_change_state", indexPath: indexPath, switchIsOn: reportedIsOn, last: false)
                } else {
                let workIsOn = workersList.first?.isEnabled ?? false
                cell.setData(name: "active_workers_change", indexPath: indexPath, switchIsOn: workIsOn, last: usePayout ? false : true)
                }
            case 2:
                if useReportedHashrate {
                let workIsOn = workersList.first?.isEnabled ?? false
                cell.setData(name: "active_workers_change", indexPath: indexPath, switchIsOn: workIsOn, last: usePayout ? false : true)
                } else {
                let payoutIsOn = payoutAlert?.isEnabled ?? false
                cell.setData(name: "payout_detection", indexPath: indexPath, switchIsOn: payoutIsOn, last: true)
                }
                
            case 3 :
                let payoutIsOn = payoutAlert?.isEnabled ?? false
                cell.setData(name: "payout_detection", indexPath: indexPath, switchIsOn: payoutIsOn, last: true)
            default:
                cell.setData(name: "", indexPath: indexPath, switchIsOn: false, last: true)
            }
            
            return cell
        case .manual:
            if indexPath.row == 0 {
                
                if  let cell = tableView.dequeueReusableCell(withIdentifier: AccountAlertSectionTableViewCell.name) as? AccountAlertSectionTableViewCell {
                    let enabledWorkersAlerts = self.workersList.filter { $0.isEnabled }
                    let enabledHashrateAlerts = self.hashrateList.filter { $0.isEnabled }
                    let enableReportedHashrateAlerts = self.reportedHashrateList.filter { $0.isEnabled }
                    switch doubleArray[indexPath.section].type{
                    case .hashrate:
                        let allAlertsCount = hashrateList.count
                        let enabledAlertsCount = enabledHashrateAlerts.count
                        cell.setData(alertType: doubleArray[indexPath.section].type, value: currentValue.hashrate, enabledAlertsCount: enabledAlertsCount, allAlertsCount: allAlertsCount,account: account)
                    case .worker:
                        let allAlertsCount = workersList.count
                        let enabledAlertsCount = enabledWorkersAlerts.count
                        cell.setData(alertType: doubleArray[indexPath.section].type, value: Double(currentValue.worker), enabledAlertsCount: enabledAlertsCount, allAlertsCount: allAlertsCount,account: account)
                    case .reportedHashrate:
                        let allAlertsCount = reportedHashrateList.count
                        let enabledAlertsCount = enableReportedHashrateAlerts.count
                        cell.setData(alertType: doubleArray[indexPath.section].type, value: currentValue.reportedHashrate, enabledAlertsCount: enabledAlertsCount, allAlertsCount: allAlertsCount,account: account)
                    }
                    
                    return cell
                    
                }
            } else {
                if  let cell = tableView.dequeueReusableCell(withIdentifier: AlertTableViewCell.name) as? AlertTableViewCell {
                    
                    let section = doubleArray[indexPath.section]
                    let alert = doubleArray[indexPath.section].model[indexPath.row - 1]
                    let allAlerts = doubleArray[indexPath.section].model
                    let comparision: AlertComparisionType = alert.comparison ? .lessThan : .greatherThan
                    
                    if indexPath.row == allAlerts.count {
                    cell.setAccountAlertData(alertType: section.type, comparision: comparision, value: alert.value, isRepeat: alert.isRepeat, isEnabled: alert.isEnabled,account: account, last: true)
                    } else {
                        cell.setAccountAlertData(alertType: section.type, comparision: comparision, value: alert.value, isRepeat: alert.isRepeat, isEnabled: alert.isEnabled,account: account)
                    }
                    
                    return cell
                }
            }
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? AccountAlertSectionTableViewCell {
            expandSection(for: indexPath)
            currentCell = cell
            cell.shows = sectionExpanded
            cell.animateArrow(expanded: sectionExpanded)
            cell.controlRoundCornersAccount(expanded: sectionExpanded)
            cell.showAccountSwipeView(false)
        }
    }
    
    
    
    // Footer
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    // Cell swipe method for less than iOS 11
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if let cell = tableView.cellForRow(at: indexPath) as? AccountAlertSectionTableViewCell {
            currentCell = cell
        }
        
        let remove = UITableViewRowAction(style: .normal, title: "delete".localized()) { (_, indexPath) in
            if indexPath.row == 0 {
                self.showAlertViewController(nil, message: "ask_for_delete", otherButtonTitles: ["ok"], cancelButtonTitle: "cancel") { (responce) in
                    if responce == "ok" {
                        self.deleteAlertAction(indexPath: indexPath)
                    }
                }
            } else {
                self.showAlertViewController(nil, message: "ask_for_delete", otherButtonTitles: ["ok"], cancelButtonTitle: "cancel") { (responce) in
                    if responce == "ok" {
                        self.deleteAlertAction(indexPath: indexPath)
                    }
                }
            }
        }
        
        let edit = UITableViewRowAction(style: .normal, title: "edit".localized()) { (_, indexPath) in
            self.editAlertAction(indexPath: indexPath)
        }
        
        edit.backgroundColor = .cellTrailingFirst
        remove.backgroundColor = .red
        if indexPath.row != 0 {
            return [edit, remove]
        } else {
            if let cell = tableView.cellForRow(at: indexPath) as? AccountAlertSectionTableViewCell {
                cell.showAccountSwipeView(true)
            }
            return [remove]
        }
        
        
        
    }
    
    // Cell swipe method for greather than iOS 11
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        switch selectedAlertCategory {
            
        case .automat:
            break
            
        case .manual :
            if let cell = tableView.cellForRow(at: indexPath) as? AccountAlertSectionTableViewCell {
                currentCell = cell
            }
            
            let edit = UIContextualAction(style: .normal, title: "") { (_, _, completion) in
                self.editAlertAction(indexPath: indexPath)
                completion(true)
            }
            
            let remove = UIContextualAction(style: .destructive, title: "") { (_, _, completion) in
                if indexPath.row == 0 {
                    self.showAlertViewController(nil, message: "ask_for_delete", otherButtonTitles: ["ok"], cancelButtonTitle: "cancel") { (responce) in
                        if responce == "ok" {
                            self.deleteAlerts(for: indexPath)
                            completion(true)
                        } else {
                            completion(false)
                        }
                    }
                } else {
                    self.showAlertViewController(nil, message: "ask_for_delete", otherButtonTitles: ["ok"], cancelButtonTitle: "cancel") { (responce) in
                        if responce == "ok" {
                            self.deleteAlerts(for: indexPath)
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
                if let cell = tableView.cellForRow(at: indexPath) as? AccountAlertSectionTableViewCell {
                    cell.showAccountSwipeView(true)
                }
            }
            swipeAction.performsFirstActionWithFullSwipe = true // This is the line which disables full swipe
            return swipeAction
        }
        return UISwipeActionsConfiguration()
    }
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if indexPath != nil {
            if let cell = tableView.cellForRow(at: indexPath!) as? AccountAlertSectionTableViewCell {
                cell.showAccountSwipeView(false)
            }
        }
    }
}


// MARK: - Add alert button delegate
extension AccountAlertsViewController: ActionSheetButtonDelegate {
    func hashrateTypesSelected(type: AddAccountHashrateTypes) {
    }
    
    func alertSelected(type: AccountAlertType) {
        alertType = type
        performSegue(withIdentifier: "addAlertSegue", sender: self)
    }
    
    func comparisionSelected(type: AlertComparisionType) { }
}

// MARK: - AutoAlert cell delegate
extension AccountAlertsViewController: AutoAlertsTableViewCellDelegate {
    func switchSelected(indexPath: IndexPath, isOn: Bool, response: @escaping (Bool) -> ()) {
        guard let user = self.user, (user.isSubscribted || user.isPromoUser) else {
            response(false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.goToSubscriptionPage()
            }
            return
        }
        
        var alertId = ""
        var AlertType = 0
        
        switch indexPath.row {
        case 0:
            alertType = .hashrate
            AlertType = alertType.getRawValue()
        case 1:
            alertType = useReportedHashrate ? .reportedHashrate : .worker
            AlertType = alertType.getRawValue()
        case 2:
            if useReportedHashrate {
            alertType = .worker
            AlertType = alertType.getRawValue()
            } else {
                guard let id = payoutAlert?.id else {
                    response(false)
                    return
                }
                alertId = id
                AlertType = 2
            }
        case 3:
            guard let id = payoutAlert?.id else {
                response(false)
                return
            }
            alertId = id
            AlertType = 2
        default:
            response(false)
        }
        
        switch alertType {
            
        case .hashrate:
            guard let id = hashrateList.first?.id else {
                response(false)
                return
            }
            alertId = id
        case .worker:
            guard let id = workersList.first?.id else {
                response(false)
                return
            }
            alertId = id
        case .reportedHashrate:
            let id = reportedHashrateList.first?.id
            alertId = id ?? "null"
        }
        
        
        Loading.shared.startLoading(ignoringActions: true, for: self.view)
        PoolRequestService.shared.updateAutomatPoolAlert(poolType: account.poolType, alertType: AlertType, alertId: alertId, isEnabled: isOn, success: {
            self.showToastAlert("", message: "alert_updated".localized())
            Loading.shared.endLoading(for: self.view)
            response(true)
        }) { (error) in
            self.showToastAlert("", message: error)
            Loading.shared.endLoading(for: self.view)
            response(false)
        }
    }
}

// MARK: - Section header delegate
extension AccountAlertsViewController: AccountAlertSectionTableViewCellDelegate {
    func sectionHeaderSelected(section: Int, show: Bool) {
        let indexPaths = doubleArray[section].model.indices.map { IndexPath(row: $0, section: section) }
        let isExpanded = doubleArray[section].isExpanded
        doubleArray[section].isExpanded = !isExpanded
        
        if isExpanded {
            tableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            tableView.insertRows(at: indexPaths, with: .fade)
        }
    }
}

// MARK: - Helpers
enum AlertCategoryEnum: String, CaseIterable {
    case automat = "alert_category_auto"
    case manual = "alert_category_manual"
}

class ExpandableAccountAlerts {
    var isExpanded: Bool = false
    var model = [PoolAlertModel]()
    var type: AccountAlertType = .hashrate
    
    init(isExpanded: Bool, type: AccountAlertType, model: [PoolAlertModel]) {
        self.type = type
        self.model = model
        self.isExpanded = isExpanded
    }
}
