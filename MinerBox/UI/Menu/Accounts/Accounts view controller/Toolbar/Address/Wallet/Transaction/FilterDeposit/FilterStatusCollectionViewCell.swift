//
//  FilterStatusCollectionViewCell.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 10.03.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit

class FilterStatusCollectionViewCell: BaseCollectionViewCell {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var contentBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }
    
    func setDate(_ status: FilterStatus) {
        self.statusLabel.text = status.name
        self.contentBackgroundView.backgroundColor = status.isSelected ?  .barSelectedItem : .segmentBackground
    }
}
