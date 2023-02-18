//
//  RewardsViewController.swift
//  MinerBox
//
//  Created by Marina on 4/7/20.
//  Copyright © 2020 WitPlex. All rights reserved.
//


import UIKit

class RewardsViewController: BaseViewController {
    
    // MARK: - Views
    @IBOutlet fileprivate weak var middleView: BaseView!
    
    @IBOutlet fileprivate weak var periodLabel: BaseLabel!
    @IBOutlet fileprivate weak var blocksLabel: BaseLabel!
    @IBOutlet fileprivate weak var luckLabel: BaseLabel!
    @IBOutlet fileprivate weak var coinLabel: BaseLabel!
    
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    @IBOutlet fileprivate weak var tableHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var currencyLabbel: BaseLabel!
    @IBOutlet weak var electricityView: BaseView!
    
    @IBOutlet weak var electricityButton: UIButton!
    
    @IBOutlet weak var electricityCostLabbel: BaseLabel!
    @IBOutlet var costFor1Hr: BaseLabel!
    @IBOutlet var electricityConsuptionLabel: BaseLabel!
    @IBOutlet var electricityPriceFor1Kwh: BaseLabel!
    @IBOutlet var costLabel: BaseLabel!
    
    @IBOutlet var kWhLabel: BaseLabel!
    @IBOutlet var USDLabel: BaseLabel!
    @IBOutlet var kWhTextField: BaseTextField!
    @IBOutlet var USDTextField: BaseTextField!
    
    @IBOutlet var USDTextFieldView: UIView!
    @IBOutlet var kWhTextFieldView: UIView!
    
    @IBOutlet var electricityViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var electricityBottomConstraint: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    
    
    // MARK: - Properties
    fileprivate var rewards = [Reward]()
    fileprivate var coinsValue = [Double]()
    fileprivate var priceUSD = 0.0
    fileprivate var currency = ""
    fileprivate var coinId = ""
    fileprivate var rewardsBlockExist = false
    
    fileprivate var electricityButtonIsSelected = false
    fileprivate var viewDidDisappear = false
    
    
    // MARK: - Static
    static func initializeStoryboard() -> RewardsViewController? {
        return UIStoryboard(name: "AccountDetails", bundle: nil).instantiateViewController(withIdentifier: RewardsViewController.name) as? RewardsViewController
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
    
    @IBAction func changeElectriCityText(_ sender: UITextField) {
        sender.getFormatedText()
    }
    
    @IBAction func ChangeElectricityUSD(_ sender: UITextField) {
        sender.getFormatedText()
    }
    
}

// MARK: - Startup default setup
extension RewardsViewController {
    fileprivate func startupSetup() {
        getPageState()
        middleView.layer.cornerRadius = 10
        tableHeightConstraint.constant = CGFloat(rewards.count) * 30
        configLabels()
        initialSetupElectricity()
        calculateRewards()
        
        middleView.layer.cornerRadius = 10
        kWhTextField.backgroundColor = .clear
        USDTextField.backgroundColor = .clear
        kWhTextField.borderStyle = .none
        USDTextField.borderStyle = .none
        kWhTextFieldView.backgroundColor = .textFieldBackgorund
        USDTextFieldView.backgroundColor = .textFieldBackgorund
        kWhTextField.delegate = self
        USDTextField.delegate = self
        
        
    }
    
    fileprivate func configLabels() {
        if let reward = rewards.first, reward.luckPer == -1 {
            luckLabel?.removeFromSuperview()
        }
        
        rewardsBlockExist = !(rewards.contains { $0.blocks == nil })
        if !rewardsBlockExist {
            blocksLabel.removeFromSuperview()
        }
        
        periodLabel.setLocalizableText("period")
        blocksLabel.setLocalizableText("blocks")
        luckLabel.setLocalizableText("luck")
        luckLabel?.addSymbolAfterText(" (%)")
        coinLabel.setLocalizableText(currency)
    }
}

// MARK: - TableView methods
extension RewardsViewController: UITableViewDataSource, UITableViewDelegate, ConverterButtonDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return rewards.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RewardsTableViewCell.name) as! RewardsTableViewCell
        let reward = rewards[indexPath.row]
        
        cell.delegate = self
        cell.setData(reward: reward, indexPath: indexPath, coinsValue: coinsValue, rewardsBlockExist: rewardsBlockExist)
        
        return cell
    }
    
    // ConverterButtonDelegate
    func converterButtonTapped(indexPath: IndexPath) {
        let sb = UIStoryboard(name: "More", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ConverterViewController") as! ConverterViewController
        
        vc.headerCoinId = coinId
        let numSrt = self.coinsValue[indexPath.row].getString()
        vc.multiplier = numSrt.toDouble() ?? 1
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

//MARK: - Page State
extension RewardsViewController {
    fileprivate func savePageState() {
        guard let account = Cacher.shared.account else {  return }
        
        UserDefaults.shared.set(electricityButtonIsSelected, forKey: account.keyPath + "rewardsElectricityButtonIsSelected")
        UserDefaults.shared.set(Locale.appCurrency, forKey: account.keyPath + "rewardsElectricityLocaleAppCurrency")
        UserDefaults.shared.set(USDTextField.text?.toDouble() , forKey: account.keyPath + "rewardsElectricityValue")
        UserDefaults.shared.set(kWhTextField.text?.toDouble() , forKey: account.keyPath + "rewardsElectricitykWhValue")
    }
    
    fileprivate func getPageState() {
        guard let account = Cacher.shared.account else {  return }
        
        self.electricityButtonIsSelected = UserDefaults.shared.bool(forKey: account.keyPath + "rewardsElectricityButtonIsSelected")
        var valueStr = UserDefaults.shared.value(forKey: account.keyPath + "rewardsElectricityValue") as? Double ?? 0
        let kWHvalueStr = UserDefaults.shared.value(forKey: account.keyPath + "rewardsElectricitykWhValue") as? Double ?? 0
        let previewCurrency = UserDefaults.shared.value(forKey: account.keyPath + "rewardsElectricityLocaleAppCurrency") as? String
        
        if previewCurrency != Locale.appCurrency {
            valueStr = 0
        }
        self.USDTextField.text = String(Double(valueStr).getString())
        self.kWhTextField.text = String(Double(kWHvalueStr).getString())
    }
}

extension RewardsViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let isNumber = CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
        let withDecimal = (
            string == NumberFormatter().decimalSeparator &&
            textField.text?.contains(string) == false
        )
        return isNumber || withDecimal
    }
}

// MARK: - Set data
extension RewardsViewController {
    public func setData(rewards: [Reward], currency: String, coinId: String,priceUSD: Double) {
        self.rewards = rewards
        self.currency = currency
        self.coinId = coinId
        self.priceUSD = priceUSD
    }
    
    func initialSetupElectricity() {
        let image = self.electricityButtonIsSelected ? UIImage(named: "cell_checkmark"): UIImage(named:"Slected")
        self.view.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(hideKeyboard)))
        self.currencyLabbel.setLocalizableText(Locale.appCurrency + "/kWh")
        self.electricityView.layer.cornerRadius = 10
        self.electricityCostLabbel.changeFontSize(to: 15)
        self.costFor1Hr.text = "electricityCost".localized()
        self.electricityCostLabbel.text = "includeElectricityCost".localized()
        self.electricityConsuptionLabel.text = "electricityConsumption".localized() + " " + "(\("1" + "hr".localized()))"
        self.electricityPriceFor1Kwh.text = "electricityPrice".localized()
        self.electricityButton.addTarget(self, action: #selector(electricityButtonAction), for: .touchUpInside)
        self.electricityButton.setImage(image, for: .normal)
//        self.electricityCostTextField.text = 0.getString()
        self.USDTextField.addTarget(self, action: #selector(calculateRewards), for: .editingChanged)
        self.kWhTextField.addTarget(self, action: #selector(calculateRewards), for: .editingChanged)
    }
    
    @objc func calculateRewards() {
        
        self.coinsValue.removeAll()
        
        self.costLabel.text = Double((String("\((kWhTextField.text!.toDouble() ?? 0) * (USDTextField.text!.toDouble() ?? 0))")))?.getString()
        
        if electricityButtonIsSelected {
            electricityViewHeightConstraint.constant = 117
            electricityBottomConstraint.constant = 10
        
            let electriCostPerHour = costLabel.text?.toDouble() ?? 0
            let myFloat =  electriCostPerHour / 3600 // electriCostPerSecond
            
            for reward in self.rewards {
                self.coinsValue.append(reward.amount - ((reward.period * myFloat ) / self.priceUSD))
            }
        } else {
            electricityViewHeightConstraint.constant = 0
            electricityBottomConstraint.constant = 0
            for reward in self.rewards {
                self.coinsValue.append(reward.amount)
            }
        }
        
        self.tableView.reloadData()
    }
    
    @objc func electricityButtonAction() {
        self.electricityButtonIsSelected.toggle()
        self.calculateRewards()
        self.electricityButton.setImage(self.electricityButtonIsSelected ? UIImage(named: "cell_checkmark"): UIImage(named:"Slected"), for: .normal)
    }
    
}

