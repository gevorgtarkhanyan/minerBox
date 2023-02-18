//
//  CoinFilterViewController.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 17.05.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

protocol CoinFilterViewControllerDelegate: AnyObject {
    func setFilterData(filters: [CoinFilterModel]?, enabled: Bool)
}

class CoinFilterViewController: BaseViewController {

    @IBOutlet weak var filterSwitch: BaseSwitch!
    @IBOutlet weak var filterLabel: BaseLabel!
    @IBOutlet weak var clearButton: BackgroundButton!
    @IBOutlet weak var clearParentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: CoinFilterViewControllerDelegate?

    private var saveButton = UIBarButtonItem()
    private var filterData = [CoinFilterModel]()
    private var filterTypes = [CoinFilterModel]()
    private var enabled = true {
        willSet {
            enableSetup(enabled: newValue)
        }
    }
    
    // MARK: - Static
    static func initializeStoryboard() -> CoinFilterViewController? {
        return UIStoryboard(name: "CoinPrice", bundle: nil).instantiateViewController(withIdentifier: CoinFilterViewController.name) as? CoinFilterViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sturtupSetup()
    }
    
    override func languageChanged() {
        title = "filter".localized()
        saveButton.title = "save".localized()
        clearButton.setTitle("clear".localized(), for: .normal)
    }

    //MARK: Setup
    private func sturtupSetup() {
        setup()
        tableViewSetup()
        getPageState()
    }
    
    private func setup() {
        saveButton = UIBarButtonItem(title: "save".localized(), style: .plain, target: self, action: #selector(saveButtonAction))
        saveButton.isEnabled = false
        filterLabel.text = "filter".localized()
        clearButton.tintColor = .barSelectedItem
        clearParentView.backgroundColor = .tableCellBackground
        navigationItem.setRightBarButton(saveButton, animated:  true)
    }
    
    private func tableViewSetup() {
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func enableSetup(enabled: Bool) {
        filterSwitch.isOn = enabled
        clearButton.isEnabled = enabled
        clearParentView.alpha = enabled ? 1 : 0.5
        tableView.reloadData()
    }
    
    //MARK: - UI Actions
    @objc func saveButtonAction() {
        
        //Check invalid value
        for filter in filterData {
            guard filter.from != nil && filter.to != nil else { continue }
            if filter.from! > filter.to! {
                for (index, filterType) in filterTypes.enumerated() {
                    if filterType.type == filter.type {
                        informInvalidCell(indexRow: index )
                    }
                }
                return
            }
        }
        
        let filters = filterData.isEmpty ? nil : filterData
        delegate?.setFilterData(filters: enabled ? filters : nil, enabled: enabled)
        savePageState()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func switchAction(_ sender: BaseSwitch) {
        enabled = sender.isOn
        checkSaveButtonEnabled()
    }
    
    @IBAction func clearButtonAction(_ sender: UIButton) {
        filterTypes = CoinSortEnum.getFilterCases().map { CoinFilterModel(type: $0, from: nil, to: nil) }
        filterData.removeAll()
        tableView.reloadData()
        saveButton.isEnabled = true
        
    }
    
    private func checkSaveButtonEnabled() {
        guard let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") else { return }
        var previewFilterData = [CoinFilterModel]()
        
        let userId = user?.id ?? ""
        if let savedFilters = userDefaults.array(forKey: "\(userId)coinPriceFilters") as? [[String: Any]] {
            previewFilterData = savedFilters.map { CoinFilterModel(filterDict: $0) }
        }
        let previewEnabled = userDefaults.bool(forKey: "\(userId)coinPriceFiltersEnabled")
        
        let filtersChanged = !(previewFilterData == filterData)
        let swithchChanged = previewEnabled != enabled
        saveButton.isEnabled = filtersChanged || swithchChanged
    }
    
    //MARK: Keyboard Notification
    override func keyboardWillShow(_ sender: Notification) {
        super.keyboardWillShow(sender)
        guard let info = sender.userInfo,
              let keyboardFrameValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardSize = keyboardFrame.size
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height - 40.0, right: 0.0)
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    override func keyboardWillHide(_ sender: Notification) {
        super.keyboardWillHide(sender)
        let contentInsets = UIEdgeInsets.zero
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
}

//MARK: - TableView DataSource
extension CoinFilterViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CoinFilterTableViewCell.name) as! CoinFilterTableViewCell
        cell.delegate = self
        cell.setup(data: filterTypes[indexPath.row], enabled: enabled)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CoinFilterTableViewCell.height
    }
    
    func informInvalidCell(indexRow: Int) {
        let cell = tableView.cellForRow(at: IndexPath(row: indexRow, section: 0)) as? CoinFilterTableViewCell
        cell?.showInvalidValue()
    }
    
}

//MARK: - Cell Delegate
extension CoinFilterViewController: CoinFilterTableViewCellDelegate {
    func setFilter(filter: CoinFilterModel) {
        if (filterData.contains { $0.type == filter.type }) {
            for (index, value) in filterData.enumerated() {
                guard value.type == filter.type else { continue }
                filterData.remove(at: index)
                filterData.insert(filter, at: index)
            }
        } else {
            filterData.append(filter)
        }
        checkSaveButtonEnabled()
    }
    
    func removeFilter(filter: CoinFilterModel) {
        filterData.removeAll { $0.type == filter.type }
        checkSaveButtonEnabled()
    }
}

//MARK: -- Page State
extension CoinFilterViewController {
    private func savePageState() {
        guard let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") else { return }
        
        let savedFilters = filterData.map { $0.toAny() }
        let userId = user?.id ?? ""
        userDefaults.set(savedFilters, forKey: "\(userId)coinPriceFilters")
        userDefaults.set(enabled, forKey: "\(userId)coinPriceFiltersEnabled")
    }
    
    private func getPageState() {
        guard let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") else { return }
        
        let userId = user?.id ?? ""
        if let savedFilters = userDefaults.array(forKey: "\(userId)coinPriceFilters") as? [[String: Any]] {
            filterData = savedFilters.map { CoinFilterModel(filterDict: $0) }
        }
        enabled = userDefaults.object(forKey: "\(userId)coinPriceFiltersEnabled") as? Bool ?? true
        
        filterTypes = CoinSortEnum.getFilterCases().map { CoinFilterModel(type: $0, from: nil, to: nil) }
        for data in filterData {
            for (index, filter) in filterTypes.enumerated() {
                guard data.type == filter.type else { continue }
                filterTypes.remove(at: index)
                filterTypes.insert(data, at: index)
            }
        }
        
        tableView.reloadData()
    }
}
