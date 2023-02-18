//
//  WorkersViewController.swift
//  MinerBox
//
//  Created by Haykaz Melikyan on 8/13/18.
//  Copyright © 2018 WitPlex. All rights reserved.
//

import UIKit

class WorkersViewController: BaseViewController {

    // MARK: - Views
    @IBOutlet weak var searchBar: BaseSearchBar!
    @IBOutlet weak var tableView: BaseTableView!
    
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
    private var account: PoolAccountModel?
    private var workers = [PoolWorkerModel]()
    private var filtredWorkers = [PoolWorkerModel]()
    
    private var searchText: String?
    private var isWorkerSegmentPresent = false
    private var sort = WorkerSort()
    private var filter: WorkerFilter? {
        willSet {
            filterBarButtonItem.setBageIsHidden(newValue == nil)
        }
    }

    // MARK: - Lyfe cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigation()
        self.startupSetup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        savePageState()
    }

    override func languageChanged() {
        title = "workers".localized()
    }
}

// MARK: - Startup default actions
extension WorkersViewController {
    fileprivate func startupSetup() {
        setupWorkerSegmentedControl()
        getPageState()
        addRefreshControl()
        getWorkers()
        self.workerSegmentHeaderViewHeightConstraits.constant = 0
        if filter == nil {
            self.workerSegmentView.unselect()
        }
        // Register table cell
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        tableView.separatorColor = .clear
        tableView.register(WorkerTableCell.self, forCellReuseIdentifier: WorkerTableCell.name)
    }
    
    fileprivate func setupWorkerSegmentedControl() {
        workerSegmentView.delegate = self
        let segmenData = WorkerFilter.allCases.map { $0.rawValue.localized() }
        workerSegmentView.setRoundedSpacingSegment(segmenData)
        workerSegmentHeaderViewHeightConstraits.constant = 0
    }
    
    fileprivate func setupNavigation() {
        navigationController?.navigationBar.shadowImage = UIImage()
        searchBarButton = UIBarButtonItem.customButton(self, action: #selector(searchButtonAction(_:)), imageName: "bar_search")
        filterBarButtonItem = BagedBarButtonItem(target: self, action: #selector(filterBarButtonAction))
        navigationItem.setRightBarButtonItems([searchBarButton, filterBarButtonItem], animated: true)
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
    
    //MARK: - Get Workers
    @objc fileprivate func getWorkers(_ refreshControl: UIRefreshControl? = nil) {
        guard let account = self.account else { return }

        if refreshControl == nil {
            Loading.shared.startLoading(ignoringActions: true, for: self.view)
        }

        PoolRequestService.shared.getAccountWorkersList(poolId: account.id, poolType: account.poolType, success: { (array) in
            self.workers = array
            self.filtredWorkers = array
            self.sort.setAllCasses(workers: self.workers)
            DispatchQueue.main.async {
                self.refrashSearchAndFilter()
                Loading.shared.endLoading(for: self.view)
                refreshControl?.endRefreshing()
            }
        }, failer: { (error) in
            Loading.shared.endLoading(for: self.view)
            refreshControl?.endRefreshing()
            self.showAlertView(nil, message: error.localized(), completion: nil)
        })
    }
    
    //MARK: - Sort Actions
    @objc private func sortNameButtonAction() {
        self.showActionShit(self, type: .simple, items: sort.alertItems)
    }
    
    @objc private func sortUpDownButtonAction() {
        sort.isUp.toggle()
        setSortTitle()
        sortWorkers()
        savePageState()
    }

    fileprivate func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(getWorkers), for: .valueChanged)

        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.backgroundView = refreshControl
        }
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
    
    private func filteringWorkers() {
        guard let filter = filter else { return }

        if let searchText = searchText {
            filtredWorkers = workers.filter {
                $0.isActive == (filter == .active) &&
                    (($0.name?.lowercased().contains(searchText.lowercased()) ?? false) ||
                    ($0.algorithm?.lowercased().contains(searchText.lowercased()) ?? false))
            }
        } else {
            filtredWorkers = workers.filter { $0.isActive == (filter == .active) }
        }
        
        sortWorkers()
    }
    
    fileprivate func sortWorkers() {
        filtredWorkers = sort.getSortedWorkers(&filtredWorkers)
        tableView.reloadData()
    }
    
    //search helpers
    private func searchWorkers() {
        guard let searchText = searchText else { return }
        
        if let filter = filter {
            filtredWorkers = workers.filter {
                $0.isActive == (filter == .active) &&
                    (($0.name?.lowercased().contains(searchText.lowercased()) ?? false) ||
                    ($0.algorithm?.lowercased().contains(searchText.lowercased()) ?? false))
            }
        } else {
            filtredWorkers = workers.filter {
                ($0.name?.lowercased().contains(searchText.lowercased()) ?? false)
                    || ($0.algorithm?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
        
        sortWorkers()
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
    
    private func resetFilterSegment() {
        self.workerSegmentView.unselect()
        self.filter = nil
        if searchText == nil {
            updateData()
        } else {
            searchWorkers()
        }
    }
    
    private func updateData() {
        filtredWorkers = self.workers
        tableView.reloadData()
    }
}

// MARK: - TableView methods
extension WorkersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtredWorkers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WorkerTableCell.name) as! WorkerTableCell

        let worker = filtredWorkers[indexPath.row]
        cell.setWorkerData(worker: worker, pool: self.account!)

        return cell
    }
}

// MARK: - Page state
extension WorkersViewController {
    fileprivate func savePageState() {
        guard let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox"),
              let account = Cacher.shared.account else { return }

        userDefaults.set(sort.encode(), forKey: "\(account.keyPath)workersSort")
        userDefaults.set(filter?.rawValue, forKey: "\(account.keyPath)workersFilter")
    }

    fileprivate func getPageState() {
        guard let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox"),
              let account = Cacher.shared.account else { return }
        
        let data = userDefaults.object(forKey: "\(account.keyPath)workersSort") as? Data
        sort = WorkerSort(data: data)
        if let filterRawValue = userDefaults.object(forKey: "\(account.keyPath)workersFilter") as? String {
            filter = WorkerFilter(rawValue: filterRawValue)
        }
        
        setupFilter()
        setupSort()
        searchBar.isHidden = true
    }
}

// MARK: - Set data
extension WorkersViewController {
    public func setAccount(_ account: PoolAccountModel) {
        self.account = account
    }
}

extension WorkersViewController: ActionSheetViewControllerDelegate, BaseSegmentControlDelegate {
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

//MARK: - Search delegate
extension WorkersViewController: UISearchBarDelegate {
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

//MARK: -Helper
enum WorkerFilter: String, CaseIterable {
    case active
    case inactive
    
    var index: Int {
        return self == .active ? 0 : 1
    }
}

struct WorkerSort: Codable {
    var type: SortType = .name
    var isUp: Bool = true
    var allCases = [SortType]()
    
    enum SortType: String, Codable {
        case name
        case difficulty
        case luck
        case paid
        case balance
        case realHashrate
        case currentHashrate
        case reportedHashrate
        case averageHashrate
        case valedShares
        case invaldShares
        case roundShares
        case staleShares
        case expiredShares
        case efficiency
        
        var localizedText: String {
            switch self {
            case .name:
                return "worker_name".localized()
            case .difficulty:
                return "diff".localized() + " " + "diff".localized()
            case .luck:
                return "luck".localized() + " " + "luck".localized()
            case .paid:
                return "paid".localized() + " " + "paid".localized()
            case .balance:
                return "balance".localized() + " " + "balance".localized()
            case .realHashrate:
                return "real".localized() + " " + "hashrate".localized()
            case .currentHashrate:
                return "current_hashrate".localized()
            case .reportedHashrate:
                return "reported".localized() + " " + "hashrate".localized()
            case .averageHashrate:
                return "average".localized() + " " + "hashrate".localized()
            case .valedShares:
                return "valid".localized() + " " + "shares".localized()
            case .invaldShares:
                return "invalid".localized() + " " + "shares".localized()
            case .staleShares:
                return "stale".localized() + " " + "shares".localized()
            case .expiredShares:
                return "expired".localized() + " " + "shares".localized()
            case .roundShares:
                return "round".localized() + " " + "shares".localized()
            case .efficiency:
                return "efficiency".localized()
            }
        }
    }
    
    var alertItems: [String] {
        return allCases.map { $0.localizedText }
    }
 
    init() {}
    
    init(data: Data?) {
        let decoder = JSONDecoder()
        if let data = data,
           let sort = try? decoder.decode(WorkerSort.self, from: data) {
            self = sort
        } else {
            self.init()
        }
    }
    
    public func encode() -> Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }

    public mutating func config(_ index: Int) {
        type = allCases[index]
    }
    
    public mutating func setAllCasses(workers: [PoolWorkerModel]) {
        allCases.removeAll()
        if (workers.contains{ $0.name != nil }) {
            allCases.append(.name)
        }
        if (workers.contains{ $0.difficulty != nil }) {
            allCases.append(.difficulty)
        }
        if (workers.contains{ $0.luck != nil }) {
            allCases.append(.luck)
        }
        if (workers.contains{ $0.paid != nil }) {
            allCases.append(.paid)
        }
        if (workers.contains{ $0.balance != nil }) {
            allCases.append(.balance)
        }
        if (workers.contains{ $0.efficiencyStr != nil }) {
            allCases.append(.efficiency)
        }
        if (workers.contains{ $0.realHashrate != nil }) {
            allCases.append(.realHashrate)
        }
        if (workers.contains{ $0.currentHashrate != nil }) {
            allCases.append(.currentHashrate)
        }
        if (workers.contains{ $0.averageHashrate != nil }) {
            allCases.append(.averageHashrate)
        }
        if (workers.contains{ $0.reportedHashrate != nil }) {
            allCases.append(.reportedHashrate)
        }
        if (workers.contains{ $0.validShares != nil }) {
            allCases.append(.valedShares)
        }
        if (workers.contains{ $0.invalidShares != nil }) {
            allCases.append(.invaldShares)
        }
        if (workers.contains{ $0.roundShares != nil }) {
            allCases.append(.roundShares)
        }
        if (workers.contains{ $0.staleShares != nil }) {
            allCases.append(.staleShares)
        }
        if (workers.contains{ $0.expiredShares != nil }) {
            allCases.append(.expiredShares)
        }
    }
    
    public func getSortedWorkers(_ workers: inout [PoolWorkerModel]) -> [PoolWorkerModel] {
        switch type {
        case .name:
            workers.sort {
                guard let item1 = $0.name, let item2 = $1.name else { return false }
                return isUp ? item1 < item2 : item1 > item2
            }
        case .difficulty:
            workers.sort {
                guard let item1 = $0.luck?.toInt(), let item2 = $1.luck?.toInt() else { return false }
                return isUp ? item1 < item2 : item1 > item2
            }
        case .luck:
            workers.sort {
                guard let item1 = $0.luck?.toDouble(), let item2 = $1.luck?.toDouble() else { return false }
                return isUp ? item1 < item2 : item1 > item2
            }
        case .paid:
            workers.sort {
                guard let item1 = $0.paid?.toDouble(), let item2 = $1.paid?.toDouble() else { return false }
                return isUp ? item1 < item2 : item1 > item2
            }
        case .balance:
            workers.sort {
                guard let item1 = $0.balance?.toDouble(), let item2 = $1.balance?.toDouble() else { return false }
                return isUp ? item1 < item2 : item1 > item2
            }
        case .realHashrate:
            workers.sort {
                guard let item1 = $0.realHashrate?.toDouble(), let item2 = $1.realHashrate?.toDouble() else { return false }
                return isUp ? item1 < item2 : item1 > item2
            }
        case .currentHashrate:
            workers.sort {
                guard let item1 = $0.currentHashrate?.toDouble(), let item2 = $1.currentHashrate?.toDouble() else { return false }
                return isUp ? item1 < item2 : item1 > item2
            }
        case .reportedHashrate:
            workers.sort {
                guard let item1 = $0.reportedHashrate?.toDouble(), let item2 = $1.reportedHashrate?.toDouble() else { return false }
                return isUp ? item1 < item2 : item1 > item2
            }
        case .averageHashrate:
            workers.sort {
                guard let item1 = $0.averageHashrate?.toDouble(), let item2 = $1.averageHashrate?.toDouble() else { return false }
                return isUp ? item1 < item2 : item1 > item2
            }
        case .valedShares:
            workers.sort {
                guard let item1 = $0.validShares?.toDoubleForWorker(), let item2 = $1.validShares?.toDoubleForWorker() else { return false }
                return isUp ? item1 < item2 : item1 > item2
            }
        case .invaldShares:
            workers.sort {
                guard let item1 = $0.invalidShares?.toDoubleForWorker(), let item2 = $1.invalidShares?.toDoubleForWorker() else { return false }
                return isUp ? item1 < item2 : item1 > item2
            }
        case .roundShares:
            workers.sort {
                guard let item1 = $0.roundShares?.toDoubleForWorker(), let item2 = $1.roundShares?.toDoubleForWorker() else { return false }
                return isUp ? item1 < item2 : item1 > item2
            }
        case .staleShares:
            workers.sort {
                guard let item1 = $0.staleShares?.toDoubleForWorker(), let item2 = $1.staleShares?.toDoubleForWorker() else { return false }
                return isUp ? item1 < item2 : item1 > item2
            }
        case .expiredShares:
            workers.sort {
                guard let item1 = $0.expiredShares?.toDoubleForWorker(), let item2 = $1.expiredShares?.toDoubleForWorker() else { return false }
                return isUp ? item1 < item2 : item1 > item2
            }
        case .efficiency:
            workers.sort {
                guard let item1 = $0.efficiencyStr?.toDouble(), let item2 = $1.efficiencyStr?.toDouble() else { return false }
                return isUp ? item1 < item2 : item1 > item2
            }
        }
        return workers
    }
    
}
