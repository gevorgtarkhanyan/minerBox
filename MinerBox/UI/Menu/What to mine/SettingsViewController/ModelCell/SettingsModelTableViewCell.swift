//
//  SettingsModelTableViewCell.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 11/4/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

protocol SettingsModelTableViewCellDelegate: AnyObject {
    func modelButtonTapped(for indexPath: IndexPath)
    func minusButtonTapped(for indexPath: IndexPath, minCount: Int)
    func plusButtonTapped(for indexPath: IndexPath)
    func modelCountChange(for indexPath: IndexPath, to count: Int)
    func insertTextField(for indexPath: IndexPath, minCount: Int)
    
    func goToLogIn()
}

class SettingsModelTableViewCell: BaseTableViewCell , UITextFieldDelegate {
    
    @IBOutlet weak var modelNameButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    
    @IBOutlet weak var parentsView: UIStackView!
    
    
    @IBOutlet weak var pcsTextField: UITextField!
    
    @IBOutlet weak var pcsNameLabel: BaseLabel!//must change name
    @IBOutlet weak var pcsValueLabel: BaseLabel!
    @IBOutlet weak var cheeckMarkButton: UIButton!
    
    var indexPath: IndexPath?
    weak var delegate: SettingsModelTableViewCellDelegate?
    var pcsCount: Int = 1
    
   
    
    static var height: CGFloat {
        return 40
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
        pcsTextField.delegate = self
    }
    
    
    func initialSetup() {
        minusButton.setImage(UIImage(named: "minus_icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        minusButton.tintColor = .workerRed
        
        plusButton.setImage(UIImage(named: "plus_icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        plusButton.tintColor = .cellTrailingFirst
        
        parentsView.roundCornerStackView(backgroundColor: darkMode ? .textFieldBackgorund : .white, radiusSize: 5)
        pcsTextField.textColor = darkMode ? .white : .textBlack
        pcsTextField.keyboardAppearance = darkMode ? .dark : .default
        pcsTextField.tintColor = .barSelectedItem
        pcsTextField.backgroundColor = .clear
        pcsTextField.borderStyle = .none
        self.pcsTextField.addTarget(self, action: #selector(insertTextField(_:)), for:.editingChanged)

//
        
        
        if darkMode {
            modelNameButton.setTitleColor(.whiteTextColor, for: .normal)
        } else {
            modelNameButton.setTitleColor(.blackTransparented, for: .normal)
        }
        modelNameButton.backgroundColor = .clear
    }
    
    func enableCellComponents(_ bool: Bool) {
        modelNameButton.isEnabled   = bool
        minusButton.isEnabled       = bool
        plusButton.isEnabled        = bool
        
        pcsNameLabel.isEnabled      = bool
        pcsTextField.isEnabled     = bool
        isUserInteractionEnabled    = bool
        
        
        modelNameButton.alpha       = bool ? 1 : 0.3
        minusButton.alpha           = bool ? 1 : 0.3
        plusButton.alpha            = bool ? 1 : 0.3
    }
    
    func setupCell(_ data: [MiningMachineModels], for indexPath: IndexPath) {
        let currentData = data[indexPath.row]
        
        if let exactInt = Int(exactly: currentData.count) {
            pcsCount = exactInt
        }
        if currentData.disabled {
            currentData.selected = false
            enableCellComponents(false)
        } else {
            enableCellComponents(true)
            
            if pcsCount == 0 {
                minusButton.isEnabled = false
                minusButton.alpha = 0.3
                
            } else {
                minusButton.isEnabled = true
                minusButton.alpha = 1
            }
        }
        
        self.indexPath = indexPath
        
        pcsTextField.text = String(pcsCount)
        modelNameButton.setTitle(currentData.name, for: .normal)
        
        if currentData.selected {
            self.cheeckMarkButton.setImage(UIImage(named: "cell_checkmark"), for: .normal)
//            modelNameButton.setTitleColor(.cellTrailingFirst, for: .normal)
            if pcsCount == 0 {
            pcsTextField.text = String(Int(1))
            pcsCount = 1
            minusButton.isEnabled = true
            minusButton.alpha = 1
            delegate?.modelCountChange(for: indexPath, to: pcsCount)
            }
            
        } else {
            self.cheeckMarkButton.setImage(UIImage(named: "Slected"), for: .normal)
            if darkMode {
                modelNameButton.setTitleColor(.white, for: .normal)
            } else {
                modelNameButton.setTitleColor(.black, for: .normal)
            }
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newText = (pcsTextField.text! as NSString).replacingCharacters(in: range, with: string) as String
        if newText == "" {
            newText = "0"
        }
        if let num = Int(newText), num >= 0 && num <= 10000 {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func insertTextField(_ sender: Any) {
        if let delegate = delegate, let indexPath = indexPath {
            if DatabaseManager.shared.currentUser != nil {
                
                    pcsCount = Int(pcsTextField.text!) ?? 0
                    if pcsCount == 0 {
                        minusButton.isEnabled = false
                        minusButton.alpha = 0.3
                        self.cheeckMarkButton.setImage(UIImage(named: "Slected"), for: .normal)
                        if darkMode {
                            modelNameButton.setTitleColor(.white, for: .normal)
                        } else {
                            modelNameButton.setTitleColor(.black, for: .normal)
                        }
                    } else if pcsCount > 0 {
                        minusButton.isEnabled = true
                        minusButton.alpha = 1
                        self.cheeckMarkButton.setImage(UIImage(named: "cell_checkmark"), for: .normal)
                        modelNameButton.setTitleColor(.cellTrailingFirst, for: .normal)
                    }
                    pcsTextField.text = String(pcsCount)
                    delegate.modelCountChange(for: indexPath, to: pcsCount)
                delegate.insertTextField(for: indexPath, minCount : pcsCount)
                
            } else {
                delegate.goToLogIn()
            }
        }
    
    }
    
    @IBAction func minusTapped() {
        if let delegate = delegate, let indexPath = indexPath {
            if DatabaseManager.shared.currentUser != nil {
                if pcsCount > 0 {
                    pcsCount -= 1
                    if pcsCount == 0 {
                        minusButton.isEnabled = false
                        minusButton.alpha = 0.3
                    }
                    pcsTextField.text = String(pcsCount)
                    delegate.modelCountChange(for: indexPath, to: pcsCount)
                    delegate.minusButtonTapped(for: indexPath, minCount: pcsCount)
                }
            } else {
                delegate.goToLogIn()
            }
        }
        
    }
    
    @IBAction func plusTapped() {
        if let delegate = delegate, let indexPath = indexPath {
            if DatabaseManager.shared.currentUser != nil {
                pcsCount += 1
                pcsTextField.text = String(pcsCount)
                minusButton.isEnabled = true
                minusButton.alpha = 1
                delegate.modelCountChange(for: indexPath, to: pcsCount)
                delegate.plusButtonTapped(for: indexPath)
            } else {
                delegate.goToLogIn()
            }
        }
    }
    
    @IBAction func nameButtonTapped() {
        if let delegate = delegate, let indexPath = indexPath {
            if DatabaseManager.shared.currentUser != nil {
                delegate.modelButtonTapped(for: indexPath)
            } else {
                delegate.goToLogIn()
            }
        }
        
    }
}
