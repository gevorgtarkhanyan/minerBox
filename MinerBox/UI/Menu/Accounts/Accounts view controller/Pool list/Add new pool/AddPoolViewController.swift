//
//  AddPoolViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 5/31/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class AddPoolViewController: BaseViewController {
    
    // MARK: - Views
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    @IBOutlet fileprivate weak var contentView: UIView!
    
    @IBOutlet fileprivate weak var poolImageView: UIImageView!
    @IBOutlet fileprivate weak var poolLabel: BaseLabel!
    
    @IBOutlet fileprivate weak var subPoolStack: UIStackView!
    @IBOutlet fileprivate weak var subPoolImageView: UIImageView!
    @IBOutlet fileprivate weak var subPoolLabel: BaseLabel!
    
    @IBOutlet fileprivate weak var apiKeyTextField: BaseTextField!
    @IBOutlet weak var invalidParametrForApiKey: UIImageView!
    @IBOutlet fileprivate weak var puidTextField: BaseTextField!
    @IBOutlet weak var invalidParametrForPuId: UIImageView!
    @IBOutlet weak var invalidParametrForExtra1: UIImageView!
    @IBOutlet weak var invalidParametrForExtra2: UIImageView!
    @IBOutlet fileprivate weak var labelTextField: BaseTextField!
    
    @IBOutlet fileprivate weak var statusCheckButton: BackgroundButton!
    
    @IBOutlet fileprivate weak var saveButton: BackgroundButton!
    
    @IBOutlet weak var guideTextView: UITextView!
    
    @IBOutlet weak var extra1ApiKeyView: UIView!
    @IBOutlet weak var extra1ApiKeyTextField: BaseTextField!
    @IBOutlet weak var extra2ApiKeyView: UIView!
    @IBOutlet weak var extra2ApiKeyTextField: BaseTextField!
    
    @IBOutlet weak var addPoolTableView: BaseTableView!
    @IBOutlet weak var addPoolTableViewHeighConstraits: NSLayoutConstraint!
    
    @IBOutlet weak var addressView: BaseView!
    @IBOutlet weak var addressImageView: BaseImageView!
    
    // MARK: - Properties
    fileprivate var pool: PoolTypeModel!
    fileprivate var subPool: SubPoolItem?
    fileprivate var rowHeight: CGFloat = 35
    fileprivate var subPoolName = ""
    
    fileprivate var poolId: Int?
    fileprivate var subPoolId: Int?
    fileprivate var oldAccount: PoolAccountModel?
    
    fileprivate var apiKeyPlaceHolder = ""
    fileprivate var apiKeyText = ""
    fileprivate var namePlaceHolder = ""
    fileprivate var nameText = ""
    fileprivate var extras: [Extra] = []
    fileprivate var showInvalidImage = false
    var oneOfTextIsChange:[String:Bool] = [:]
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard  oldAccount == nil else {
            self.saveButton.isEnabled = false
            self.saveButton.alpha = 0.4
            return
        }
    }
    
    override func languageChanged() {
        title = oldAccount == nil ? "new_account".localized() : "edit_account".localized()
    }
    
    func checkOldAccount() {
        guard oldAccount != nil else { return }
        
        if apiKeyText != oldAccount!.poolAccountId || nameText != oldAccount!.poolAccountLabel {
            self.saveButton.isEnabled = true
            self.saveButton.alpha = 1
            return
        }
        
        for (index,extra) in oldAccount!.accountExtras.enumerated() {
            if extra.extraValue != self.extras[index].text {
                self.saveButton.isEnabled = true
                self.saveButton.alpha = 1
                return
            }
        }
        self.saveButton.isEnabled = false
        self.saveButton.alpha = 0.4
    }
}

// MARK: - Default startup settings
extension AddPoolViewController {
    fileprivate func startupSetup() {
        getPool()
        setupUI()
        addObservers()
        addGestureToView()
    }
    
    private func setupTableView() {
        addPoolTableView.register(UINib(nibName: AddPoolTableViewCell.name, bundle: nil), forCellReuseIdentifier: AddPoolTableViewCell.name)
    }
    
    func addGestureToView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
        let walletTapted = UITapGestureRecognizer(target: self, action: #selector(goToAddressPage))
        self.addressView.addGestureRecognizer(walletTapted)
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}

// MARK: - Setup UI
extension AddPoolViewController {
    fileprivate func setupUI() {
        
        setupTableView()
        configTableViewConent()
        configButtons()
        configPoolInfo()
        configScrollView()
        configAddres()
    }
    
    fileprivate func configScrollView() {
        
        guideTextView.textColor = darkMode ? .white : .black
        guideTextView.backgroundColor =  darkMode ? .viewDarkBackground: .sectionHeaderLight
        guideTextView.font = UIFont.systemFont(ofSize: 12)
        guideTextView.roundCorners([.bottomLeft,.bottomRight,.topLeft,.topRight], radius: 5)
        let contentSize = self.guideTextView.sizeThatFits(self.guideTextView.bounds.size)
        let bottomInset = guideTextView.isHidden ? 0 : (contentSize.height * 1.5)

        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        
    }
    
    fileprivate func configPoolInfo() {
        if oldAccount == nil {
            guard let pool = self.pool else { return }
            poolLabel.setLocalizableText(pool.poolName)
            poolImageView.sd_setImage(with: URL(string: Constants.HttpUrlWithoutApi + pool.poolLogoImagePath), completed: nil)
            if  pool.guide != ""  {
                setGuidForPool(pool.guide)
            }
            
            guard let subPool = self.subPool else {
                subPoolStack.removeFromSuperview()
                return
            }
            if  subPool.guide != ""  {
                setGuidForPool(subPool.guide)
            }
            subPoolLabel.setLocalizableText(subPool.name)
            subPoolImageView.sd_setImage(with: URL(string: Constants.HttpUrlWithoutApi + subPool.coinIconUrl), completed: nil)
        } else {
            guard let oldPool = self.oldAccount, let pool = DatabaseManager.shared.getPool(id: oldPool.poolType) else { return }
            poolLabel.setLocalizableText(pool.poolName)
            poolImageView.sd_setImage(with: URL(string: Constants.HttpUrlWithoutApi + pool.poolLogoImagePath), completed: nil)
            
            if  pool.guide != ""  {
                setGuidForPool(pool.guide)
            }
            
            let subItem = pool.subPools.first { $0.id == oldPool.poolSubItem }
            guard let subPool = subItem else {
                subPoolStack.removeFromSuperview()
                return
            }
            if  subPool.guide != ""  {
                setGuidForPool(subPool.guide)
            }
            subPoolLabel.setLocalizableText(subPool.name)
            subPoolImageView.sd_setImage(with: URL(string: Constants.HttpUrlWithoutApi + subPool.coinIconUrl), completed: nil)
        }
    }
    
    fileprivate func configTableViewConent() {
        
        guard let pool = self.pool else { return }
        let subPool = self.subPool
        let defPlaceHolder =  "API key / Miner ID";
        
        
        if (subPool != nil) && (subPool!.placeholder != "") {
            self.apiKeyPlaceHolder = subPool!.placeholder
        }
        else if pool.placeholder != "" {
            self.apiKeyPlaceHolder = pool.placeholder
        }
        else {
            self.apiKeyPlaceHolder = defPlaceHolder
        }
        
        self.namePlaceHolder = "optional_input_label"
        
        if (subPool != nil) && (subPool!.extraDataIsExist) {
            for _extra in subPool!.extras!{
                let extra = Extra() //Not Realm Object
                extra.extraId = _extra.extraId
                extra.acceptChars = _extra.acceptChars
                extra.placeholder = _extra.placeholder
                extra.optional = _extra.optional
                self.extras.append(extra)
            }
        } else {
            for _extra in pool.extras{
                let extra = Extra() //Not Realm Object
                extra.extraId = _extra.extraId
                extra.acceptChars = _extra.acceptChars
                extra.placeholder = _extra.placeholder
                extra.optional = _extra.optional
                self.extras.append(extra)
            }
        }
        self.addPoolTableViewHeighConstraits.constant = CGFloat(self.extras.count + 2) * AddPoolTableViewCell.height
    
        guard oldAccount != nil else { return } // Add Old data in Table View
        
        self.apiKeyText = self.oldAccount!.poolAccountId
        self.nameText   = self.oldAccount!.poolAccountLabel
        
        for (index,accounExtra) in oldAccount!.accountExtras.enumerated() {
            self.extras[index].text = accounExtra.extraValue ?? ""
        }
    }
    
    fileprivate func configButtons() {
        // Status check button
        statusCheckButton.clipsToBounds = true
        statusCheckButton.layer.cornerRadius = 15
        statusCheckButton.changeFontSize(to: 17)
        statusCheckButton.setLocalizedTitle("status_check")
        statusCheckButton.changeFont(to: Constants.semiboldFont)
        statusCheckButton.addTarget(self, action: #selector(statusCheckButtonAction(_:)), for: .touchUpInside)
        
        // Save button
        saveButton.clipsToBounds = true
        saveButton.layer.cornerRadius = 15
        saveButton.changeFontSize(to: 17)
        saveButton.setLocalizedTitle("save_account")
        saveButton.changeFont(to: Constants.semiboldFont)
        saveButton.addTarget(self, action: #selector(saveButtonAction(_:)), for: .touchUpInside)
    }
    
    func configAddres(){
        self.addressView.roundCorners(radius: 4)
        self.addressImageView.image = UIImage(named:"wallet_icon")?.withRenderingMode(.alwaysTemplate)
        self.addressView.backgroundColor = darkMode ? .viewDarkBackground: .sectionHeaderLight
        self.addressImageView.tintColor = .appGreen
    }
}


// MARK: - UI actions
extension AddPoolViewController {
    
    @objc func goToAddressPage() {
        guard let addressVC = AddressViewController.initializeStoryboard() else { return }
        addressVC.delegate = self
        addressVC.subPoolId = self.subPoolId
        addressVC.poolType = self.pool.poolId
        addressVC.isSelectingMode = true
        navigationController?.pushViewController(addressVC, animated: true)
    }
    
    @objc fileprivate func statusCheckButtonAction(_ sender: BackgroundButton) {
        guard apiKeyText != "" else {
            animateCellTextView(indexRow: 0)
            return
        }
        
        
        
        // Check for extra api key
        for (index,extra) in self.extras.enumerated() {
            if !extra.optional {
            guard extra.text != "" else {
                animateCellTextView(indexRow: index + 1)
                return
            }
            }
            guard extra.text != extra.acceptChars else {
                informInvalidCell(indexRow: index + 1)
                return
            }
        }
        
        
        if oldAccount == nil {
            guard let poolId = self.poolId else { return }
            checkStatus(pool, apiKeyText, poolId, sender)
        } else {
            guard let oldPool = self.oldAccount, let pool = DatabaseManager.shared.getPool(id: oldPool.poolType) else { return }
            let poolId = oldPool.poolType
            checkStatus(pool, apiKeyText, poolId, sender)
        }
    }
    
    @objc  func invalidButtonAction() {
        self.showToastAlert("", message: "incorrect_symbol".localized())
    }
    
    @objc fileprivate func saveButtonAction(_ sender: BackgroundButton) {
        if showInvalidImage {
            self.showToastAlert("", message: "incorrect_symbol".localized())
        }
        
        guard apiKeyText != "" else {
            animateCellTextView(indexRow: 0)
            return
        }
        
        // Check for valid miner ID/api key
        guard let pool = self.pool else { return }
        if apiKeyText.containPoolSpecificSpecialCharacters(filter: pool.acceptChars) {
            informInvalidCell(indexRow: 0)
            self.showToastAlert("", message: "incorrect_symbol".localized())
            return
        }
        
        // Check for extra api key
        for (index,extra) in self.extras.enumerated() {
            if !extra.optional {
            guard extra.text != "" else {
                animateCellTextView(indexRow: index + 1)
                return
            }
            }
            guard extra.text != extra.acceptChars else {
                informInvalidCell(indexRow: index + 1)
                return
            }
        }
        
        guard let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") else { return }
        
        var optionalLabelCount = userDefaults.integer(forKey: "optionalLabelCount")
        var label = ""
        if nameText == "" {
            optionalLabelCount += 1
            label = "account \(optionalLabelCount)"
        } else {
            label = nameText
        }
        
        if oldAccount == nil {
            guard let poolId = self.poolId else { return }
            
            Loading.shared.startLoading(ignoringActions: true, for: self.view)
            PoolRequestService.shared.addPoolAccountRequest(apiKey: apiKeyText, poolId: poolId, subPoolId: subPoolId,extras: self.extras , label: label, success: {
                userDefaults.set(optionalLabelCount, forKey: "optionalLabelCount")
                self.showToastAlert("", message: "successfully_added".localized())
                NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.newPoolAdded), object: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.gotoAccounts()
                })
                Loading.shared.endLoading(for: self.view)
            }) { (error) in
                Loading.shared.endLoading(for: self.view)
                self.showAlertView("", message: error.localized(), completion: nil)
            }
        } else {
            guard let oldPool = self.oldAccount else { return }
            
            Loading.shared.startLoading(ignoringActions: true, for: self.view)
            PoolRequestService.shared.updatePoolAccountRequest(apiKey: apiKeyText, poolType: oldPool.poolType, poolId: oldPool.id,subPoolId: subPool?.id,extras: self.extras, label: label, success: {
                NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.newPoolAdded), object: nil)
                self.gotoAccounts()
                Loading.shared.endLoading(for: self.view)
            }) { (error) in
                Loading.shared.endLoading(for: self.view)
                self.showAlertView("", message: error.localized(), completion: nil)
            }
        }
    }
}

// MARK: - Default actions
extension AddPoolViewController {
    fileprivate func getPool() {
        guard let pools = DatabaseManager.shared.allPoolTypes else { return }
        
        if oldAccount == nil {
            pool = pools.first { $0.poolId == poolId }
            subPool = pool?.subPools.first { $0.id == subPoolId }
        } else {
            guard let oldPool = self.oldAccount else { return }
            pool = pools.first { $0.poolId == oldPool.poolType }
            subPool = pool?.subPools.first { $0.id == oldPool.poolSubItem }
        }
    }
    
    fileprivate func setPoolInfo(poolLabel: BaseLabel, pool: PoolTypeModel, poolImageView: UIImageView) {
        poolLabel.setLocalizableText(pool.poolName)
        
        if  pool.guide != ""  {
            guideTextView.attributedText = pool.guide.htmlToAttributedString
            guideTextView.textColor = darkMode ? .white : .black
            guideTextView.tintColor = .barSelectedItem
        }
        
        guard let imageUrl = URL(string: Constants.HttpUrlWithoutApi + "\(pool.poolLogoImagePath)") else { return }
        poolImageView.sd_setImage(with: imageUrl, completed: nil)
        
    }
    
    fileprivate func gotoAccounts() {
        guard let navigation = self.navigationController else { return }
        for controller in navigation.viewControllers {
            if let accountVC = controller as? AccountsViewController {
                navigation.popToViewController(accountVC, animated: true)
                return
            }
        }
    }
    
    fileprivate func checkStatus(_ pool: PoolTypeModel, _ apiKey: String, _ poolId: Int, _ sender: BackgroundButton) {
        
        Loading.shared.startLoading(ignoringActions: true, for: self.view)
        PoolRequestService.shared.checkAccountStatusRequest(apiKey: apiKey, poolId: poolId, subPoolId: subPoolId ?? -1,extras: self.extras , success: {
            sender.backgroundColor = .workerGreen
            Loading.shared.endLoading(for: self.view)
        }, failer: { (error) in
            sender.backgroundColor = .workerRed
            Loading.shared.endLoading(for: self.view)
            self.showAlertView("", message: error.localized(), completion: nil)
        })
    }
    
    override func keyboardFrameChanged(_ sender: Notification) {
        guard let userInfo = sender.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let contentSize = self.guideTextView.sizeThatFits(self.guideTextView.bounds.size)
        var bottomInset =  (self.view.frame.height - keyboardFrame.origin.y * 0.7) + contentSize.height
        if guideTextView.isHidden {
            bottomInset = (self.view.frame.height - keyboardFrame.origin.y * 0.7)
            
        }
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
    }
}

// MARK: - Set data
extension AddPoolViewController {
    public func setPoolInfo(poolId: Int, subPoolId: Int?) {
        self.poolId = poolId
        self.subPoolId = subPoolId
    }
    
    public func setAccountForEdit(_ account: PoolAccountModel) {
        self.oldAccount = account
        self.subPoolId = account.poolSubItem
    }
    
    fileprivate func setGuidForPool(_ guide: String){
        guideTextView.attributedText = guide.htmlAttributed(using: Constants.boldFont.withSize(10))
        guideTextView.textColor = darkMode ? .white : .black
        guideTextView.tintColor = .barSelectedItem
        guideTextView.isHidden = false
        guideTextView.textAlignment = .center
        
    }
}

// MARK: - Gesture recognizer delegate
extension AddPoolViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (gestureRecognizer.view is UIButton) == false && (gestureRecognizer.view is UITextField) == false
    }
}

// MARK: - TableView methods
extension AddPoolViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.extras.count + 2 //Api Text and Label Text
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: AddPoolTableViewCell.name) as! AddPoolTableViewCell
        
        if indexPath.row == 0 {   // First Cell
            cell.setData(placeHolder: self.apiKeyPlaceHolder,indexPath: indexPath, oldAccountText: self.apiKeyText )
            if cell.textField.text != "" {
            cell.copyButton?.isEnabled = true
            }
        } else if indexPath.row == self.extras.count + 1 {    // Last Cell
            cell.setData(placeHolder: self.namePlaceHolder,indexPath: indexPath, oldAccountText: self.nameText)
            if cell.textField.text != "" {
            cell.copyButton?.isEnabled = true
            }
        } else {
            if extras[indexPath.row - 1].optional {
                cell.setData(placeHolder: self.extras[indexPath.row - 1].placeholder + " " + "optional".localized(),indexPath: indexPath, oldAccountText: self.extras[indexPath.row - 1].text)
            } else {
            cell.setData(placeHolder: self.extras[indexPath.row - 1].placeholder,indexPath: indexPath, oldAccountText: self.extras[indexPath.row - 1].text)
            }
            if cell.textField.text != "" {
            cell.copyButton?.isEnabled = true
            }
        }
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return AddPoolTableViewCell.height
        
    }
    
    func animateCellTextView(indexRow: Int) {
        let cell = addPoolTableView.cellForRow(at: IndexPath(row: indexRow, section: 0)) as? AddPoolTableViewCell
        cell?.textField.animateWithShake()
    }
    
    func informInvalidCell(indexRow: Int) {
        // Check for valid miner ID/api key
        let cell = addPoolTableView.cellForRow(at: IndexPath(row:  indexRow, section: 0)) as? AddPoolTableViewCell
        if apiKeyText.containPoolSpecificSpecialCharacters(filter: pool.acceptChars) {
            if indexRow != self.extras.count + 1 {
            cell?.invalidParametrIcon.isHidden = false
            cell?.invalidIconConstraint.constant = 10
            cell?.copyButton?.isHidden = true
            }
//            self.showToastAlert("", message: "incorrect_symbol".localized())
        } else {
            if indexRow != self.extras.count + 1 {
            cell?.invalidParametrIcon.isHidden = true
            cell?.invalidIconConstraint.constant = 33
            cell?.copyButton?.isHidden = false
            }
        }
            }
}

// MARK: - AddPoolTableViewCellDelegate -

extension AddPoolViewController: AddPoolTableViewCellDelegate, AddressViewControllerDelegate {
    func addPoolTextFieldChange(for text: String, indexPath: IndexPath?) {
        
        guard  indexPath != nil else { return }
        
        switch indexPath?.row {
        case 0:
            self.apiKeyText = text
        case self.extras.count + 1:
            self.nameText = text
        default:
            self.extras[indexPath!.row - 1].text = text
        }
        self.checkOldAccount()
        let cell = addPoolTableView.cellForRow(at: IndexPath(row: indexPath!.row, section: 0)) as? AddPoolTableViewCell
        if text.containPoolSpecificSpecialCharacters(filter: pool.acceptChars) {
            if indexPath?.row != self.extras.count + 1 {
            cell?.invalidParametrIcon.isHidden = false
            cell?.invalidIconConstraint.constant = 10
            cell?.copyButton?.isHidden = true
            }
//            self.showToastAlert("", message: "incorrect_symbol".localized())
        } else {
            if indexPath?.row != self.extras.count + 1 {
            cell?.invalidParametrIcon.isHidden = true
            cell?.invalidIconConstraint.constant = 33
            cell?.copyButton?.isHidden = false
            cell?.copyButton?.setValueForCopy(text )
            }
        }

    }
    
    func invalidButtonAction(buttonAction: Bool) {
        if buttonAction {
            self.showToastAlert("", message: "incorrect_symbol".localized())
        }
    }
    
    func invalidImage(isHidden: Bool) {
        showInvalidImage = !isHidden
    }
    
    func selectAddres(address: AddressModel?) {
        guard address != nil else { return }
        self.apiKeyText = address!.credentials["address"] ?? ""
        for extra in self.extras {
            extra.text = address!.credentials[extra.extraId] ?? ""
        }
        self.addPoolTableView.reloadData()
    }
}

