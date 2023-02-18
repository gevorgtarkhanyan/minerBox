//
//  PayoutsInfoTableViewCell.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 10.05.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

class PopUpInfoTableViewCell: BaseTableViewCell {
    
    // MARK: - Views
    @IBOutlet fileprivate weak var keyLabel: UILabel!
    @IBOutlet fileprivate weak var valueLabel: BaseLabel!
    
    @IBOutlet fileprivate weak var qrButton: QRShowButton!
    @IBOutlet fileprivate weak var copyButton: CopyButton!
    @IBOutlet fileprivate weak var converterButton: ConverterButton!
    
    fileprivate weak var vc: UIViewController?
    
    static var height: CGFloat = 35

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - Properties
    fileprivate var indexPath: IndexPath = .zero
    
    override func startupSetup() {
        super.startupSetup()
        
        converterButton.isHidden = true
        qrButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 3, bottom: 5, right: 5)


    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 0)
    }
    deinit {
        debugPrint("PopUpInfoTableViewCell Deinit")
    }
    
    // MARK: - Set data
    public func setPayoutData(item: (name: String, value: String, showQrCopy: Bool), vc: UIViewController) {
        backgroundColor = .clear
        self.vc = vc
        
        keyLabel.text = item.name.localized() + ":"
        valueLabel.setLocalizableText(item.value)
        valueLabel.adjustsFontSizeToFitWidth = false
        
        setupButtons(with: item)
    }
    
    //MARK: - Buttons setup
    private func setupButtons(with item: (name: String, value: String, showQrCopy: Bool)) {
        configCopyAndQRButtons(item: item)
        setupConverterButton(with: item)
    }
    
    private func setupConverterButton(with item: (name: String, value: String, showQrCopy: Bool)) {
        guard item.name == "amount" || item.name == "account_rewards" || item.name == "txFee" || item.name == "fee" else { return }
        
        let components = item.value.components(separatedBy: "+")
        guard let amount = components.first?.toDouble(),
              let coinId = components.last else { return }

        var labelText = components[0] + " " + components[1]
        converterButton.isHidden = false
        
        if item.name == "txFee" {
            if components.count > 3 {
                labelText = components[0] + " " + components[components.count - 2] + " " + components[1]
            } else if components[0].contains("%") {
                converterButton.isHidden = true
            }
        }
        
        valueLabel.setLocalizableText(labelText)
        converterButton.setData(coinId, amount: amount)
        converterButton.setController(vc!)
    }

    private func configCopyAndQRButtons(item: (name: String, value: String, showQrCopy: Bool)) {
        guard let vc = vc else { return }
        
        qrButton.setController(vc)
        copyButton.setController(vc)
        if item.showQrCopy {
            qrButton.setValueForQR(item.value)
            copyButton.setValueForCopy(item.value)
        } else {
            copyButton.isHidden = true
            qrButton.isHidden = true
        }
    }
    
}
