//
//  SubCollectionViewCelll.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 22.11.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

class SubCollectionViewCelll: BaseCollectionViewCell {
    
    @IBOutlet weak var backgroundVew: UIView!
    @IBOutlet weak var buttonName: BaseLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        self.backgroundVew.backgroundColor = .barSelectedItem
        self.backgroundVew?.roundCorners(radius: 10)
    }
    
    func setDate(balance: BalanceSelectedType) {
        self.buttonName.text = balance.balanceName.localized()
        self.backgroundVew.backgroundColor = balance.isSelected ?  .barSelectedItem : darkMode ? .darkGray : .lightGray
    }
}
