//
//  CoinStateTableViewCell.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 17.08.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

class CoinStateTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var keyLabbel: BaseLabel!
    @IBOutlet weak var valueLabbel: BaseLabel!
    @IBOutlet weak var convertorButton: ConverterButton!
    @IBOutlet var converterButtonWidth: NSLayoutConstraint!
    @IBOutlet var converterButtonTrailingConstraint: NSLayoutConstraint!
    
    fileprivate var indexPath: IndexPath = .zero
    
    override func startupSetup() {
        super.startupSetup()
        keyLabbel.changeFont(to: Constants.semiboldFont)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 0)
    }
    
}

extension CoinStateTableViewCell {
    
    
    public func setCoinData(list: ExpandableRows, indexPath: IndexPath, isSingelCoin:Bool = false) {
        let item = list.rows[isSingelCoin ? indexPath.row : indexPath.row - 1]
        keyLabbel.setLocalizableText(item.name)
        valueLabbel.setLocalizableText(item.value)
        
        self.indexPath = indexPath
        let indexPatchRow = isSingelCoin ? indexPath.row : indexPath.row - 1
        configBackgroundCorner(lastRow: indexPatchRow == list.rows.indices.last,isSingelCoin: isSingelCoin)
        self.convertorButton.setData(list.coinId, amount: item.value.toDouble())
        if item.name == "next_payout_time" {
            convertorButton.isHidden =  true
            converterButtonWidth.constant = 0
            converterButtonTrailingConstraint.constant = 10
        } else {
            convertorButton.isHidden =  false
            converterButtonWidth.constant = 24
            converterButtonTrailingConstraint.constant = 16
        }
    }
}

// MARK: - Actions
extension CoinStateTableViewCell {
    fileprivate func configBackgroundCorner(lastRow: Bool,isSingelCoin:Bool = true) {
        if indexPath.row == 0 && lastRow {
            roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10)
        } else if indexPath.row == 0 {
            roundCorners([.topLeft, .topRight], radius: 10)
        } else if !isSingelCoin && indexPath.row == 1 {
            roundCorners([.topLeft, .topRight], radius: 10)
        } else if lastRow {
            roundCorners([.bottomLeft, .bottomRight], radius: 10)
        }
    }
}
