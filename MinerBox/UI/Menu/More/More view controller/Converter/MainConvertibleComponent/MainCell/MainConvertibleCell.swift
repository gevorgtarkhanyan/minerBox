//
//  MainConvertibleCell.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/21/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class MainConvertibleCell: BaseTableViewCell {
    
    @IBOutlet weak var coinNameLabel: BaseLabel!
    @IBOutlet weak var coinValueLabel: BaseLabel!

    
    static var height: CGFloat {
        return 28
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        coinNameLabel.changeFontSize(to: 14)
        coinValueLabel.changeFontSize(to: 14)
    }
    
    public func setData(_ data: CoinModel, for indexPath: IndexPath) {
        let coinData = MainCriptoDataSource.coinModel(data)
        
        coinNameLabel.text = coinData[indexPath.row].mainInfo
        coinValueLabel.text = coinData[indexPath.row].mainValue
    }
    
    public func setData(_ data: FiatModel, at marketPriceBTC: Double, for indexPath: IndexPath) {
        let fiatData = MainCriptoDataSource.fiatModel(data, at: marketPriceBTC)
        
        coinNameLabel.text = fiatData[indexPath.row].mainInfo
        coinValueLabel.text = fiatData[indexPath.row].mainValue
    }
}
