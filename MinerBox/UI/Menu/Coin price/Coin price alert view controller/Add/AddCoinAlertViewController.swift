//
//  AddCoinAlertViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/15/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

@objc protocol AddCoinAlertViewControllerDelegate: AnyObject {
    @objc optional func alertAdded(with alert: AlertModel)
    @objc optional func editAlert(with editableAlert: AlertModel)
    @objc optional func addFavorite(with favoriteCoin: CoinModel)
    @objc optional func addWalletCoin(with walletCoin: CoinModel)
}

class AddCoinAlertViewController: BaseViewController {
    
    @IBOutlet weak var coinAlertTableView: BaseTableView!
    @IBOutlet weak var priceRepeatParentView: UIView!
    @IBOutlet weak var searchBar: BaseSearchBar!
    @IBOutlet weak var scrollTopImageView: UIImageView!
    @IBOutlet weak var priceLabel: BaseLabel!
    @IBOutlet weak var repeatLabel: BaseLabel!
    @IBOutlet weak var enabledLabel: BaseLabel!
    @IBOutlet weak var repeatSwitch: BaseSwitch!
    @IBOutlet weak var enabledSwitch: BaseSwitch!
    @IBOutlet weak var priceTextField: BaseTextField!
    @IBOutlet weak var lessThanGreaterButton: BackgroundButton!
    @IBOutlet weak var priceRepeatViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: AddCoinAlertViewControllerDelegate?
    
    private var refreshControl: UIRefreshControl?
    private var saveButton = UIBarButtonItem()
    private var previewSelectedCell: AddCoinAlertTableViewCell?
    private var comparision: CoinAlertType = .lessThan
    private var coins: [CoinModel] = []
    private var favoriteCoins: [CoinModel] = []
    private var filteredCoins: [CoinModel] = []
    private var searchCoins: [CoinModel]?
    private var selectedCoin: CoinModel?
    private var sendedCoin: CoinModel?
    private var editableAlert: AlertModel?
    private var cellForCheck: AddCoinAlertTableViewCell?
    private var currentEditAlertText: String?
    private var isCurrentTextEdit = false
    private var coinAlertModel: [CustomAlertModel] = []
    private var selectedIndexPath: IndexPath?
    private var isPaginating = false
    private var searchText: String?
    private var priceEditableText: String?
    private var timer = Timer()
    private var refreshTimer = Timer()
    private var refreshTime = Constants.refreshTimeInterval
    private var isFavoriteState = false
    private var isWalletState = false
    private var selectFirtRow = true
    
    let rates = UserDefaults.standard.value(forKey: "\(DatabaseManager.shared.currentUser?.id ?? "" )/rates") as? [String:Double]
    
    private var skip: Int {
        filteredCoins.count
    }
    
    static func initializeStoryboard() -> AddCoinAlertViewController? {
        return UIStoryboard(name: "CoinPrice", bundle: nil).instantiateViewController(withIdentifier: AddCoinAlertViewController.name) as? AddCoinAlertViewController
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        setupNavigation()
        setupTableView()
        addGesture()
        if sendedCoin == nil && editableAlert == nil {
            if ShortListCacher.shared.coins.isEmpty {
                getShortList()
            } else {
                coins = ShortListCacher.shared.coins
                filteredCoins = ShortListCacher.shared.coins
                coinAlertTableView.reloadData()
                guard isWalletState else {
                    selectFirstRow()
                    return
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        disablePageRotate()
        removeUserDefaultValues()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        enablePageRotate()
        editableAlert = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupInterfaceForEditMode()
    }
    
    // MARK: - Setup
    func addGesture() {
        priceRepeatParentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    private func setupTableView() {
        setupScrollImageView()
        coinAlertTableView.roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10)
        if filteredCoins.count == 1 {
            coinAlertTableView.separatorColor = .clear
        }
    }
    
    func setupInterfaceForEditMode() {
        if editableAlert != nil || sendedCoin != nil {
            priceRepeatViewBottomConstraint?.isActive = false
            coinAlertTableView.translatesAutoresizingMaskIntoConstraints = false
            coinAlertTableView.heightAnchor.constraint(equalToConstant: AddCoinAlertTableViewCell.height).isActive = true
            coinAlertTableView.isScrollEnabled = false
            
            searchBarHeightConstraint.constant = 0
            searchBar.isHidden = true
        }
    }
    func goToAddAddress() {
        if self.isWalletState {
            guard let selectedCoin = selectedCoin else { return }
            self.delegate?.addWalletCoin?(with: selectedCoin)
        }
        guard let navigation = self.navigationController else { return }
        for controller in navigation.viewControllers {
            if let addAddressVC = controller as? AddAddressViewController {
                navigation.popToViewController(addAddressVC, animated: true)
                return
            }
        }
    }
    
    private func setupNavigation() {
        let isLanguageRussian = UserDefaults(suiteName: "group.com.witplex.MinerBox")?.value(forKey: "appLanguage") as? String == "ru"
        
       if !isWalletState {
            saveButton = UIBarButtonItem(title: "save".localized(), style: .done, target: self, action: #selector(saveButtonAction(_:)))
           navigationItem.setRightBarButton(saveButton, animated: true)
           let attributes: [NSAttributedString.Key: Any] = isLanguageRussian ? [.font: Constants.semiboldFont.withSize(12), .foregroundColor: UIColor.barSelectedItem] : [.font: Constants.semiboldFont.withSize(16), .foregroundColor: UIColor.barSelectedItem]
           navigationItem.rightBarButtonItem!.setTitleTextAttributes(attributes, for: .normal)
           navigationItem.rightBarButtonItem!.setTitleTextAttributes(attributes, for: .selected)
        }
        addTitleLabel()
    }
    
    private func addTitleLabel() {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 200, height: 44))
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.textAlignment = .center
        let attributes: [NSAttributedString.Key: Any] = [.font: Constants.semiboldFont.withSize(20), .foregroundColor: UIColor.barSelectedItem]
        titleLabel.attributedText = NSAttributedString(string: title ?? "", attributes: attributes)
        navigationItem.titleView = titleLabel
    }
    
    private func initialSetup() {
        priceRepeatParentView.isHidden = isFavoriteState
        priceRepeatParentView.clipsToBounds = true
        priceRepeatParentView.layer.cornerRadius = 10
        priceRepeatParentView.backgroundColor = .separator
        priceRepeatViewBottomConstraint.constant = isFavoriteState ? -(priceRepeatParentView.frame.height) : 16
        
        repeatLabel.setLocalizableText("repeat")
        enabledLabel.setLocalizableText("enabled")
        priceLabel.setLocalizableText("coin_sort_price")
        lessThanGreaterButton.setTitle(comparision.rawValue.localized(), for: .normal)
        
        repeatSwitch.setOn(editableAlert?.isRepeat ?? true, animated: false)
        enabledSwitch.setOn(editableAlert?.isEnabled ?? true, animated: false)
        repeatSwitch.addTarget(self, action: #selector(oldParametDidChange), for: .touchUpInside)
        enabledSwitch.addTarget(self, action: #selector(oldParametDidChange), for: .touchUpInside)
        
        
        searchBar.addBarButtomSeparator()
        searchBar.showsCancelButton = false
        searchBar(searchBar, textDidChange: "")
        
        coinAlertModel = AddAlertDataSource.coinAlertDataModel
        lessThanGreaterButton.layer.cornerRadius = CGFloat(10)
        oldParametDidChange()
    }
    
    private func selectFirstRow() {
        let indexPath = IndexPath(row: 0, section: 0)
        coinAlertTableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        tableView(coinAlertTableView, didSelectRowAt: indexPath)
    }
    
    private func removeUserDefaultValues() {
        UserDefaults.standard.removeObject(forKey: Constants.url_open_coinAlert)
        UserDefaults.standard.removeObject(forKey: Constants.url_open_add_favorite)
    }
    
    @objc private func oldParametDidChange() {
        
        guard editableAlert != nil else {
            self.saveButton.isEnabled = true
            return
        }
        
        if ((cellForCheck?.priceSelected) != nil) {
            let prefixText =  priceTextField.text
            if cellForCheck!.priceSelected && editableAlert?.coinAlertPriceUSD.getString() != prefixText!.deletingPrefix("\(Locale.getCurrencySymbol(cur: editableAlert!.cur)) ") {
                self.saveButton.isEnabled = true
                return
            }
        }
        if editableAlert!.comparison && comparision != .lessThan  {
            self.saveButton.isEnabled = true
            return
        }
        if !editableAlert!.comparison && comparision != .greatherThan {
            self.saveButton.isEnabled = true
            return
        }
        
        if editableAlert?.isEnabled != enabledSwitch.isOn || editableAlert?.isRepeat != repeatSwitch.isOn || isCurrentTextEdit {
            self.saveButton.isEnabled = true
        } else {
            self.saveButton.isEnabled = false
        }
    }
    
    @IBAction func priceTextFieldEditingChanged(_ sender: BaseTextField) {
        isCurrentTextEdit = currentEditAlertText != sender.text
        oldParametDidChange()
        sender.text = sender.text?.deletingPrefix("\( editableAlert == nil ? Locale.appCurrencySymbol : Locale.getCurrencySymbol(cur: editableAlert!.cur) )")
        sender.text?.removeAll { $0 == " "}
        sender.getFormatedText()
        if let text = sender.text {
            sender.text = "\( editableAlert == nil ? Locale.appCurrencySymbol : Locale.getCurrencySymbol(cur: editableAlert!.cur) ) " + text
        }
        if sender.text == "\( editableAlert == nil ? Locale.appCurrencySymbol : Locale.getCurrencySymbol(cur: editableAlert!.cur) ) " {
            sender.text = "\( editableAlert == nil ? Locale.appCurrencySymbol : Locale.getCurrencySymbol(cur: editableAlert!.cur) ) "
        }
        priceEditableText = sender.text
        if let selectedIndexPath = selectedIndexPath,
           let cell = coinAlertTableView.cellForRow(at: selectedIndexPath) as? AddCoinAlertTableViewCell {
            
            if editableAlert != nil && cell.priceSelected {
                cell.unselect()
            }
        }
    }
    
    @IBAction func priceComparisonAction() {
        hideKeyboard() // must add resetSearchResult function
        setupAlert(coinAlertModel)
        oldParametDidChange()
    }
    
    func setupAlert(_ alertModel: [CustomAlertModel]) {
        let controller = tabBarController ?? self
        let newVC = ActionSheetViewController()
        newVC.delegate = self
        newVC.modalPresentationStyle = .overCurrentContext
        
        newVC.setData(controller: controller, type: .comparision)
        controller.present(newVC, animated: false, completion: nil)
    }
    
    //MARK: -- Keyboard frame changes
    override func keyboardFrameChanged(_ sender: Notification) {
        guard let userInfo = sender.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let bottomInset = UIScreen.main.bounds.height - keyboardFrame.origin.y - (tabBarController?.tabBar.frame.height ?? 0)
        if editableAlert == nil {
            if filteredCoins.count != 1 {
                UIView.animate(withDuration: Constants.animationDuration) {
                    self.priceRepeatViewBottomConstraint.constant = bottomInset > 0 ?
                    self.isFavoriteState ? bottomInset - self.priceRepeatParentView.frame.height : bottomInset :
                    self.isFavoriteState ? -(self.priceRepeatParentView.frame.height) : 16
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    // MARK: -- Listen language change
    override func languageChanged() {
        saveButton.title = "save".localized()
        title = isFavoriteState ? "add_favorite".localized() : editableAlert == nil ? "new_alert".localized() : "edit_alert".localized()
        if isWalletState {title =  "add_wallet".localized() }
    }
    
    // MARK: -- Save button action
    @objc func saveButtonAction(_ sender: UIBarButtonItem) {
        if user != nil {
           if isFavoriteState {
                addFavoriteCoin()
            } else {
                alertAction()
            }
        } else {
            goToLoginPage()
        }
    }
    
    private func addFavoriteCoin() {
        guard let selectedCoin = selectedCoin else { return }
        
        if !favoriteCoins.contains(where: { $0.coinId == selectedCoin.coinId }) {
            Loading.shared.startLoading(ignoringActions: true, for: self.view)
            CoinRequestService.shared.addToFavorites(userId: user!.id, coinId: selectedCoin.coinId, success: { (coin,String) in
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.addFavorite?(with: coin)
                    Loading.shared.endLoading(for: self.view)
                }
            }) { (error) in
                Loading.shared.endLoading(for: self.view)
                self.showAlertView("", message: error.localized(), completion: nil)
            }
        } else {
            self.showAlertView("", message: "Coin Favorite Already Exist!".localized(), completion: nil)
        }
    }
    
    private func alertAction() {
        view.endEditing(true)
        guard let text = priceTextField.text, text != "\(Locale.appCurrencySymbol) ",
              let alertValue = text.deletingPrefix("\(Locale.appCurrencySymbol) ").toDouble() else { return }
        print("alertValue:", alertValue)
        
        let comparision = self.comparision == .greatherThan ? 0 : 1
        if let alert = editableAlert {
            Loading.shared.startLoading(ignoringActions: true, for: self.view)
            AlertRequestService.shared.editAlertRequest(alertId: alert.id, value: alertValue, isRepeat: repeatSwitch.isOn, enabled: enabledSwitch.isOn, comparison: comparision, success: { (string, alertData) in
                Loading.shared.endLoading(for: self.view)
                self.showToastAlert("", message: string)
                let alert = AlertModel(json: alertData, alert: alert)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.editAlert?(with: alert)
                })
            }) { (error) in
                Loading.shared.endLoading(for: self.view)
                self.showToastAlert("", message: error)
            }
        } else {
            if let indexPath = coinAlertTableView.indexPathForSelectedRow, filteredCoins.indices.contains(indexPath.row) {
                let coin = filteredCoins[indexPath.row]
                coin.marketPriceUSD = selectedCoin?.marketCapUsd ?? 0
                self.saveButton.isEnabled = false
                Loading.shared.startLoading(ignoringActions: true, for: self.view)
                AlertRequestService.shared.addAlertRequest(coinId: coin.coinId, value: alertValue, isRepeat: repeatSwitch.isOn, enabled: enabledSwitch.isOn, comparison: comparision, success: { (string, alertData) in
                    Loading.shared.endLoading(for: self.view)
                    let alert = AlertModel(json: alertData, coin: coin)
                    self.delegate?.alertAdded?(with: alert)
                    let param = ["alert": alert]
                    NotificationCenter.default.post(name: .addAlert, object: nil, userInfo: param)
                    self.showToastAlert("", message: string)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.navigationController?.popViewController(animated: true)
                    })
                }) { (error) in
                    self.saveButton.isEnabled = true
                    Loading.shared.endLoading(for: self.view)
                    self.showAlertView("", message: error, completion: nil)
                }
            }
        }
    }
    
    override func hideKeyboard() {
        super.hideKeyboard()
    }
    
}

//MARK: - Get Data
extension AddCoinAlertViewController {
    
    private func getShortList(with skip: Int = 0) {
        Loading.shared.startLoading()
        CoinRequestService.shared.getShortList(skip: 0) { (coins, _) in
            self.coins = coins
            self.filteredCoins = coins
            ShortListCacher.shared.coins = coins
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                Loading.shared.endLoading()
                self.coinAlertTableView.reloadData()
                guard self.isWalletState else {
                    self.selectFirstRow()
                    return
                }
            })
        } failer: { (error) in
            Loading.shared.endLoading()
            self.showAlertView("", message: error.localized(), completion: nil)
        }
    }
    
    fileprivate func getCoinPrice(_ coinId: String) {
        coinAlertTableView.isUserInteractionEnabled = false
        Loading.shared.startLoading()
        DispatchQueue.global().async {
            CoinRequestService.shared.getPrice(coinID: coinId) { (coin) in
                
                if self.selectedCoin == nil {
                    self.selectedCoin = CoinModel()
                }
                self.selectedCoin!.marketCapUsd = coin.marketPriceUSD
                
                DispatchQueue.main.async {
//                    if self.selectFirtRow {
//                        self.selectFirtRow = false
//                        self.selectFirstRow()
//                    }
                    self.priceTextField.text = self.editableAlert == nil
                    ? "\(Locale.appCurrencySymbol) " + (coin.marketPriceUSD * (self.rates?[Locale.appCurrency] ?? 1.0)).getFormatedString(maximumFractionDigits: 3)
                    : "\(Locale.getCurrencySymbol(cur: self.editableAlert!.cur)) " + self.editableAlert!.value.getFormatedString(maximumFractionDigits: 3)
                    self.coinAlertTableView.isUserInteractionEnabled = true
                    Loading.shared.endLoading()
                }
            } failer: { (error) in
                self.coinAlertTableView.isUserInteractionEnabled = true
                self.showAlertView("", message: error.localized(), completion: nil)
                Loading.shared.endLoading()
            }
        }
    }
}

//MARK: -- Alert VC Delegate
extension AddCoinAlertViewController: ActionSheetViewControllerDelegate {
    func comparisionSelected(index: Int) {
        comparision = index == 0 ? .lessThan : .greatherThan
        oldParametDidChange()
        
        lessThanGreaterButton.setTitle(comparision.rawValue.localized(), for: .normal)
        let controller = tabBarController ?? self
        controller.dismiss(animated: false, completion: nil)
    }
}

// MARK: -- TextField delegate methods
extension AddCoinAlertViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField.allowOnlyNumbersForConverter(string: string)//allowOnlyNumbers(string: string)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "0." {
            textField.text = "0"
        }
    }
}

// MARK: -- SearchBar delegate methods
extension AddCoinAlertViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchText.trimmingCharacters(in: .whitespaces)
        
        guard !(editableAlert != nil || sendedCoin != nil) else { return }
        guard searchText != "" else { resetSearchData(); return }
        
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: Constants.searchTimeInterval, target: self, selector: #selector(self.searching), userInfo: nil, repeats: true)
        
        self.searchText = searchText
        if filteredCoins.count == 1 {
            coinAlertTableView.separatorColor = .clear
        }
        
    }
    
    @objc private func searching() {
        timer.invalidate()
        if let searchText = searchText {
            getSearchCoins(with: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resetSearchData()
        hideKeyboard()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        hideKeyboard()
    }
    
    private func resetSearchData() {
        searchBar.text = ""
        searchText = nil
        filteredCoins = coins
        coinAlertTableView.reloadDataScrollUp()//reloadData()
    }
    
    private func getSearchCoins(with searchText: String) {
        CoinRequestService.shared.getShortList(skip: 0, searchText: searchText) { (searchCoins, allCount) in
            self.filteredCoins = searchCoins
            self.searchCoins = searchCoins
            
            DispatchQueue.main.async {
                self.coinAlertTableView.visibleCells.forEach({
                    guard let visibleCell = $0 as? AddCoinAlertTableViewCell else { return }
                    visibleCell.checkMarkImageView.image = nil
                })
                self.coinAlertTableView.reloadData()
                if !self.filteredCoins.isEmpty && !self.isWalletState {
                    self.selectFirstRow()
                }
            }
        } failer: { (error) in
            self.showAlertView("", message: error.localized(), completion: nil)
        }
    }
    
}

// MARK: - TableView methods
extension AddCoinAlertViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCoins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AddCoinAlertTableViewCell.name) as! AddCoinAlertTableViewCell
        cell.setupCell(coins: filteredCoins, indexPath: indexPath, last: indexPath.row == coins.indices.last)
        
        if editableAlert != nil {
            cell.priceParentView.isHidden = false
        }
        
        if selectedIndexPath?.row == indexPath.row {
            cell.checkMarkImageView.image = UIImage(named: "cell_checkmark")
        } else {
            cell.checkMarkImageView.image = nil
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        if let cell = tableView.cellForRow(at: indexPath) as? AddCoinAlertTableViewCell, editableAlert != nil {
            cell.setCurrentValue()
            cellForCheck = cell
            self.oldParametDidChange()
            if cell.priceSelected {
                priceTextField.text = "\(Locale.getCurrencySymbol(cur: editableAlert!.cur)) " + selectedCoin!.marketPriceUSD.getFormatedString(maximumFractionDigits: 3)
            } else {
                if priceEditableText == nil {
                    priceTextField.text = "\(Locale.getCurrencySymbol(cur: editableAlert!.cur)) " + editableAlert!.value.getFormatedString(maximumFractionDigits: 3)
                    currentEditAlertText = "\(Locale.getCurrencySymbol(cur: editableAlert!.cur))" + editableAlert!.value.getFormatedString(maximumFractionDigits: 3)
                } else {
                    priceTextField.text = priceEditableText
                }
            }
            
            return
        }
        
        tableView.visibleCells.forEach({
            guard let visibleCell = $0 as? AddCoinAlertTableViewCell else { return }
            visibleCell.checkMarkImageView.image = nil
        })
        
        if let previewSelectedCell = previewSelectedCell {
            previewSelectedCell.checkMarkImageView.image = nil
        }
        if let cell = tableView.cellForRow(at: indexPath) as? AddCoinAlertTableViewCell {
            priceTextField.text = "\(Locale.appCurrencySymbol) "
            previewSelectedCell = cell
            cell.checkMarkImageView.image = UIImage(named: "cell_checkmark")
            
            if sendedCoin == nil && editableAlert == nil {
                let selectedCoin = filteredCoins[indexPath.row]
                if isFavoriteState {
                    self.selectedCoin = selectedCoin
                    if isWalletState {
                        goToAddAddress()
                    }
                } else {
                    getCoinPrice(selectedCoin.coinId)
                }
            } else if let sendedCoin = sendedCoin {
                getCoinPrice(sendedCoin.coinId)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AddCoinAlertTableViewCell.height
    }
}

//MARK: - Pagination
extension AddCoinAlertViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        scrollTopImageView.isHidden = position < 100
        
        if position > coinAlertTableView.contentSize.height - scrollView.frame.size.height * 0.85 {
            if !isPaginating {
                
                coinAlertTableView.tableFooterView = createIndicatorFooter()
                isPaginating = true
                
                CoinRequestService.shared.getShortList(skip: skip, searchText: searchText, success: { (coins, _)  in
                    if self.searchText == nil {
                        self.coins += coins
                        self.filteredCoins = self.coins
                        ShortListCacher.shared.coins = self.coins
                    } else {
                        self.filteredCoins += coins
                    }
                    DispatchQueue.main.async {
                        self.coinAlertTableView.tableFooterView = nil
                        self.coinAlertTableView.reloadData()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.isPaginating = false
                    }
                }) { (error) in
                    self.showAlertView("", message: error.localized(), completion: nil)
                    self.coinAlertTableView.tableFooterView = nil
                    self.isPaginating = false
                }
            }
        }
    }
    
    // Scroll View Delegate Method
    private func createIndicatorFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        Loading.shared.startLoadingForView(with: footerView)
        return footerView
    }
    
    func setupScrollImageView() {
        let tapDesture = UITapGestureRecognizer(target: self, action: #selector(scrollTop))
        scrollTopImageView.isUserInteractionEnabled = true
        scrollTopImageView.addGestureRecognizer(tapDesture)
        scrollTopImageView.layer.cornerRadius = scrollTopImageView.frame.size.height / 2
        scrollTopImageView.image = UIImage(named: "arrow_up")?.withRenderingMode(.alwaysTemplate)
        
        scrollTopImageView.tintColor = darkMode ? .white : .black
        scrollTopImageView.backgroundColor = darkMode ? UIColor.viewDarkBackgroundWithAlpha : UIColor.viewLightBackgroundWithAlpha
    }
    
    @objc private func scrollTop() {
        self.coinAlertTableView.scroll(to: .top, animated: true)
    }
    
}

//MARK: - Public setup
extension AddCoinAlertViewController {
    public func setEditableAlert(_ alert: AlertModel) {
        let coin = CoinModel(coinId: alert.coinID, marketPriceUSD: alert.coinAlertPriceUSD, name: alert.coinName, rank: alert.coinRank, symbol: alert.coinSymbol, iconPath: alert.iconPath, currentAlertCurrency: alert.cur)
        self.editableAlert = alert
        self.comparision = alert.comparison ? .lessThan : .greatherThan
        self.sendedCoin = coin
        self.filteredCoins.removeAll()
        self.filteredCoins.append(coin)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.coinAlertTableView.reloadData()
            self.priceTextField.text = "\(Locale.getCurrencySymbol(cur: self.editableAlert!.cur)) " + self.editableAlert!.value.getFormatedString(maximumFractionDigits: 3)
            self.selectedCoin = coin
            self.getCoinPrice(coin.coinId)
        }
    }
    
    public func setCoinForAlert(_ coin: CoinModel) {
        self.coins.append(coin)
        self.filteredCoins.append(coin)
        self.sendedCoin = coin
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.coinAlertTableView.reloadData()
            self.getCoinPrice(coin.coinId)
            self.selectFirstRow()
        }
    }
    
    public func setFavoriteState(_ isFavoriteState: Bool, favoriteCoins: [CoinModel]) {
        self.isFavoriteState = isFavoriteState
        self.favoriteCoins = favoriteCoins
    }
    public func setWalletState(_ isWalletState: Bool) {
        self.isFavoriteState = isWalletState
        self.isWalletState = isWalletState
    }
}

// MARK: - Helper
fileprivate class ShortListCacher {
    static let shared = ShortListCacher()
    var coins = [CoinModel]()
}
