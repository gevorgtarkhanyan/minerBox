//
//  ConverterFlagCell.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/18/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class ConverterFlagCell: BaseTableViewCell {
    
    @IBOutlet weak var flagContentView: UIView!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var criptoNameLabel: UILabel!
    @IBOutlet weak var criptoValueLabel: BaseLabel!
    @IBOutlet weak var borderBottomView: UIView!
    
    static var height: CGFloat {
        return 35
    }
    
    private var fiatData: [FiatModel]?
    private var coinData: [CoinModel]?
    private var indexPath = IndexPath()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        borderBottomView.backgroundColor = .separator
        criptoValueLabel.changeFontSize(to: 14)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cornerRadiusSetup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        borderBottomView.isHidden = false
        fiatData = nil
        coinData = nil
    }
    
    func setFiatData(_ data: [FiatModel], for indexPath: IndexPath) {
        self.indexPath = indexPath
        self.fiatData = data
        let currentData = data[indexPath.row]
        let fiatData = CoinFiatDataSource.fiatModel(currentData)
//        priceLabel.text = fiatData.priceName
        flagImageView.sd_setImage(with: URL(string: fiatData.flagName), completed: nil)
        criptoNameLabel.text = fiatData.criptoName
        criptoValueLabel.text = fiatData.changeAblePrice.getString() + " " +  fiatData.criptoValue
    }
    
    func setCoinData(_ data: [CoinModel], for indexPath: IndexPath) {
        self.indexPath = indexPath
        self.coinData = data
        let currentData = data[indexPath.row]
        let coinData = CoinFiatDataSource.coinModel(currentData)
//        priceLabel.text = coinData.priceName
//        let imagePath = coinData.flagName.contains("http") ? coinData.flagName : Constants.HttpUrlWithoutApi + "images/coins/" + coinData.flagName
        flagImageView.sd_setImage(with: URL(string: coinData.flagName), completed: nil)
        criptoNameLabel.text = coinData.criptoName
        criptoValueLabel.text = coinData.changeAblePrice.getString() + " " + coinData.criptoValue
    }
    
    private func cornerRadiusSetup() {
        if let fiatData = fiatData {
            let currentData = fiatData[indexPath.row]
            if currentData == fiatData.last {
                roundCorners([.bottomLeft, .bottomRight], radius: 10)
                borderBottomView.isHidden = true
            } else {
                roundCorners([.topLeft, .topRight], radius: 0)
            }
        } else if let coinData = coinData {
            let currentData = coinData[indexPath.row]
            if currentData == coinData.last {
                roundCorners([.bottomLeft, .bottomRight], radius: 10)
                borderBottomView.isHidden = true
            } else {
                roundCorners([.bottomLeft, .bottomRight], radius: 0)
            }
        }
    }
    
}
