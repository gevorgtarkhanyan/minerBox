//
//  AccountAddAlertViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/4/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class AccountAddAlertViewController: BaseViewController {

    // MARK: - Views
    @IBOutlet fileprivate weak var middleView: UIView!

    @IBOutlet fileprivate weak var alertTypeLabel: BaseLabel!
    @IBOutlet fileprivate weak var currentValueLabel: BaseLabel!
    @IBOutlet fileprivate weak var currentValueButton: UIButton!
    
    @IBOutlet fileprivate weak var speedLabel: BaseLabel!
    @IBOutlet fileprivate weak var comparisionButton: ActionSheetButton!
    @IBOutlet fileprivate weak var selectedValueTextField: BaseTextField!
    @IBOutlet fileprivate weak var hsNameLabel: BaseLabel!
    
    @IBOutlet fileprivate weak var repeatLabel: BaseLabel!
    @IBOutlet fileprivate weak var repeatSwitch: BaseSwitch!

    @IBOutlet fileprivate weak var enabledLabel: BaseLabel!
    @IBOutlet fileprivate weak var enabledSwitch: BaseSwitch!
    @IBOutlet weak var selectHashrateButton: ActionSheetButton!
    
    // MARK: - Properties
    fileprivate var currentValue = 0.0
    fileprivate var currentValue2 = 0.0
    fileprivate var alertTypeNumber = 0
    fileprivate var account: PoolAccountModel!
    fileprivate var currentAlert: PoolAlertModel?
    fileprivate var alertType: AccountAlertType = .hashrate
    fileprivate var comparision: AlertComparisionType = .lessThan
    fileprivate var hashrateTypes: AddAccountHashrateTypes = .reported
    fileprivate var editableText: String?
    fileprivate var currentSpeedValue: String?
    fileprivate var checkMarkIsSelected = false
    private var isCurrentTextEdit = false
    fileprivate let alertButton = ActionSheetButton()
    fileprivate var saveButton: UIBarButtonItem!
    fileprivate var value = 0.0
    private var accountSettings = PoolSettingsModel(json: NSDictionary())
    fileprivate var useReportedHashrate: Bool {
        guard let pool = DatabaseManager.shared.getPool(id: account.poolType) else { return false }
        
        if pool.subItems.count > 0 && pool.subItems[account.poolSubItem].extRepHash != -1 {
            return true
        } else {
            return pool.extRepHash
        }
        
    }
    // MARK: - Static
    static func initializeStoryboard() -> AccountAddAlertViewController? {
        return UIStoryboard(name: "AccountDetails", bundle: nil).instantiateViewController(withIdentifier: AccountAddAlertViewController.name) as? AccountAddAlertViewController
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad() 
        startupSetup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = saveButton
//        saveButton.isEnabled = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationItem.rightBarButtonItem = nil
    }

    override func languageChanged() {
        var title = [""]
        saveButton?.title = "save".localized()

        repeatLabel.setLocalizableText("repeat")
        enabledLabel.setLocalizableText("enabled")
        
        if let _ = currentAlert { // Edit
            switch alertType {
            case .hashrate:
                title = ["edit_hashrate_alert".localized()]
                selectHashrateButton.isHidden = true
            case .worker:
                title = ["edit_worker_alert".localized()]
            case .reportedHashrate:
                title = ["edit_reportedHashrate_alert".localized()]
                selectHashrateButton.isHidden = true
            }
        } else { // Add
            switch alertType {
            case .hashrate:
                title = ["add_hashrate_alert".localized()]
            case .worker:
                title = ["add_worker_alert".localized()]
            case .reportedHashrate:
                title = ["add_hashrate_alert".localized()]
            }
        }
        setCustomTitles(title)
    }
}

// MARK: - Startup default setup
extension AccountAddAlertViewController {
    fileprivate func startupSetup() {
        setupUI()
        configLabels()
        selectedValueTextField.delegate = self

        saveButton = UIBarButtonItem(title: "save".localized(), style: .done, target: self, action: #selector(saveButtonAction(_:)))
        currentValueButton.addTarget(self, action: #selector(currentButtonAction), for: .touchUpInside)
        selectedValueTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        
        saveButton.isEnabled = currentAlert != nil ? false : true
        
        if alertType.rawValue == "workers" {
            selectHashrateButton.isHidden = true
        }
    }
    
    fileprivate func configLabels() {
        switch alertType {
            
        case .hashrate:
            speedLabel.setLocalizableText("speed")
            alertTypeLabel.setLocalizableText("hashrate")
            if !useReportedHashrate {
                selectHashrateButton.isUserInteractionEnabled = false
                selectHashrateButton.backgroundColor = darkMode ? .darkGray : .lightGray
            }
            selectedValueTextField.keyboardType = .decimalPad
            currentValueLabel.setLocalizableText(currentValue.textFromHashrate(account: account))
            value = currentAlert?.value ?? currentValue
            selectedValueTextField.text = (currentAlert?.value ?? currentValue).textFromHashrate(withLetters: false,account: account)
            currentSpeedValue = (currentAlert?.value ?? currentValue).textFromHashrate(withLetters: false,account: account)
            let hsName = (currentAlert?.value ?? currentValue).textFromHashrate(account: account)
            let fullHsArr = hsName.components(separatedBy: " ")
            if fullHsArr.count == 2 {
                hsNameLabel.text = fullHsArr[1]
            }
        case .worker:
            speedLabel.setLocalizableText("count")
            alertTypeLabel.setLocalizableText("current_workers_count")
            selectedValueTextField.keyboardType = .numberPad
            currentValueLabel.setLocalizableText(currentValue.getFormatedString(maximumFractionDigits: 3))
        
            selectedValueTextField.text = (currentAlert?.value ?? currentValue).getFormatedString(maximumFractionDigits: 3)
            value = currentAlert?.value ?? currentValue
            currentSpeedValue = (currentAlert?.value ?? currentValue).getFormatedString(maximumFractionDigits: 3)
            hsNameLabel.text = nil
        case .reportedHashrate:
            speedLabel.setLocalizableText("speed")
            !useReportedHashrate || alertType.rawValue == "workers" || currentAlert?.value != nil ?  alertTypeLabel.setLocalizableText("current_reportedHashrate") : alertTypeLabel.setLocalizableText("hashrate")
            selectedValueTextField.keyboardType = .decimalPad
            currentValueLabel.setLocalizableText(currentValue2.textFromHashrate(account: account))
            value = currentAlert?.value ?? currentValue2
            selectedValueTextField.text = (currentAlert?.value ?? currentValue2).textFromHashrate(withLetters: false,account: account)
            currentSpeedValue = (currentAlert?.value ?? currentValue2).textFromHashrate(withLetters: false,account: account)
            let hsName = (currentAlert?.value ?? currentValue).textFromHashrate(account: account)
            let fullHsArr = hsName.components(separatedBy: " ")
            if fullHsArr.count == 2 {
                hsNameLabel.text = fullHsArr[1]
            }
        }
    }
}

// MARK: - Setup UI
extension AccountAddAlertViewController {
    fileprivate func setupUI() {
        middleView.clipsToBounds = true
        middleView.layer.cornerRadius = 10
        let val: CGFloat = 31
        currentValueButton.imageEdgeInsets = UIEdgeInsets(top: val, left: val, bottom: val, right: val)

        configComparisionButton()
        configAlertButtons()
        configHashrateTypesButton()
    }

    
    fileprivate func changeHashrateButton(to type: AddAccountHashrateTypes) {
        hashrateTypes = type
        selectHashrateButton.setTitle(hashrateTypes.rawValue.localized(), for: .normal)
    }
    
    fileprivate func configHashrateTypesButton() {
        selectHashrateButton.delegate = self
        selectHashrateButton.clipsToBounds = true
        selectHashrateButton.layer.cornerRadius = 8
        selectHashrateButton.setLocalizedTitle(hashrateTypes.rawValue)
        selectHashrateButton.reportedHashrate(Bool: useReportedHashrate)
        selectHashrateButton.setData(controller: tabBarController ?? self, type: .addAlert)
        if alertType == .hashrate {
            changeHashrateButton(to: AddAccountHashrateTypes.current)
        } else {
            changeHashrateButton(to: AddAccountHashrateTypes.reported)
        }
    }
    
    fileprivate func configComparisionButton() {
        comparisionButton.delegate = self

        comparisionButton.clipsToBounds = true
        comparisionButton.layer.cornerRadius = 8
        comparisionButton.setData(controller: tabBarController ?? self, type: .comparision)

        if let alert = currentAlert {
            changeComparision(to: alert.comparison ? .lessThan : .greatherThan)
        } else {
            changeComparision(to: .lessThan)
        }

        comparisionButton.setLocalizedTitle(comparision.rawValue)
    }

    fileprivate func configAlertButtons() {
        repeatSwitch.isOn = currentAlert?.isRepeat ?? true
        enabledSwitch.isOn = currentAlert?.isEnabled ?? true
        repeatSwitch.addTarget(self, action: #selector(oldParametrDidChange), for: .touchUpInside)
        enabledSwitch.addTarget(self, action: #selector(oldParametrDidChange), for: .touchUpInside)
    }
    
    @objc private func oldParametrDidChange() {
        guard currentAlert != nil else { return }
        
        if checkMarkIsSelected {
            var lastValue = ""
            switch alertType {
            case .hashrate:
                lastValue = (currentAlert?.value.textFromHashrate(difficulty: true))!
                lastValue.removeLast(2)
            case .worker:
                lastValue = (currentAlert?.value.getString())!
            case .reportedHashrate:
                lastValue = (currentAlert?.value.textFromHashrate(difficulty: true))!
                lastValue.removeLast(2)
            }
            
            guard selectedValueTextField.text == lastValue else {
                
                self.saveButton.isEnabled = true
                return
            }
        }
        
        if currentAlert!.comparison && comparision != .lessThan  {
            self.saveButton.isEnabled = true
            return
        }
        if !currentAlert!.comparison && comparision != .greatherThan {
            self.saveButton.isEnabled = true
            return
        }
        
        if currentAlert?.isEnabled != enabledSwitch.isOn || currentAlert?.isRepeat != repeatSwitch.isOn || isCurrentTextEdit {
            self.saveButton.isEnabled = true
        } else {
            self.saveButton.isEnabled = false
        }
    }
}

// MARK: - Actions
extension AccountAddAlertViewController {
    fileprivate func changeComparision(to type: AlertComparisionType) {
        comparision = type
        comparisionButton.setTitle(comparision.rawValue.localized(), for: .normal)
    }

    @objc fileprivate func saveButtonAction(_ sender: UIBarButtonItem) {
        guard let user = self.user, (user.isSubscribted || user.isPromoUser) else {
            goToSubscriptionPage()
            return
        }

        guard let text = selectedValueTextField.text, let textValue = text.toDouble() else {
            self.showToastAlert("", message: "Enter valid value".localized())
            return
        }

        var count = textValue
        if alertType == .hashrate {
            let hashrate = currentValue.textFromHashrate(account: account)
            let hsName = hsNameLabel.text != nil ? hsNameLabel.text! : hashrate
            if hsName.contains("KH/s") || hsName.contains("K\(account.poolTypeHsUnit)") || hsName.contains("K\(account.poolSubItemHsUnit)") {
                count *= 1_000
            } else if hsName.contains("MH/s") || hsName.contains("M\(account.poolTypeHsUnit)") || hsName.contains("M\(account.poolSubItemHsUnit)"){
                count *= 1_000_000
            } else if hsName.contains("GH/s") || hsName.contains("G\(account.poolTypeHsUnit)") || hsName.contains("G\(account.poolSubItemHsUnit)") {
                count *= 1_000_000_000
            } else if hsName.contains("TH/s") || hsName.contains("T\(account.poolTypeHsUnit)") || hsName.contains("T\(account.poolSubItemHsUnit)") {
                count *= 1_000_000_000_000
            } else if hsName.contains("PH/s") || hsName.contains("P\(account.poolTypeHsUnit)") || hsName.contains("P\(account.poolSubItemHsUnit)") {
                count *= 1_000_000_000_000_000
            } else if hsName.contains("EH/s") || hsName.contains("E\(account.poolTypeHsUnit)") || hsName.contains("E\(account.poolSubItemHsUnit)") {
                count *= 1_000_000_000_000_000_000
            } else if hsName.contains("ZH/s") || hsName.contains("Z\(account.poolTypeHsUnit)") || hsName.contains("Z\(account.poolSubItemHsUnit)") {
                count *= 1_000_000_000_000_000_000_000
            }
//            else if hsName.contains("YH/s") || hsName.contains("Y\(account.poolTypeHsUnit)") || hsName.contains("Y\(account.poolSubItemHsUnit)") {
//                count *= 1_000_000_000_000_000_000_000_000//999_999_999_999_999_983_222_784
//            }
        }
        if alertType == .reportedHashrate {
            let hashrate = currentValue2.textFromHashrate(account: account)
            let hsName = hsNameLabel.text != nil ? hsNameLabel.text! : hashrate
            if hsName.contains("KH/s") || hsName.contains("K\(account.poolTypeHsUnit)") || hsName.contains("K\(account.poolSubItemHsUnit)") {
                count *= 1_000
            } else if hsName.contains("MH/s") || hsName.contains("M\(account.poolTypeHsUnit)") || hsName.contains("M\(account.poolSubItemHsUnit)"){
                count *= 1_000_000
            } else if hsName.contains("GH/s") || hsName.contains("G\(account.poolTypeHsUnit)") || hsName.contains("G\(account.poolSubItemHsUnit)") {
                count *= 1_000_000_000
            } else if hsName.contains("TH/s") || hsName.contains("T\(account.poolTypeHsUnit)") || hsName.contains("T\(account.poolSubItemHsUnit)") {
                count *= 1_000_000_000_000
            } else if hsName.contains("PH/s") || hsName.contains("P\(account.poolTypeHsUnit)") || hsName.contains("P\(account.poolSubItemHsUnit)") {
                count *= 1_000_000_000_000_000
            } else if hsName.contains("EH/s") || hsName.contains("E\(account.poolTypeHsUnit)") || hsName.contains("E\(account.poolSubItemHsUnit)") {
                count *= 1_000_000_000_000_000_000
            } else if hsName.contains("ZH/s") || hsName.contains("Z\(account.poolTypeHsUnit)") || hsName.contains("Z\(account.poolSubItemHsUnit)") {
                count *= 1_000_000_000_000_000_000_000
            }
//            else if hsName.contains("YH/s") || hsName.contains("Y\(account.poolTypeHsUnit)") || hsName.contains("Y\(account.poolSubItemHsUnit)") {
//                count *= 1_000_000_000_000_000_000_000_000//999_999_999_999_999_983_222_784
//            }
        }
        Loading.shared.startLoading(ignoringActions: true, for: self.view)

        let comparisionNumber = comparision == .greatherThan ? 0 : 1
        var alertTypeNumber = 0
        switch alertType {
            
        case .hashrate:
            alertTypeNumber = 0
        case .worker:
            alertTypeNumber = 1
        case .reportedHashrate:
            alertTypeNumber = 3
        }
        saveButton.isEnabled = false

        if let editableAlert = currentAlert { // Edit alert
            PoolRequestService.shared.updatePoolAlert(alertId: editableAlert.id, count: value, isRepeat: repeatSwitch.isOn, isEnabled: enabledSwitch.isOn, comparison: comparisionNumber, poolType: account.poolType, success: {
                Loading.shared.endLoading(for: self.view)
                self.showToastAlert("", message: "alert_updated".localized())
                NotificationCenter.default.post(name: NSNotification.Name(Constants.accountAlertAdded), object: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.navigationController?.popViewController(animated: true)
                })
            }) { (error) in
                Loading.shared.endLoading(for: self.view)
                self.showAlertView("", message: error.localized(), completion: nil)
            }
        } else { // Add alert
            PoolRequestService.shared.addAccountAlert(poolId: account.id, count: value, isRepeat: repeatSwitch.isOn, isEnabled: enabledSwitch.isOn, comparison: comparisionNumber, alertType: alertTypeNumber, poolType: account.poolType, success: {
                
                Loading.shared.endLoading(for: self.view)
                self.showToastAlert("", message: "alert_added".localized())
                NotificationCenter.default.post(name: NSNotification.Name(Constants.accountAlertAdded), object: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.navigationController?.popViewController(animated: true)
                })
                self.saveButton.isEnabled = true
            }) { (error) in
                self.saveButton.isEnabled = true
                Loading.shared.endLoading(for: self.view)
                self.showAlertView("", message: error.localized(), completion: nil)
            }
        }
    }

    @objc private func currentButtonAction(sender: UIButton) {
        currentValueButton.isUserInteractionEnabled = false
        if checkMarkIsSelected == false {
        Loading.shared.startLoading()
        PoolRequestService.shared.getAccountSettings(poolId: account.id, poolType: account.poolType, success: { (accountsettings) in
            self.accountSettings = accountsettings
            self.updateCurrentValue(sender: sender)
            Loading.shared.endLoading()
            self.currentValueButton.isUserInteractionEnabled = true
        }) { (error) in
            Loading.shared.endLoading()
            self.currentValueButton.isUserInteractionEnabled = true
            self.showAlertView("", message: error, completion: nil)
        }
        } else {
            self.currentValueButton.isUserInteractionEnabled = true
            self.updateCurrentValue(sender: sender)
        }
        
    }
    
    fileprivate func updateCurrentValue(sender: UIButton) {
        
        switch alertType {
            
        case .hashrate:
            
            currentValue = accountSettings.currentHashrate
            
            var val: Double = 0
            
            if sender.tag == 0 {
                selectedValueTextField.text = currentValue.textFromHashrate(withLetters: false,account: account)
                val = currentValue
            } else if let currentAlert = currentAlert {
                if editableText != nil {
                    selectedValueTextField.text = editableText?.toDouble()?.textFromHashrate(withLetters: false,account: account)
                    val = editableText?.toDouble() ?? 0
                } else {
                    selectedValueTextField.text = currentAlert.value.textFromHashrate(withLetters: false,account: account)
                    val = currentAlert.value
                }
            }
            
            let hsName = val.textFromHashrate(account: account)
            let fullHsArr = hsName.components(separatedBy: " ")
            if fullHsArr.count == 2 {
                hsNameLabel.text = fullHsArr[1]
            }
        case .worker:
            currentValue = max(accountSettings.activeWorkers, 0)
            if sender.tag == 0 {
                selectedValueTextField.text = currentValue.getFormatedString(maximumFractionDigits: 3)
            } else if let currentAlert = currentAlert {
                if editableText != nil {
                    selectedValueTextField.text = editableText
                } else {
                    selectedValueTextField.text = currentAlert.value.getFormatedString(maximumFractionDigits: 3)
                }
            }
            hsNameLabel.text = nil
        case .reportedHashrate:
            currentValue2 = max(accountSettings.reportedHashrate, 0)
            var val: Double = 0
            
            if sender.tag == 0 {
                selectedValueTextField.text = currentValue2.textFromHashrate(withLetters: false,account: account)
                val = currentValue2
            } else if let currentAlert = currentAlert {
                if editableText != nil {
                    selectedValueTextField.text = editableText?.toDouble()?.textFromHashrate(withLetters: false,account: account)
                    val = editableText?.toDouble() ?? 0
                } else {
                    selectedValueTextField.text = currentAlert.value.textFromHashrate(withLetters: false,account: account)
                    val = currentAlert.value
                }
            }
            
            let hsName = val.textFromHashrate(account: account)
            let fullHsArr = hsName.components(separatedBy: " ")
            if fullHsArr.count == 2 {
                hsNameLabel.text = fullHsArr[1]
            }
        }
        
        sender.tag = sender.tag == 0 ? 1 : 0
        let imageName = sender.tag == 0 ? "Slected" : "cell_checkmark"
        checkMarkIsSelected = sender.tag == 0 ? false : true
        currentValueButton.setImage(UIImage(named: imageName), for: .normal)
        oldParametrDidChange()
    }
    
    @objc private func textFieldEditingChanged(sender: BaseTextField) {
        if let _ = currentAlert { // isEditMode
            isCurrentTextEdit = currentSpeedValue != sender.text
            oldParametrDidChange()
        } else {
            saveButton.isEnabled = true
        }
        sender.getFormatedText()
            
        var editTextForHashrate = sender.text?.toDouble() ?? 0
        
        switch alertType {
            
        case .hashrate:
            let hashrate = currentValue.textFromHashrate(account: account)
            let hsName = hsNameLabel.text != nil ? hsNameLabel.text! : hashrate
            if hsName.contains("KH/s") || hsName.contains("K\(account.poolTypeHsUnit)") || hsName.contains("K\(account.poolSubItemHsUnit)") {
                editTextForHashrate *= 1_000
            } else if hsName.contains("MH/s") || hsName.contains("M\(account.poolTypeHsUnit)") || hsName.contains("M\(account.poolSubItemHsUnit)"){
                editTextForHashrate *= 1_000_000
            } else if hsName.contains("GH/s") || hsName.contains("G\(account.poolTypeHsUnit)") || hsName.contains("G\(account.poolSubItemHsUnit)") {
                editTextForHashrate *= 1_000_000_000
            } else if hsName.contains("TH/s") || hsName.contains("T\(account.poolTypeHsUnit)") || hsName.contains("T\(account.poolSubItemHsUnit)") {
                editTextForHashrate *= 1_000_000_000_000
            } else if hsName.contains("PH/s") || hsName.contains("P\(account.poolTypeHsUnit)") || hsName.contains("P\(account.poolSubItemHsUnit)") {
                editTextForHashrate *= 1_000_000_000_000_000
            } else if hsName.contains("EH/s") || hsName.contains("E\(account.poolTypeHsUnit)") || hsName.contains("E\(account.poolSubItemHsUnit)") {
                editTextForHashrate *= 1_000_000_000_000_000_000
            } else if hsName.contains("ZH/s") || hsName.contains("Z\(account.poolTypeHsUnit)") || hsName.contains("Z\(account.poolSubItemHsUnit)") {
                editTextForHashrate *= 1_000_000_000_000_000_000_000
            }
            editableText = editTextForHashrate.getString()
            value = editableText?.toDouble() ?? 0
        case .worker:
            editableText = sender.text
            value = editableText?.toDouble() ?? 0
        case .reportedHashrate:
            let hashrate = currentValue2.textFromHashrate(account: account)
            let hsName = hsNameLabel.text != nil ? hsNameLabel.text! : hashrate
            if hsName.contains("KH/s") || hsName.contains("K\(account.poolTypeHsUnit)") || hsName.contains("K\(account.poolSubItemHsUnit)") {
                editTextForHashrate *= 1_000
            } else if hsName.contains("MH/s") || hsName.contains("M\(account.poolTypeHsUnit)") || hsName.contains("M\(account.poolSubItemHsUnit)"){
                editTextForHashrate *= 1_000_000
            } else if hsName.contains("GH/s") || hsName.contains("G\(account.poolTypeHsUnit)") || hsName.contains("G\(account.poolSubItemHsUnit)") {
                editTextForHashrate *= 1_000_000_000
            } else if hsName.contains("TH/s") || hsName.contains("T\(account.poolTypeHsUnit)") || hsName.contains("T\(account.poolSubItemHsUnit)") {
                editTextForHashrate *= 1_000_000_000_000
            } else if hsName.contains("PH/s") || hsName.contains("P\(account.poolTypeHsUnit)") || hsName.contains("P\(account.poolSubItemHsUnit)") {
                editTextForHashrate *= 1_000_000_000_000_000
            } else if hsName.contains("EH/s") || hsName.contains("E\(account.poolTypeHsUnit)") || hsName.contains("E\(account.poolSubItemHsUnit)") {
                editTextForHashrate *= 1_000_000_000_000_000_000
            } else if hsName.contains("ZH/s") || hsName.contains("Z\(account.poolTypeHsUnit)") || hsName.contains("Z\(account.poolSubItemHsUnit)") {
                editTextForHashrate *= 1_000_000_000_000_000_000_000
            }
            editableText = editTextForHashrate.getString()
            value = editableText?.toDouble() ?? 0
        }
        currentValueButtonUnSelect()
    }
    
    private func currentValueButtonUnSelect() {
        currentValueButton.tag = 0
        currentValueButton.setImage(UIImage(named: "Slected"), for: .normal)
    }
    
}

//MARK: -- TextField delegate methods
extension AccountAddAlertViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return selectedValueTextField.allowOnlyNumbersForConverter(string: string)
    }
}

// MARK: - Set data
extension AccountAddAlertViewController {
    public func setData(account: PoolAccountModel, alertType: AccountAlertType, currentAlert: PoolAlertModel?, currentValue: Double, currentValue2 : Double) {
        self.account = account
        self.alertType = alertType
        self.currentAlert = currentAlert
        self.currentValue = currentValue
        self.currentValue2 = currentValue2
    }
}

// MARK: - Comparision selection delegate
extension AccountAddAlertViewController: ActionSheetButtonDelegate {
    func hashrateTypesSelected(type: AddAccountHashrateTypes) {
        changeHashrateButton(to: type)
        switch hashrateTypes {
            
        case .current:
            alertType = .hashrate
        case .reported:
            alertType = .reportedHashrate
        }
        startupSetup()
        languageChanged()
        
    }
    
    func comparisionSelected(type: AlertComparisionType) {
        changeComparision(to: type)
        oldParametrDidChange()
    }

    func alertSelected(type: AccountAlertType) { }
}
