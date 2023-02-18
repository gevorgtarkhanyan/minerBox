//
//  BalanceTableViewCell.swift
//  MinerBox
//
//  Created by Vazgen Hovakinyan on 14.05.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

protocol BalanceTableViewCellDelegate: AnyObject {
    
    func converterIconTapped(indexPath: IndexPath,isBtcTotal:Bool,isAmmounValue:Bool)
}

class BalanceTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var balanceTypeLabbel: BaseLabel!
    @IBOutlet weak var balanceValueLabbel: BaseLabel!
    
    @IBOutlet weak var convertorButton: UIButton!
    @IBOutlet weak var convertorWidthConstraits: NSLayoutConstraint!
    @IBOutlet weak var ammountConvertorButton: UIButton!
    @IBOutlet weak var ammountConvertorButtonWidthConstraits: NSLayoutConstraint!
    @IBOutlet weak var ammountLabbel: BaseLabel!
    
    
    static var height: CGFloat = 40
    static var heightForTotal: CGFloat = 25
    
    var indexPath: IndexPath?
    weak var delegate: BalanceTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialSetup()
    }
    
    private func initialSetup() {
        
        balanceTypeLabbel.changeFont(to: Constants.semiboldFont)
        balanceTypeLabbel.changeFontSize(to: 12)
        balanceValueLabbel.changeFontSize(to: 12)
        ammountLabbel.changeFontSize(to: 12)
        roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 0)
    }
    
    func setData(paid:(key: BalanceType, value: String,coinId: String),indexPath: IndexPath,isConvertorIconShow: Bool = false,last:Bool) {
        
        self.indexPath = indexPath
        self.ammountLabbel.isHidden = true
        self.balanceTypeLabbel.isHidden = false
        self.ammountConvertorButtonWidthConstraits.constant = 0
        self.balanceTypeLabbel.setLocalizableText(paid.key.rawValue)
        self.balanceValueLabbel.setLocalizableText(paid.value)
        guard paid.key != .credit else {
            convertorWidthConstraits.constant = 0
            ammountConvertorButtonWidthConstraits.constant = 0
            return
        }
        if last {
            roundCorners([.bottomLeft, .bottomRight], radius: 10)
        } else {
            roundCorners([.bottomLeft, .bottomRight], radius: 0)
        }
        if isConvertorIconShow {
            self.convertorButton.addTarget(self, action: #selector(convertorIconTapped), for: .touchUpInside)
            convertorWidthConstraits.constant = 25
            if darkMode {
                convertorButton.setImage(UIImage(named: "details_converter_white"), for: .normal)
            } else {
                convertorButton.setImage(UIImage(named: "details_converter_black"), for: .normal)
            }
        }
    }
    func setData(coinName:String, amount: String, btcTotal: String,indexPath: IndexPath,isConvertorIconShow: Bool = false, isAmmountConvertorIconShow: Bool = false) {
        
        self.indexPath = indexPath
        self.convertorButton.addTarget(self, action: #selector(convertorBtcIconTapped), for: .touchUpInside)
        self.ammountConvertorButton.addTarget(self, action: #selector(ammountConvertorBtcIconTapped), for: .touchUpInside)
        self.convertorWidthConstraits.constant = 0
        self.ammountConvertorButtonWidthConstraits.constant = 0
        self.balanceTypeLabbel.isHidden = false
        self.ammountLabbel.isHidden = false
        self.balanceTypeLabbel.setLocalizableText(coinName)
        self.ammountLabbel.setLocalizableText(amount)
        self.balanceValueLabbel.setLocalizableText(btcTotal)
        
        if isConvertorIconShow {
            
            convertorWidthConstraits.constant = 20
            if darkMode {
                convertorButton.setImage(UIImage(named: "details_converter_white"), for: .normal)
            } else {
                convertorButton.setImage(UIImage(named: "details_converter_black"), for: .normal)
            }
        }
        if isAmmountConvertorIconShow {
            ammountConvertorButtonWidthConstraits.constant = 20
            if darkMode {
                ammountConvertorButton.setImage(UIImage(named: "details_converter_white"), for: .normal)
            } else {
                ammountConvertorButton.setImage(UIImage(named: "details_converter_black"), for: .normal)
            }
        }
    }
    func setHideOrShowCellSetting(isHIdeZero: Bool) {
   

        self.ammountLabbel.isHidden = true
        self.balanceTypeLabbel.isHidden = true
        self.balanceValueLabbel.isHidden = true
        self.convertorButton.isHidden = true
        self.ammountConvertorButton.isHidden = true
    }
    
    // MARK: - Delegate Methods-
    @objc func convertorIconTapped() {
        if let delegate = delegate, let indexPath = indexPath {
            
            delegate.converterIconTapped(indexPath: indexPath,isBtcTotal: false, isAmmounValue: false)
        }
    }
    @objc func convertorBtcIconTapped() {
        if let delegate = delegate,let indexPath = indexPath {
            
            delegate.converterIconTapped(indexPath: indexPath,isBtcTotal: true, isAmmounValue: false)
        }
    }
    @objc func ammountConvertorBtcIconTapped() {
        if let delegate = delegate,let indexPath = indexPath {
            
            delegate.converterIconTapped(indexPath: indexPath,isBtcTotal: false, isAmmounValue: true)
        }
    }
}
