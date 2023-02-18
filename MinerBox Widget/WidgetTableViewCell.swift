//
//  WidgetTableViewCell.swift
//  MinerBox Widget
//
//  Created by Ruben Nahatakyan on 12/12/18.
//  Copyright © 2018 WitPlex. All rights reserved.
//

import UIKit

class WidgetTableViewCell: UITableViewCell {
    // MARK: - Views
    @IBOutlet fileprivate weak var poolTypeLabel: UILabel!
    @IBOutlet fileprivate weak var nameLabel: UILabel!

    @IBOutlet fileprivate weak var hashrateLabel: WidgetLabel!
    @IBOutlet fileprivate weak var hashrateValueLabel: UILabel!

    @IBOutlet fileprivate weak var workersLabel: WidgetLabel!
    @IBOutlet fileprivate weak var workersValueLabel: UILabel!

    // MARK: - Static
    static var height: CGFloat = 86

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        workersLabel.setLocalizableText("workers")
        hashrateLabel.setLocalizableText("hashrate")
    }
}

// MARK: - Set data
extension WidgetTableViewCell {
    public func setData(item: WidgetAccountModel) {
        poolTypeLabel.text = item.getPoolName()
        nameLabel.text = item.poolAccountLabel
        hashrateValueLabel.text = item.currentHashrate.textFromHashrate()
        workersValueLabel.text = "\(item.workersCount)"
    }
}
