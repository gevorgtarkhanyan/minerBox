//
//  CoinPriceViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/25/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//ƒ

import UIKit

protocol CoinPriceViewControllerDelegate: AnyObject {
    func viewLoaded(controller: CoinPriceViewController)
    func searchBarCancelClicked()
    func showSearchBar(searchText: String)
    func ignoreUserActions(_ bool: Bool)
    func startLoading()
    func endLoading()
    func changeSegmentedControlState()
    func setFilterState(isHidden: Bool)
    func isFavoriteEnpty(isEmpty: Bool)
    func endEditing(_ bool: Bool)
}

class CoinPriceViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    @IBOutlet weak var scrollTopImageView: UIImageView!
    weak var delegate: CoinPriceViewControllerDelegate?
    
    private var coinSortView: CoinPriceSort!
    private var refreshControl: UIRefreshControl?
    private var adsViewForCoin = AdsView()
    private var isAdsCome = false
    var adsManager = AdsManager.shared
    
    var justFavorites = false
    private var isAnimatingIndicator = true
    private var coinsContentOfSetY: Float = 0.0
    private var favoritesContentOfSetY: Float = 0.0
    private var filteredCoins = [CoinModel]() {
        didSet {
            if filteredCoins.count == 0 && isShowNoDataLabelOrButton {
                
                guard !isSearchFavorite else {
                    showNoDataLabel()
                    self.delegate?.isFavoriteEnpty(isEmpty: false)
                    return
                }
                guard !justFavorites else {
                    self.delegate?.isFavoriteEnpty(isEmpty: true)
                    hideNoDataLabel()
                    return
                }
                showNoDataLabel()
                self.delegate?.isFavoriteEnpty(isEmpty: false)
            } else {
                self.delegate?.isFavoriteEnpty(isEmpty: false)
                hideNoDataLabel()
            }
        }
    }
    private var isShowNoDataLabelOrButton = false
    private var isSearchFavorite = false
    public  var favoriteCoins = [CoinModel]()
    private var coins = [CoinModel]()
    private var searchCoins: [CoinModel]?
    private var sort = CoinSortModel()
    private var favoriteSort = CoinSortModel()
    private var filters: [CoinFilterModel]?
    
    private var timer = Timer()
    private var refreshTimer = Timer()
    private var refreshTime = Constants.refreshTimeInterval
    private var previewSearchText: String = ""
    private var searchText: String?
    private var indexPathForVisibleRow: IndexPath?
    private var isPaginating = false
    private var filterBageIsHidden = true
    private var defaultCoinState = true
    private var coinsIsDownloaded = false
    
    private var skip: Int {
        filteredCoins.count
    }
    
    // MARK: - Static
    static func initializeStoryboard() -> CoinPriceViewController? {
        return UIStoryboard(name: "CoinPrice", bundle: nil).instantiateViewController(withIdentifier: CoinPriceViewController.name) as? CoinPriceViewController
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getSortState()
        if !coinsIsDownloaded {
            getFirstCoins(with: filterBageIsHidden ? nil : filters)
        }
        setupTableView()
        startupSetup()
        addObservers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.checkSubscription()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeRefreshAction()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        tableView.setEditing(false, animated: false)
        tableView.reloadData()
    }
    
    //MARK: -- Observers code part
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(hideAds), name: .hideAdsForSubscribeUsers, object: nil)
    }
    
}

// MARK: - Startup default setup
extension CoinPriceViewController {
    private func startupSetup() {
        addRefreshControl()
        setupScrollImageView()
        delegate?.viewLoaded(controller: self)
        adsViewForCoin.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupTableView() {
        tableView.register(CoinPriceTableViewCell.self, forCellReuseIdentifier: CoinPriceTableViewCell.name)
        tableView.register(AdsTableViewCell.self, forCellReuseIdentifier: AdsTableViewCell.name)
    }
    
    func setupScrollImageView() {
        let tapDesture = UITapGestureRecognizer(target: self, action: #selector(scrollTop))
        scrollTopImageView.isHidden = true
        scrollTopImageView.isUserInteractionEnabled = true
        scrollTopImageView.addGestureRecognizer(tapDesture)
        scrollTopImageView.layer.cornerRadius = scrollTopImageView.frame.size.height / 2
        scrollTopImageView.image = UIImage(named: "arrow_up")?.withRenderingMode(.alwaysTemplate)
        
        scrollTopImageView.tintColor = darkMode ? .white : .black
        scrollTopImageView.backgroundColor = darkMode ? UIColor.viewDarkBackgroundWithAlpha : UIColor.viewLightBackgroundWithAlpha
    }
    
    func setupCoins() {
        filteredCoins = justFavorites ? favoriteCoins : coins
        tableView.reloadData()
    }
    
    @objc private func scrollTop() {
        self.tableView.scroll(to: .top, animated: true)
    }
    
    //MARK: - Refresh control
    func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = .barSelectedItem
        refreshControl?.addTarget(self, action: #selector(getCoins), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.backgroundView = refreshControl
        }
    }
    
    @objc public func getCoins() {
        self.isShowNoDataLabelOrButton = false
        if justFavorites {
            refreshControl?.endRefreshing()
        } else {
            if refreshTime == Constants.refreshTimeInterval {
                refreshTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.refreshing), userInfo: nil, repeats: true)
                refreshTime = 0
                if let searchText = searchText {
                    getSearchCoins(with: searchText)
                } else {
                    self.delegate?.ignoreUserActions(false)
                    let filters = filterBageIsHidden ? nil : self.filters
                    CoinRequestService.shared.getCoinsList(skip: 0, sort: sort, filters: filters, favoriteCoins: favoriteCoins, success: { (coins, _, allCount) in
                        self.coins = coins
                        self.filteredCoins = coins
                        self.isPaginating = self.filteredCoins.count == allCount
                        self.refreshControl?.endRefreshing()
                        self.isShowNoDataLabelOrButton = true
                        self.delegate?.ignoreUserActions(true)
                    }) { (error) in
                        self.refreshControl?.endRefreshing()
                        self.delegate?.ignoreUserActions(true)
                        self.showAlertView("", message: error.localized(), completion: nil)
                    }
                }
            } else {
                refreshControl?.endRefreshing()
            }
        }
    }
    
    @objc private func refreshing() {
        refreshTime += 1
        if refreshTime == Constants.refreshTimeInterval {
            refreshTimer.invalidate()
        }
    }
    
    func removeRefreshAction() {
        tableView.reloadData()
        refreshControl?.endRefreshing()
        self.delegate?.ignoreUserActions(true)
    }
}

// MARK: - Set data
extension CoinPriceViewController {
    public func setFilterState(isHidden: Bool) {
        filterBageIsHidden = isHidden
        if let filters = filters, !filterBageIsHidden {
            if justFavorites {
                filterFavorites(with: filters)
            } else {
                resetTableView()
                getFirstCoins(with: filters)
            }
        } else if justFavorites {
            filteredCoins = favoriteCoins
            if let searchText = searchText {
                searchFavoriteCoins(with: searchText)
            } else {
                sortFavorites(with: favoriteSort)
            }
        } else {
            resetTableView()
            getFirstCoins()
        }
        saveSortState()
    }
    
    public func setSortView(_ view: CoinPriceSort) {
        coinSortView = view
    }
    
    public func changeSegmented(with favorite: Bool, at previewPage: CoinPricePageEnum) {
        justFavorites = favorite
        isShowNoDataLabelOrButton = favorite
        
        if !favorite {
            isSearchFavorite = false
            hideNoDataLabel()
        }
        
        configCoins(at: previewPage)
        if let searchText = searchText  {
            self.delegate?.showSearchBar(searchText: searchText)
        }
        if let indexPathForVisibleRow = indexPathForVisibleRow, !justFavorites {
            tableView.scrollToRowSafely(at: indexPathForVisibleRow, at: .top, animated: false)
        } else {
            tableView.scroll(to: .top, animated: false)
        }
    }
    
    public func setFavoriteCoin(with coin: CoinModel) {
        coin.isFavorite = true
        addFavorites(with: coin)
        
        //fix this
        DispatchQueue.main.async {
            self.configCoins(at: .alerts)
        }
    }
    
    public func removeFavoriteCoin(with coin: CoinModel) {
        
        self.favoriteCoins.removeAll { $0.coinId == coin.coinId }
        self.filteredCoins.removeAll { $0.coinId == coin.coinId }
        DispatchQueue.main.async {
            self.configCoins(at: .alerts)
        }
        let currentCoin = self.coins.first { $0.coinId == coin.coinId }
        currentCoin?.isFavorite = false
        
    }
}

// MARK: - TableView methods
extension CoinPriceViewController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isAdsCome && indexPath.row == 5  { return AdsTableViewCell.height }
        if isAdsCome && indexPath.row == filteredCoins.count && filteredCoins.count < 5 { return AdsTableViewCell.height }
        
        return CoinPriceTableViewCell.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isAdsCome && !filteredCoins.isEmpty ? filteredCoins.count + 1 : filteredCoins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !filteredCoins.isEmpty && filteredCoins.count < 5 && isAdsCome && indexPath.row == filteredCoins.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: AdsTableViewCell.name) as! AdsTableViewCell
            cell.setData(view: adsViewForCoin)
            return cell
        }
        
        if isAdsCome && indexPath.row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: AdsTableViewCell.name) as! AdsTableViewCell
            cell.setData(view: adsViewForCoin)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CoinPriceTableViewCell.name) as! CoinPriceTableViewCell
        let coin = isAdsCome && indexPath.row > 5 ? filteredCoins[indexPath.row - 1] : filteredCoins[indexPath.row]
        
        cell.setData(coin: coin, indexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isAdsCome && indexPath.row == 5 { return }
        if !filteredCoins.isEmpty && filteredCoins.count < 5 && isAdsCome && indexPath.row == filteredCoins.count { return }
        let coinID = isAdsCome && indexPath.row > 5 ? filteredCoins[indexPath.row - 1].coinId : filteredCoins[indexPath.row].coinId
        let index = isAdsCome && indexPath.row > 5 ? indexPath.row - 1 : indexPath.row
        let coin = filteredCoins[index]
        guard let chartVC = CoinChartViewController.initializeStoryboard() else { return }
        chartVC.setFavoriteCoins(self.favoriteCoins)
        chartVC.setCoinId(coinID)
        chartVC.setCoin(coin: coin)
        self.navigationController?.pushViewController(chartVC, animated: true)
    }
    
    //MARK: - Swipe
    // Cell swipe method for less than iOS 11
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if isAdsCome && indexPath.row == 5 { return [] }
        let index = isAdsCome && indexPath.row > 5 ? indexPath.row - 1 : indexPath.row
        
        let alert = UITableViewRowAction(style: .normal, title: "coin_price_alerts".localized()) { (action, indexpath) in
            self.coinAlertAction(index: index)
        }
        
        let favorite = UITableViewRowAction(style: .normal, title: "coin_price_favorites".localized()) { (action, indexpath) in
            self.coinFavoriteAction(index: index, indexPath: indexPath)
        }
        
        
        alert.backgroundColor = .cellTrailingSecond
        favorite.backgroundColor = .cellTrailingFirst
        
        return [alert, favorite]
    }
    
    // Cell swipe method for greather than iOS 11
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let adsIndex = filteredCoins.count < 5 ? filteredCoins.count : 5
        if isAdsCome && indexPath.row == adsIndex { return UISwipeActionsConfiguration(actions: []) }
        
        let index = isAdsCome && indexPath.row > 5 ? indexPath.row - 1 : indexPath.row
        let coin = filteredCoins[index]
        
        // Alert action
        let alert = UIContextualAction(style: .normal, title: "") { (action, view, completion) in
            self.coinAlertAction(index: index)
            completion(true)
        }
        
        // Favorite action
        let favorite = UIContextualAction(style: .normal, title: "") { (action, view, completion) in
            self.coinFavoriteAction(index: index, indexPath: indexPath)
            completion(true)
        }
        
        let converter = UIContextualAction(style: .normal, title: "") { (action, view, completion) in
            self.coinConverterAction(index: index)
            completion(true)
        }
        
        favorite.backgroundColor = .cellTrailingFirst
        favorite.image = coin.isFavorite ? UIImage(named: "cell_hearth_full") : UIImage(named: "cell_hearth_empty")
        
        alert.backgroundColor = .cellTrailingSecond
        alert.image = UIImage(named: "cell_ring")
        
        converter.backgroundColor = .cellTrailingThird
        converter.image = UIImage(named: "converter_icon")
        
        let swipeAction = UISwipeActionsConfiguration(actions: [favorite, alert, converter])
        swipeAction.performsFirstActionWithFullSwipe = false // This is the line which disables full swipe
        return swipeAction
    }
    
    // Footer
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    
    //MARK: - Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !justFavorites {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                guard let indexPathsForVisibleRows = self.tableView.indexPathsForVisibleRows, !indexPathsForVisibleRows.isEmpty else { return }
                self.indexPathForVisibleRow = indexPathsForVisibleRows.first
            }
        }
        
        let position = scrollView.contentOffset.y
        scrollTopImageView.isHidden = position < 100
        
        if position > tableView.contentSize.height - scrollView.frame.size.height * 0.85 {
            if !isPaginating && !justFavorites {
                tableView.tableFooterView = createIndicatorFooter()
                self.isPaginating = true
                let filters = filterBageIsHidden ? nil : self.filters
                CoinRequestService.shared.getCoinsList(skip: skip, searchText: searchText, sort: sort, filters: filters, favoriteCoins: favoriteCoins, success: { (coins, _, allCount)  in
                    if self.searchText == nil {
                        self.coins += coins
                        self.filteredCoins = self.coins
                    } else {
                        self.filteredCoins += coins
                    }
                    DispatchQueue.main.async {
                        self.tableView.tableFooterView = nil
                        self.tableView.reloadData()
                        self.delegate?.endLoading()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.isPaginating = self.filteredCoins.count == allCount
                    }
                    self.isShowNoDataLabelOrButton = true
                }) { (error) in
                    self.delegate?.ignoreUserActions(true)
                    self.showAlertView("", message: error.localized(), completion: nil)
                    self.tableView.tableFooterView = nil
                    self.isPaginating = false
                }
            }
        }
    }
    
    private func createIndicatorFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        Loading.shared.startLoadingForView(with: footerView)
        return footerView
    }
    
}

// MARK: - Actions
extension CoinPriceViewController {
    override func keyboardFrameChanged(_ sender: Notification) {
        guard let userInfo = sender.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let bottomInset = keyboardFrame.height - (tabBarController?.tabBar.frame.height ?? 0)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
    }
    
    private func searchFavoriteCoins(with searchText: String) {
        self.isShowNoDataLabelOrButton = true
        self.isSearchFavorite = true
        filteredCoins = favoriteCoins.filter { (coin) -> Bool in
            let rank = String(coin.rank)
            return coin.name.lowercased().contains(searchText.lowercased()) || coin.symbol.lowercased().contains(searchText.lowercased()) || rank.contains(searchText)
        }
        
        if let filters = filters {
            filterFavorites(with: filters)
        } else {
            sortFavorites(with: favoriteSort)
        }
    }
    
    // Cell trailing methods
    private func coinFavoriteAction(index: Int, indexPath: IndexPath) {
        guard let user = self.user else {
            goToLoginPage()
            return
        }
        let coin = filteredCoins[index]
        
        if coin.isFavorite {
            Loading.shared.startLoading(ignoringActions: true, for: tableView)
            delegate?.ignoreUserActions(false)
            CoinRequestService.shared.deleteFromFavorites(userId: user.id, coinId: coin.coinId, success: { (String) in
                self.showToastAlert("", message: String.localized())
                WidgetCointManager.shared.removeCoin(coin.coinId)
                coin.isFavorite = false
                let currentCoin = self.coins.first { $0.coinId == coin.coinId }
                currentCoin?.isFavorite = false
                if self.justFavorites {
                    self.filteredCoins.removeAll { $0.coinId == coin.coinId }
                    //                    let indexPath = IndexPath(index: index)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
                self.favoriteCoins.removeAll { $0.coinId == coin.coinId }
                self.delegate?.ignoreUserActions(true)
                Loading.shared.endLoading(for: self.tableView)
            }, failer: { (error) in
                Loading.shared.endLoading(for: self.tableView)
                self.delegate?.ignoreUserActions(true)
                self.showAlertView("", message: error, completion: nil)
            })
        } else {
            Loading.shared.startLoading(ignoringActions: true, for: tableView)
            delegate?.ignoreUserActions(false)
            CoinRequestService.shared.addToFavorites(userId: user.id, coinId: coin.coinId, success: { (CoinModel,String) in
                self.showToastAlert("", message: String.localized())
                coin.isFavorite = true
                self.favoriteCoins.append(coin)
                self.delegate?.ignoreUserActions(true)
                Loading.shared.endLoading(for: self.tableView)
            }) { (error) in
                self.delegate?.ignoreUserActions(true)
                Loading.shared.endLoading(for: self.tableView)
                self.showAlertView("", message: error, completion: nil)
            }
        }
    }
    
    private func coinAlertAction(index: Int) {
        guard let newVC = AddCoinAlertViewController.initializeStoryboard() else { return }
        
        let selectedCoin = filteredCoins[index]
        newVC.setCoinForAlert(selectedCoin)
        
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    
    private func coinConverterAction(index: Int) {
        let sb = UIStoryboard(name: "More", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ConverterViewController") as! ConverterViewController
        vc.headerCoinId = filteredCoins[index].coinId
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Coin Actions
    private func configCoins(at previewPage: CoinPricePageEnum) {
        if searchText != nil {
            self.isShowNoDataLabelOrButton = true
            if !justFavorites {
                if previewSearchText != searchText! {
                    indexPathForVisibleRow = nil
                    delegate?.startLoading()
                    getSearchCoins(with: searchText!)
                } else if let searchCoins = searchCoins, filterBageIsHidden {
                    filteredCoins = searchCoins
                } else {
                    delegate?.startLoading()
                    resetTableView()
                    getSearchCoins(with: searchText!)
                }
            } else {
                searchFavoriteCoins(with: searchText!)
            }
            previewSearchText = searchText!
        } else if filters != nil && !filterBageIsHidden {
            if justFavorites {
                resetTableView()
                filteredCoins = favoriteCoins
                filterFavorites(with: filters!)
                defaultCoinState = false
            } else if previewPage != .alerts {
                coinsIsDownloaded = true
                resetTableView()
                getFirstCoins(with: filters!)
            }
        } else {
            if justFavorites {
                filteredCoins = favoriteCoins
            } else if defaultCoinState {
                filteredCoins = coins
            } else {
                resetTableView()
                defaultCoinState = true
                getFirstCoins()
            }
        }
        
        changeSortView()
        if !filteredCoins.isEmpty {
            tableView.reloadData()
        }
    }
    
    private func addFavorites(with favoteCoin: CoinModel) {
        self.favoriteCoins.append(favoteCoin)
        
        coins.forEach { (currentCoin) in
            if currentCoin.coinId == favoteCoin.coinId {
                currentCoin.isFavorite = true
            }
        }
        
        filteredCoins.forEach { (currentCoin) in
            if currentCoin.coinId == favoteCoin.coinId {
                currentCoin.isFavorite = true
            }
        }
    }
    
    private func resetTableView() {
        isPaginating = true
        filteredCoins = []
        tableView.reloadData()
    }
    
    //MARK: - Get coins
    private func getSearchCoins(with searchText: String) {
        let filters = filterBageIsHidden ? nil : self.filters
        DispatchQueue.global().async {
            CoinRequestService.shared.getCoinsList(skip: 0, searchText: searchText, sort: self.sort, filters: filters, favoriteCoins: self.favoriteCoins) { (searchCoins, _, allCount) in
                self.delegate?.endLoading()
                if self.searchText != nil {
                    self.isShowNoDataLabelOrButton = true
                    self.filteredCoins = searchCoins
                    self.searchCoins = searchCoins
                    self.isPaginating = self.filteredCoins.count == allCount
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                    }
                }
            } failer: { (error) in
                self.delegate?.endLoading()
                self.refreshControl?.endRefreshing()
                if self.searchText != nil {
                    self.showAlertView("", message: error.localized(), completion: nil)
                }
            }
        }
    }
    
    private func getFirstCoins(with filters: [CoinFilterModel]? = nil) {
        self.isShowNoDataLabelOrButton = false
        delegate?.startLoading()
        DispatchQueue.global().async {
            CoinRequestService.shared.getCoinsList(skip: 0, searchText: self.searchText, sort: self.sort, filters: filters, success: { [weak self] (coins, favoriteCoins, allCount) in
                guard let self = self else { return }
                self.isShowNoDataLabelOrButton = true
                self.coins = coins
                self.filteredCoins = coins
                self.favoriteCoins = favoriteCoins
                self.isPaginating = self.filteredCoins.count == allCount
                DispatchQueue.main.async {
                    self.delegate?.changeSegmentedControlState()
                    self.tableView.reloadData()
                }
            }) { (error) in
                DispatchQueue.main.async {
                    self.showAlertView("", message: error.localized(), completion: nil)
                    self.delegate?.endLoading()
                }
            }
        }
    }
    
    private func resetCurrentCoins() {
        isPaginating = true
        filteredCoins.removeAll()
        tableView.reloadData()
    }
    
}

// MARK: - Search delegate
extension CoinPriceViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchText.trimmingCharacters(in: .whitespaces)
        
        self.isShowNoDataLabelOrButton = false
        guard searchText != "" else {
            if self.searchText != nil {
                self.isShowNoDataLabelOrButton = true
                self.isSearchFavorite = false
                delegate?.endLoading()
            }
            searchCancelAction()
            return
        }
        
        resetCurrentCoins()
        self.searchText = searchText
        if !justFavorites {
            timer.invalidate()
            delegate?.startLoading()
            timer = Timer.scheduledTimer(timeInterval: Constants.searchTimeInterval, target: self, selector: #selector(self.searching), userInfo: nil, repeats: true)
        } else {
            searchFavoriteCoins(with: searchText)
        }
    }
    
    @objc private func searching() {
        timer.invalidate()
        if let searchText = searchText, !justFavorites {
            getSearchCoins(with: searchText)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        delegate?.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        delegate?.searchBarCancelClicked()
        searchCancelAction()
    }
    
    //helpers method
    private func searchCancelAction() {
        searchText = nil
        searchCoins = nil
        isPaginating = false
        if justFavorites {
            filteredCoins = favoriteCoins
            if let filters = filters {
                filterFavorites(with: filters)
            } else {
                sortFavorites(with: favoriteSort)
            }
        } else {
            filteredCoins = coins
            tableView.reloadData()
        }
    }
}

// MARK: - Sort Coin
extension CoinPriceViewController: CoinPriceSortDelegate {
    // Coin sort delegate methods
    func sortIconTapped(_ sender: SortButton, type: CoinSortEnum, sortIconFirstTapped: Bool) {
        guard type != .rank else { return }
        
        if justFavorites {
            favoriteSort = CoinSortModel(type: type, lowToHigh: true)
        } else {
            sort = CoinSortModel(type: type, lowToHigh: true)
        }
        guard sortIconFirstTapped else { return }
        
        let controller = tabBarController ?? self
        let newVC = ActionSheetViewController()
        newVC.delegate = self
        newVC.modalPresentationStyle = .overCurrentContext
        
        switch type {
        case .coin:
            newVC.setData(controller: controller, type: .coinSort, point: sender.alertPoint)
        case .price:
            newVC.setData(controller: controller, type: .coinPriceSort, point: sender.alertPoint)
        case .change:
            newVC.setData(controller: controller, type: .coinChangeSort, point: sender.alertPoint)
        default:
            break
        }
        DispatchQueue.main.async {
            if controller.presentedViewController == nil {
                controller.present(newVC, animated: false, completion: nil)
            }
        }
    }
    
    func changeSort(with sort: CoinSortModel) {
        if justFavorites {
            self.favoriteSort = sort
            sortFavorites(with: sort)
        } else {
            self.sort = sort
            isPaginating = true
            resetCurrentCoins()
            sortAllCoins()
        }
        saveSortState()
    }
    
    // Coin sort methods
    private func sortAllCoins() {
        delegate?.startLoading()
        let filters = filterBageIsHidden ? nil : self.filters
        CoinRequestService.shared.getCoinsList(skip: 0, searchText: searchText, sort: sort, filters: filters, favoriteCoins: favoriteCoins, success: { (coins, _, allCount) in
            self.coins = coins
            self.filteredCoins = coins
            self.isPaginating = self.filteredCoins.count == allCount
            DispatchQueue.main.async {
                self.delegate?.endLoading()
                self.tableView.reloadDataScrollUp()
            }
        }) { (error) in
            self.delegate?.endLoading()
            self.showAlertView("", message: error.localized(), completion: nil)
        }
    }
    
    private func sortFavorites(with sort: CoinSortModel) {
        let lowToHigh = sort.lowToHigh
        switch sort.type {
        case .rank:
            filteredCoins.sort { lowToHigh ? $0.rank < $1.rank : $0.rank > $1.rank }
        case .coin, .symbol:
            filteredCoins.sort { lowToHigh ? $0.symbol < $1.symbol : $0.symbol > $1.symbol }
        case .name:
            filteredCoins.sort { lowToHigh ? $0.name < $1.name : $0.name > $1.name }
        case .price, .marketPriceUSD:
            filteredCoins.sort { lowToHigh ? $0.marketPriceUSD < $1.marketPriceUSD : $0.marketPriceUSD > $1.marketPriceUSD }
        case .marketCapUsd:
            filteredCoins.sort { lowToHigh ? $0.marketCapUsd < $1.marketCapUsd : $0.marketCapUsd > $1.marketCapUsd }
        case .change, .change1h:
            filteredCoins.sort { lowToHigh ? $0.change1h < $1.change1h : $0.change1h > $1.change1h }
        case .change24h:
            filteredCoins.sort { lowToHigh ? $0.change24h < $1.change24h : $0.change24h > $1.change24h }
        case .change1w:
            filteredCoins.sort { lowToHigh ? $0.change7d < $1.change7d : $0.change7d > $1.change7d }
        }
        
        tableView.reloadData()
    }
    
    //MARK: - Filter
    private func filterFavorites(with filters: [CoinFilterModel]) {
        for filter in filters {
            switch filter.type {
            case .rank:
                if filter.from != nil && filter.to != nil {
                    filteredCoins = filteredCoins.filter { $0.rank >= filter.from! && $0.rank <= filter.to! }
                } else if filter.from != nil {
                    filteredCoins = filteredCoins.filter { $0.rank >= filter.from! }
                } else {
                    filteredCoins = filteredCoins.filter { $0.rank <= filter.to! }
                }
            case .marketPriceUSD:
                if filter.from != nil && filter.to != nil {
                    filteredCoins = filteredCoins.filter { $0.marketPriceUSD >= Double(filter.from!) && $0.marketPriceUSD <= Double(filter.to!) }
                } else if filter.from != nil {
                    filteredCoins = filteredCoins.filter { $0.marketPriceUSD >= Double(filter.from!) }
                } else {
                    filteredCoins = filteredCoins.filter { $0.marketPriceUSD <= Double(filter.to!) }
                }
            case .marketCapUsd:
                if filter.from != nil && filter.to != nil {
                    filteredCoins = filteredCoins.filter { $0.marketCapUsd >= Double(filter.from!) && $0.marketCapUsd <= Double(filter.to!) }
                } else if filter.from != nil {
                    filteredCoins = filteredCoins.filter { $0.marketCapUsd >= Double(filter.from!) }
                } else {
                    filteredCoins = filteredCoins.filter { $0.marketCapUsd <= Double(filter.to!) }
                }
            case .change1h:
                if filter.from != nil && filter.to != nil {
                    filteredCoins = filteredCoins.filter { $0.change1h >= Double(filter.from!) && $0.change1h <= Double(filter.to!) }
                } else if filter.from != nil {
                    filteredCoins = filteredCoins.filter { $0.change1h >= Double(filter.from!) }
                } else {
                    filteredCoins = filteredCoins.filter { $0.change1h <= Double(filter.to!) }
                }
            case .change24h:
                if filter.from != nil && filter.to != nil {
                    filteredCoins = filteredCoins.filter { $0.change24h >= Double(filter.from!) && $0.change24h <= Double(filter.to!) }
                } else if filter.from != nil {
                    filteredCoins = filteredCoins.filter { $0.change24h >= Double(filter.from!) }
                } else {
                    filteredCoins = filteredCoins.filter { $0.change24h <= Double(filter.to!) }
                }
            case .change1w:
                if filter.from != nil && filter.to != nil {
                    filteredCoins = filteredCoins.filter { $0.change7d >= Double(filter.from!) && $0.change7d <= Double(filter.to!) }
                } else if filter.from != nil {
                    filteredCoins = filteredCoins.filter { $0.change7d >= Double(filter.from!) }
                } else {
                    filteredCoins = filteredCoins.filter { $0.change7d <= Double(filter.to!) }
                }
            default:
                return
            }
        }
        
        sortFavorites(with: favoriteSort)
    }
    
    //MARK: Sort State
    private func saveSortState() {
        guard let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") else { return }
        
        let userId = self.user?.id ?? ""
        userDefaults.set(sort.toAny(), forKey: "\(userId)coinPriceSort")
        userDefaults.set(favoriteSort.toAny(), forKey: "\(userId)coinPriceFavoriteSort")
        userDefaults.synchronize()
    }
    
    private func getSortState() {
        guard let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") else { return }
        
        let sortDict: [String: Any]?
        let favoriteSortDict: [String: Any]?
        var filterEnabled = false
        
        let userId = self.user?.id ?? ""
        sortDict = userDefaults.dictionary(forKey: "\(userId)coinPriceSort")
        favoriteSortDict = userDefaults.dictionary(forKey: "\(userId)coinPriceFavoriteSort")
        
        if let savedFilters = userDefaults.array(forKey: "\(userId)coinPriceFilters") as? [[String: Any]] {
            filters = savedFilters.map { CoinFilterModel(filterDict: $0) }
        }
        filterEnabled = userDefaults.bool(forKey: "\(userId)coinPriceFiltersEnabled")
        
        
        if let sortDict = sortDict, let favoriteSortDict = favoriteSortDict {
            self.sort = CoinSortModel(sortDict: sortDict)
            self.favoriteSort = CoinSortModel(sortDict: favoriteSortDict)
        }
        
        if let filters = filters {
            self.filters = filters.isEmpty ? nil : filters
        }
        
        let isHidden = !filterEnabled || filters == nil
        filterBageIsHidden = isHidden
        
        delegate?.setFilterState(isHidden: isHidden)
        changeSortView()
    }
    
    private func changeSortView() {
        if justFavorites {
            if let filters = filters, !filterBageIsHidden {
                filterFavorites(with: filters)
            } else {
                sortFavorites(with: favoriteSort)
            }
        }
        let currentSort = justFavorites ? favoriteSort : sort
        sortPreviewTag = currentSort.type.getIndex()
        coinSortView.setSelectedButtonState(with: currentSort)
    }
    
}

// MARK: - Action sheet delegate
extension CoinPriceViewController: ActionSheetViewControllerDelegate {
    func coinSortTypeSelected(index: Int, type: ActionSheetTypeEnum) {
        var sortType = CoinSortEnum.name
        switch type {
        case .coinSort:
            sortType = CoinSortEnum.getCoinCases()[index]
        case .coinPriceSort:
            sortType = CoinSortEnum.getPriceCases()[index]
        case .coinChangeSort:
            sortType = CoinSortEnum.getChangeCases()[index]
        default:
            break
        }
        coinSortView.setChangeType(sortType)
    }
}

// MARK: - CoinFilter VC Delegate
extension CoinPriceViewController: CoinFilterViewControllerDelegate {
    func setFilterData(filters: [CoinFilterModel]?, enabled: Bool) {
        self.filters = filters
        filterBageIsHidden = filters == nil || !enabled
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.delegate?.setFilterState(isHidden: self.filterBageIsHidden)
            self.isPaginating = true
            
            self.filteredCoins = self.justFavorites ? self.favoriteCoins : filters == nil ? self.coins : []
            self.tableView.reloadData()
            
            if self.justFavorites {
                if let filters = filters {
                    self.filterFavorites(with: filters)
                } else {
                    self.sortFavorites(with: self.favoriteSort)
                }
            } else {
                self.resetTableView()
                self.getFirstCoins(with: filters)
            }
        }
    }
}

// MARK: - Ads Methods
extension CoinPriceViewController {
    @objc func hideAds() {
        self.isAdsCome = false
        self.tableView.reloadData()
    }
    
    func checkUserForAds() {
        guard !justFavorites else  {
            self.isAdsCome = false
            return
        }
        self.adsManager.checkUserForAds(zoneName: .coinsPrcie,isAdsTableView: true) {[weak self]  adsView in
            guard let self = self else { return }
            self.adsViewForCoin = adsView
            self.isAdsCome = true
            self.tableView.reloadData()
        }
        
    }
    func checkSubscription() {
        if let user = user {
            guard !user.isSubscribted else {
                self.isAdsCome = false
                self.tableView.reloadData()
                return
            }
        }
    }
}
