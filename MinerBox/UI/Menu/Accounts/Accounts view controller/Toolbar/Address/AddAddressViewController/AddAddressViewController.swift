//
//  AddWalletViewController.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 10.02.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit


class AddAddressViewController: BaseViewController {
    
    //MARK: - Properties
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var typeImage: BaseImageView!
    @IBOutlet weak var typeLabel: BaseLabel!
    @IBOutlet weak var fieldTableView: BaseTableView!
    @IBOutlet weak var fieldTableViewHeightConstraits: NSLayoutConstraint!
    
    @IBOutlet weak var selectedCoinView: BaseView!
    @IBOutlet weak var selectedCoinLabel: BaseLabel!
    @IBOutlet weak var selectedCurrencyLabbel: BaseLabel!
    @IBOutlet weak var addWalletCoinButton: BaseButton!
    @IBOutlet weak var descTextfield: BaseTextField!
    private var selectedCoin: CoinModel?
    private var addressTypies: [AddressType] = [AddressType(name: "None")]
    private var selectedType: AddressType?
    private var selectedAddress: AddressModel?
    @IBOutlet weak var selectedIconImage: BaseImageView!
    private var saveButton: UIBarButtonItem?
    private var isHideTableView = true
    private var isEditMode = false
    private var filteredPoolTypes = [ExpandablePoolType]()
    private var poolTypes = [ExpandablePoolType]()
    private var showInvalidImage = false
    // MARK: - Static
    static func initializeStoryboard() -> AddAddressViewController? {
        return UIStoryboard(name: "Menu", bundle: nil).instantiateViewController(withIdentifier: AddAddressViewController.name) as? AddAddressViewController
    }
    
    //MARK: - Live Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupTableView()
        self.getAddresses()
        
    }
    
    override func languageChanged() {
        title =  isEditMode ? "edit_wallet".localized() : "add_wallet".localized()
    }
    
    private func setupViews() {
        self.descTextfield.isHidden = !isEditMode
        self.selectedCoinView.roundCorners(radius: 5)
        self.selectedCurrencyLabbel.text = "add_coin".localized()
        self.descTextfield.setPlaceholder("description".localized())
        self.addWalletCoinButton.addTarget(self, action: #selector(goToAddWalletCoin), for: .touchUpInside)
        self.saveButton = UIBarButtonItem(title: "save".localized(), style: .done, target: self, action: #selector(saveButtonAction))
        self.saveButton?.isEnabled = false
        navigationItem.setRightBarButton(saveButton, animated: true)
        
        self.descTextfield.text = selectedAddress?.description
        if selectedAddress != nil{
            self.configTableView(fieldsCount: selectedAddress?.credentials.count)
            if selectedAddress?.type == "coin",selectedCoin != nil {
                self.addWalletCoin(with: self.selectedCoin!)
                selectedCoinView.isHidden = false
            }
        }
        self.isHideTableView = selectedAddress?.type == "None"
    }
    
    private func setupTableView() {
        self.fieldTableView.register(UINib(nibName: AddAddressTableViewCell.name, bundle: nil), forCellReuseIdentifier: AddAddressTableViewCell.name)
        self.fieldTableView.backgroundColor = .clear
        self.fieldTableView.separatorStyle = .none
        
    }
    
    func configTableView(fieldsCount: Int?) {
        self.fieldTableViewHeightConstraits.constant = CGFloat(fieldsCount ?? 1) * AddAddressTableViewCell.height
    }
    
  
    
    func addGestureToView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
        let addCoin = UITapGestureRecognizer(target: self, action: #selector(goToAddWalletCoin))
        self.selectedCoinView.addGestureRecognizer(addCoin)
    }
    
    private func getAddresses() {
        Loading.shared.startLoading()
        AddressManager.shared.getAddressTypies { addressTypies in
            self.addressTypies = addressTypies
            if self.isEditMode {
                //                RealmWrapper.sharedInstance.updateObjects {
                addressTypies.forEach {
                    if $0.name == self.selectedAddress!.type {
                        self.selectedType = $0
                        for field in $0.fields {
                            if let text = self.selectedAddress?.credentials.keys.filter({ $0 == field.id}).first {
                                field.inputFieldText = self.selectedAddress?.credentials[text] ?? ""
                            }
                        }
                    }
                }
                //                }
            }
            self.fieldTableView.reloadData()
            self.addGestureToView()
            self.saveButton?.isEnabled = true
            Loading.shared.endLoading()
        } failer: { error in
            debugPrint(error)
            Loading.shared.endLoading()
        }
    }
    
    public func actionShitSelected(index: Int) {
        
        self.selectedType = addressTypies[index]
        self.selectedCoinView.isHidden = selectedType!.name  != "coin"
        self.descTextfield.isHidden = selectedType!.name == "None"
        self.isHideTableView = selectedType!.name == "None"
        self.configTableView(fieldsCount: isHideTableView  ? 0 : selectedType!.fields.count)
        self.fieldTableView.reloadData()
    }
    
    public func getPools() {
        if let types = DatabaseManager.shared.allEnabledPoolTypes {
            poolTypes = types.map { ExpandablePoolType(expanded: false, model: $0) }
            //            poolTypes.sort { $0.model.poolName < $1.model.poolName }
            filteredPoolTypes = poolTypes
        }
    }
    
    public func setTypeImageLabel (indexPath : IndexPath) {
        viewDidLoad()
        getPools()
        let type = addressTypies[indexPath.section].typeName
        typeLabel.text = type
        for pools in filteredPoolTypes {
            if indexPath.section == 0 {
                typeLabel.text = "Coin"
                typeImage.image = UIImage(named: "empty_coin")
            } else if type == pools.model.poolName {
                typeImage.sd_setImage(with: URL(string: Constants.HttpUrlWithoutApi + pools.model.poolLogoImagePath), completed: nil)
            }
        }
    }
    
    public func setTypeEditWallet (typeName: AddressModel) {
        viewDidLoad()
        getPools()
        for pools in filteredPoolTypes {
            if typeName.type == "coin" {
                typeLabel.text = "Coin"
                typeImage.image = UIImage(named: "empty_coin")
            } else if typeName.poolName == pools.model.poolName {
                typeImage.sd_setImage(with: URL(string: Constants.HttpUrlWithoutApi + pools.model.poolLogoImagePath), completed: nil)
                typeLabel.text = typeName.poolName
            }
        }
    }
    
    override func keyboardFrameChanged(_ sender: Notification) {
        guard let userInfo = sender.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let contentSize = self.fieldTableView.sizeThatFits(self.fieldTableView.bounds.size)
        let bottomInset =  (self.view.frame.height - keyboardFrame.origin.y * 0.7) + contentSize.height
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
    }
    
    @objc  func invalidButtonAction() {
        self.showToastAlert("", message: "incorrect_symbol".localized())
    }
    
    
    @objc private func saveButtonAction() {
        if showInvalidImage {
            self.showToastAlert("", message: "incorrect_symbol".localized())
            return
        }
        guard user != nil else {
            self.goToLoginPage()
            return
        }
        
        guard self.selectedType != nil && !isHideTableView else { return }
        
        if selectedType?.name == "coin", selectedCoin == nil {
            self.showToastAlert("", message: "Select coin".localized())
            return
        }
        
        guard let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") else { return }
        
        var optionalWalletCount = userDefaults.integer(forKey: "optionalWalletCount")
        var desctipt = ""
        if descTextfield.text == "" {
            optionalWalletCount += 1
            desctipt = "more_wallet".localized() + " \(optionalWalletCount)"
        } else {
            desctipt = descTextfield.text!
        }
        
        for (index,field) in self.selectedType!.fields.enumerated() {
            guard field.inputFieldText != "" else {
                animateCellTextView(indexRow: index)
                return
            }
            
            
            
        }
        Loading.shared.startLoading()
        self.saveButton?.isEnabled = false
        if isEditMode {
            AddressManager.shared.editAddress(addressId: selectedAddress!._id ,addressType: selectedType!, selectedCoin: selectedCoin, description: desctipt ) {
                userDefaults.set(optionalWalletCount, forKey: "optionalWalletCount")
                debugPrint("Wallet successfully edited")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.newWalletAdded), object: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.goToAddress()
                })
                Loading.shared.endLoading()
            } failer: { err in
                debugPrint(err)
                self.showAlertView("", message: err.localized(), completion: nil)
                self.saveButton?.isEnabled = true
                Loading.shared.endLoading()
            }
        } else {
            AddressManager.shared.addAddress(addressType: selectedType!,  selectedCoin: selectedCoin, description: desctipt ) {
                debugPrint("Wallet successfully added")
                userDefaults.set(optionalWalletCount, forKey: "optionalWalletCount")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.newWalletAdded), object: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.goToAddress()
                })
                Loading.shared.endLoading()
            } failer: { err in
                debugPrint(err)
                self.showAlertView("", message: err.localized(), completion: nil)
                self.saveButton?.isEnabled = true
                Loading.shared.endLoading()
            }
        }
    }
    
    @objc func goToAddWalletCoin() {
        guard let controller = AddCoinAlertViewController.initializeStoryboard() else { return }
        
        controller.delegate = self
        controller.setWalletState(true)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    fileprivate func goToAddress() {
        guard let navigation = self.navigationController else { return }
        for controller in navigation.viewControllers {
            if let addresstVC = controller as? AddressViewController {
                navigation.popToViewController(addresstVC, animated: true)
                return
            }
        }
    }
    public func setAddress(oldAddress: AddressModel){
        self.isEditMode = true
        self.selectedAddress = oldAddress
        self.selectedCoin = CoinModel()
        self.selectedCoin!.name = oldAddress.coinName
        self.selectedCoin!.symbol = oldAddress.currency
        self.selectedCoin!.coinId = oldAddress.coinId
        self.selectedCoin!.icon = oldAddress.coinId + ".png"
    }
    
}

//MARK: - TableViewDelegate  -
extension AddAddressViewController: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.selectedType?.fields.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: AddAddressTableViewCell.name) as? AddAddressTableViewCell {
            cell.setData(field: (self.selectedType!.fields[indexPath.row]), indexPath: indexPath,vc: self)
            cell.delegate = self
            return cell
        }
        return AddAddressTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AddAddressTableViewCell.height
    }
    
    func animateCellTextView(indexRow: Int) {
        let cell = fieldTableView.cellForRow(at: IndexPath(row: indexRow, section: 0)) as? AddAddressTableViewCell
        cell?.fieldTextField.animateWithShake()
    }


}

// MARK: - AddPoolTableViewCellDelegate -

extension AddAddressViewController: AddAddressTableViewCellDelegate, AddCoinAlertViewControllerDelegate {
    func addFieldTextFieldChange(for text: String, indexPath: IndexPath?) {
        
        guard indexPath != nil else { return }
        self.selectedType?.fields[indexPath!.row].inputFieldText = text
        for (index,field) in self.selectedType!.fields.enumerated() {
            let cell = fieldTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? AddAddressTableViewCell
            if field.acceptChars != nil {
                if field.inputFieldText.containPoolSpecificSpecialCharacters(filter: field.acceptChars!)   {
                    cell?.showInvalidIcon()
                    cell?.copyButton?.isHidden = true
                } else {
                    cell?.copyButton?.isHidden = false
                    cell?.invalidImage?.isHidden = true
                }
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
    
    func addWalletCoin(with walletCoin: CoinModel) {
        self.selectedCoin = walletCoin
        self.selectedCurrencyLabbel.text = selectedCoin!.symbol
        self.selectedCoinLabel.text = "(\(selectedCoin!.name))"
        self.selectedIconImage.sd_setImage(with: URL(string: Constants.HttpUrlWithoutApi + "images/coins/" + walletCoin.icon), placeholderImage: UIImage(named: "empty_coin"))
    }
}

