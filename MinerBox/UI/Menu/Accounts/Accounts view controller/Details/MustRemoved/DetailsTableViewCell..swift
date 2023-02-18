//
//  DetailsTableViewCell.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/2/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class DetailsTableViewCell: BaseTableViewCell {

    // MARK: - Views
    @IBOutlet fileprivate weak var keyLabel: BaseLabel!
    @IBOutlet fileprivate weak var valueLabel: BaseLabel!
    @IBOutlet weak var keyLeadingConstraits: NSLayoutConstraint!
    
    // For coin graph
    @IBOutlet fileprivate weak var changeValueLabel: UILabel!

    // MARK: - Properties
    fileprivate var indexPath: IndexPath = .zero
    
    override func startupSetup() {
        super.startupSetup()
        keyLabel.changeFont(to: Constants.semiboldFont)
        changeValueLabel?.font = Constants.regularFont.withSize(15)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 0)
    }
}

// MARK: - Set data
extension DetailsTableViewCell {
    public func setPayoutData(item: (name: String, value: String)) {
        backgroundColor = .clear
        keyLabel.setLocalizableText(item.name)

        valueLabel.setLocalizableText(item.value)
        valueLabel.adjustsFontSizeToFitWidth = false
    }

    public func setInfoData(list: ExpandableRowsForPoolInfo, indexPath: IndexPath, isSingelCoin:Bool = false) {
        let item = list.rows[isSingelCoin ? indexPath.row : indexPath.row - 1]
        keyLabel.setLocalizableText(item.name)
        valueLabel.setLocalizableText(item.value)
        
        self.indexPath = indexPath
        let indexPatchRow = isSingelCoin ? indexPath.row : indexPath.row - 1
        configBackgroundCorner(lastRow: indexPatchRow == list.rows.indices.last,isSingelCoin: isSingelCoin)
        
        self.keyLeadingConstraits.constant = 15
        
        if list.isSystemExist {
            if item.name == Fee.fee.rawValue ||  item.name == Fee.txFee.rawValue  || item.name == Fee.txFeeAuto.rawValue  || item.name == Fee.txFeeManual.rawValue  {
                self.keyLeadingConstraits.constant = 40
            } else {
                self.keyLeadingConstraits.constant = 15
            }
        }
    }

    public func setCoinGraphData(list: [(key: String, value: String)], indexPath: IndexPath) {
        let item = list[indexPath.row]
        keyLabel.setLocalizableText(item.key)

        if item.key.contains("change") {
            changeValueLabel.text = item.value.contains("-") ? "\(item.value)%" : "+\(item.value)%"
            changeValueLabel.textColor = item.value.contains("-") ? .workerRed : .workerGreen
            valueLabel.setLocalizableText("")
        } else {
            changeValueLabel.text = ""
            valueLabel.setLocalizableText(item.value)
        }

        self.indexPath = indexPath
        configBackgroundCorner(lastRow: indexPath.row == list.indices.last)
    }
}

// MARK: - Actions
extension DetailsTableViewCell {
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
