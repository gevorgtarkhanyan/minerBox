//
//  TransactionCollectionViewCell.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 01.03.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit

class StatusCollectionViewCell: BaseCollectionViewCell {
    
    @IBOutlet weak var statusBackgorundView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    func setDate( history: HistoryType) {
        self.statusLabel.text = history.name
        self.statusBackgorundView.backgroundColor = history.isSelected ?  .barSelectedItem : darkMode ? .viewDarkBackground : .viewLightBackground
    }
}
