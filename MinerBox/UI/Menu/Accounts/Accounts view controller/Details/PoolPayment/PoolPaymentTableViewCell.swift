//
//  DateFilterTableViewCell.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/3/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import Localize_Swift

class PoolPaymentTableViewCell: BaseTableViewCell {
    
    // MARK: - Views
    @IBOutlet fileprivate weak var value1Label: BaseLabel!
    @IBOutlet fileprivate weak var value2Label: BaseLabel!
    @IBOutlet fileprivate weak var value3Label: BaseLabel!
    @IBOutlet fileprivate weak var amountLabel: BaseLabel!
    @IBOutlet fileprivate weak var currencyLabel: BaseLabel!
    @IBOutlet fileprivate weak var value4Label: BaseLabel!
    
    
    // MARK: - Properties
    fileprivate var indexPath: IndexPath = .zero
    
    
    // MARK: - Startup setup
    override func startupSetup() {
        super.startupSetup()
        
        // This lines are important. Without this payout info are showing long time
        selectionStyle = .default
        
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        selectedBackgroundView = view
    }
    
    override func changeColors() {
        backgroundColor = .clear
    }
}

// MARK: - Set data
extension PoolPaymentTableViewCell {
    public func setData(model: PoolPaymentModel, showCurrency: Bool) {
        
        if model.paidOn != -1.0 || model.timestamp != 0 || model.dateUnix != 0{
            var paidDate = Date()
            if model.paidOn != -1.0  {
                paidDate = Date(timeIntervalSince1970: model.paidOn)
            } else if model.dateUnix != 0 {
                paidDate = Date(timeIntervalSince1970: model.dateUnix)
            } else {
                paidDate = Date(timeIntervalSince1970: model.timestamp)
            }
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: Localize.currentLanguage())
            dateFormatter.dateFormat = "dd/MM/yy HH:mm"
            value1Label.setLocalizableText(dateFormatter.string(from: paidDate))
        }
        
        if model.amount != -1.0 {
            amountLabel.setLocalizableText(model.amount.getString())
        } else if model.rewards != -1.0 {
            amountLabel.setLocalizableText(model.rewards.getString())
        }
        
        if let currency = model.currency {
            currencyLabel.text = currency
        }
        currencyLabel.isHidden = !showCurrency
        
        if model.type != nil {
            value2Label?.setLocalizableText(model.type!)
        } else if model.blockNumber != -1 {
            value2Label?.setLocalizableText(model.blockNumber.getString())
        } else if model.height != 0.0 {
            value2Label?.setLocalizableText(model.height.getString())
        } else {
            value2Label.isHidden = true
        }
        
        if model.paidOn != -1.0 {
            value3Label.setLocalizableText(model.duration ?? "")
        }
        else if model.immature != -1 {
            value3Label?.setLocalizableText(model.immature == 1 ? "Immature".localized() : "matured".localized())
        }
        else if model.cfms  != -1 {
            value3Label?.setLocalizableText( model.cfms  == -1 ? "" : model.cfms.getString())  //empty String when one
        } else if model.worker != nil{
            value3Label?.setLocalizableText(model.worker ?? "")
        } else {
            value3Label.isHidden = true
        }
        
        if model.luckPer != -1 {
            value4Label?.setLocalizableText(model.luckPer.getString())
        } else if model.txHash != nil {
            value4Label.setLocalizableText(model.txHash ?? "")
            value4Label.adjustsFontSizeToFitWidth = false
        } else if model.status != nil {
            value4Label?.setLocalizableText(model.status!)
        } else if model.sharePer != -1 {
            value4Label?.setLocalizableText(model.sharePer.getString())
        } else if model.shareDifficulty != -1 {
            value4Label?.setLocalizableText(model.shareDifficulty.textFromHashrate(difficulty: true))
        } else {
            value4Label.isHidden = true
        }
        
        contentView.layoutIfNeeded()
    }
}
