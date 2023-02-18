//
//  ConverterViewController.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/18/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

protocol ConverterViewControllerDelegate: AnyObject {
    func changeMainTableView(_ coinModel: CoinModel)
    func changeMainTableView(_ fiatModel: FiatModel)
    func getCoin(_ coinModel: CoinModel, coins: [CoinModel])
    func getCoins(_ coins: [CoinModel])
    func getFiat(_ fiatModel: FiatModel)
}

class ConverterViewController: BaseViewController {
    
    @IBOutlet weak var coinFiatView: CoinFiatView!
    @IBOutlet weak var coinFiatListTableView: BaseTableView!
    @IBOutlet weak var mainCriptTableView: BaseTableView!
    @IBOutlet weak var priceTextField: BaseTextField!
    @IBOutlet weak var textParentView: BaseView!
    @IBOutlet weak var priceCoinLabel: BaseLabel!
    @IBOutlet weak var coinFiatListTableBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var coinFiatViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainCriptoTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    
    private var shareItem: UIBarButtonItem!
    private var tap: UITapGestureRecognizer?
    private var cachedFiatConstraint: CGFloat!
    private var cachedCoinConstraint: CGFloat!
    private var customHeaderView: MainConvertibleHeaderView?
    public var headerCoinId: String?
    private let mainCoinId = "bitcoin"
    private var addedCoinsContainsHeaderCoin = true
    private var addedCoinsContainsMainCoin = true
    private var reversed = false
    
    private var addedCoins: [CoinModel] = []
    private var addedFiats: [FiatModel] = []
    private var allFiats: [FiatModel] = []
    public var coins: [CoinModel] = []
    public var multiplier: Double = 1
    private var mainCoin: CoinModel?
    private var headerCoin: CoinModel?
    private var headerFiat: FiatModel?
    
    private var adsViewForConverter = AdsView()

    var coinIds: [String] {
        return addedCoins.map { $0.coinId }
    }
    
    // MARK: - Static
    static func initializeStoryboard() -> ConverterViewController? {
        return UIStoryboard(name: "More", bundle: nil).instantiateViewController(withIdentifier: ConverterViewController.name) as? ConverterViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupTableView()
        addNotificationsListeners()
        initialSetup()
        getFiatList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addBackgroundNotificaitonObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if customHeaderView != nil {
            customHeaderView!.animateImageScale()
        }
        coinFiatView.addRotateAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeBackgroundNotificaitonObserver()
        savePageState()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIApplication.shared.statusBarOrientation.isPortrait && UIDevice.current.userInterfaceIdiom == .phone  {
            adsViewForConverter.isHidden = true
        } else {
            adsViewForConverter.isHidden = false
        }
    }
    
    override func applicationEnteredToBackground(_ sender: Notification) {
        savePageState()
    }
    
    //MARK: -- Setup Navigation
    func setupNavigation() {
        title = MoreSettingsEnum.converter.rawValue.localized()
        shareItem = UIBarButtonItem(image: UIImage(named: "share"), style: .done, target: self, action: #selector(share))
        navigationItem.setRightBarButtonItems([shareItem], animated: true)
    }
    
    @objc func share() {
//        let screenImage = view.takeScreenshot()
//        let mainImageView = UIImageView(image: screenImage)
//        let logoImageView = UIImageView(frame: CGRect(x: view.frame.maxX - 50, y: 20, width: 30, height: 30))
//        logoImageView.image = UIImage(named: "logo")
//        let titleLabel = BaseLabel(frame: CGRect(x: logoImageView.frame.origin.x - 85, y: logoImageView.frame.origin.y, width: 100, height: 30))
//        titleLabel.text = "Miner Box"
//        titleLabel.textColor = .cellTrailingFirst
//
//        mainImageView.addSubview(logoImageView)
//        mainImageView.addSubview(titleLabel)
//        UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, UIScreen.main.scale)
//        mainImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
//
//        let sendedImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        if sendedImage != nil {
//            let activityViewController = UIActivityViewController(activityItems: [sendedImage!], applicationActivities: nil)
//            activityViewController.popoverPresentationController?.sourceView = self.view
//            self.present(activityViewController, animated: true, completion: nil)
//        }
        ShareManager.share(self, fileName: "Converter")
    }
    
    //MARK: -- Setup TableView
    func setupTableView() {
        coinFiatListTableView.register(UINib(nibName: "ConverterFlagCell", bundle: nil), forCellReuseIdentifier: "flagCell")
        coinFiatListTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: coinFiatListTableView.frame.width, height: 1))
        //        coinFiatListTableView.layer.cornerRadius = CGFloat(10)
        coinFiatListTableView.separatorStyle = .none
        
        mainCriptTableView.register(UINib(nibName: "MainConvertibleCell", bundle: nil), forCellReuseIdentifier: "mainCell")
        mainCriptTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: coinFiatListTableView.frame.width, height: 1))
        
        mainCriptTableView.reloadData()
        mainCriptTableView.layoutIfNeeded()
        mainCriptTableView.heightAnchor.constraint(equalToConstant: mainCriptTableView.contentSize.height).isActive = true
        
        if mainCriptTableView.contentSize.height > 250 {
            mainCriptTableView.isScrollEnabled = true
        } else {
            mainCriptTableView.isScrollEnabled = false
        }
    }
    
    @objc func addNotificationsListeners() {
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIScene.willEnterForegroundNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        }
    }
    
    func initialSetup() {
        coinFiatView.delegate = self
        
        textParentView.isHidden = true
        mainCriptTableView.isHidden = true
        coinFiatListTableView.isHidden = true
        coinFiatView.isHidden = true
        textParentView.alpha = 0
        mainCriptTableView.alpha = 0
        coinFiatListTableView.alpha = 0
        coinFiatView.alpha = 0
        
        priceTextField.attributedPlaceholder = NSAttributedString(string: "1", attributes: [NSAttributedString.Key.foregroundColor : UIColor.placeholder])
        textParentView.layer.cornerRadius = CGFloat(10)
        coinFiatListTableView.layer.cornerRadius = CGFloat(10)
        mainCriptTableView.layer.cornerRadius = CGFloat(10)
        
        cachedFiatConstraint = coinFiatListTableBottomConstraint.constant
        cachedCoinConstraint = coinFiatViewTopConstraint.constant
        
        if multiplier != 1 {
            if let correctInt = Int(exactly: multiplier) {
                priceTextField.text = correctInt.getFormatedString()
            } else {
                priceTextField.text = multiplier.getFormatedString()
            }
        }
        
        if headerCoin != nil {
            priceCoinLabel.text = headerCoin!.symbol
        }
    }
    
    @IBAction func priceEditingChanged(_ sender: UITextField) {
        sender.getFormatedText()
    }
    
    //MARK: - Get Data
    private func getMainCoin() {
        CoinRequestService.shared.getCoin(success: { (coin) in
            self.mainCoin = coin
            if self.addedCoins.isEmpty {
                self.addedCoins.append(coin)
            }
            DispatchQueue.main.async {
                if self.headerCoinId == nil {
                    self.showViews()
                    self.convertWithCurrency()
                    self.mainCriptTableView.reloadData()
                    self.coinFiatListTableView.reloadData()
                }
            }
        }) { (error) in
            self.showAlertView("", message: error.localized(), completion: nil)
            debugPrint(error)
        }
    }
    
    private func getHeaderCoin(in coins: [CoinModel]) {
        if let headerCoinId = headerCoinId {
            self.headerCoin = coins.first { $0.coinId == headerCoinId }
            self.priceCoinLabel.text = reversed ? headerFiat?.currency : headerCoin?.symbol
            self.mainCriptTableView.reloadData()
            //fix these
            print("addedCoinsContainsHeaderCoin:", addedCoinsContainsHeaderCoin)
            if !addedCoinsContainsHeaderCoin {//} && addedCoins.count > 1 {
                addedCoins.removeAll { $0.coinId == headerCoinId }
            }
        }
    }
    
    private func getManyCoin(with coinIds: [String]) {
        var newCoiIds = coinIds
        
        if let headerCoinId = headerCoinId, !newCoiIds.contains(headerCoinId) {
            newCoiIds.append(headerCoinId)
        }
        
        if !newCoiIds.contains(mainCoinId) {
            newCoiIds.append(mainCoinId)
            addedCoinsContainsMainCoin = false
        }
        
        Loading.shared.startLoadingForView(with: self.view)
        CoinRequestService.shared.getManyCoin(with: newCoiIds) { (manyCoins) in
            self.addedCoins = manyCoins
            self.mainCoin = self.addedCoins.first { $0.coinId == self.mainCoinId }
            if !self.addedCoinsContainsMainCoin && self.headerCoinId != self.mainCoinId {
                self.addedCoins.removeAll { $0.coinId == self.mainCoinId }
            }
            
            DispatchQueue.main.async {
                self.getHeaderCoin(in: self.addedCoins)
                self.convertWithCurrency()
                self.showViews()
                self.checkUserForAds()
                Loading.shared.endLoadingForView(with: self.view)
            }
        } failer: { (error) in
            Loading.shared.endLoadingForView(with: self.view)
            self.showAlertView("", message: error.localized(), completion: nil)
        }
    }
    
    private func getFiatList() {
        let isLoadingTime = TimerManager.shared.isLoadingTime(item: .fiats)
        if isLoadingTime {
            getFiatListFromServer()
        } else if let fiats = DatabaseManager.shared.fiats {
            fiatGetingLogics(fiats)
        } else {
            getFiatListFromServer()
        }
    }
    
    private func getFiatListFromServer() {
        Loading.shared.startLoadingForView(with: self.view)
        self.letViewBeTapped(false)
        FiatRequestService.shared.getFiatList(success: { (fiats) in
            Loading.shared.endLoadingForView(with: self.view)
            self.fiatGetingLogics(fiats)
            DispatchQueue.main.async {
                self.letViewBeTapped(true)
                self.convertWithCurrency()
            }
        }) { (error) in
            Loading.shared.endLoadingForView(with: self.view)
            self.letViewBeTapped(false)
            self.showAlertView("", message: error.localized(), completion: nil)
            TimerManager.shared.failed(.fiats)
            debugPrint(error)
        }
    }
    
    private func fiatGetingLogics(_ fiats: [FiatModel]) {
        self.allFiats = fiats
        self.headerFiat = self.allFiats.first { $0.currency == Locale.appCurrency }
        self.getMainFiat()
        self.getPageState()
    }
    
    private func getMainFiat() {
        for fiat in allFiats {
            if fiat.currency == Locale.appCurrency {
                if addedFiats.count == 0 {
                    addedFiats.append(fiat)
                }
                break
            }
        }
    }
    
    //MARK: -- Page State
    private func savePageState() {
        let coinsIds = addedCoins.map { $0.coinId }
        let fiatsCurrencys = addedFiats.map { $0.currency }
        let headerCoinId = headerCoin?.coinId ?? mainCoinId
        let headerFiatCurrency = headerFiat?.currency ?? Locale.appCurrency
        //check page default state
        let isDefaultCoin = coinIds.count == 1 && coinIds.contains(mainCoinId) && headerCoin?.coinId == mainCoinId
        let isDefaultFiat = fiatsCurrencys.count == 1 && fiatsCurrencys.contains(Locale.appCurrency) && headerFiat?.currency == Locale.appCurrency
        
        guard let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") else { return }
        let userId = self.user?.id ?? ""
        
        if !(isDefaultCoin && isDefaultFiat) {
            userDefaults.set(coinsIds, forKey: "\(userId)converterCoinsIds")
            userDefaults.set(fiatsCurrencys, forKey: "\(userId)converterFiatsCurrencys")
            userDefaults.set(headerCoinId, forKey: "\(userId)converterHeaderCoinId")
            userDefaults.set(headerFiatCurrency, forKey: "\(userId)converterHeaderFiatCurrency")
            userDefaults.set(addedCoinsContainsMainCoin, forKey: "\(userId)converterAddedCoinsContainsMainCoin")
        }
        userDefaults.set(reversed, forKey: "\(userId)converterReversed")
    }
    
    private func getPageState() {
        guard let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") else { return }
        
        var coinIds = [String]()
        var fiatsCurrencys = [String]()
        var headerFiatCurrency = Locale.appCurrency
        let userId = self.user?.id ?? ""
        
        if let _coinsIds = userDefaults.array(forKey: "\(userId)converterCoinsIds") as? [String],
           let _fiatsCurrencys = userDefaults.array(forKey: "\(userId)converterFiatsCurrencys") as? [String],
           let _headerCoinId = userDefaults.string(forKey: "\(userId)converterHeaderCoinId"),
           let _headerFiatCurrency = userDefaults.string(forKey: "\(userId)converterHeaderFiatCurrency") {
            
            coinIds = _coinsIds
            fiatsCurrencys = _fiatsCurrencys
            headerFiatCurrency = _headerFiatCurrency
            addedCoinsContainsMainCoin = userDefaults.bool(forKey: "\(userId)converterAddedCoinsContainsMainCoin")
            reversed = headerCoinId == nil ? userDefaults.bool(forKey: "\(userId)converterReversed") : false
            headerCoinId = headerCoinId == nil ? _headerCoinId : headerCoinId
        }
        
        if coinIds.isEmpty {
            coinIds.append(mainCoinId)
            addedCoinsContainsMainCoin = true
        }
        if fiatsCurrencys.isEmpty {
            fiatsCurrencys.append(headerFiatCurrency)
        }
        
        coinFiatView.setData(reversed)
        addedCoins.removeAll()
        
        if let headerCoinId = headerCoinId {
            addedCoinsContainsHeaderCoin = coinIds.contains(headerCoinId)
            if !addedCoinsContainsHeaderCoin {
                coinIds.append(headerCoinId)
            }
        }
        
        if !coinIds.isEmpty {
            addedFiats.removeAll()
            for currency in fiatsCurrencys {
                for fiat in allFiats {
                    if fiat.currency == currency {
                        addedFiats.append(fiat)
                    }
                }
            }
//            if let headerFiat = headerFiat, coinIds.count == 1 {
//                coinIds.append(mainCoinId)
//                if !addedFiats.contains(headerFiat) {
//                    addedFiats.append(headerFiat)
//                }
//            }
            if headerCoinId == nil {
                headerCoinId = coinIds.first
            }
            headerFiat = allFiats.first { $0.currency == headerFiatCurrency }
            getManyCoin(with: coinIds)
        } else {
            getMainCoin()
        }
    }
    
    //MARK: -- Control View Enabled
    func letViewBeTapped(_ bool: Bool) {
        shareItem.isEnabled = bool
        navigationItem.backBarButtonItem?.isEnabled = bool
    }
    
    //animate button when app comes from inactive state
    @objc func willEnterForeground() {
        if customHeaderView != nil {
            customHeaderView?.animateImageScale()
        }
    }
    
    // show when download data
    private func showViews() {
        self.textParentView.isHidden = false
        self.mainCriptTableView.isHidden = false
        self.coinFiatListTableView.isHidden = false
        self.coinFiatView.isHidden = false
        UIView.animate(withDuration: 0) {
            self.textParentView.alpha = 1
            self.mainCriptTableView.alpha = 1
            self.coinFiatListTableView.alpha = 1
            self.coinFiatView.alpha = 1
        }
    }
    
    //MARK: -- Calculation method
    private func convertCoin(headerCoin: CoinModel, in coins: [CoinModel], into fiats: [FiatModel], with count: Double = 1, for tableView: BaseTableView? = nil) {
        let headerPriceUSD = headerCoin.marketPriceUSD
        let headerPriceBTC = headerCoin.marketPriceBTC
        
        for coin in coins {
            let coinPriceBTC = coin.marketPriceBTC
            
            let coinBTCValue = (headerPriceBTC / coinPriceBTC) * count
            coin.changeAblePrice = coinBTCValue
        }
        
        for fiat in fiats {
            let fiatPriceUSD = fiat.price
            
            let fiatPriceValue = headerPriceUSD * fiatPriceUSD * count
            fiat.changeAblePrice = fiatPriceValue
        }
        
        if tableView != nil {
            tableView!.reloadData()
        }
    }
    
    private func convertFiat(headerFiat: FiatModel, in fiats: [FiatModel], into coins: [CoinModel], with count: Double = 1, for tableView: BaseTableView? = nil) {
        let headerPriceUSD = 1 / headerFiat.price
        
        for coin in coins {
            let coinPriceUSD = coin.marketPriceUSD
            
            let coinUSDValue = (headerPriceUSD / coinPriceUSD) * count
            coin.changeAblePrice = coinUSDValue
        }
        
        for fiat in fiats {
            let fiatPriceUSD = fiat.price
            
            let fiatPriceValue = fiatPriceUSD * headerPriceUSD * count
            fiat.changeAblePrice = fiatPriceValue
        }
        
        if tableView != nil {
            tableView!.reloadData()
        }
        
    }
    
    private func convertWithCurrency() {
        if !reversed {
            if headerCoin != nil {
                convertCoin(headerCoin: headerCoin!, in: addedCoins, into: addedFiats, with: multiplier, for: coinFiatListTableView)
            } else if mainCoin != nil {
                convertCoin(headerCoin: mainCoin!, in: addedCoins, into: addedFiats, with: multiplier, for: coinFiatListTableView)
            }
        } else if let headerFiat = headerFiat {
            convertFiat(headerFiat: headerFiat, in: addedFiats, into: addedCoins, with: multiplier, for: coinFiatListTableView)
        }
    }
    
    //MARK: --Keyboard frame changes
override func keyboardWillShow(_ sender: Notification) {
        super.keyboardWillShow(sender)
        guard let info = sender.userInfo,
              let keyboardFrameValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardSize = keyboardFrame.size
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height - 40.0, right: 0.0)
        self.coinFiatListTableView.contentInset = contentInsets
        self.coinFiatListTableView.scrollIndicatorInsets = contentInsets
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    override func keyboardWillHide(_ sender: Notification) {
        super.keyboardWillHide(sender)
        let contentInsets = UIEdgeInsets.zero
        self.coinFiatListTableView.contentInset = contentInsets
        self.coinFiatListTableView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
}
//MARK: -- ConverterViewController Delegate
extension ConverterViewController: ConverterViewControllerDelegate {
    func getCoins(_ coins: [CoinModel]) {
        self.coins = coins
    }
    
    func getCoin(_ coinModel: CoinModel, coins: [CoinModel]) {
        self.coins = coins
        if coinModel.coinId == mainCoinId {
            addedCoinsContainsMainCoin = true
        }
        
        if !addedCoins.contains(coinModel) {
            addedCoins.append(coinModel)
        }
        
        if let headerCoin = headerCoin, headerCoin.coinId == coinModel.coinId {
            addedCoinsContainsHeaderCoin = addedCoins.contains(coinModel)
        }
        
        savePageState()
        getManyCoin(with: coinIds)
    }
    
    func getFiat(_ fiatModel: FiatModel) {
        //must be modified
        
        if !addedFiats.contains(fiatModel) {
            addedFiats.append(fiatModel)
        }
        
        savePageState()
        getManyCoin(with: coinIds)
    }
    
    //for header coin
    func changeMainTableView(_ coinModel: CoinModel) {
        headerCoinId = coinModel.coinId
        addedCoinsContainsHeaderCoin = false
        
        addedCoins.forEach { (coin) in
            if coin.coinId == coinModel.coinId {
                addedCoinsContainsHeaderCoin = true
            }
        }
        
        if !addedCoinsContainsHeaderCoin {
            addedCoins.append(coinModel)
            if coinModel.coinId == mainCoinId {
                addedCoinsContainsMainCoin = false
            }
        } else if coinModel.coinId == mainCoinId {
            addedCoinsContainsMainCoin = true
        }
        
        savePageState()
        getManyCoin(with: coinIds)
    }
    
    //for header fiat
    func changeMainTableView(_ fiatModel: FiatModel) {
        self.headerFiat = fiatModel
        self.savePageState()
        self.getManyCoin(with: self.coinIds)
        DispatchQueue.main.async {
            self.priceCoinLabel.text = fiatModel.currency
            self.mainCriptTableView.reloadData()
        }
    }
    
}

//MARK: -- Reverse View Delegate
extension ConverterViewController: CoinFiatViewDelegate {
    func reverse(_ reversed: Bool) {
        self.reversed = reversed
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.mainCriptTableView.reloadData()
                self.mainCriptTableView.layoutIfNeeded()
                self.mainCriptoTableViewHeightConstraint.constant = self.mainCriptTableView.contentSize.height
                self.view.layoutIfNeeded()
            }
            self.priceCoinLabel.text = reversed ? self.headerFiat?.currency : self.headerCoin?.symbol
            self.convertWithCurrency()
        }
    }
}

//MARK: -- TextField delegate methods
extension ConverterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            var updatedText = text.replacingCharacters(in: textRange, with: string)
            updatedText.filterDigits()
            if updatedText.isEmpty || ((priceTextField.text == "0." || priceTextField.text == "0,") && string == "") {
                multiplier = 1
                convertWithCurrency()
            } else if let count = updatedText.toDouble() {
                multiplier = count
                convertWithCurrency()
            }
            if let selectedRange = textField.selectedTextRange {
                let cursorPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
                if cursorPosition  == 0 && (string == "," || string == ".") {
                    priceTextField.text = "0" + updatedText
                    return false
                }
            }
        }
        return priceTextField.allowOnlyNumbersForConverter(string: string)
    }
}

//MARK: -- TableView delegate and data source methods
extension ConverterViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == coinFiatListTableView {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case mainCriptTableView:
            return reversed ? MainCriptoDataSource.fiatDataCount : MainCriptoDataSource.coinDataCount
        case coinFiatListTableView:
            switch section {
            case 0:
                return addedFiats.count
            case 1:
                return addedCoins.count
            default:
                break
            }
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case mainCriptTableView:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as? MainConvertibleCell else { return UITableViewCell() }
            
            if let headerFiat = headerFiat, let mainCoin = mainCoin, reversed {
                cell.setData(headerFiat, at: mainCoin.marketPriceUSD, for: indexPath)
            } else {
                if headerCoin != nil {
                    cell.setData(headerCoin!, for: indexPath)
                } else if let coin = mainCoin {
                    cell.setData(coin, for: indexPath)
                }
            }
            
            return cell
        case coinFiatListTableView:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "flagCell", for: indexPath) as? ConverterFlagCell {
                if indexPath.section == 0 {
                    cell.setFiatData(addedFiats, for: indexPath)
                } else if indexPath.section == 1 {
                    cell.setCoinData(addedCoins, for: indexPath)
                }
                
                return cell
            }
        default:
            break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == mainCriptTableView {
            let sb = UIStoryboard(name: "CoinPrice", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "CoinChartViewController") as! CoinChartViewController
            if headerCoin != nil {
                vc.setCoinId(headerCoin!.coinId)
            } else if let coin = mainCoin {
                vc.setCoinId(coin.coinId)
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: -- Cell swipe method for less than iOS 11
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if tableView == coinFiatListTableView {
            let remove = UITableViewRowAction(style: .destructive, title: "delete".localized()) { (_, indexPath) in
                self.deleteCripto(indexPath: indexPath)
            }
            
            remove.backgroundColor = .red
            return [remove]
        }
        return []
    }
    
    //MARK: --  Cell swipe method for greather than iOS 11
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if tableView == coinFiatListTableView {
            let remove = UIContextualAction(style: .destructive, title: "") { (_, _, completion) in
                self.deleteCripto(indexPath: indexPath)
                completion(true)
            }
            
            remove.image = UIImage(named: "cell_delete")
            remove.backgroundColor = .red
            
            let swipeAction = UISwipeActionsConfiguration(actions: [remove])
            swipeAction.performsFirstActionWithFullSwipe = true
            return swipeAction
        }
        return UISwipeActionsConfiguration(actions: [])
    }
    
    private func deleteCripto(indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            self.addedFiats.remove(at: indexPath.row)
            self.coinFiatListTableView.reloadData()
        case 1:
            if self.addedCoins[indexPath.row].coinId == mainCoinId {
                addedCoinsContainsMainCoin = false
            }
            self.addedCoins.remove(at: indexPath.row)
            self.coinFiatListTableView.reloadData()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == mainCriptTableView {
            return MainConvertibleCell.height
        } else {
            return ConverterFlagCell.height
        }
    }
    
    //MARK: Header Footer view
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == mainCriptTableView {
            customHeaderView = MainConvertibleHeaderView(frame: .zero)
            if let headerFiat = headerFiat, reversed {
                customHeaderView?.tag = 0
                customHeaderView?.setData(headerFiat)
            } else {
                if customHeaderView != nil {
                    customHeaderView!.tag = 1
                    if headerCoin != nil {
                        customHeaderView!.setData(headerCoin!)
                    } else if let coin = mainCoin {
                        customHeaderView!.setData(coin)
                    }
                }
            }
            customHeaderView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(coinFiatHeaderTapped(sender:))))
            customHeaderView!.animateImageScale()
            return customHeaderView
        } else if tableView == coinFiatListTableView {
            let addFiatCoinHeaderView = AddFiatCoinHeaderView(frame: .zero, tag: section)
            let tap = UITapGestureRecognizer(target: self, action: #selector(addHeaderTapped(sender:)))
            addFiatCoinHeaderView.addGestureRecognizer(tap)
            return addFiatCoinHeaderView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView == coinFiatListTableView && section == 0 {
            let footerView = UIView(frame: .zero)
            footerView.backgroundColor = .clear
            return footerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == mainCriptTableView {
            return MainConvertibleHeaderView.height
        }
        if tableView == coinFiatListTableView {
            return AddFiatCoinHeaderView.height
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0.0
        }
        if tableView == coinFiatListTableView && section == 0 {
            return 10
        }
        return 0
    }
    
    
    //MARK: - Header tapped
    // mainCriptTableView header
    @objc func coinFiatHeaderTapped(sender: UITapGestureRecognizer) {
        guard let senderView = sender.view else { return }
        
        let sb = UIStoryboard(name: "More", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "SelectCriptoViewController") as! SelectCriptoViewController
        let headerTag = senderView.tag
        
        //when select a coin headerTag = 1
        if headerTag == 0 {
            vc.fiat = self.allFiats
            vc.isSelectedFiat = true
        } else {
            vc.coins = self.coins
        }
        
        if customHeaderView != nil {
            customHeaderView!.removeScaleAnimation()
        }
        
        vc.openedForChangeHeader = true
        vc.delegate = self
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func addHeaderTapped(sender: UITapGestureRecognizer) {
        guard let senderView = sender.view else { return }
        
        let sb = UIStoryboard(name: "More", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "SelectCriptoViewController") as! SelectCriptoViewController
        let headerTag = senderView.tag
        
        //when adding a coin headerTag = 1
        if headerTag == 1 {
            vc.alreadyExistedCriptoCount = addedCoins.count
            vc.coins = self.coins
        } else if headerTag == 0 {
            vc.alreadyExistedCriptoCount = addedFiats.count
            vc.isSelectedFiat = true
            vc.fiat = allFiats
        }
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - Ads Methods -

extension ConverterViewController {
    
    func checkUserForAds() {
        AdsManager.shared.checkUserForAds(zoneName: .converter) { adsView in
            self.adsViewForConverter = adsView
            self.setupAds()
        }
    }
    
    func setupAds() {
        
        adsViewForConverter.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(adsViewForConverter)
        
        adsViewForConverter.translatesAutoresizingMaskIntoConstraints = false
        adsViewForConverter.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 10).isActive = true
        scrollView.rightAnchor.constraint(equalTo: adsViewForConverter.rightAnchor, constant: 10).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: adsViewForConverter.bottomAnchor,constant: 24).isActive = true
    }
}
