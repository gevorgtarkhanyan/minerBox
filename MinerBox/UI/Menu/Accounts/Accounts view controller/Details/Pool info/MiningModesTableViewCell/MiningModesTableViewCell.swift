//
//  MiningModesTableViewCell.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 11.08.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

class MiningModesTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var systemBackgroundVew: UIView!
    @IBOutlet weak var systemNameLabbel: BaseLabel!
    @IBOutlet weak var systemValueLabbel: BaseLabel!
    
    @IBOutlet weak var feeBackgroundView: UIView!
    @IBOutlet weak var feeNameLabbel: BaseLabel!
    @IBOutlet weak var feeValueLabbel: BaseLabel!
    
    @IBOutlet weak var txFeeBackgroundView: UIView!
    @IBOutlet weak var txFeeNameLabbel: BaseLabel!
    @IBOutlet weak var txFeeValueLabbel: BaseLabel!
    
    @IBOutlet weak var txFeeManualBackgroundView: UIView!
    @IBOutlet weak var txFeeManualNameLabbel: BaseLabel!
    @IBOutlet weak var txFeeManualValueLabbel: BaseLabel!
    
    @IBOutlet weak var txFeeAutoBackgroundView: UIView!
    @IBOutlet weak var txFeeAutoNameLabbel: BaseLabel!
    @IBOutlet weak var txFeeAutoValueLabbel: BaseLabel!
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialSetup()
    }

    func initialSetup() {
        
        backgroundColor =  darkMode ? .viewDarkBackground: .sectionHeaderLight
        roundCorners([.topLeft, .topRight ,.bottomLeft ,.bottomRight], radius: 10)
        
    }
    
    public func setData(miningModes: MiningModes) {
      
        self.systemNameLabbel.setLocalizableText("System")
        self.systemValueLabbel.setLocalizableText(miningModes.system ?? "")
        
        self.feeNameLabbel.setLocalizableText("Fee")
        self.feeValueLabbel.setLocalizableText(miningModes.feeStr ?? "")
        
        self.txFeeNameLabbel.setLocalizableText("TxFee")
        self.txFeeValueLabbel.setLocalizableText(miningModes.txFeeStr ?? "")
        
        self.txFeeManualNameLabbel.setLocalizableText("TxFeeManual")
        self.txFeeManualValueLabbel.setLocalizableText(miningModes.txFeeManual?.getString() ?? "")
        
        self.txFeeAutoNameLabbel.setLocalizableText("TxFeeAuto")
        self.txFeeAutoValueLabbel.setLocalizableText(miningModes.txFeeAuto?.getString() ?? "")
        
        
    }
   
    
}
