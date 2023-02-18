//
//  WalletViewController.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 21.02.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit



class WalletViewController: BaseViewController {
    
    //MARK: - Properties
    @IBOutlet weak var searchBar: BaseSearchBar!
    @IBOutlet weak var searchBarHeigthConstraits: NSLayoutConstraint!
    private var reloadButton: ReloadBarButtonItem!
    private var searchButton: UIBarButtonItem!
    private var transactionButton: TransactionBarButtonItem?
    
    @IBOutlet weak var topViewHeightConstraits: NSLayoutConstraint!
    @IBOutlet weak var walletTypeCollectionView: BaseCollectionView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var lastUpdateLabel: UILabel!
    @IBOutlet weak var equitiLabel: BaseLabel!
    @IBOutlet weak var priceLabel: BaseLabel!
    @IBOutlet weak var curentPriceLabel: BaseLabel!
    @IBOutlet weak var showButtonBackgorundView: BaseView!
    @IBOutlet weak var showButton: UIButton!
    @IBOutlet weak var balanceTableView: BaseTableView!
    @IBOutlet weak var totalView: BaseView!
    @IBOutlet weak var totalViewHeight: NSLayoutConstraint!
    @IBOutlet weak var showPassButton: UIButton!
    public var walletId: String?
    public var walletType: String?
    private var viewModel: WalletViewModel?
    
    
    // MARK: - Static
    static func initializeStoryboard() -> WalletViewController? {
        return UIStoryboard(name: "Menu", bundle: nil).instantiateViewController(withIdentifier: WalletViewController.name) as? WalletViewController
    }
    
    //MARK: - Live Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViewModel()
        self.setupNavigation()
        self.configCollectionLayout()
        self.configTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        configNavigationItems()
    }
    
    
    override func languageChanged() {
        title = (walletType ?? "") + " " + "more_wallet".localized()
    }
    
    deinit {
        print("WalletViewController deinit")
        Cacher.shared.walletTransactionState = .loading
    }
    
    //MARK: - Setup
    private func setupViewModel() {
        self.viewModel = WalletViewModel(walletId: self.walletId)
        self.viewModel?.delegate = self
        self.viewModel?.getExchange()
    }
    
    private func setupViews() {
        self.lastUpdateLabel.text = "last_updated".localized() +  " " + (viewModel?.selectedWallet?.lastUpdated?.getDateFromUnixTime() ?? "")
        
        if self.viewModel!.selectedWallet!.showingBalances.isEmpty {
            showNoDataLabel(forView: self.balanceTableView)
        } else {
          hideNoDataLabel()
        }
        
        if searchBar.isHidden {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.totalViewHeight.constant = 0
                self.topViewHeightConstraits.constant = 90
                self.totalView.isHidden = true
            }
        }
        if viewModel?.selectedWallet?.totalBalance != nil {
            if searchBar.isHidden {
                UIView.animate(withDuration: Constants.animationDuration) {
                    self.totalView.isHidden = false
                    self.totalViewHeight.constant = 76
                    self.topViewHeightConstraits.constant = 166
                }
            }
            self.equitiLabel.text = "equity_value".localized() +  " (\(viewModel?.selectedWallet?.totalBalance?.currency ?? ""))"
            if self.viewModel!.exchange!.showWalletTotalValue {
                self.priceLabel.text = viewModel?.selectedWallet?.totalBalance?.value?.getFormatedString()
                self.curentPriceLabel.text = " ~ \(Locale.appCurrencySymbol) " + (viewModel?.selectedWallet?.totalBalance?.priceUSD ?? 1.0 * (viewModel?.rates?[Locale.appCurrency] ?? 1.0)).getFormatedString()
                self.showPassButton.setImage(UIImage(named: "views_Icon"), for: .normal)
            } else {
                self.showPassButton.setImage(UIImage(named: "none_view"), for: .normal)
                self.priceLabel.text = "********"
                self.curentPriceLabel.text = " ~ \(Locale.appCurrencySymbol) " + "*******"
            }
        }
        self.showButton.setTitle(viewModel!.show0 ? "hide_0".localized() : "show_0".localized() , for: .normal)
        self.showPassButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 10)
        self.showButton.tintColor = .barSelectedItem
        self.disableButton(viewModel?.selectedWallet?.balances.count ?? 0 < 1)
        self.showButtonBackgorundView.addSeparatorView(from: showButtonBackgorundView, to: showButtonBackgorundView, color: darkMode ? .blackBackground : .white)
    }
    
    func setupNavigation() {
        navigationController?.navigationBar.shadowImage = UIImage()
        
        searchButton = UIBarButtonItem.customButton(self, action: #selector(_showSearchBar), imageName: "bar_search")
        searchButton.isEnabled = false
        searchBar.delegate = self
        reloadButton =  ReloadBarButtonItem(target: self, action: #selector(updateWallet))
        transactionButton = TransactionBarButtonItem(target: self, action: #selector(goToTransactionPage))
        let buttons: [UIBarButtonItem] = [searchButton, transactionButton!,reloadButton]
        navigationItem.setRightBarButtonItems(buttons, animated: false)
    }
    
    func configNavigationItems() {
    guard #available(iOS 13.0, *) else {
        searchButton = UIBarButtonItem.customButton(self, action: #selector(_showSearchBar), imageName: "bar_search")
        searchBar.delegate = self
        reloadButton =  ReloadBarButtonItem(target: self, action: #selector(updateWallet))
        transactionButton = TransactionBarButtonItem(target: self, action: #selector(goToTransactionPage))
        let buttons: [UIBarButtonItem] = [searchButton, transactionButton!,reloadButton]
        navigationItem.setRightBarButtonItems(buttons, animated: false)
        return
    }
    }
    func configCollectionLayout() {
        
        if viewModel?.exchange?.wallets.count == 1 && viewModel?.exchange?.wallets.first!.name == nil  {
            self.walletTypeCollectionView.isHidden = true
        }
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.itemSize = CGSize(width: 171, height: 32)
        let leftEdge: CGFloat = (viewModel?.exchange?.wallets.count ?? 0) > 1 ? 16.0 : self.view.frame.width / 2 - 75
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: leftEdge , bottom: 0, right: 0)
        flowLayout.scrollDirection = .horizontal
        self.walletTypeCollectionView.reloadData()
        self.walletTypeCollectionView.collectionViewLayout = flowLayout
        self.walletTypeCollectionView.backgroundColor = .clear
    }
    
    func configTableView() {
        self.balanceTableView.register(UINib(nibName: WalletTableViewCell.name, bundle: nil), forCellReuseIdentifier: WalletTableViewCell.name)
    }
    
    @IBAction func showPassAction(_ sender: Any) {
        self.viewModel?.toggleShowWalletValue()
    }
    
    @IBAction func showZero(_ sender: Any) {
        self.viewModel?.show0.toggle()
        self.viewModel?.sortBalanceWithout0()
    }
    
    @objc func searchBalance() {
        self.viewModel?.searchTimer.invalidate()
        self.viewModel?.sortBalanceWithSearchText()
    }
    
    @objc private func _showSearchBar() {
        configNavigationItems()
        if searchBar.isHidden {
            searchBar.isHidden = false
            let buttonItems: [UIBarButtonItem] = [transactionButton!, reloadButton]
            navigationItem.setRightBarButtonItems(buttonItems, animated: false)
            
            UIView.animate(withDuration: Constants.animationDuration) {
                self.topViewHeightConstraits.constant = 0
                self.topView.isHidden = true
                self.searchBarHeigthConstraits.constant = 40
                self.searchBar.becomeFirstResponder()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func hideSearchBar() {
        configNavigationItems()
        if !searchBar.isHidden {
            searchBar.text = ""
            view.endEditing(true)
            let buttons: [UIBarButtonItem] = [searchButton, transactionButton!, reloadButton]
            navigationItem.setRightBarButtonItems(buttons, animated: false)
            
            UIView.animate(withDuration: Constants.animationDuration, animations: {
                self.searchBarHeigthConstraits.constant = 0
                self.topViewHeightConstraits.constant = 166
                self.topView.isHidden = false
                self.view.layoutIfNeeded()
            }) { (_) in
                self.searchBar.isHidden = true
            }
        }
    }
    
    @objc private func updateWallet() {
        self.viewModel?.updateExchange()
    }
    
    @objc  private func goToTransactionPage() {
        switch Cacher.shared.walletTransactionState  {
        case .show:
            guard let vc = TransactionController.initializeStoryboard() else { return }
            vc.walletId = walletId ?? ""
            vc.historyTypes = viewModel?.exchange?.historyTypes ?? []
            navigationController?.pushViewController(vc, animated: true)
        case .noShow:
            showToastAlert("Out of date!".localized(), message: nil)
        case .loading:
            return
        }
    }
}


//MARK: - TableViewDelegate  -
extension WalletViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel?.selectedWallet?.showingBalances.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: WalletTableViewCell.name) as? WalletTableViewCell {
            
            cell.setDate( ballance: self.viewModel?.selectedWallet?.showingBalances[indexPath.row])
            return cell
        }
        
        return WalletTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.viewModel?.selectedWallet?.showingBalances[indexPath.row].isDepositEnabled ?? false {
            self.viewModel?.changeSelectedBalance(index: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WalletTableViewCell.height
    }
    
}


//MARK: - WalletViewModelDelegate
extension WalletViewController: WalletViewModelDelegate {
    
    func showActionShit() {
        Loading.shared.endLoading(for: self.view)
        let netWorkNames: [String]? = viewModel?.selectedWallet?.selectedWalletCoin?.addresses.map({$0.network})
        guard netWorkNames != nil else { return }
        self.view.alpha = 1
        if netWorkNames!.count == 1 {
            openDepositController(index: 0)
            return
        }
        self.showActionShit(self, type: .simple, items: netWorkNames!)
    }
    
    func startLoading(toLoweAlpha: Bool) {
        Loading.shared.startLoading(ignoringActions: true, for: self.view)
        if toLoweAlpha { self.view.alpha = 0.4}
        transactionButton = TransactionBarButtonItem(target: self, action: #selector(goToTransactionPage))
        transactionButton?.isEnabled = false
    }
    
    func endLoading(toRaiseAlpha: Bool) {
        Loading.shared.endLoading(for: self.view)
        if toRaiseAlpha { self.view.alpha = 1}
        transactionButton = TransactionBarButtonItem(target: self, action: #selector(goToTransactionPage))
        if toRaiseAlpha {
        transactionButton?.isEnabled = true
        }
    }
    
    func reloadData() {
        self.configCollectionLayout()
        self.balanceTableView.reloadData()
        self.setupViews()
        self.walletTypeCollectionView.reloadData()
    }
    
    func requestFailed(with error: String) {
        self.showAlertView("", message: error, completion: nil)
    }
}


//MARK: - UICollectionViewDelegate -

extension WalletViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.exchange?.wallets.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "walletType", for: indexPath) as? WalletCollectionViewCell {
            cell.setDate(wallet: (viewModel?.exchange?.wallets[indexPath.row])!)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel?.changeSelect(index: indexPath.row)
    }
}

// MARK: - Search delegate
extension WalletViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchText.trimmingCharacters(in: .whitespaces)
        
        guard searchText != "" else {
            self.viewModel?.searchText = searchText
            self.viewModel?.sortBalanceWithSearchText()
            return
        }
        self.viewModel?.searchText = searchText
        self.viewModel?.searchTimer.invalidate()
        self.viewModel?.searchTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(searchBalance), userInfo: nil, repeats: true)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        searchBar.setCancelButtonEnabled(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.viewModel?.searchText = ""
        self.viewModel?.sortBalanceWithSearchText()
        hideSearchBar()
    }
    
    func disableButton(_ bool: Bool) {
        searchButton.isEnabled = !bool
        view.layoutIfNeeded()
    }
    
    func openDepositController(index: Int){
        guard let vc = DepositViewController.initializeStoryboard() else { return }
        vc.walletCoin = self.viewModel?.selectedWallet?.selectedWalletCoin
        vc.walletId = self.walletId!
        vc.exchange = (self.viewModel?.exchange!.exchange)!
        vc.historyTypes = viewModel?.exchange?.historyTypes ?? []
        vc.selectedIndex = index
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - ActionSheetViewControllerDelegate
extension WalletViewController: ActionSheetViewControllerDelegate {
    func actionShitSelected(index: Int) {
        openDepositController(index: index)
    }
}
