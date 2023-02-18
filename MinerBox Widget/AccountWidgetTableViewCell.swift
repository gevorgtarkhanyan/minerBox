//
//  WidgetTableViewCell.swift
//  MinerBox Widget
//
//  Created by Ruben Nahatakyan on 12/12/18.
//  Copyright © 2018 WitPlex. All rights reserved.
//

import UIKit
import SDWebImage


class AccountWidgetTableViewCell: UITableViewCell {
    // MARK: - Views
    @IBOutlet fileprivate weak var poolTypeLabel: UILabel!
    @IBOutlet fileprivate weak var nameLabel: UILabel!

    @IBOutlet fileprivate weak var hashrateValueLabel: UILabel!

    @IBOutlet fileprivate weak var workersValueLabel: UILabel!
    @IBOutlet weak var incomeValueLabel: UILabel!
    @IBOutlet weak var accountLogoImageView: UIImageView!
    @IBOutlet weak var accountLogoBackgroundView: UIView!
    @IBOutlet weak var incomeView: UIView!
    
    // MARK: - Static
    static var height: CGFloat = 80

    static var heightWithBalance: CGFloat = 105

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        accountLogoBackgroundView.layer.cornerRadius = 6.5
        accountLogoImageView.layer.cornerRadius = accountLogoBackgroundView.layer.cornerRadius
    }

}

// MARK: - Set data
extension AccountWidgetTableViewCell {
    public func setData(item: WidgetAccountModel) {
        poolTypeLabel.text = item.getPoolName()
        nameLabel.text = item.poolAccountLabel
        hashrateValueLabel.text = item.currentHashrate.textFromHashrate(accountFromWidget: item)
        workersValueLabel.text = "\(item.workersCount)"
        getLogoImage(item: item)
        
            switch item.selectedBalanceType {
            case "paid":
                incomeValueLabel.text = "\(item.paid.getString()) \(item.currency ?? "")"
            case "unpaid":
                incomeValueLabel.text = "\(item.unpaid.getString()) \(item.currency ?? "")"
            case "confirmed":
                incomeValueLabel.text = "\(item.confirmed.getString()) \(item.currency ?? "")"
            case "unconfirmed":
                incomeValueLabel.text = "\(item.unconfirmed.getString()) \(item.currency ?? "")"
            case "orphaned":
                incomeValueLabel.text = "\(item.orphaned.getString()) \(item.currency ?? "")"
            case "credit":
                incomeValueLabel.text = "\(item.credit.textFromCredit())"
            default:
                incomeView.isHidden = true
            }
    }
}
// MARK: - Actions
extension AccountWidgetTableViewCell {
    fileprivate func getLogoImage(item: WidgetAccountModel) {
        guard let pool = DatabaseManager.shared.getPool(id: item.poolType) else { return }
        accountLogoImageView.sd_setImage(with: URL(string: Constants.HttpUrlWithoutApi + pool.poolLogoImagePath), completed: nil)
    }
}
