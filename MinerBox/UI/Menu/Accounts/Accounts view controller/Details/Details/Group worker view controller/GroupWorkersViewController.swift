//
//  GroupWorkersViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/5/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class GroupWorkersViewController: BaseViewController {

    // MARK: - Views
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    @IBOutlet fileprivate weak var searchBar: BaseSearchBar!
    
    @IBOutlet weak var sortParentView: BarCustomView!
    @IBOutlet weak var sortLayerView: UIView!
    @IBOutlet weak var sortNameButton: BackgroundButton!
    @IBOutlet weak var sortUpDownButton: UIButton!
    
    @IBOutlet weak var workerSegmentHeadarView: BarCustomView!
    @IBOutlet weak var workerSegmentView: BaseSegmentControl!
    @IBOutlet weak var workerSegmentHeaderViewHeightConstraits: NSLayoutConstraint!
    
    private var searchBarButton = UIBarButtonItem()
    private var filterBarButtonItem = BagedBarButtonItem()

    // MARK: - Properties
    fileprivate var account: PoolAccountModel?
    fileprivate var workerGroups = [WorkerGroup]()

    fileprivate var groups = [ExpandableWorkerGroupType]()
    fileprivate var filteredGroups = [ExpandableWorkerGroupType]()
    
    fileprivate var searchText: String?
    fileprivate var isWorkerSegmentPresent = false
    fileprivate var sort = WorkerSort()
    
    fileprivate var filter: WorkerFilter? {
        willSet {
            filterBarButtonItem.setBageIsHidden(newValue == nil)
        }
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
        self.workerSegmentHeaderViewHeightConstraits.constant = 0

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        savePageState()
    }

    override func languageChanged() {
        title = "Groups / Workers".localized()
    }
}

//MARK: - Get Groups
extension GroupWorkersViewController {
    fileprivate func getGroups() {
        guard let account = self.account else { return }
        
        Loading.shared.startLoading(ignoringActions: true, for: self.view)
        PoolRequestService.shared.getAccountWorkersList(poolId: account.id, poolType: account.poolType, success: { (array) in
            self.setupWorkers(workers: array)
            Loading.shared.endLoading(for: self.view)
        }, failer: { (error) in
            Loading.shared.endLoading(for: self.view)
            self.showAlertView(nil, message: error.localized(), completion: nil)
        })
    }
}

// MARK: - Startup default actions
extension GroupWorkersViewController {
    fileprivate func startupSetup() {
        // Register table cell
        tableView.register(WorkerTableCell.self, forCellReuseIdentifier: WorkerTableCell.name)
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        searchBar.isHidden = true
        
        setupUI()
        getGroups()
        getPageState()
    }
    
    fileprivate func setupWorkers(workers: [PoolWorkerModel]) {
        sort.setAllCasses(workers: workers)
        for group in workerGroups {
            let filteredWorkers = workers.filter { $0.groupId == group.groupId }
            group.workers = filteredWorkers

            let newGroup = ExpandableWorkerGroupType(expanded: false, model: group)
            groups.append(newGroup)
        }
        filteredGroups = groups
        refrashSearchAndFilter()
    }
    
    fileprivate func setupWorkerSegmentedControl() {
        workerSegmentView.delegate = self
        let segmenData = WorkerFilter.allCases.map { $0.rawValue.localized() }
        workerSegmentView.setRoundedSpacingSegment(segmenData)
        workerSegmentHeaderViewHeightConstraits.constant = 0
    }

    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    override func keyboardFrameChanged(_ sender: Notification) {
        guard let userInfo = sender.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let bottomInset = view.frame.height - keyboardFrame.origin.y
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
    }
    
    //MARK: - Actions
    private func refrashSearchAndFilter() {
        if let _ = filter {
            filteringWorkers()
        } else if let _ = searchText {
            searchWorkers()
        } else {
            sortWorkers()
        }
    }
    
    @objc private func searchButtonAction(_ sender: UIBarButtonItem) {
        guard searchBar.isHidden else { return }
        
        UIView.animate(withDuration: Constants.animationDuration) {
            self.searchBar.isHidden = false
            self.searchBar.becomeFirstResponder()
            self.view.layoutIfNeeded()
            self.navigationItem.setRightBarButtonItems([self.filterBarButtonItem], animated: true)
        }
    }
    
    @objc private func filterBarButtonAction() {
        self.isWorkerSegmentPresent.toggle()
        
        if self.isWorkerSegmentPresent {
//            workerSegmentView.unselect()
            UIView.animate(withDuration: Constants.animationDuration) {
                self.workerSegmentHeaderViewHeightConstraits.constant = 40
                self.view.layoutIfNeeded()
            }
        } else {
//            self.resetFilterSegment()
            UIView.animate(withDuration: Constants.animationDuration) {
                self.workerSegmentHeaderViewHeightConstraits.constant =  0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func sortNameButtonAction() {
        self.showActionShit(self, type: .simple, items: sort.alertItems)
    }
    
    @objc private func sortUpDownButtonAction() {
        sort.isUp.toggle()
        setSortTitle()
        sortWorkers()
        savePageState()
    }
    
    fileprivate func setupSort() {
        sortParentView.removeLayer()
        sortLayerView.cornerRadius(radiusType: .half)
        sortLayerView.backgroundColor = .tableCellBackground
        sortNameButton.cornerRadius(radiusType: .half)
        sortNameButton.addTarget(self, action: #selector(sortNameButtonAction), for: .touchUpInside)
        sortUpDownButton.addTarget(self, action: #selector(sortUpDownButtonAction), for: .touchUpInside)
        setSortTitle()
    }
    
    fileprivate func setupFilter() {
        isWorkerSegmentPresent = filter != nil
        if let filter = filter {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.workerSegmentHeaderViewHeightConstraits.constant = 40
                self.view.layoutIfNeeded()
            }
            workerSegmentView.selectSegmentFirstTime(index: filter.index)
        }
    }
    
    fileprivate func setSortTitle() {
        let imageName = sort.isUp ? "arrow_up" : "arrow_down"
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        sortUpDownButton.setImage(image, for: .normal)
        sortUpDownButton.tintColor = darkMode ? .white : .black
        sortNameButton.setTitle(sort.type.localizedText, for: .normal)
    }
    
    private func resetFilterSegment() {
        self.workerSegmentView.unselect()
        self.filter = nil
        if searchText == nil {
            updateData()
        } else {
            searchWorkers()
        }
    }
    
    //MARK: - Filter
    private func filteringWorkers() {
        guard let filter = filter else { return }
        
        var filteredData = [ExpandableWorkerGroupType]()
        let oldGroups = groups.map { $0.model }
        DispatchQueue.global().async {
            for group in oldGroups {
                let newGroup = WorkerGroup(value: group)
                newGroup.workers.removeAll()
                
                for worker in group.workers {
                    if worker.isActive == (filter == .active) {
                        newGroup.workers.append(worker)
                        if let searchText = self.searchText {
                            newGroup.workers = newGroup.workers.filter {
                                $0.name?.lowercased().contains(searchText.lowercased()) ?? false ||
                                    $0.algorithm?.lowercased().contains(searchText.lowercased()) ?? false
                            }
                        }
                    }
                }
                
                if newGroup.workers.count != 0 {
                    filteredData.append(ExpandableWorkerGroupType(expanded: true, model: newGroup))
                }
            }
            
            self.filteredGroups = filteredData
            self.sortWorkers()
        }
    }
    
    fileprivate func sortWorkers() {
        DispatchQueue.global().async {
            self.filteredGroups.forEach({ group in
                group.model.workers = self.sort.getSortedWorkers(&group.model.workers)
            })
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //search helpers
    private func searchWorkers() {
        guard let searchText = searchText else { return }
        
        var filteredData = [ExpandableWorkerGroupType]()
        let oldGroups = groups.map { $0.model }
        
        DispatchQueue.global().async {
            for group in oldGroups {
                if group.groupName.lowercased().contains(searchText.lowercased()) {
                    filteredData.append(ExpandableWorkerGroupType(expanded: true, model: group))
                    continue
                }
                
                let newGroup = WorkerGroup(value: group)
                newGroup.workers.removeAll()
                
                for worker in group.workers {
                    if worker.name?.lowercased().contains(searchText.lowercased()) ?? false ||
                        worker.algorithm?.lowercased().contains(searchText.lowercased()) ?? false {
                        newGroup.workers.append(worker)
                        if let filter = self.filter {
                            newGroup.workers = newGroup.workers.filter { $0.isActive == (filter == .active) }
                        }
                    }
                }
                
                if newGroup.workers.count != 0 {
                    filteredData.append(ExpandableWorkerGroupType(expanded: true, model: newGroup))
                }
            }
            
            self.filteredGroups = filteredData
            self.sortWorkers()
        }
    }
    
    private func hideSearchBar() {
        searchBar.text = ""
        UIView.animate(withDuration: Constants.animationDuration) {
            self.searchBar.isHidden = true
            self.view.layoutIfNeeded()
        }
        view.endEditing(true)
        navigationItem.setRightBarButtonItems([searchBarButton, filterBarButtonItem], animated: true)
    }
    
    private func resetSearch() {
        searchText = nil
        if filter == nil {
            updateData()
        } else {
            filteringWorkers()
        }
    }
    
    private func updateData() {
        filteredGroups = groups
        tableView.reloadData()
    }
}

// MARK: - Setup UI
extension GroupWorkersViewController {
    fileprivate func setupUI() {
        configNavBar()
        setupWorkerSegmentedControl()
//        getPageState()
        if filter == nil {
            self.workerSegmentView?.unselect()
        }
    }

    fileprivate func configNavBar() {
        navigationController?.navigationBar.shadowImage = UIImage()
        searchBarButton = UIBarButtonItem.customButton(self, action: #selector(searchButtonAction(_:)), imageName: "bar_search")
        filterBarButtonItem = BagedBarButtonItem(target: self, action: #selector(filterBarButtonAction))
        navigationItem.setRightBarButtonItems([searchBarButton, filterBarButtonItem], animated: true)
    }
}

// MARK: - TableView methods
extension GroupWorkersViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredGroups.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0.0
        }
        return GroupWorkersTableHeader.height
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = GroupWorkersTableHeader(frame: .zero)

        // Setup header data
        headerView.tag = section
        headerView.sizeToFit()
        let item = filteredGroups[section]
        headerView.setGroupData(group: item.model, account: account!)

        // Add tap recognizer
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handeExpandClose(recognizer:)))
        headerView.addGestureRecognizer(tapRecognizer)
        headerView.rotateArrow(angle: item.isExpanded ? CGFloat(Double.pi) : 0)

        return headerView
    }

    // Header tap action
    @objc func handeExpandClose(recognizer: UITapGestureRecognizer) {
        guard let contentView = recognizer.view as? GroupWorkersTableHeader else { return }

        let section = contentView.tag
        guard filteredGroups[section].model.workers.count > 0 else { return }
        let indexPats = filteredGroups[section].model.workers.indices.map { IndexPath(row: $0, section: section) }

        let isExpanded = filteredGroups[section].isExpanded
        filteredGroups[section].isExpanded = !isExpanded

        if isExpanded {
            tableView.deleteRows(at: indexPats, with: .fade)
        } else {
            tableView.insertRows(at: indexPats, with: .fade)
        }

        contentView.rotateArrow(angle: !isExpanded ? CGFloat.pi : 0)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredGroups[section].isExpanded ? filteredGroups[section].model.workers.count : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WorkerTableCell.name) as! WorkerTableCell

        let worker = filteredGroups[indexPath.section].model.workers[indexPath.row]
        cell.setWorkerData(worker: worker, pool: self.account!)

        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}

extension GroupWorkersViewController: ActionSheetViewControllerDelegate, BaseSegmentControlDelegate {
    // MARK: - ActionSheetViewControllerDelegate
    func actionShitSelected(index: Int) {
        sort.config(index)
        setSortTitle()
        savePageState()
        sortWorkers()
    }

    //MARK: - Segment control delegate
    func segmentSelected(index: Int) {
        guard filter != WorkerFilter.allCases[index] else { resetFilterSegment(); return }
        
        filter = WorkerFilter.allCases[index]
        filteringWorkers()
    }
    
    func segmentSelectedFirstTime(index: Int) {
        filter = WorkerFilter.allCases[index]
        filteringWorkers()
    }
}

// MARK: - Search delegate
extension GroupWorkersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let searchText = searchText.trimmingCharacters(in: .whitespaces)

        guard searchText != "" else { resetSearch(); return }

        self.searchText = searchText
        searchWorkers()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
        resetSearch()
    }
}

// MARK: - Page state
extension GroupWorkersViewController {
    fileprivate func savePageState() {
        guard let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox"),
              let account = Cacher.shared.account else { return }

        userDefaults.set(sort.encode(), forKey: "\(account.keyPath)groupsWorkersSort")
        userDefaults.set(filter?.rawValue, forKey: "\(account.keyPath)groupsWorkersFilter")
    }

    fileprivate func getPageState() {
        guard let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox"),
              let account = Cacher.shared.account else { return }
        
        let data = userDefaults.object(forKey: "\(account.keyPath)groupsWorkersSort") as? Data
        sort = WorkerSort(data: data)
        if let filterRawValue = userDefaults.object(forKey: "\(account.keyPath)groupsWorkersFilter") as? String {
            filter = WorkerFilter(rawValue: filterRawValue)
        }
        
        setupFilter()
        setupSort()
    }
}

// MARK: - Expandable table helper class
class ExpandableWorkerGroupType: NSObject {
    public var isExpanded = false
    public var model = WorkerGroup(json: NSDictionary())

    init(expanded: Bool, model: WorkerGroup) {
        self.isExpanded = expanded
        self.model = model
    }
}

// MARK: - Set data
extension GroupWorkersViewController {
    public func setAccount(_ account: PoolAccountModel) {
        self.account = account
    }

    public func setGroups(_ groups: [WorkerGroup]) {
        self.workerGroups = groups
    }
}
