//
//  CoinTableViewCell.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/31/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class CoinTableViewCell: BaseTableViewCell {

    @IBOutlet weak var imageParentView: UIView!
    @IBOutlet weak var coinImageView: UIImageView!
    @IBOutlet weak var coinNameLabel: BaseLabel!
    @IBOutlet weak var coinSymbolLabel: BaseLabel!
    @IBOutlet weak var algorithmLabel: BaseLabel!
    @IBOutlet weak var profitLabel: BaseLabel!
    @IBOutlet weak var revenueLabel: BaseLabel!
    

    static var height: CGFloat {
        return 64
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }
    
    private func initialSetup() {
        self.clipsToBounds = true
        imageParentView.layer.cornerRadius = CGFloat(10)
    }
    
    func setupCell(_ data: CoinTableViewDataModel, _ isTappedRevenue: Bool) {
        let rates = UserDefaults.standard.value(forKey: "\(DatabaseManager.shared.currentUser?.id ?? "" )/rates") as? [String:Double]

        self.coinImageView.sd_setImage(with: URL(string: data.imageName), completed: nil)
        self.coinNameLabel.text = data.coinName
        self.coinSymbolLabel.text = data.coinSymbol
        self.algorithmLabel.text = data.algorithmName
        self.profitLabel.text = "\(Locale.appCurrencySymbol) \((data.profit * (rates?[Locale.appCurrency] ?? 1.0)).getString())"
        self.revenueLabel.text = "\(Locale.appCurrencySymbol) \((data.revenue * (rates?[Locale.appCurrency] ?? 1.0)).getString())"
        
        styleProfitAndRevenueLabel(isTappedRevenue, with: data)
    }
    
    private func styleProfitAndRevenueLabel(_ isTappedRevenue: Bool, with data: CoinTableViewDataModel) {
        if isTappedRevenue {
                if data.revenue >= 0 {
                    self.revenueLabel.textColor = .workerGreen
                    self.profitLabel.textColor = darkMode ? .white : UIColor.black.withAlphaComponent(0.85)
                } else {
                    self.revenueLabel.textColor = .systemRed
                    self.profitLabel.textColor = darkMode ? .white : UIColor.black.withAlphaComponent(0.85)
                }
        } else {
            if data.profit >= 0 {
                    self.profitLabel.textColor = .workerGreen
                    self.revenueLabel.textColor = darkMode ? .white : UIColor.black.withAlphaComponent(0.85)
                } else {
                    self.profitLabel.textColor = .systemRed
                    self.revenueLabel.textColor = darkMode ? .white : UIColor.black.withAlphaComponent(0.85)
                }
        }
    }
}
