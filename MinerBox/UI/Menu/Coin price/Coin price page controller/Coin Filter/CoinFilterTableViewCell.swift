//
//  CoinFilterTableViewCell.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 17.05.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

protocol CoinFilterTableViewCellDelegate {
    func setFilter(filter: CoinFilterModel)
    func removeFilter(filter: CoinFilterModel)
}

class CoinFilterTableViewCell: BaseTableViewCell {
    //MARK: - Views
    @IBOutlet private weak var typeLabel: BaseLabel!
    @IBOutlet private weak var fromTextField: BaseTextField!
    @IBOutlet private weak var toTextField: BaseTextField!
    @IBOutlet private weak var fromParentView: UIView!
    @IBOutlet private weak var toParentView: UIView!
    @IBOutlet private weak var fromClearButton: UIButton!
    @IBOutlet private weak var toClearButton: UIButton!
    @IBOutlet private weak var seperatorView: UIView!
    @IBOutlet weak var invalidValue: UIImageView!
    private var filterType: CoinSortEnum!
    
    static var height: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 50 : 85
    
    var delegate: CoinFilterTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        fromTextField.delegate = self
        toTextField.delegate = self
        uiSetup()
    }
    
    //MARK: - Setup
    public func setup(data: CoinFilterModel, enabled: Bool) {
        self.filterType = data.type
        setPlaceholders(type: data.type)
        typeLabel.text = data.type.localized//rawValue.localized()
        fromTextField.text = data.from?.getFormatedString()
        toTextField.text = data.to?.getFormatedString()
        
        setClearButtonsState()
        self.enable(on: enabled)
    }
    func setPlaceholders(type: CoinSortEnum) {
        switch type {
        case .marketPriceUSD:
            fromTextField.setPlaceholder("from_textfield".localized())
            toTextField.setPlaceholder("to_textfield".localized())
        case .rank:
            fromTextField.setPlaceholder("from_textfield".localized())
            toTextField.setPlaceholder("to_textfield".localized())
        case .marketCapUsd:
            fromTextField.setPlaceholder("from_textfield".localized())
            toTextField.setPlaceholder("to_textfield".localized())
        case .change1h:
            fromTextField.setPlaceholder("%")
            toTextField.setPlaceholder("%")
        case .change24h:
            fromTextField.setPlaceholder("%")
            toTextField.setPlaceholder("%")
        case .change1w:
            fromTextField.setPlaceholder("%")
            toTextField.setPlaceholder("%")
        default:
            debugPrint("_")
        }
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.regular, .regular):
            CoinFilterTableViewCell.height = 50
        case (.regular, .compact):
            CoinFilterTableViewCell.height = 50
        default:
            CoinFilterTableViewCell.height = 85
        }
    }
    
    private func uiSetup() {
        DispatchQueue.main.async {
            
            self.fromParentView.layer.cornerRadius = self.fromParentView.frame.height / 2
            self.toParentView.layer.cornerRadius = self.toParentView.frame.height / 2
            
            self.fromTextField.textColor = self.darkMode ? .white : .textBlack
            self.toTextField.textColor = self.darkMode ? .white : .textBlack
            
            self.fromTextField.keyboardAppearance = self.darkMode ? .dark : .default
            self.toTextField.keyboardAppearance = self.darkMode ? .dark : .default
            
            self.fromTextField.backgroundColor = .clear
            self.toTextField.backgroundColor = .clear
            
            self.fromParentView.backgroundColor = .textFieldBackground
            self.toParentView.backgroundColor = .textFieldBackground

            self.fromClearButton.tintColor = self.darkMode ? .lightGray : .darkGray
            self.toClearButton.tintColor = self.darkMode ? .lightGray : .darkGray
            
            self.fromTextField.borderStyle = .none
            self.toTextField.borderStyle = .none
            
            
            
            self.seperatorView.backgroundColor = UIColor.separator
        }
    }
    
    private func createFilterData() {
        let from = fromTextField.text?.toInt()
        let to = toTextField.text?.toInt()
        
        let filter = CoinFilterModel(type: filterType, from: from, to: to)
        
        if from == nil && to == nil {
            delegate?.removeFilter(filter: filter)
        } else {
            delegate?.setFilter(filter: filter)
        }
        setClearButtonsState()
    }
    
    private func setClearButtonsState() {
        fromClearButton.isHidden = fromTextField.text == nil || fromTextField.text == ""
        toClearButton.isHidden = toTextField.text == nil || toTextField.text == ""
    }
    
    
    
    //MARK: UI Action
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        sender.getFormatedText()
        createFilterData()
    }
    
    @IBAction func fromButtonAction(_ sender: Any) {
        fromTextField.text = nil
        fromClearButton.isHidden = true
        createFilterData()
    }
    
    @IBAction func toButtonAction(_ sender: Any) {
        toTextField.text = nil
        toClearButton.isHidden = true
        createFilterData()
    }
    
    
}

//MARK: -- TextField delegate methods
extension CoinFilterTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //for the hide keyboard
//        view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField.allowOnlyInt(string: string)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        invalidValue?.isHidden = true
        return true
    }
    
    func showInvalidValue() {
        invalidValue?.isHidden = false
    }
}
