//
//  DetailTableViewCell.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/26/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class DetailTableViewCell: BaseTableViewCell {

    @IBOutlet weak var keyLabel: BaseLabel!
    @IBOutlet weak var valueLabel: BaseLabel!
    @IBOutlet weak var converterButton: ConverterButton!
    @IBOutlet weak var iconRightConstraint: NSLayoutConstraint!
    
    private var indexPath: IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }
    
    private func initialSetup() {
        keyLabel.changeFont(to: Constants.semiboldFont)
        keyLabel.changeFontSize(to: 13)
        valueLabel.changeFontSize(to: 13)
        roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 0)//prerpareFirReuse?
    }
    
    func setData(list: [(key: String, value: String)], coinId: String?, indexPath: IndexPath, isIconShow: Bool = false) {
        let item = list[indexPath.row]
        keyLabel.setLocalizableText(item.key)
        valueLabel.setLocalizableText(item.value)
        
        valueLabel.addSymbolAfterText(item.key == "shares" ? " %" : "")

        self.indexPath = indexPath
        configBackgroundCorner(lastRow: indexPath.row == list.indices.last)
        if isIconShow && item.key != "coins" {
            converterButton.setData(coinId, amount: item.value.toDouble())
            converterButton.isHidden = false
            iconRightConstraint.constant = 16
        }
        else {
            converterButton.setData(coinId, amount: item.value.toDouble())
            converterButton.isHidden = true
            iconRightConstraint.constant = -16
        }
    }
    
    private func configBackgroundCorner(lastRow: Bool) {
        if indexPath.row == 0 && lastRow {
            roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10)
        } else if indexPath.row == 0 {
            roundCorners([.topLeft, .topRight], radius: 10)
        } else if lastRow {
            roundCorners([.bottomLeft, .bottomRight], radius: 10)
        }
        else if indexPath.row != 0 && !lastRow {
            roundCorners([], radius: 0)
        }
    }
    
}
