//
//  SelectCriptoCoinTableViewCell.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 30.03.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

class SelectCriptoCoinTableViewCell: BaseTableViewCell {

    @IBOutlet weak var coinRankLabel: BaseLabel!
    @IBOutlet weak var coinSymbolLabel: BaseLabel!
    @IBOutlet weak var coinNameLabel: BaseLabel!
    @IBOutlet weak var iconParentView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    static let height: CGFloat = 44
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func startupSetup() {
        super.startupSetup()
        selectionStyle = .default

        let selectedView = UIView(frame: .zero)
        selectedView.backgroundColor = .tableCellBackground
        self.selectedBackgroundView = selectedView
        iconParentView.layer.cornerRadius = CGFloat(5)
    }
    
    func setupCoinData(_ data: CoinModel) {
        coinRankLabel.text = String(data.rank)
        coinNameLabel.text = data.name
        coinSymbolLabel.text = data.symbol
//        let imagePath = data.icon.contains("http") ? data.icon : Constants.HttpUrlWithoutApi + "images/coins/" + data.icon
        iconImageView.sd_setImage(with: URL(string: data.iconPath), completed: nil)
    }
    
}
