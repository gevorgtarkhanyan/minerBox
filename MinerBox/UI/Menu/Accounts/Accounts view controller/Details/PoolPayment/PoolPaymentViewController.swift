//
//  PoolPaymentViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/3/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import Localize_Swift
import FirebaseCrashlytics

class PoolPaymentViewController: BaseViewController {
    
    // MARK: - Views
    @IBOutlet fileprivate weak var dateFromView: DateSelectorView!
    @IBOutlet fileprivate weak var dateToView: DateSelectorView!
    
    @IBOutlet fileprivate weak var dateSegmentedControl: BaseSegmentControl!
    @IBOutlet fileprivate weak var dateSegmenParentStackView: UIStackView!
    @IBOutlet fileprivate weak var dateButton: BackgroundButton!
    
    @IBOutlet fileprivate weak var viewForTable: BaseView!
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    
    // Table menu
    @IBOutlet fileprivate weak var headerStackView: UIStackView!
    @IBOutlet fileprivate weak var value1Label: BaseLabel!
    @IBOutlet fileprivate weak var value2Label: BaseLabel!
    @IBOutlet fileprivate weak var value2FilterView: FilterView!
    @IBOutlet fileprivate weak var value2HeaderView: UIView!
    @IBOutlet fileprivate weak var value3Label: BaseLabel!
    @IBOutlet fileprivate weak var value4Label: BaseLabel!
    @IBOutlet fileprivate weak var value4FilterView: FilterView!
    @IBOutlet fileprivate weak var value5Label: BaseLabel!
    @IBOutlet fileprivate weak var value5FilterView: FilterView!
    @IBOutlet fileprivate weak var value5HeaderView: UIView!
    
    @IBOutlet var stackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var balanceParentView: UIView!
    @IBOutlet fileprivate weak var balanceLabel: BaseLabel!
    @IBOutlet fileprivate weak var converterButton: ConverterButton!
    
    typealias DetailsData = [(name: String, value: String, showQrCopy: Bool)]
    
    // MARK: - Properties
    fileprivate var currentPage: PoolPaymentType?
    fileprivate var account: PoolAccountModel!
    fileprivate var currency: String?
    fileprivate var singleCurrency: String?
    fileprivate var coinID = ""
    fileprivate var newCurrency = ""
    fileprivate var payments = [PoolPaymentModel]()
    fileprivate var filteredPayments = [PoolPaymentModel]() {
        didSet {
            if filteredPayments.count == 0 {
                showNoDataLabel()
                
            } else {
                hideNoDataLabel()
            }
        }
    }
    fileprivate var filter = DateFilter()
    fileprivate var openFromBalance = false
    
    fileprivate var payoutsType: [String]? {
        var payoutsType = [String]()
        for payment in payments {
            guard let type = payment.type, !payoutsType.contains(type) && type != "" else { continue }
            payoutsType.append(type)
        }
        return payoutsType.count > 0 ? ["all"] + payoutsType : nil
    }
    
    fileprivate var payoutsCurrency: [String]? {
        var payoutsCurrency = [String]()
        payments.forEach {
            if let currency = $0.currency, !payoutsCurrency.contains(currency) {
                payoutsCurrency.append(currency)
            }
        }
        if payoutsCurrency.count == 1 {
            singleCurrency = payoutsCurrency.first
        }
        return payoutsCurrency.count > 1 ? ["all"] + payoutsCurrency : nil
    }
    
    public var rightBarButtonItms: [UIBarButtonItem] {
        let shareItem = UIBarButtonItem(image: UIImage(named: "share"), style: .done, target: self, action: #selector(share))
        let refreshItem = UIBarButtonItem(image: UIImage(named: "bar_refresh"), style: .done, target: self, action: #selector(refreshButtonAction(_:)))
        refreshItem.imageInsets = UIEdgeInsets(top: 0.0, left: 30, bottom: 0, right: 0.0)
        return [shareItem]
    }
    
    fileprivate var dateInterval: DateInterval = .month
    fileprivate var segmentPreviewIndex: Int?
    fileprivate var currentCoinId: String?
    
    // MARK: - Static
    static func initializeStoryboard() -> PoolPaymentViewController? {
        return UIStoryboard(name: "AccountDetails", bundle: nil).instantiateViewController(withIdentifier: PoolPaymentViewController.name) as? PoolPaymentViewController
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Loading.shared.endLoading(for: self.view)
        savePageState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    override func languageChanged() {
        balanceLabel.setLocalizableText("balance")
        switch currentPage {
        case .payout:
            print("None Title")
        case .resentCredit:
            title = "balance".localized()
            stackViewBottomConstraint.constant = -18
        case .block:
            title = "blocks".localized()
        case .none:
            print("None Title")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let newVC = segue.destination as? PopUpInfoViewController,
            let indexPath = tableView.indexPathForSelectedRow,
            filteredPayments.indices.contains(indexPath.row)
        else { return }
        
        let payment = filteredPayments[indexPath.row]
        let rows = getDetailsData(payment)
        
        newVC.setData(rows: rows)
    }
    
}

// MARK: - Startup default setup
extension PoolPaymentViewController {
    fileprivate func startupSetup() {
        setupUI()
        
        configLabels()
        addRefreshControl()
        setupDate()
        getPageState()
        
        guard openFromBalance else {
            getPayments()
            return
        }
        self.configData()
        
    }
    
    fileprivate func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(getPayments(_:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.backgroundView = refreshControl
        }
    }
    
    private func setupDate() {
        configDateFilters()
        configDateButton()
        configDateSegmentedControl()
    }
    
    fileprivate func configLabels() {
        
        value1Label.changeFont(to: Constants.semiboldFont)
        value2Label.changeFont(to: Constants.semiboldFont)
        value3Label.changeFont(to: Constants.semiboldFont)
        value4Label.changeFont(to: Constants.semiboldFont)
        value5Label.changeFont(to: Constants.semiboldFont)
        balanceLabel.changeFont(to: Constants.semiboldFont)
    }
    
    fileprivate func configDateFilters() {
        dateToView.delegate = self
        dateToView.setPlaceholder("date_to")
        dateToView.setMaximumDate(date: Date())
        
        dateFromView.delegate = self
        dateFromView.setPlaceholder("date_from")
        dateFromView.setMaximumDate(date: Date())
    }
    
    fileprivate func configDateButton() {
        dateButton.addTarget(self, action: #selector(dateButtonAction(_:)), for: .touchUpInside)
        let image = UIImage(named: "calendar")?.withRenderingMode(.alwaysTemplate)
        dateButton.setImage(image, for: .normal)
        dateButton.tintColor = dateSegmenParentStackView.isHidden ? darkMode ? .white : .viewDarkBackground : .barSelectedItem
        dateButton.backgroundColor = .clear
        dateButton.changeEdgeInsets(constat: 25)
    }
    
    fileprivate func configDateSegmentedControl() {
        let segmenData = DateInterval.allCases.map { "1 \($0.rawValue.localized())" }
        dateSegmentedControl.setRoundedSpacingSegment(segmenData)
        dateSegmentedControl.delegate = self
    }
}

// MARK: - Setup UI
extension PoolPaymentViewController {
    fileprivate func setupUI() {
        configTableView()
        navigationItem.setRightBarButtonItems(rightBarButtonItms, animated: true)
    }
    
    fileprivate func configTableView() {
        viewForTable.clipsToBounds = true
        viewForTable.layer.cornerRadius = 10
    }
    
}


// MARK: - Actions
extension PoolPaymentViewController {
    func getDetailsData(_ payment: PoolPaymentModel) -> DetailsData {
        let currency = payment.currency ?? newCurrency
        let currentCoinId = payment.coinId ?? coinID
        let coinStrData = currency + "+" + currentCoinId
        // Config table data
        var rows = DetailsData()
        
        if payment.dateUnix !=  0.0 {
            rows.append((name: "date", value: payment.dateUnix.getDateFromUnixTime(), showQrCopy: false))
        }
        if payment.paidOn != -1.0 {
            rows.append((name: "date", value: payment.paidOn.getDateFromUnixTime(), showQrCopy: false))
        }
        if let duration = payment.duration { rows.append((name: "duration", value: duration, showQrCopy: false)) }
        if payment.timestamp != 0.0 {
            rows.append((name:"date", value: payment.timestamp.getDateFromUnixTime(), showQrCopy: false))
        }
        if payment.blockNumber != -1 {
            rows.append((name: "block", value: payment.blockNumber.getString(), showQrCopy: false))
        }
        if payment.height != 0.0 {
            rows.append((name: "height", value: payment.height.getString(), showQrCopy: false))
        }
        if let block = payment.block { rows.append((name: "block", value: block, showQrCopy: false)) }
        if let id = payment.id { rows.append((name: "id", value: id, showQrCopy: false)) }
        if payment.status != nil {
            rows.append((name: "status", value: payment.status!, showQrCopy: false))
        }
        if payment.type != nil {
            rows.append((name: "type", value: payment.type!, showQrCopy: false))
        }
        if let worker = payment.worker { rows.append((name: "worker", value: worker, showQrCopy: false)) }
        if payment.confirmations != -1 {
            rows.append((name: "confirmations".localized(), value: payment.confirmations.getString(), showQrCopy: false))
            rows.append((name: "status", value: payment.confirmations >= 130 ? "confirmed" : "unconfirmed", showQrCopy: false))
        }
        if payment.cfms != -1  {
            rows.append((name: "confirmations", value: payment.cfms.getString(), showQrCopy: false))
        }
        if payment.amount != -1 {
            rows.append((name: "amount", value: payment.amount.getString() + "+" + coinStrData, showQrCopy: false))
        }
        if payment.rewards != -1 {
            rows.append((name: "account_rewards", value: payment.rewards.getString() + "+" + coinStrData, showQrCopy: false))
        }
        if payment.txFee != -1 && payment.txFeePer != -1 {
            let value = "\(payment.txFee.getString())+(\(payment.txFeePer) % + \(coinStrData)"
            rows.append((name: "txFee", value: value, showQrCopy: false))
        } else if payment.txFee != -1 {
            let value = "\(payment.txFee.getString())+\(coinStrData)"
            rows.append((name: "txFee", value: value, showQrCopy: false))
        } else if payment.txFeePer != -1 {
            let value = "\(payment.txFeePer) %"
            rows.append((name: "txFee", value: value, showQrCopy: false))
        }
        if payment.networkFee != -1 {
            rows.append((name: "networkFee", value: "\(payment.networkFee.getString())", showQrCopy: false))
        }
        if payment.networkFeePer != -1 {
            rows.append((name: "networkFee", value: "\(payment.networkFeePer.getString()) %", showQrCopy: false))
        }
        if payment.coinPrice != -1 {
            rows.append((name: "coin_price", value: "\(payment.coinPrice.getString()) USD", showQrCopy: false))
        }
        if payment.sharePer != -1 {
            rows.append((name: "shares", value: payment.sharePer.getString(), showQrCopy: false))
        }
        if payment.luckPer != -1 {
            rows.append((name: "luck", value: "\(payment.luckPer.getString()) (%)", showQrCopy: false))
        }
        if let matured = payment.matured {
            rows.append((name: "matured", value: "\(matured)", showQrCopy: false))
        }
        if let orphan = payment.orphan {
            rows.append((name: "orphaned", value: "\(orphan)", showQrCopy: false))
        }
        if payment.shareDifficulty != -1 {
            rows.append((name: "difficulty", value: payment.shareDifficulty.textFromHashrate(difficulty: true), showQrCopy: false))//.getString()))
        }
        if payment.mixin != -1 {
            rows.append((name: "mixin", value: payment.mixin.getString(), showQrCopy: false))
        }
        if let coinAddress = payment.coinAddress { rows.append((name: "coinAddress".localized(), value: coinAddress, showQrCopy: true)) }
        if let txHash = payment.txHash, !txHash.isEmpty { rows.append((name: "tx", value: txHash, showQrCopy: true)) }
        if payment.immature != -1 {
            rows.append((name: "state", value: payment.immature == 1 ? "Immature".localized() : "matured".localized(), showQrCopy: false))
        }
        if let txId = payment.txId {
            rows.append((name: "txId", value: txId, showQrCopy: true))
        }
        return rows
    }
    
    @objc func share() {
        let items = ShareType.allCases.map { $0.rawValue }
        let fileName = account.poolTypeName + "_" + (currentPage?.strRawValue ?? "").capitalizingFirstLetter()
        
        self.showActionShit(self, items: items) { [weak self] index in
            guard let self = self else { return }
            let data = self.filteredPayments.map { $0.dataDescription }
            let shareType = ShareType(index)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                ShareManager.share(self, shareType: shareType, data: data, fileName: fileName)
            }
        }
    }
}

// MARK: - Request
extension PoolPaymentViewController {
    
    @objc func getPayments(_ refreshControl: UIRefreshControl? = nil) {
        if refreshControl == nil {
            Loading.shared.startLoadingForView(with: tableView)
        }
        Loading.shared.startLoadingForView(with: tableView)
        PoolRequestService.shared.getAccountPayments(poolId: account.id, poolType: account.poolType, type: currentPage ?? .payout, successArray: { (payments) in
            self.payments = payments
            self.configData()
            Loading.shared.endLoadingForView(with: self.tableView)
            refreshControl?.endRefreshing()
        }) { (error) in
            Loading.shared.endLoadingForView(with: self.tableView)
            refreshControl?.endRefreshing()
            self.showAlertView("", message: error, completion: nil)
        }
    }
    
    fileprivate func configData() {
        self.configHeaderStackLabels()
        self.checkPayoutsCoinInfo()
        configTx()
        self.filterPayments()
    }
    
    fileprivate func configTx() {
        guard (payments.contains { $0.txHash != nil }) else { return }
        payments.forEach({
            guard $0.txHash == nil else { return }
            $0.txHash = ""
        })
    }
    
    fileprivate func configHeaderStackLabels() {
        
        value2FilterView?.addTarget(self, action: #selector(filterTapped(_:)))
        value4FilterView?.addTarget(self, action: #selector(filterTapped(_:)))
        value5FilterView?.addTarget(self, action: #selector(filterTapped(_:)))
        
        filter.currencys = (payments.map { $0.currency ?? "all" }).uniqued()
        if !filter.currencys.contains("all") {
            filter.currencys.append("all")
        }
        
        if payments.contains(where: { $0.paidOn != -1 }) {
            value1Label.setLocalizableText("paidOn")
        } else {
            value1Label.setLocalizableText("date")
        }
        
        if payments.contains(where: { $0.type != nil }) {
            value2Label.setLocalizableText("type")
            
            filter.types = (payments.map { $0.type! }).uniqued()
            if filter.types.count < 2  {
                self.value2FilterView?.removeFromSuperview()
            }
            
            filter.types.append("all")
        } else if payments.contains(where: { $0.blockNumber != -1 }) {
            self.value2FilterView?.removeFromSuperview()
            value2Label.setLocalizableText("block")
        } else if payments.contains(where: { $0.height != 0.0 }) {
            self.value2FilterView?.removeFromSuperview()
            value2Label.setLocalizableText("height")
        } else {
            value2HeaderView.isHidden = true
        }
        
        if payments.contains(where: { $0.paidOn != -1 }) {
            value3Label.setLocalizableText("duration")
        } else if payments.contains(where: { $0.immature != -1 }) {
            value3Label.setLocalizableText("state")
        } else if payments.contains(where: { $0.cfms != -1 }) {
            value3Label.setLocalizableText("confirmations")
        } else if payments.contains(where: { $0.worker != nil }) {
            value3Label.setLocalizableText("worker")
        } else {
            value3Label.isHidden = true
        }
        
        
        if payments.contains(where: { $0.rewards != -1 })  {
            value4Label.setLocalizableText("account_rewards")
            value4Label.addSymbolAfterText("(\(currency ?? ""))")
        } else  {
            value4Label.setLocalizableText("amount")
        }
        
        if payments.contains(where: { $0.txHash != nil }) {
            value5Label.setLocalizableText("tx")
            self.value5FilterView?.removeFromSuperview()
        } else if payments.contains(where: { $0.status != nil }) {
            value5Label.setLocalizableText("status")
            filter.statuses = (payments.map { $0.status!}).uniqued()
            if filter.statuses.count < 2  {
                self.value5FilterView?.removeFromSuperview()
            }
            filter.statuses.append("all")
        } else if payments.contains(where: { $0.sharePer != -1 }) {
            self.value5FilterView?.removeFromSuperview()
            value5Label.setLocalizableText("shares")
            value5Label.addSymbolAfterText("(%)")
        } else if payments.contains(where: { $0.luckPer != -1 }) {
            self.value5FilterView?.removeFromSuperview()
            value5Label.setLocalizableText("luck")
            value5Label.addSymbolAfterText("(%)")
        } else if payments.contains(where: { $0.shareDifficulty != -1 }) {
            self.value5FilterView?.removeFromSuperview()
            value5Label.setLocalizableText("difficulty")
        } else {
            value5HeaderView.isHidden = true
        }
    }
}

// MARK: - SegmentControl Delegate
extension PoolPaymentViewController: BaseSegmentControlDelegate {
    func segmentSelected(index: Int) {
        if segmentPreviewIndex == index {
            dateSegmentedControl.unselect()
            segmentPreviewIndex = nil
            clearFilteredProperties()
            filterPayments()
        } else {
            guard let oldDate = Calendar.current.date(
                    byAdding: index == 0 ? .day : index == 1 ? .weekOfMonth : .month,
                    value: -1,
                    to: Date()) else { return }

            dateFromView.setDate(date: oldDate)
            dateToView.setDate(date: Date())
            segmentPreviewIndex = index
        }
    }
}

// MARK: - Date selector delegate
extension PoolPaymentViewController: DateSelectorViewDelegate {
    func dateSelected(sender: DateSelectorView, date: Date) {
//        Crashlytics.crashlytics().setCustomValue(date, forKey: "currentDate")
//        Crashlytics.crashlytics().setCustomValue(filter.minimumDate ?? "noDate" , forKey: "minimumDate")
//        Crashlytics.crashlytics().setCustomValue(filter.maximumDate ?? "noDate" , forKey: "maximumDate")

        switch sender {
        case dateFromView:
            dateToView.setMinimumDate(date: date)
            filter.minimumDate = date.timeIntervalSince1970
        case dateToView:
            dateFromView.setMaximumDate(date: date)
            filter.maximumDate = date.timeIntervalSince1970
        default:
            break
        }
        filterPayments()
    }
    
    func dateClear(sender: DateSelectorView) {
        switch sender {
        case dateFromView:
            dateToView.setMinimumDate(date: nil)
            filter.minimumDate = nil
        case dateToView:
            let date = Date()
            dateFromView.setMaximumDate(date: date)
            filter.maximumDate = nil
        default:
            break
        }
        dateSegmentedControl.unselect()
        segmentPreviewIndex = nil
        filterPayments()
    }
    
    func doneButtonTapped() {
        dateSegmentedControl.unselect()
        segmentPreviewIndex = nil
    }
    
}

// MARK: - Filter Actions
extension PoolPaymentViewController {
    
    @objc func filterTapped(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        showActionShit(self, type: .simple, items: filter.allCases[index])
        filter.setCurrentType(index)
    }
    
    fileprivate func filterPayments() {
        filteredPayments = payments.filter({ (payment) -> Bool in
            let minDate = filter.minimumDate ?? 0.0
            let maxDate = filter.maximumDate ?? Date().timeIntervalSince1970
            
            var dateFilter = true
            
            switch currentPage {
            case .payout:
                dateFilter =  payment.paidOn >= minDate && payment.paidOn <= maxDate
            case .resentCredit:
                dateFilter = payment.dateUnix >= minDate && payment.dateUnix <= maxDate
            case .block:
                dateFilter = payment.timestamp >= minDate && payment.timestamp <= maxDate
            case .none:
                dateFilter = true
            }
            
            let typeFilter = filter.type == "all" || filter.type == payment.type
            let currencyFilter = filter.currency == "all" || filter.currency == payment.currency
            let statusFilter =  payment.status == nil ? true : filter.status == "all" || filter.status == payment.status
            
            return dateFilter && typeFilter && currencyFilter && statusFilter
        })
        filterAction()
    }
    
    private func filterAction() {
        value2FilterView?.setBageIsHidden(filter.type == "all")
        value4FilterView?.setBageIsHidden(filter.currency == "all")
        value5FilterView?.setBageIsHidden(filter.status == "all")
        checkSingleCurrency()
        getAmountCurrency()
        setBalance(payments: filteredPayments)
        tableView.reloadDataScrollUp()
    }
    
    @objc func setupPayoutsAlertByType() {
        guard let payoutsType = payoutsType, payoutsType.count > 2 else { return }
        self.showActionShit(self, type: .payoutsType, items: payoutsType)
    }
    
    @objc func setupPayoutsAlert() {
        guard let payoutsCurrency = payoutsCurrency else { return }
        self.showActionShit(self, type: .payoutsCurrency, items: payoutsCurrency)
    }
    
    
    fileprivate func checkPayoutsCoinInfo() {
        let hasCurrencys = payments.contains(where: { $0.currency != nil })
        if hasCurrencys {
            self.currency = nil
        }
        checkBlockAndType()
    }
    
    private func checkBlockAndType() {
        let containsBlock = payments.contains { $0.block != nil }
        //payoutsType default have 1 value` "all"
        setFilterHeaderViewEnabled(false)
        if let payoutsType = payoutsType {
            if !containsBlock && payoutsType.count == 2 {
                value2Label.setLocalizableText("type")
                value2FilterView?.isHidden = true
            } else if payoutsType.count >= 2 {
                value2Label.setLocalizableText("type")
                value2FilterView?.isHidden = payoutsType.count == 2
                value2HeaderView?.isHidden = false
                setFilterHeaderViewEnabled(true)
            }
        }
        headerStackView.isHidden = false
    }
    
    func getAmountCurrency() {
        var newCurrency = ""
        if currency == nil {
            if let singleCurrency = singleCurrency {
                newCurrency = singleCurrency
                filter.currency = singleCurrency
            } else if filter.currency != "all" {
                newCurrency = filter.currency
                singleCurrency = filter.currency
            }
        } else {
            newCurrency = currency!
        }
        if let payoutsCurrency = payoutsCurrency {
            value4FilterView?.isHidden = payoutsCurrency.count < 2
        } else {
            value4FilterView?.isHidden = true
        }
        
        let visibleText = newCurrency == "" ? "" : " (\(newCurrency))"
        value4Label.addSymbolAfterText(visibleText)
    }
    
    private func setFilterHeaderViewEnabled(_ bool: Bool) {
        for recognizer in value2HeaderView.gestureRecognizers ?? [] {
            recognizer.isEnabled = bool
        }
        
    }
    
    func setBalance(payments: [PoolPaymentModel]) {
        var amounts = currentPage != .block ? payments.map { $0.amount } :  payments.map { $0.rewards }
        amounts.removeAll{ $0 == -1.0 }
        let balance = amounts.reduce(0, +)
        
        if let currency = singleCurrency {
            balanceParentView.isHidden = false
            newCurrency = currency
        } else if let currency = currency {
            balanceParentView.isHidden = false
            newCurrency = currency
        } else {
            balanceParentView.isHidden = true
        }
        coinID = (payments.first { $0.currency == newCurrency })?.coinId ?? currentCoinId ?? ""
        converterButton.setData(coinID, amount: balance)
        balanceLabel.addSymbolAfterText(": \(balance.getString()) \(newCurrency)")
    }
    
    private func checkSingleCurrency() {
        var payoutsCurrency = [String]()
        filteredPayments.forEach {
            if let currency = $0.currency, !payoutsCurrency.contains(currency) {
                payoutsCurrency.append(currency)
            }
        }
        if payoutsCurrency.count == 1 {
            singleCurrency = payoutsCurrency.first
        } else {
            singleCurrency = nil
        }
    }
    
    // MARK: - UI actions
    @objc public func refreshButtonAction(_ sender: UIBarButtonItem) {
        getPayments()
    }
    public func setCurrentPage(_ type: PoolPaymentType) {
        self.currentPage = type
    }
    public func openFromBalance(currency: String?,payments:[PoolPaymentModel]) {
        guard let account = Cacher.shared.account else {return}
        self.payments = payments
        self.account = account
        self.currency = currency
        filter.currency = currency ?? "all"
        openFromBalance = true
    }
    
    @objc func dateButtonAction(_ sender: UIButton) {
        dateSegmenParentStackView.isHidden = !dateSegmenParentStackView.isHidden
        dateButton.tintColor = dateSegmenParentStackView.isHidden ? darkMode ? .white : .viewDarkBackground : .barSelectedItem
    }
    
    fileprivate func clearFilteredProperties() {
        filter.minimumDate = nil
        filter.maximumDate = nil
        
        dateToView.clearText()
        dateFromView.clearText()
    }
}

// MARK: - TableView methods
extension PoolPaymentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPayments.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PoolPaymentTableViewCell.name) as! PoolPaymentTableViewCell
        
        cell.setData(model: filteredPayments[indexPath.row],
                     showCurrency: filter.currency == "all")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "payoutInfoSegue", sender: self)
    }
}

// MARK: - Set Data
extension PoolPaymentViewController {
    public func setData(currency: String?, account: PoolAccountModel, coinId: String?) {
        self.account = account
        self.currency = currency
        self.currentCoinId = coinId
    }
}

// MARK: - Page State
extension PoolPaymentViewController {
    private func savePageState() {
        guard let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox"),
              let account = Cacher.shared.account else { return }
        
        let dateButtonEnubled = !dateSegmenParentStackView.isHidden
        let dateSegmentSelectedIndex = dateSegmentedControl.getSelectedIndex()
        let openFromBalance = self.openFromBalance ? "fromBalance" : ""
        userDefaults.set(dateButtonEnubled, forKey: "\(account.keyPath)\(currentPage?.rawValue ?? 0))DateButtonEnubled\(openFromBalance)")
        userDefaults.set(dateSegmentSelectedIndex, forKey: "\(account.keyPath)\(currentPage?.rawValue ?? 0)DateSegmentSelectedIndex\(openFromBalance)")
        userDefaults.set(filter.encode(), forKey: "\(account.keyPath)\(currentPage?.rawValue ?? 0)Filter\(openFromBalance)")
    }
    
    private func getPageState() {
        guard let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox"),
              let account = Cacher.shared.account else { return }
        
        var dateButtonEnubled: Bool
        var dateSegmentSelectedIndex: Int?
        
        let openFromBalance = self.openFromBalance ? "fromBalance" : ""
        
        dateButtonEnubled = userDefaults.bool(forKey: "\(account.keyPath)\(currentPage?.rawValue ?? 0)DateButtonEnubled\(openFromBalance)")
        dateSegmentSelectedIndex = userDefaults.object(forKey: "\(account.keyPath)\(currentPage?.rawValue ?? 0)DateSegmentSelectedIndex\(openFromBalance)") as? Int
        let data = userDefaults.object(forKey: "\(account.keyPath)\(currentPage?.rawValue ?? 0)Filter\(openFromBalance)") as? Data
        
        if openFromBalance == "" {
        filter = DateFilter(data: data)
        }
        
        dateSegmenParentStackView.isHidden = !dateButtonEnubled
        dateButton.tintColor = dateSegmenParentStackView.isHidden ? darkMode ? .white : .viewDarkBackground : .barSelectedItem
        dateSegmentedControl.setSelectedIndex(with: dateSegmentSelectedIndex)
        
        if dateSegmentSelectedIndex == nil {
            dateFromView.setDate(timeInterval: filter.minimumDate)
            dateToView.setDate(timeInterval: filter.maximumDate)
        }
    }
}

//MARK: -- Alert VC Delegate
extension PoolPaymentViewController: ActionSheetViewControllerDelegate {
    func actionShitSelected(index: Int) {
        filter.config(index)
        filterPayments()
        savePageState()
    }
    
    func payoutTypeSelected(index: Int) {
        guard let payoutsType = payoutsType else { return }
        
        filter.type = payoutsType[index]
        alertAction()
    }
    
    func payoutCurrencySelected(index: Int) {
        guard let payoutsCurrency = payoutsCurrency else { return }
        
        filter.currency = payoutsCurrency[index]
        alertAction()
    }
    
    private func alertAction() {
        switch currentPage {
        case .payout:
            filterPayments()
        case .resentCredit:
            filterPayments()
        case .block:
            filterPayments()
        case .none:
            print("No Cases")
        }
        let controller = tabBarController ?? self
        controller.dismiss(animated: false, completion: nil)
    }
}

//MARK: -Helper
fileprivate enum DateInterval: String, CaseIterable {
    case day
    case week
    case month
}

struct DateFilter: Codable {
    var currentType: FilterType?
    
    var type: String = "all"
    var status: String = "all"
    var currency: String = "all"
    var minimumDate: Double?
    var maximumDate: Double?
    
    var types = [String]()
    var statuses = [String]()
    var currencys = [String]()
    
    var allCases: [[String]] {
        return [types,currencys,statuses]
    }
    
    enum FilterType: Int, Codable {
        case type
        case currency
        case status
    }
    
    init() {}
    
    init(data: Data?) {
        let decoder = JSONDecoder()
        if let data = data,
           let filter = try? decoder.decode(DateFilter.self, from: data) {
            self = filter
        } else {
            self.init()
        }
    }
    
    func encode() -> Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }
    
    mutating func config(_ index: Int) {
        switch currentType {
        case .type:
            type = types[index]
        case .status:
            status = statuses[index]
        case .currency:
            currency = currencys[index]
        case .none:
            print("none")
        }
    }
    
    mutating func setCurrentType(_ index: Int) {
        currentType = FilterType(rawValue: index)
    }
}

enum PoolPaymentType: Int {
    case payout 
    case resentCredit
    case block
    
    var strRawValue: String {
        switch self {
        case .payout:
            return "payout"
        case .resentCredit:
            return "resentCredit"
        case .block:
            return "block"
        }
    }
}
