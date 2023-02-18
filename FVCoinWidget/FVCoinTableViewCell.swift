//
//  FVCoinTableViewCell.swift
//  FVCoinWidget
//
//  Created by Vazgen Hovakinyan on 24.02.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit
import SDWebImage


class FVCoinTableViewCell: UITableViewCell {
    
    // Coin
    @IBOutlet fileprivate var logoImageView: UIImageView!
    @IBOutlet fileprivate var logoBackground: UIView!
    
    @IBOutlet fileprivate var coinNameLabel: UILabel!

    // Price
    @IBOutlet fileprivate var priceValueLabel: BaseLabel!
    @IBOutlet fileprivate var priceCapitalizationLabel: BaseLabel!

    // Change
    @IBOutlet fileprivate var hourLabel: UILabel!
    @IBOutlet fileprivate var dayLabel: UILabel!
    @IBOutlet fileprivate var weekLabel: UILabel!
    
    let rates = UserDefaults.standard.value(forKey: "\(DatabaseManager.shared.currentUser?.id ?? "" )/rates") as? [String:Double]

    // MARK: - Static
    static var height: CGFloat = 100
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        logoImageView.layer.cornerRadius = 6.5
        logoBackground.layer.cornerRadius = 5

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    

}

// MARK: - Set data
extension FVCoinTableViewCell {
    public func setData(item: FVCoinModel,indexPath: IndexPath) {
        self.hourLabel.text                = "1h  \(item.change1h)"
        self.dayLabel.text                 = "24h  \(item.change24h)"
        self.weekLabel.text                = "1w  \(item.change7d)"
        self.coinNameLabel.text            = "\(item.symbol) / \(item.name)"
        self.priceValueLabel.text          = "\(Locale.appCurrencySymbol) \((item.marketPriceUSD * (rates?[Locale.appCurrency] ?? 1.0)).getString()) "
        self.priceCapitalizationLabel.text = "฿ \(item.marketPriceBTC.getString())"
  
        self.getLogoImage(item: item,indexPath: indexPath)
        
        self.configChangeLabels(coin: item)
        
    }
}

// MARK: - Actions
extension FVCoinTableViewCell {
    fileprivate func getLogoImage(item: FVCoinModel,indexPath: IndexPath) {
        let coinIconPath = Constants.HttpUrlWithoutApi + "images/coins/" + item.icon
        self.logoImageView.tag = indexPath.row
        self.logoImageView.sd_setImage(with: URL(string: "\(coinIconPath)"), placeholderImage: UIImage(named: "empty_coin"))
        
    }
    fileprivate func configChangeLabels(coin: FVCoinModel) {
        let hour = coin.change1h
        hourLabel.text = hour < 0 ? "\(hour)%" : "+\(hour)%"

        let day = coin.change24h
        dayLabel.text = day < 0 ? "\(day)%" : "+\(day)%"

        let week = coin.change7d
        weekLabel.text = week < 0 ? "\(week)%" : "+\(week)%"
        
        if week < 0 {
            hourLabel.textColor = .workerRed
            dayLabel.textColor = .workerRed
            weekLabel.textColor = .workerRed
        }
    }
}

