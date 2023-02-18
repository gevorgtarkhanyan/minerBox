//
//  EstimationsTableViewCell.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/4/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class EstimationsTableViewCell: BaseTableViewCell {

    // MARK: - Views
    @IBOutlet fileprivate weak var periodLabel: BaseLabel!
    @IBOutlet fileprivate weak var btcLabel: BaseLabel!
    @IBOutlet fileprivate weak var usdLabel: BaseLabel!
    @IBOutlet fileprivate weak var coinLabel: BaseLabel!
    @IBOutlet fileprivate weak var btcConverterButton: ConverterButton!
    @IBOutlet fileprivate weak var coinConverterButton: ConverterButton!
    @IBOutlet fileprivate weak var coinParentView: UIView!

    override func changeColors() {
        backgroundColor = .clear
    }
    
    // MARK: - Set data
    public func setData(period: String, btc: String, usd: String, coin: String, coinID: String, coinIsHidden: Bool) {
        periodLabel.setLocalizableText(period)
        btcLabel.setLocalizableText(btc)
        usdLabel.setLocalizableText(usd)
        coinLabel.setLocalizableText(coin)
        
        coinConverterButton.setData(coinID, amount: coin.toDouble() ?? 1)
        btcConverterButton.setData("bitcoin", amount: btc.toDouble() ?? 1)
        coinParentView.isHidden = coinIsHidden
    }
}

