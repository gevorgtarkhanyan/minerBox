//
//  SettingsAlgorithmTableViewCell.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 11/4/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

protocol SettingsAlgorithmTableViewCellDelegate: AnyObject {
    func algorithmButtonTapped(for indexPath: IndexPath)
    func algosTextFieldChange(for text: String, indexPath: IndexPath, changedText: String)
    func goToLogIn()
}

class SettingsAlgorithmTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var algorithmNameButton: UIButton!
    @IBOutlet weak var mhsLabel: BaseLabel! //must change name
    @IBOutlet weak var wLabel: BaseLabel! //must change name
    @IBOutlet weak var mhsTextField: BaseTextField!//must change name
    @IBOutlet weak var wTextField: BaseTextField!
    @IBOutlet var mhsView: UIView!
    @IBOutlet var wView: UIView!
    
    @IBOutlet weak var cheeckMarkButton: UIButton!
    var indexPath: IndexPath?
    weak var delegate: SettingsAlgorithmTableViewCellDelegate?
    static var height: CGFloat {
        return 40
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }
    
    func initialSetup() {
       
        mhsTextField.delegate = self
        wTextField.delegate = self
        mhsView.backgroundColor = darkMode ? .textFieldBackgorund : .white
        wView.backgroundColor = darkMode ? .textFieldBackgorund : .white
        
        mhsTextField.textColor = darkMode ? .white : .textBlack
        mhsTextField.keyboardAppearance = darkMode ? .dark : .default
        mhsTextField.tintColor = .barSelectedItem
        mhsTextField.backgroundColor = .clear
        mhsTextField.borderStyle = .none
        wTextField.textColor = darkMode ? .white : .textBlack
        wTextField.keyboardAppearance = darkMode ? .dark : .default
        wTextField.tintColor = .barSelectedItem
        wTextField.backgroundColor = .clear
        wTextField.borderStyle = .none

        
        if darkMode {
            algorithmNameButton.setTitleColor(.whiteTextColor, for: .normal)
        } else {
            algorithmNameButton.setTitleColor(.blackTransparented, for: .normal)
        }
    }
    @IBAction func changeElectriCityText(_ sender: UITextField) {
        sender.getFormatedText()
    }
    
    func enableCellComponents(_ bool: Bool) {
        algorithmNameButton.isEnabled = bool
        isUserInteractionEnabled = bool
        
        mhsLabel.isEnabled = bool
        wLabel.isEnabled = bool
        
        mhsTextField.isEnabled = bool
        wTextField.isEnabled = bool
        
        algorithmNameButton.alpha = bool ? 1 : 0.3
        mhsTextField.alpha = bool ? 1 : 0.3
        wTextField.alpha = bool ? 1 : 0.3
    }
    
    
    func setupCell(_ data: [MiningAlgorithmsModel], for indexPath: IndexPath) {
        let currentData = data[indexPath.row]
        if currentData.disabled {
            currentData.selected = false
            enableCellComponents(false)
        } else {
            enableCellComponents(true)
        }
        
        self.indexPath = indexPath
        algorithmNameButton.setTitle(currentData.name, for: .normal)
        mhsLabel.text = String(currentData.unit)
        mhsTextField.text = currentData.hs.getString()
        wTextField.text = currentData.w.getString()
        
        if currentData.selected {
            self.cheeckMarkButton.setImage(UIImage(named: "cell_checkmark"), for: .normal)
//            algorithmNameButton.setTitleColor(.cellTrailingFirst, for: .normal)
        } else {
            self.cheeckMarkButton.setImage(UIImage(named: "Slected"), for: .normal)
            if darkMode {
                algorithmNameButton.setTitleColor(.white, for: .normal)
            } else {
                algorithmNameButton.setTitleColor(.black, for: .normal)
            }
        }
        
    }
    
    @IBAction func nameButtonTapped() {
        if delegate != nil, indexPath != nil {
            if DatabaseManager.shared.currentUser != nil {
                delegate!.algorithmButtonTapped(for: indexPath!)
            } else {
                delegate!.goToLogIn()
            }
            
        }
    }
}

extension SettingsAlgorithmTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       
        return textField.allowOnlyNumbersForConverter(string: string)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if DatabaseManager.shared.currentUser == nil {
            if delegate != nil, indexPath != nil {
                textField.resignFirstResponder()
                delegate!.goToLogIn()
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if delegate != nil, indexPath != nil {
            switch textField {
            case mhsTextField:
                if mhsTextField.text == "0." {
                    mhsTextField.text = "0"
                }
                delegate!.algosTextFieldChange(for: "hs", indexPath: indexPath!, changedText: mhsTextField.text!)
            case wTextField:
                if wTextField.text == "0." {
                    wTextField.text = "0"
                }
                delegate!.algosTextFieldChange(for: "w", indexPath: indexPath!, changedText: wTextField.text!)
            default:
                break
            }
            
        }
    }
    
}

