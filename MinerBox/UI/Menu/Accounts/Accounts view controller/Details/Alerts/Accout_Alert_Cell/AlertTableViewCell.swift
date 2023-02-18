//
//  CoinPriceAddAlertTableViewCell.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/27/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class AlertTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var comparisionLabel: BaseLabel!
    @IBOutlet weak var alertValueLabel: BaseLabel!
    @IBOutlet weak var bellImageView: BaseImageView!
    @IBOutlet weak var repeatImageView: BaseImageView!
    @IBOutlet weak var seperatorView: UIView!
    
    static var height: CGFloat = 44
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }
    
    func initialSetup() {
//        backgroundColor = .clear
        bellImageView.changeColors()
        repeatImageView.changeColors()
        repeatImageView.image = UIImage(named: "alert_repeat")?.withRenderingMode(.alwaysTemplate)
        
    }
}

// MARK: - Set data
extension AlertTableViewCell {
    public func setAccountAlertData(alertType: AccountAlertType, comparision: AlertComparisionType, value: Double, isRepeat: Bool, isEnabled: Bool,account: PoolAccountModel, last:Bool = false) {
        comparisionLabel.setLocalizableText(comparision.rawValue)
        repeatImageView.isHidden = !isRepeat
        
        switch alertType {
        case .hashrate:
            alertValueLabel?.setLocalizableText(value.textFromHashrate(account: account))
        case .worker:
            alertValueLabel?.setLocalizableText(value.getFormatedString(maximumFractionDigits: 3))//getString())
        case .reportedHashrate:
            alertValueLabel?.setLocalizableText(value.textFromHashrate(account: account))
        }
        
        bellImageView.changeColors()
        repeatImageView.changeColors()
        if last {
            seperatorView.backgroundColor = .clear
            roundCorners([.bottomLeft, .bottomRight], radius: 10)
        } else {
            seperatorView.backgroundColor = .separator
            roundCorners([.bottomLeft, .bottomRight], radius: 0)
        }
    
    
            let imageName = isEnabled ? "cell_ring" : "cell_ring_off"
            bellImageView.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
    
    }

}
