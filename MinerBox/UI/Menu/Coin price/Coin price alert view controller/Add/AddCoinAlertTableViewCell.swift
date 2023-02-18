//
//  AddCoinAlertTableViewCell.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/15/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class AddCoinAlertTableViewCell: BaseTableViewCell {

    @IBOutlet weak var coinRankLabel: BaseLabel!
    @IBOutlet weak var coinSymbolLabel: BaseLabel!
    @IBOutlet weak var coinNameLabel: BaseLabel!
    @IBOutlet weak var priceParentView: UIView!
    @IBOutlet weak var coinPriceLabel: BaseLabel!
    @IBOutlet weak var iconParentView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var checkMarkImageView: UIImageView!
    
//    public var priceEmptying = false
    public var priceSelected = true
    
    private var indexPath: IndexPath = .zero
//    private(set) var price: String = ""
    public var coinId: String?

    static let height: CGFloat = 44
    
    let rates = UserDefaults.standard.value(forKey: "\(DatabaseManager.shared.currentUser?.id ?? "" )/rates") as? [String:Double]

    override func prepareForReuse() {
        super.prepareForReuse()
        checkMarkImageView.image = nil
        iconImageView.image = nil
    }
    
    override func startupSetup() {
        super.startupSetup()
        selectionStyle = .default

        let selectedView = UIView(frame: .zero)
        selectedView.backgroundColor = .tableCellBackground
        self.selectedBackgroundView = selectedView
        iconParentView.layer.cornerRadius = CGFloat(5)
        priceParentView.isHidden = true
    }
    
    public func setupCell(coins: [CoinModel], indexPath: IndexPath, last: Bool) {
        let coindData = coins[indexPath.row]
//        let imagePath = coindData.icon.contains("http") ? coindData.icon : Constants.HttpUrlWithoutApi + "images/coins/" + coindData.icon
        self.indexPath = indexPath
        iconImageView.sd_setImage(with: URL(string: coindData.iconPath), completed: nil)
        coinRankLabel.text = String(coindData.rank)
        coinSymbolLabel.setLocalizableText(coindData.symbol)
        coinNameLabel.setLocalizableText(coindData.name)
//        price = priceEmptying ? "\(Locale.appCurrencySymbol) " : "\(Locale.appCurrencySymbol) " + coindData.marketPriceUSD.getFormatedString(maximumFractionDigits: 3)
        coinPriceLabel.text = "\(coindData.currentAlertCurrency != "" ? Locale.getCurrencySymbol(cur: coindData.currentAlertCurrency) : Locale.appCurrencySymbol) " + coindData.marketPriceUSD.getString()
        coinId = coindData.coinId
        if coins.count != 0 {
            if coindData == coins[0] && coins.count != 1 {
                self.roundCorners([.topRight, .topLeft], radius: 10)
            } else if coindData == coins[coins.count - 1] {
                if coins.count == 1 {
                    roundCorners([.bottomLeft, .bottomRight, .topRight, .topLeft], radius: 10)
                } else {
                    roundCorners([.topRight, .topLeft], radius: 0)
                    roundCorners([.bottomLeft, .bottomRight], radius: 10)
                }
            } else {
                roundCorners([.topRight, .topLeft, .bottomLeft, .bottomRight], radius: 0)
            }
        }
    }
    
    public func setCurrentValue() {
        priceSelected.toggle()
        let image = priceSelected ? "cell_checkmark" : "Slected"
        checkMarkImageView.image = UIImage(named: image)
        contentView.layoutIfNeeded()
    }
    
    public func unselect() {
        priceSelected = false
        checkMarkImageView.image = UIImage(named: "Slected")
        contentView.layoutIfNeeded()
    }

}
