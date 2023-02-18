//
//  EstimationsViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/3/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class EstimationsViewController: BaseViewController {
    
    // MARK: - Views
    @IBOutlet fileprivate weak var middleView: BaseView!
    
    @IBOutlet fileprivate weak var buttonsParentView: UIView!
    @IBOutlet fileprivate weak var nameButton: BackgroundButton!
    @IBOutlet fileprivate weak var typeButton: BackgroundButton!
    
    @IBOutlet fileprivate weak var periodLabel: BaseLabel!
    @IBOutlet fileprivate weak var btcLabel: BaseLabel!
    @IBOutlet fileprivate weak var usdLabel: BaseLabel!
    @IBOutlet fileprivate weak var coinLabel: BaseLabel!
    
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    @IBOutlet weak var currencyLabbel: BaseLabel!
    
    @IBOutlet weak var electricityView: BaseView!
    
    @IBOutlet weak var electricityButton: UIButton!
    @IBOutlet weak var electricityCostLabbel: BaseLabel!
    
    @IBOutlet weak var costFor1hr: BaseLabel!
    @IBOutlet weak var electricityCunsoptionLabel: BaseLabel!
    @IBOutlet weak var electricityPricefor1Kwh: BaseLabel!
    @IBOutlet weak var electricityCostlabel: BaseLabel!
    
    @IBOutlet weak var kWhLabel: BaseLabel!
    @IBOutlet weak var USDLabel: BaseLabel!
    @IBOutlet weak var kWhTextField: BaseTextField!
    @IBOutlet weak var USDTextField: BaseTextField!
    @IBOutlet weak var electricityCalculatorView: BaseView!
    
    @IBOutlet weak var kWhTextFieldView: UIView!
    @IBOutlet weak var USDTextFIeldView: UIView!
    
    @IBOutlet weak var electricityViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var spaceConstraintElectricityAndMiddle: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    
    // MARK: - Properties
    fileprivate let periods = ["minute", "hour", "day", "week", "month", "year"]
    fileprivate var estimations = [Estimation]()
    fileprivate var selectedEstimation = Estimation()
    fileprivate var filter = EstimationFilter()
    
    fileprivate var coinId = ""
    fileprivate var currency = ""
    fileprivate var priceUSD = 0.0
    fileprivate var priceBTC = 0.0
    private var electricityCost = Currency(json: NSDictionary())
    private var currencys = [Currency]()
    fileprivate var btc = [Double]()
    fileprivate var usd = [Double]()
    fileprivate var coins = [Double]()
    fileprivate var electricityButtonIsSelected = false
    fileprivate var viewDidDisappear = false
    
    let rates = UserDefaults.standard.value(forKey: "\(DatabaseManager.shared.currentUser?.id ?? "" )/rates") as? [String:Double]
    
    // MARK: - Static
    static func initializeStoryboard() -> EstimationsViewController? {
        return UIStoryboard(name: "AccountDetails", bundle: nil).instantiateViewController(withIdentifier: EstimationsViewController.name) as? EstimationsViewController
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard !viewDidDisappear else { return }
        viewDidDisappear = true
        savePageState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let size: CGSize = UIScreen.main.bounds.size
            if size.width / size.height > 1 {
                scrollView.isScrollEnabled = true
            } else {
                scrollView.isScrollEnabled = false
            }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        let size: CGSize = UIScreen.main.bounds.size
        if size.width / size.height > 1 {
            scrollView.isScrollEnabled = true
        } else {
            scrollView.isScrollEnabled = false
        }
    }
    
    override func applicationEnteredToBackground(_ sender: Notification) {
        savePageState()
    }
    
    override func languageChanged() {
        periodLabel.setLocalizableText("period")
        btcLabel.setLocalizableText("BTC")
        usdLabel.setLocalizableText(Locale.appCurrency)
        coinLabel.setLocalizableText(currency)
    }
    
    @IBAction func changeElectriCityText(_ sender: UITextField) {
        sender.getFormatedText()
    }
    @IBAction func changeElectricityUSD(_ sender: UITextField) {
        sender.getFormatedText()
        
    }
    
    
}

// MARK: - Startup default setup
extension EstimationsViewController {
    fileprivate func startupSetup() {
        getPageState()
        initialSetupElectricity()
        filterSetup()
        calculateEstimations()
        
        middleView.layer.cornerRadius = 10
        kWhTextField.backgroundColor = .clear
        USDTextField.backgroundColor = .clear
        kWhTextField.borderStyle = .none
        USDTextField.borderStyle = .none
        kWhTextFieldView.backgroundColor = .textFieldBackgorund
        USDTextFIeldView.backgroundColor = .textFieldBackgorund
//        if USDTextField.text == "0" {
//            getCurrencyList { currencies in
//                self.currencys = currencies
//                self.setupCost()
//                self.calculateEstimations()
//            }
//        }
        kWhTextField.delegate = self
        USDTextField.delegate = self
        
    }
    
//    fileprivate func setupCost() {
//        for cost in currencys {
//            if Locale.appCurrency == cost.name {
//                USDTextField.text = String(cost.cost.getString())
//            }
//        }
//    }
    
    
    
    private func filterSetup() {
        if !filter.isEmpty && (estimations.contains { $0.type == filter.type && $0.name == filter.name }) {
            filterEstimations()
        } else if let first = estimations.first {
            selectedEstimation = first
            filter.type = selectedEstimation.type
            filter.name = selectedEstimation.name
        }
        
        filter.types = ((estimations.filter { $0.type != nil }).map { $0.type! }).uniqued()
        filter.names = ((estimations.filter { $0.name != nil }).map { $0.name! }).uniqued()
        
        filterButtonsSetup()
    }
    
    fileprivate func filterButtonsSetup() {
        typeButton.isHidden = !estimations.contains(where: { $0.type != nil })
        nameButton.isHidden = !estimations.contains(where: { $0.name != nil })
        buttonsParentView.isHidden = typeButton.isHidden && nameButton.isHidden
        
        typeButton.isEnabled = filter.types.isNil ? false : filter.types!.count > 1
        nameButton.isEnabled = filter.names.isNil ? false : filter.names!.count > 1
        
        typeButton.tag = 0
        nameButton.tag = 1
        
        typeButton.roundCorners(radius: typeButton.frame.height / 2)
        nameButton.roundCorners(radius: nameButton.frame.height / 2)
        
        typeButton.addTarget(self, action: #selector(buttonsAction(_:)), for: .touchUpInside)
        nameButton.addTarget(self, action: #selector(buttonsAction(_:)), for: .touchUpInside)
        
        coinLabel.isHidden = selectedEstimation.coinId == nil || selectedEstimation.coinId == "bitcoin"
        
        setButtonTitle()
    }
    
    fileprivate func setButtonTitle() {
        typeButton.setLocalizedTitle(selectedEstimation.type ?? "")
        nameButton.setLocalizedTitle(selectedEstimation.name ?? "")
        let newCurrency = (Cacher.shared.accountSettings?.coins.first { $0.coinId == selectedEstimation.coinId })?.currency
        coinLabel.setLocalizableText(newCurrency ?? currency)
    }
    
    //MARK: - Actions
    @objc private func buttonsAction(_ sender: BackgroundButton) {
        let controller = tabBarController ?? self
        let newVC = ActionSheetViewController()
        newVC.delegate = self
        newVC.modalPresentationStyle = .overCurrentContext
        
        let items = (sender.tag == 0 ? filter.types : filter.names) ?? []
        let shitType: ActionSheetTypeEnum = sender.tag == 0 ? .estimationsType : .estimationsName
        
        newVC.setData(controller: controller, type: shitType, names: items)
        controller.present(newVC, animated: false, completion: nil)
    }
    
    @objc fileprivate func calculateEstimations() {
        btc.removeAll()
        usd.removeAll()
        coins.removeAll()
        var btcPerMinForCalc = selectedEstimation.btcPerMin//btcPerMin
        var usdPerMinForCalc = selectedEstimation.usdPerMin * (rates?[Locale.appCurrency] ?? 1.0)//usdPerMin
        var coinsPerMinForCalc = selectedEstimation.coinsPerMin//coinsPerMin
        
        self.electricityCostlabel.text = Double((String("\((kWhTextField.text!.toDouble() ?? 0) * (USDTextField.text!.toDouble() ?? 0))")))?.getString()
        
        if electricityButtonIsSelected {
            electricityViewHeightConstraint.constant = 117
            spaceConstraintElectricityAndMiddle.constant = 10
            
            if let electriCostPerHour = electricityCostlabel.text!.toDouble() {
                
                let myFloat =  electriCostPerHour / 60
                
                if selectedEstimation.btcPerMin == 0 {
                    btcPerMinForCalc   -= myFloat / ((priceUSD * (rates?[Locale.appCurrency] ?? 1.0)) / priceBTC)
                    
                } else {
                    btcPerMinForCalc   -= myFloat / (selectedEstimation.usdPerMin * (rates?[Locale.appCurrency] ?? 1.0) / selectedEstimation.btcPerMin)
                }
                if selectedEstimation.coinsPerMin == 0 {
                    coinsPerMinForCalc -= myFloat / self.priceUSD * (rates?[Locale.appCurrency] ?? 1.0)
                    
                } else {
                    coinsPerMinForCalc -= myFloat / (selectedEstimation.usdPerMin * (rates?[Locale.appCurrency] ?? 1.0) / selectedEstimation.coinsPerMin)
                }
                usdPerMinForCalc   -= myFloat
            }
        } else {
            electricityViewHeightConstraint.constant = 0
            spaceConstraintElectricityAndMiddle.constant = 0
        }
        for i in [1, 60, 24] {
            btcPerMinForCalc *= Double(i)
            usdPerMinForCalc *= Double(i)
            coinsPerMinForCalc *= Double(i)
            btc.append(btcPerMinForCalc)
            usd.append(usdPerMinForCalc)
            coins.append(coinsPerMinForCalc)
        }
        let lastBtc = btc.last!
        let lastUsd = usd.last!
        let lastCoins = coins.last!
        
        for i in [7, 30, 360] {
            btcPerMinForCalc = lastBtc * Double(i)
            usdPerMinForCalc = lastUsd * Double(i)
            coinsPerMinForCalc = lastCoins * Double(i)
            btc.append(btcPerMinForCalc)
            usd.append(usdPerMinForCalc)
            coins.append(coinsPerMinForCalc)
        }
        
        tableView.reloadData()
    }
}

// MARK: - TableView methods
extension EstimationsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return periods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EstimationsTableViewCell.name) as! EstimationsTableViewCell
        
        let btc = self.btc[indexPath.row].getString()
        let usd = self.usd[indexPath.row].getString()
        let coin = self.coins[indexPath.row].getString()
        
        cell.setData(period: periods[indexPath.row],
                     btc: btc,
                     usd: usd,
                     coin: coin,
                     coinID: selectedEstimation.coinId ?? coinId,
                     coinIsHidden: coinLabel.isHidden)
        
        return cell
    }
}

extension EstimationsViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let isNumber = CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
        let withDecimal = (
            string == NumberFormatter().decimalSeparator &&
            textField.text?.contains(string) == false
        )
        return isNumber || withDecimal
    }
}

//MARK: - Page State
extension EstimationsViewController {
    
//    fileprivate func getCurrencyList(success: @escaping ([Currency]) -> Void) {
//        Loading.shared.startLoading(ignoringActions: true, for: view, barButtons: [navigationItem.backBarButtonItem])
//        UserRequestsService.shared.getCurrencyList { currency in
//            success(currency)
//            Loading.shared.endLoading(for: self.view, barButtons: [self.navigationItem.backBarButtonItem])
//        } failer: { err in
//            self.showAlertView("", message: err, completion: nil)
//            debugPrint(err)
//            Loading.shared.endLoading(for: self.view, barButtons: [self.navigationItem.backBarButtonItem])
//        }
//    }
//    
    
    fileprivate func savePageState() {
        
        guard let account = Cacher.shared.account else {  return }
        
        UserDefaults.shared.set(filter.encode(), forKey: account.keyPath + "estimationFilter")
        UserDefaults.shared.set(electricityButtonIsSelected, forKey: account.keyPath + "estimationElectricityButtonIsSelected")
        UserDefaults.shared.set(Locale.appCurrency, forKey: account.keyPath + "estimationElectricityLocaleAppCurrency")
        UserDefaults.shared.set(USDTextField.text?.toDouble() , forKey: account.keyPath + "estimationElectricityValue")
        UserDefaults.shared.set(kWhTextField.text?.toDouble() , forKey: account.keyPath + "estimationElectricitykWhValue")
        
    }
    
    fileprivate func getPageState() {
        
        guard let account = Cacher.shared.account else {  return }
        
        let filterData = UserDefaults.shared.value(forKey: account.keyPath + "estimationFilter") as? Data
        filter = EstimationFilter(data: filterData)
        self.electricityButtonIsSelected = UserDefaults.shared.bool(forKey: account.keyPath + "estimationElectricityButtonIsSelected")
        var valueStr = UserDefaults.shared.value(forKey: account.keyPath + "estimationElectricityValue") as? Double ??  0
        
        let kWHvalueStr = UserDefaults.shared.value(forKey: account.keyPath + "estimationElectricitykWhValue") as? Double ?? 0
        
        let previewCurrency = UserDefaults.shared.value(forKey: account.keyPath + "estimationElectricityLocaleAppCurrency") as? String
        if previewCurrency != Locale.appCurrency {
            valueStr = 0
        }
        
        self.USDTextField.text = String(Double(valueStr).getString())
        self.kWhTextField.text = String(Double(kWHvalueStr).getString())
    }
}

//MARK: -- Alert VC Delegate
extension EstimationsViewController: ActionSheetViewControllerDelegate {
    func estimationTypeSelected(index: Int) {
        filter.configType(index)
        filterEstimations()
    }
    
    func estimationNameSelected(index: Int) {
        filter.configName(index)
        filterEstimations()
    }
    
    private func filterEstimations() {
        guard let selectedEstimation = estimations.filter({ $0.type == filter.type && $0.name == filter.name }).first else { return }
        
        self.selectedEstimation = selectedEstimation
        calculateEstimations()
        setButtonTitle()
        savePageState()
    }
}

// MARK: - Set data
extension EstimationsViewController {
    public func setData(estimations: [Estimation], currency: String, coinId: String, priceUSD: Double, priceBTC: Double) {
        self.estimations = estimations
        self.currency = currency
        self.coinId = coinId
        self.priceUSD = priceUSD
        self.priceBTC = priceBTC
    }
    
    func initialSetupElectricity() {
        let image = self.electricityButtonIsSelected ? UIImage(named: "cell_checkmark"): UIImage(named:"Slected")
        self.view.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(hideKeyboard)))
        self.currencyLabbel.setLocalizableText(Locale.appCurrency + "/kWh")
        self.USDLabel.setLocalizableText(Locale.appCurrency)
        self.electricityView.layer.cornerRadius = 10
        self.electricityCostLabbel.changeFontSize(to: 15)
        self.costFor1hr.text = "electricityCost".localized()
        self.electricityCostLabbel.text = "includeElectricityCost".localized()
        self.electricityCunsoptionLabel.text = "electricityConsumption".localized() + " " + "(\("1" + "hr".localized()))"
        self.electricityPricefor1Kwh.text = "electricityPrice".localized()
        self.electricityButton.addTarget(self, action: #selector(electricityButtonAction), for: .touchUpInside)
        self.electricityButton.setImage(image, for: .normal)
        
        self.USDTextField.addTarget(self, action: #selector(calculateEstimations), for: .editingChanged)
        self.kWhTextField.addTarget(self, action: #selector(calculateEstimations), for: .editingChanged)
        
    }
    
    @objc func electricityButtonAction() {
        self.electricityButtonIsSelected.toggle()
        self.electricityButton.setImage(self.electricityButtonIsSelected ? UIImage(named: "cell_checkmark"): UIImage(named:"Slected"), for: .normal)
        self.calculateEstimations()
    }
    
}

//MARK: - Helper
struct EstimationFilter: Codable {
    var type: String?
    var name: String?
    var types: [String]?
    var names: [String]?
    
    init() {}
    
    init(data: Data?) {
        let decoder = JSONDecoder()
        if let data = data,
           let filter = try? decoder.decode(EstimationFilter.self, from: data) {
            self = filter
        } else {
            self.init()
        }
    }
    
    func encode() -> Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }
    
    mutating func configType(_ index: Int) {
        type = types?[index]
    }
    
    mutating func configName(_ index: Int) {
        name = names?[index]
    }
    
    var isEmpty: Bool {
        return type == nil && name == nil
    }
    
}


