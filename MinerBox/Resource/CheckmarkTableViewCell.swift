//
//  CheckmarkTableViewCell.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/12/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class CheckmarkTableViewCell: BaseTableViewCell {

    // MARK: - Views
    @IBOutlet fileprivate weak var nameLabel: BaseLabel!
    @IBOutlet fileprivate weak var iconImageView: BaseImageView?
    @IBOutlet fileprivate weak var checkmarkImageView: UIImageView!
    @IBOutlet fileprivate weak var iconImageViewTrailingConstraint: NSLayoutConstraint?
    
    // MARK: - Properties
    fileprivate var indexPath: IndexPath = .zero

    // MARK: - Startup
    override func startupSetup() {
        super.startupSetup()
        clipsToBounds = true
        checkmarkImageView.image = UIImage(named: "cell_checkmark")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkmarkImageView.isHidden = !selected
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        checkmarkImageView.isHidden = true
        roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 0)
    }
}

// MARK: - Set data
extension CheckmarkTableViewCell {
    public func setData(name: String, indexPath: IndexPath, last: Bool, roundCorners: Bool = true) {
        self.indexPath = indexPath
        nameLabel.setLocalizableText(name)
        if roundCorners {
            configBackgroundCorner(lastRow: last)
        }
        iconImageViewTrailingConstraint?.constant = 0
    }
    
    public func setData(coin: CoinModel, indexPath: IndexPath, last: Bool, roundCorners: Bool = true) {
        iconImageView?.sd_setImage(with: URL(string: coin.iconPath), placeholderImage: UIImage(named: "empty_coin"))
        nameLabel.setLocalizableText(coin.name)
        self.indexPath = indexPath
        if roundCorners {
            configBackgroundCorner(lastRow: last)
        }
    }
    
    public func setData(currency: Currency, indexPath: IndexPath, last: Bool, roundCorners: Bool = true) {
        iconImageView?.sd_setImage(with: URL(string: currency.iconPath), placeholderImage: UIImage(named: "empty_coin"))
        let nameText = "\(currency.name) (\(Locale.getCurrencySymbol(cur: currency.name)))"
        nameLabel.setLocalizableText(nameText)
        self.indexPath = indexPath
        if roundCorners {
            configBackgroundCorner(lastRow: last)
        }
    }
}

// MARK: - Actions
extension CheckmarkTableViewCell {
    fileprivate func configBackgroundCorner(lastRow: Bool) {
        if indexPath.row == 0 && lastRow {
            roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10)
        } else if indexPath.row == 0 {
            roundCorners([.topLeft, .topRight], radius: 10)
        } else if lastRow {
            roundCorners([.bottomLeft, .bottomRight], radius: 10)
        }
    }
}
