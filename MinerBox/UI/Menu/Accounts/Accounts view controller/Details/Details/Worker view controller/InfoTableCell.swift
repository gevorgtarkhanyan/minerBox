//
//  InfoTableCell.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/5/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class InfoTableCell: BaseTableViewCell {

    // MARK: - Views
    fileprivate var stackView: UIStackView!

    fileprivate var nameLabel: BaseLabel!
    fileprivate var valueLabel: BaseLabel!
    
    fileprivate var qrShowButton: QRShowButton!
    fileprivate var copyButton: CopyButton!

    // MARK: - Static
    static let height: CGFloat = 20

    
    // MARK: - Startup
    override func startupSetup() {
        super.startupSetup()
        setupUI()
    }

    override func changeColors() {
        backgroundColor = .clear
    }
}

// MARK: - Setup UI
extension InfoTableCell {
    fileprivate func setupUI() {
        addStackView()
        addLabels()
        addQRShowButton()
        addCopyButton()
    }

    fileprivate func addStackView() {
        stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 5

        stackView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }

    fileprivate func addLabels() {
        // Add Name Label
        nameLabel = BaseLabel(frame: .zero)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(nameLabel)
        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        nameLabel.font = Constants.regularFont.withSize(14)

        // Add Value Label
        valueLabel = BaseLabel(frame: .zero)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(valueLabel)

        valueLabel.font = Constants.regularFont.withSize(11)
    }
    
    fileprivate func addQRShowButton() {
        qrShowButton = QRShowButton()
        qrShowButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(qrShowButton)
        qrShowButton.addConstraint(NSLayoutConstraint(item: self.qrShowButton!,
                                                      attribute: NSLayoutConstraint.Attribute.height,
                                                      relatedBy: NSLayoutConstraint.Relation.equal,
                                                      toItem: self.qrShowButton!,
                                                      attribute: NSLayoutConstraint.Attribute.width,
                                                      multiplier: 1,
                                                      constant: 0))
        
        qrShowButton.isHidden = true
    }
    
    fileprivate func addCopyButton() {
        copyButton = CopyButton()
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(copyButton)
        copyButton.addConstraint(NSLayoutConstraint(item: self.copyButton!,
                                                      attribute: NSLayoutConstraint.Attribute.height,
                                                      relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self.copyButton!,
                                                  attribute: NSLayoutConstraint.Attribute.width,
                                                  multiplier: 1,
                                                  constant: 0))
        copyButton.isHidden = true
    }
    
    //MARK: - QR and Copy
    fileprivate func setupQrShowButton(key: String, value: String) {
        qrShowButton.isHidden = false
//        qrShowButton.superview?.setNeedsDisplay()
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            qrShowButton.setController(topController)
            qrShowButton.setValueForQR(value)
        }
    }
    
    fileprivate func setupCopyButton(key: String, value: String) {
        copyButton.isHidden = false
//        copyButton.superview?.setNeedsDisplay()
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            copyButton.setController(topController)
            copyButton.setValueForCopy(value)
        }
    }
    
}

// MARK: - Set data
extension InfoTableCell {
    public func setData(key: String, value: String) {
        nameLabel.setLocalizableText(key)
        valueLabel.setLocalizableText(value)
        
        if key == "Referral" {
            setupQrShowButton(key: key, value: value)
            setupCopyButton(key: key, value: value)
        }
    }
}
