//
//  PayoutInfoTableViewCell.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 1/11/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class OldPayoutInfoTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var copyButton: UIButton!
    @IBOutlet var qrButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func qrButtonAction(_ sender: UIButton) {
        sender.isSelected = false
        if let id = valueLabel.text {
            NotificationCenter.default.post(name: NSNotification.Name("qrButtonAction"), object: id)
        }
    }

    @IBAction func copyButtonAction(_ sender: UIButton) {
        if let id = valueLabel.text {
            NotificationCenter.default.post(name: NSNotification.Name("copyButtonAction"), object: id)
        }
    }
}
