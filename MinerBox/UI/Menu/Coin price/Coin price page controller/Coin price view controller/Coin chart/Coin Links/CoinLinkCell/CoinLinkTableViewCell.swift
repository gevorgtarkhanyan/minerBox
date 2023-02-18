//
//  CoinLinkTableViewCell.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 31.05.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

class CoinLinkTableViewCell: BaseTableViewCell {

    @IBOutlet weak var linkLabel: BaseLabel!
    @IBOutlet var coinLinkTableViewCell: CoinLinkTableViewCell!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("CoinLinkTableViewCell", owner: self, options: nil)
        
        addSubview(coinLinkTableViewCell)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
}
