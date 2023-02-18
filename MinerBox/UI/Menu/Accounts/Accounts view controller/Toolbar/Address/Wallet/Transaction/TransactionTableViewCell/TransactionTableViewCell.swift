//
//  TransactionTableViewCell.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 03.03.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit

class TransactionTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var confirmLabel: UILabel!
    @IBOutlet weak var currencyLabel: BaseLabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var amountLabel: BaseLabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var detailButton: BaseButton!
    
    private var transaction: TransactionModel?
    
    static var height: CGFloat = 54
    
    typealias DetailsData = [(name: String, value: String, showQrCopy: Bool)]

    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialSetup()
    }
    
    func initialSetup() {
        self.backgroundColor = .clear
        self.confirmLabel.textColor = darkMode ? .lightGray : .darkGray
        self.dateLabel.textColor    = darkMode ? .lightGray : .darkGray
        self.statusLabel.textColor  = darkMode ? .lightGray : .darkGray
        self.feeLabel.textColor     = darkMode ? .lightGray : .darkGray
        self.detailButton.addTarget(self, action: #selector(openPopUp), for: .touchUpInside)
    }
    
    func setDate(transaction: TransactionModel) {
        
        self.transaction =  transaction
        self.confirmLabel.text   = transaction.confirmations?.getString()
        self.currencyLabel.text  = transaction.currency
        self.dateLabel.text      = transaction.date.getDateFromUnixTime()
        self.statusLabel.text    = transaction.status
        self.amountLabel.text    = transaction.amount?.getString()
        self.feeLabel.text       = transaction.fee?.getString() ?? "0"
        self.detailButton.setImage(UIImage(named: "account_details")?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    @objc func openPopUp(){
        guard transaction != nil else { return }
        self.configTransactionData(transaction: transaction!)
    }
    
    func configTransactionData(transaction: TransactionModel ) {
        
        var rows = DetailsData()
        
        let coinStrData = transaction.currency + "+" + transaction.coinId

        if let confirmation = transaction.confirmations {
            rows.append((name: "confirmations", value: confirmation.getString(), showQrCopy: false))
        }
        if let network = transaction.network {
            rows.append((name: "network", value: network, showQrCopy: false))
        }
        if let txId = transaction.txId {
            rows.append((name: "txId", value: txId, showQrCopy: false))
        }
        if let status =  transaction.status {
            rows.append((name: "status", value: status, showQrCopy: false))
        }
        if let amount =  transaction.amount {
            rows.append((name: "amount", value: amount.getString() + "+" + coinStrData, showQrCopy: false))
        }
        if let address =  transaction.address {
            rows.append((name: "address", value: address, showQrCopy: true))
        }
        if let type =  transaction.type {
            rows.append((name: "type", value: type, showQrCopy: false))
        }
        rows.append((name: "date", value: transaction.date.getDateFromUnixTime(), showQrCopy: false))

        if transaction.fee != nil && transaction.feePer != nil {
            let value = "\(transaction.fee!.getString())+(\(transaction.feePer!) % + \(coinStrData)"
            rows.append((name: "fee", value:value, showQrCopy: false))
        } else if transaction.fee != nil {
            let value = "\(transaction.fee!.getString())+\(coinStrData)"
            rows.append((name: "fee", value:value, showQrCopy: false))
        } else if transaction.feePer != nil {
            let value = "\(transaction.feePer!) %"
            rows.append((name: "fee", value:value, showQrCopy: false))
        }
        
        guard let popVC = PopUpInfoViewController.initializeStoryboard() else { return }
        popVC.setData(rows: rows)
        UIApplication.getTopViewController()?.present(popVC, animated: true)
    }
}
