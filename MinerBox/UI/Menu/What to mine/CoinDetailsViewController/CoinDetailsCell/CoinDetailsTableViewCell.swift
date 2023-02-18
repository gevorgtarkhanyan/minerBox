//
//  CoinDetailsTableViewCell.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/31/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class CoinDetailsTableViewCell: BaseTableViewCell {

    @IBOutlet weak var nameLabel: BaseLabel!
    @IBOutlet weak var valueLabel: BaseLabel!
    
    static var height: CGFloat {
        return 28
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
    }
    
    func setupCell(_ data: [CoinDetailsDataModel], for indexPath: IndexPath) {
        let currentData = data[indexPath.row]
        nameLabel.text = currentData.key
        valueLabel.text = currentData.value
    }
}
