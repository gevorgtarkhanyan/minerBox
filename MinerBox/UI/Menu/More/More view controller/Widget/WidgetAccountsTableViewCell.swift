//
//  WidgetAccountsTableViewCell.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/18/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

protocol WidgetAccountsTableViewDelegate: AnyObject {
    func selectBalanceRow(IndexPath: IndexPath, selectedBalance: String)
}

class WidgetAccountsTableViewCell: BaseTableViewCell {
    
    // MARK: - Views
    @IBOutlet weak var backgroundCellView: UIView!
    @IBOutlet fileprivate weak var balanceLabel: BaseLabel!
    @IBOutlet fileprivate weak var checkmarkButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    
    // MARK: - Static
    static var height: CGFloat = 40
    private var indexPath: IndexPath = .zero
    private var balance: String = ""
    var isSelectedBalance: Bool = false
    weak var delegate: WidgetAccountsTableViewDelegate?

    
    // MARK: - Startup
    override func startupSetup() {
        super.startupSetup()
        clipsToBounds = true
        backgroundColor = .clear
        backgroundCellView.backgroundColor = .tableCellBackground
        backgroundCellView.roundCorners([.bottomLeft, .bottomRight, .topRight, .topLeft], radius: 10)
    }
}


// MARK: - Set data
extension WidgetAccountsTableViewCell {
    public func setData(balances: [String], indexPath: IndexPath, selectedBalanceType: String) {
        let balance = balances[indexPath.row - 1]
        self.indexPath = indexPath
        balanceLabel.setLocalizableText(balance)
        checkmarkButton.addTarget(self, action: #selector(selectingBalanceRow), for: .touchUpInside)
        if selectedBalanceType == balance {
            checkmarkButton.setImage(UIImage(named: "cell_checkmark"), for: .normal)
            isSelectedBalance = true
        } else {
            checkmarkButton.setImage(UIImage(named:"Slected"), for: .normal)
            isSelectedBalance = false
        }
        self.balance = balance
        
    }
    func deselectButton() {
        checkmarkButton.setImage(UIImage(named:"Slected"), for: .normal)
    }
    func selectButton() {
        checkmarkButton.setImage(UIImage(named:"cell_checkmark"), for: .normal)
    }
    
    @objc func selectingBalanceRow() {
        if let delegate = self.delegate {
            var _balance = ""
            if isSelectedBalance {
                _balance = ""
                checkmarkButton.setImage(UIImage(named:"Slected"), for: .normal)
                isSelectedBalance.toggle()
            } else {
                _balance = self.balance
                checkmarkButton.setImage(UIImage(named: "cell_checkmark"), for: .normal)
                isSelectedBalance.toggle()
            }
            delegate.selectBalanceRow(IndexPath: indexPath, selectedBalance: _balance)
        }
    }
}
