//
//  WalletTableViewCell.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 23.02.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit

class WalletTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var iconeImageView: BaseImageView!
    @IBOutlet weak var currencyLabel: BaseLabel!
    @IBOutlet weak var coinNameLabel: BaseLabel!
    @IBOutlet weak var valueLabel: BaseLabel!
    @IBOutlet weak var priceLabel: BaseLabel!
    @IBOutlet weak var rightArrowView: BaseImageView!
    
    let rates = UserDefaults.standard.value(forKey: "\(DatabaseManager.shared.currentUser?.id ?? "" )/rates") as? [String:Double]

    static var height: CGFloat = 54
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialSetup()
    }

    func initialSetup() {
        self.backgroundColor = .clear
    }
    
    func setDate( ballance: WalletBalanceModel? ) {
        
        guard ballance != nil else { return }
        
        self.rightArrowView.isHidden = !ballance!.isDepositEnabled
        self.iconeImageView.sd_setImage(with: URL(string: Constants.HttpUrlWithoutApi + "images/coins/" + ballance!.coinId + ".png"), placeholderImage: UIImage(named: "empty_coin"))
        self.currencyLabel.setLocalizableText(ballance!.currency)
        self.coinNameLabel.setLocalizableText(ballance!.coinName)
        self.valueLabel.setLocalizableText(ballance!.availableBalance?.getString() ?? "")
        self.priceLabel.setLocalizableText("\(Locale.appCurrencySymbol) " + (ballance!.priceUSD ?? 1.0 * (rates?[Locale.appCurrency] ?? 1.0)).getString())
    }
    
}
