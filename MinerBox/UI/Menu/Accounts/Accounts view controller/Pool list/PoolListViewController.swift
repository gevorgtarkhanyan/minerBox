//
//  PoolListViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 5/30/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import FirebaseCrashlytics


class PoolListViewController: BaseViewController {

    @IBOutlet weak var searchBar: BaseSearchBar!
    @IBOutlet weak var poolsTableView: BaseTableView!
    @IBOutlet weak var requestNewPoolButton: BackgroundButton!
    @IBOutlet weak var newPoolRequestParentView: UIView!
    
    private var poolTypes = [ExpandablePoolType]()
    private var filteredPoolTypes = [ExpandablePoolType]()
    private var selectedPool: PoolTypeModel?
    private var selectedSubPool: SubPoolItem?
    private var cells: [UITableViewCell] = []
    private var currentUser: UserModel? {
        return DatabaseManager.shared.currentUser
    }
    
    public var currentAccountsCount = 0
    private var spaceBetwenHeaderAndFirstCell: CGFloat = 4
    private var lastSection: Int?
    private var sectionExpanded = true
    private var lastCell: PoolSectionTableViewCell?

    
    // MARK: - Static
    static func initializeStoryboard() -> PoolListViewController? {
        return UIStoryboard(name: "Menu", bundle: nil).instantiateViewController(withIdentifier: PoolListViewController.name) as? PoolListViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupTableView()
        setupNewPoolButton()
        getPools()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeUserDefaultValues()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if cells.count == 0 {
            cells = poolsTableView.visibleCells
        }
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        removeUserDefaultValues()
//    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeUserDefaultValues()
    }
   
    private func setupNavigation() {
        navigationController?.navigationBar.shadowImage = UIImage()
        title = "select_pool".localized()
        searchBar.addBarButtomSeparator()
        searchBar.showsCancelButton = false
    }
    
    private func setupTableView() {
        poolsTableView.register(UINib(nibName: "PoolListTableViewCell", bundle: nil), forCellReuseIdentifier: "poolCell")
        poolsTableView.register(UINib(nibName: "PoolSectionTableViewCell", bundle: nil), forCellReuseIdentifier: "poolSectionCell")
        poolsTableView.separatorColor = .clear
    }

    private func setupNewPoolButton() {
        //must be modified
//        newPoolRequestParentView.backgroundColor = darkMode ? .viewDarkBackground : .viewLightBackground
        newPoolRequestParentView.backgroundColor = .clear
        requestNewPoolButton.clipsToBounds = true
        requestNewPoolButton.layer.cornerRadius = 15
        requestNewPoolButton.changeFontSize(to: 17)
        requestNewPoolButton.setLocalizedTitle("request_new_pool")
        requestNewPoolButton.changeFont(to: Constants.semiboldFont)
    }
    
    private func removeUserDefaultValues() {
        UserDefaults.standard.removeObject(forKey: Constants.url_open_selectpool)
    }
    
    private func getPools() {
        if let types = DatabaseManager.shared.allEnabledPoolTypes {
            poolTypes = types.map { ExpandablePoolType(expanded: false, model: $0) }
//            poolTypes.sort { $0.model.poolName < $1.model.poolName }
            filteredPoolTypes = poolTypes
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let newVC = segue.destination as? AddPoolViewController, let pool = selectedPool else { return }
        newVC.setPoolInfo(poolId: pool.poolId, subPoolId: selectedSubPool?.id)
    }

    
    @IBAction func requestNewPool() {
        let sb = UIStoryboard(name: "Menu", bundle: nil)
        let newVC = sb.instantiateViewController(withIdentifier: "RequestPoolViewController") as! BaseViewController
        let controller = tabBarController ?? self
        controller.present(newVC, animated: true, completion: nil)
    }
    
    
    // MARK: -- Keyboard frame changed
    override func keyboardFrameChanged(_ sender: Notification) {
        guard let userInfo = sender.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let bottomInset = view.frame.height - keyboardFrame.origin.y
        poolsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: max(0, bottomInset), right: 0)
    }
    
    //MARK: -- Pool selected method
    private func poolSelected(pool: PoolTypeModel, indexPath: IndexPath) {
        if let user = currentUser {
            if user.maxAccountCount > currentAccountsCount {
                selectedPool = pool
                if indexPath.row != 0 {
                    selectedSubPool = pool.subPools[indexPath.row - 1]
                }
                performSegue(withIdentifier: "addAccountSegue", sender: self)
            } else {
                if user.isPremiumUser {
                    showToastAlert("", message: "maximum_count_reached!".localized())
                } else {
                    goToSubscriptionPage()
                }
            }
        } else {
            goToLoginPage()
        }
    }
    
    public func setCurrentAccountCount(_ count: Int) {
        self.currentAccountsCount = count
    }
    
    //MARK: -- Expandable part of code
    func expandSection(for indexPath: IndexPath) {
        if indexPath.row == 0 {
            var existExpandableData = false
            let data = filteredPoolTypes[indexPath.section]
            
            let indexPaths = data.model.subPools.indices.map { IndexPath(row: $0 + 1, section: indexPath.section) }
            let isExpanded = data.isExpanded
            data.isExpanded = !isExpanded
            
            if lastCell == nil {
                lastCell = poolsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PoolSectionTableViewCell
            }
            
            // Because first section not expanded automatically this code no needed
            /*if lastSection == nil {
                if indexPath.section != 0 {
                    existExpandableData = true
                    sectionExpanded = !isExpanded
                    lastSection = 0
                }
            }*/
            
            if let lastSection = lastSection {
                if lastSection != indexPath.section {
                    let restData = filteredPoolTypes[lastSection]
                    let restIndexPaths = restData.model.subPools.indices.map { IndexPath(row: $0 + 1, section: lastSection) }
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
            lastCell = poolsTableView.cellForRow(at: indexPath) as? PoolSectionTableViewCell
            lastSection = indexPath.section
            sectionExpanded = !isExpanded
            
            hideKeyboard()
        }
    }
    
    func sectionExpande(_ bool: Bool, for indexPaths: [IndexPath], close: Bool = false, closingPaths: [IndexPath] = [], indexPath: IndexPath) {
        poolsTableView.beginUpdates()
        if close, closingPaths.count != 0 {
            poolsTableView.deleteRows(at: closingPaths, with: .fade)
        }
        if bool {
            poolsTableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            poolsTableView.insertRows(at: indexPaths, with: .fade)
        }
        poolsTableView.endUpdates()
        poolsTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        UIView.animate(withDuration: 0) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - TableView Delegate and DataSource methods
extension PoolListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredPoolTypes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPoolTypes[section].isExpanded ? filteredPoolTypes[section].model.subPools.count + 1 : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "poolSectionCell", for: indexPath) as? PoolSectionTableViewCell {
                let pool = filteredPoolTypes[indexPath.section].model
                cell.setupCell(pool: pool)
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "poolCell", for: indexPath) as? PoolListTableViewCell {
                let pool = filteredPoolTypes[indexPath.section].model
                let subPools = pool.subPools
                cell.setPoolData(pools: subPools, indexPath: indexPath)
                return cell
            }
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = filteredPoolTypes[indexPath.section]
        if let cell = tableView.cellForRow(at: indexPath) as? PoolSectionTableViewCell {
            if data.model.subPools.count == 0 {
                let pool = filteredPoolTypes[indexPath.section].model
                hideKeyboard()
                poolSelected(pool: pool, indexPath: indexPath)
            } else {
                expandSection(for: indexPath)
                cell.animateArrow(expanded: sectionExpanded)
            }
        } else {
            let pool = filteredPoolTypes[indexPath.section].model
            hideKeyboard()
            poolSelected(pool: pool, indexPath: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return PoolSectionTableViewCell.height
        } else {
            return PoolListTableViewCell.height
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4
    }

}

// MARK: - Search delegate
extension PoolListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let searchText = searchText.trimmingCharacters(in: .whitespaces)
        
        guard searchText != "" else {
            filteredPoolTypes = poolTypes
            DispatchQueue.main.async {
                self.poolsTableView.reloadData()
            }
            return
        }
        
        var filteredData = [ExpandablePoolType]()
        let pools = poolTypes.map { $0.model }
        let text = searchText.lowercased()

        for pool in pools {
            if pool.poolName.lowercased().contains(text) || pool.keywords.lowercased().contains(text) {
                filteredData.append(ExpandablePoolType(expanded: true, model: pool))
                continue
            }

            let newPool = PoolTypeModel(value: pool)
            let filteredSubpools = newPool.subPools.filter { $0.name.lowercased().contains(text) || $0.keywords.lowercased().contains(text) }
            newPool.subItems.removeAll()

            for subPool in filteredSubpools {
                newPool.addSubPools(SubPoolItem(value: subPool))
            }

            if newPool.subPools.count != 0 {
                filteredData.append(ExpandablePoolType(expanded: true, model: newPool))
            }
        }
        lastSection = nil
        filteredPoolTypes = filteredData

        DispatchQueue.main.async {
            self.poolsTableView.reloadData()
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredPoolTypes = poolTypes

        DispatchQueue.main.async {
            self.poolsTableView.reloadData()
        }
        hideKeyboard()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        hideKeyboard()
    }
}

// MARK: - Expandable table helper class
class ExpandablePoolType: NSObject {
    public var isExpanded = false
    public var model = PoolTypeModel(json: NSDictionary())

    init(expanded: Bool, model: PoolTypeModel) {
        self.isExpanded = expanded
        self.model = model
    }
}
