//
//  SelectCriptoViewController.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/22/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//
import FirebaseCrashlytics
import UIKit

class SelectCriptoViewController: BaseViewController {

    @IBOutlet weak var searchBar: BaseSearchBar!
    @IBOutlet weak var criptoListTableView: BaseTableView!
    @IBOutlet weak var scrollTopImageView: BaseImageView!
    
    weak var delegate: ConverterViewControllerDelegate?
    private var freeCoinsCount = 0
    private var isPaginating = false
    private var searchText: String?
    private var timer = Timer()
    public var alreadyExistedCriptoCount = 0
    var currentUser: UserModel? {
        return DatabaseManager.shared.currentUser
    }
    var coins: [CoinModel] = []
    var fiat: [FiatModel] = []
    var isSelectedFiat = false
    var openedForChangeHeader = false
    var filteredCoins: [CoinModel] = [] {
        didSet {
            updateNoDataLabel()
        }
    }
    
    var filteredFiats: [FiatModel] = [] {
        didSet {
            updateNoDataLabel()
        }
    }
    
    private var skip: Int {
        return coins.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !isSelectedFiat && coins.isEmpty {
            getShortList()
        }
        setupTableView()
        setupNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFreeLimitation()
        DispatchQueue.main.async {
            self.initialSetup()
            self.criptoListTableView.animate()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if fiat.isEmpty {
            delegate?.getCoins(coins)
        }
    }

    func getFreeLimitation() {
        CoinRequestService.shared.getFreeCoinLimitation(success: { (count) in
            self.freeCoinsCount = count
        }) { (error) in
            self.showAlertView(nil, message: error, completion: nil)
        }
    }
    
    func setupNavigation() {
        title = (isSelectedFiat ? "fiat" : "coin_sort_coin").localized()
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func initialSetup() {
        filteredFiats = fiat
        filteredCoins = coins
        searchBar.showsCancelButton = false
    }
    
    func setupTableView() {
        if isSelectedFiat {
            criptoListTableView.register(UINib(nibName: "SelectCriptoTableViewCell", bundle: nil), forCellReuseIdentifier: "criptoCell")
        } else {
            criptoListTableView.register(UINib(nibName: "SelectCriptoCoinTableViewCell", bundle: nil), forCellReuseIdentifier: SelectCriptoCoinTableViewCell.name)
        }
        
        setupScrollImageView()
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
    
    @objc private func scrollTop() {
        self.criptoListTableView.scroll(to: .top, animated: true)
    }
    
    func goToConverterBage() {
        navigationController?.popViewController(animated: true)
    }
    
    private func updateNoDataLabel() {
        if isSelectedFiat && filteredFiats.isEmpty {
            showNoDataLabel()
        } else if !isSelectedFiat && filteredCoins.isEmpty {
            showNoDataLabel()
        } else {
            hideNoDataLabel()
        }
    }
}

//MARK: -- Get Data
extension SelectCriptoViewController {
    private func getShortList(with skip: Int = 0) {
        Loading.shared.startLoading()
        CoinRequestService.shared.getShortList(skip: 0) { (coins, _) in
            self.coins = coins
            self.filteredCoins = coins
            DispatchQueue.main.async {
                Loading.shared.endLoading()
                Crashlytics.crashlytics().setCustomValue("success", forKey: "getShortList")
                self.criptoListTableView.animate()
            }
        } failer: { (error) in
            Crashlytics.crashlytics().setCustomValue(error, forKey: "getShortListError")
            Loading.shared.endLoading()
            self.showAlertView("", message: error.localized(), completion: nil)
        }
    }
    
    private func getSearchCoins(with searchText: String) {
        Loading.shared.startLoading()
        CoinRequestService.shared.getShortList(skip: 0, searchText: searchText) { (searchCoins, allCount) in
            Loading.shared.endLoading()
            if self.searchText != nil {
                self.filteredCoins = searchCoins
                self.isPaginating = self.filteredCoins.count == allCount
                DispatchQueue.main.async {
                    self.criptoListTableView.reloadDataScrollUp()
                }
            }
        } failer: { (error) in
            Loading.shared.endLoading()
            if self.searchText != nil {
                self.showAlertView("", message: error.localized(), completion: nil)
            }
        }
    }
    
}

//MARK: -- SearchBar delegate methods
extension SelectCriptoViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchText.trimmingCharacters(in: .whitespaces)

        if isSelectedFiat {
            filteredFiats = fiat.filter({$0.currency.lowercased().contains(searchText.lowercased())})
            if searchText.isEmpty {
                filteredFiats = fiat
            }
        } else {
            if searchText.isEmpty {
                self.searchText = nil
                filteredCoins = coins
            }
            
            self.searchText = searchText
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: Constants.searchTimeInterval, target: self, selector: #selector(self.searching), userInfo: nil, repeats: true)
        }
        criptoListTableView.reloadData()
    }
    
    @objc private func searching() {
        timer.invalidate()
        if let searchText = searchText {
            getSearchCoins(with: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.searchText = nil
        initialSetup()
        hideKeyboard()
        criptoListTableView.reloadData()
    }
    
}

//MARK: -- TableView delegate and data source methods
extension SelectCriptoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSelectedFiat ? filteredFiats.count: filteredCoins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSelectedFiat {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "criptoCell", for: indexPath) as? SelectCriptoTableViewCell {
                cell.setupFiatData(filteredFiats[indexPath.row])
                
                return cell
            }
            return UITableViewCell()
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: SelectCriptoCoinTableViewCell.name, for: indexPath) as? SelectCriptoCoinTableViewCell {
                cell.setupCoinData(filteredCoins[indexPath.row])
                
                return cell
            }
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if openedForChangeHeader {
            if fiat.isEmpty {
                delegate?.changeMainTableView(filteredCoins[indexPath.row])
            } else {
                delegate?.changeMainTableView(filteredFiats[indexPath.row])
            }
            goToConverterBage()
        } else if isSelectedFiat {
            let selectedFiat = filteredFiats[indexPath.row]
            if let user = currentUser {
                if let subsciptionInfo = user.subsciptionInfo, user.isSubscribted {
                    if alreadyExistedCriptoCount < subsciptionInfo.maxConvertCoinCount {
                        delegate?.getFiat(selectedFiat)
                        goToConverterBage()
                    } else {
                        self.showAlertView(nil, message: "maximum_count_reached!".localized(), completion: nil)
                    }
                } else if let subsciptionInfo = user.subsciptionInfo {
                    fiatLimitationAction(fiat: selectedFiat, freeCoinsCount: subsciptionInfo.maxConvertCoinCount)
                }
            } else {
                fiatLimitationAction(fiat: selectedFiat, freeCoinsCount: freeCoinsCount)
            }
        } else {
            let selectedCoin = filteredCoins[indexPath.row]
            if let user = currentUser {
                if let subsciptionInfo = user.subsciptionInfo, user.isSubscribted {
                    if alreadyExistedCriptoCount < subsciptionInfo.maxConvertCoinCount {
                        delegate?.getCoin(selectedCoin, coins: coins)
                        goToConverterBage()
                    } else {
                        self.showAlertView(nil, message: "maximum_count_reached!".localized(), completion: nil)
                    }
                } else if let subsciptionInfo = user.subsciptionInfo {
                    coinLimitationAction(coin: selectedCoin, freeCoinsCount: subsciptionInfo.maxConvertCoinCount)
                }
            } else {
                coinLimitationAction(coin: selectedCoin, freeCoinsCount: freeCoinsCount)
            }
        }
    }
    
    func coinLimitationAction(coin: CoinModel, freeCoinsCount: Int) {
        if alreadyExistedCriptoCount < freeCoinsCount {
            delegate?.getCoin(coin, coins: coins)
            goToConverterBage()
        } else {
            goToSubscription()
        }
    }
    
    func fiatLimitationAction(fiat: FiatModel, freeCoinsCount: Int) {
        if alreadyExistedCriptoCount < freeCoinsCount {
            delegate?.getFiat(fiat)
            goToConverterBage()
        } else {
             goToSubscription()
        }
    }
    
    func goToSubscription() {
        let sb = UIStoryboard(name: "More", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ManageSubscriptionViewController") as! ManageSubscriptionViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // hiding keyboard during scrolling
        hideKeyboard()
        
        let position = scrollView.contentOffset.y
        scrollTopImageView.isHidden = position < 100
        if position > criptoListTableView.contentSize.height - scrollView.frame.size.height * 0.85 {
            if !isPaginating && fiat.isEmpty {
                criptoListTableView.tableFooterView = createIndicatorFooter()
                self.isPaginating = true
                CoinRequestService.shared.getCoinsList(skip: skip, searchText: searchText, success: { (coins, _, allCount)  in
                    if self.searchText == nil {
                        self.coins += coins
                        self.filteredCoins = self.coins
                    } else {
                        self.filteredCoins += coins
                    }
                    DispatchQueue.main.async {
                        self.criptoListTableView.tableFooterView = nil
                        self.criptoListTableView.reloadData()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.isPaginating = self.filteredCoins.count == allCount
                    }
                }) { (error) in
                    self.showAlertView("", message: error.localized(), completion: nil)
                    self.criptoListTableView.tableFooterView = nil
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


