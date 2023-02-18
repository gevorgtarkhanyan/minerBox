//
//  WalletCollectionViewCell.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 22.02.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit

class WalletCollectionViewCell: BaseCollectionViewCell {
    
    @IBOutlet weak var walletTypeLabel: UILabel!
    @IBOutlet weak var backgorundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setDate( wallet: WalletModel) {
        self.walletTypeLabel.text = wallet.name
        self.backgorundView.backgroundColor = wallet.isSelected ?  .barSelectedItem : darkMode ? .viewDarkBackground : .viewLightBackground
    }
}

