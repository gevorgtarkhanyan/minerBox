//
//  CoinAlertTableViewCell.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 11/23/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class CoinAlertTableViewCell: BaseTableViewCell {

    @IBOutlet weak var comparisionLabel: BaseLabel!
    @IBOutlet weak var priceLabel: BaseLabel!
    @IBOutlet weak var repeatImageView: BaseImageView!
    @IBOutlet weak var bellImageView: BaseImageView!
    @IBOutlet weak var separatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }
    
    func initialSetup() {
        repeatImageView.changeColors()
        bellImageView.changeColors()
    }
    
    func setupCell(_ alert: AlertModel, last: Bool = false) {
        let comparision: CoinAlertType = alert.comparison ? .lessThan : .greatherThan
        comparisionLabel.setLocalizableText(comparision.rawValue)
        priceLabel.setLocalizableText("\(Locale.getCurrencySymbol(cur: alert.cur)) " + alert.value.getString())
        repeatImageView.isHidden = !alert.isRepeat
        
        let imageName = alert.isEnabled ? "cell_ring" : "cell_ring_off"
        bellImageView.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        repeatImageView.image = UIImage(named: "alert_repeat")?.withRenderingMode(.alwaysTemplate)
        
        if last {
            separatorView.backgroundColor = .clear
            roundCorners([.bottomLeft, .bottomRight], radius: 10)
        } else {
            separatorView.backgroundColor = .separator
            roundCorners([.bottomLeft, .bottomRight], radius: 0)
        }
    }
}
