//
//  AddWalletTableViewCell.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 10.02.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit

protocol AddAddressTableViewCellDelegate: AnyObject {
    func addFieldTextFieldChange(for text: String, indexPath: IndexPath?)
    func invalidButtonAction(buttonAction: Bool)
    func invalidImage(isHidden: Bool)
}

class AddAddressTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var fieldTextField: BaseTextField!
    public  var copyButton: CopyButton? = CopyButton()
    public  var invalidImage: UIImageView? = UIImageView()
    @IBOutlet weak var qrBackgroundView: UIView!
    @IBOutlet weak var qrScanButton: QRScanButton!
    weak var delegate: AddAddressTableViewCellDelegate?
    private var indexPath: IndexPath = .zero
    static var height: CGFloat = 49

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.qrScanButton.delegate = self
        self.qrBackgroundView.roundCorners(radius: 5)
        self.qrBackgroundView.backgroundColor = darkMode ? .viewDarkBackground: .sectionHeaderLight
        fieldTextField.rightView = getQRscanButton()
        fieldTextField.rightViewMode = .always
        copyButton?.isEnabled = false
        invalidImage?.isHidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(invalidButtonAction))
        invalidImage!.addGestureRecognizer(tap)
        invalidImage!.isUserInteractionEnabled = true

    }
    
    func setData(field: FieldModel, indexPath: IndexPath, vc: UIViewController) {
        self.indexPath = indexPath
        self.fieldTextField.setPlaceholder(field.placeholder)
        self.fieldTextField.text = field.inputFieldText
        self.copyButton?.setController(vc)
        guard field.inputFieldText.isEmpty  else {
            self.copyButton?.isEnabled = true
            self.copyButton?.setValueForCopy(field.inputFieldText)
            return
        }
    }
    
    func getQRscanButton() -> UIView {
        
        let backgorundView = BaseView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let maskView = UIView(frame:  CGRect(x: 0, y: 0, width: 22, height: 20))
        copyButton?.backgroundColor = .clear
        backgorundView.backgroundColor = .clear
        maskView.backgroundColor = .clear
        backgorundView.roundCorners(radius: 5)
        backgorundView.addSubview(copyButton ?? UIView())
        backgorundView.addSubview(invalidImage ?? UIView())
        invalidImage?.image = UIImage(named: "attention_sign")
        copyButton?.translatesAutoresizingMaskIntoConstraints = false
        copyButton?.topAnchor.constraint(equalTo: backgorundView.topAnchor,constant: 0).isActive = true
        copyButton?.bottomAnchor.constraint(equalTo: backgorundView.bottomAnchor,constant: 0).isActive = true
        copyButton?.leftAnchor.constraint(equalTo: backgorundView.leftAnchor,constant: 0).isActive = true
        copyButton?.rightAnchor.constraint(equalTo: backgorundView.rightAnchor,constant: 0).isActive = true
        invalidImage?.translatesAutoresizingMaskIntoConstraints = false
        invalidImage?.topAnchor.constraint(equalTo: backgorundView.topAnchor,constant: 2).isActive = true
        invalidImage?.bottomAnchor.constraint(equalTo: backgorundView.bottomAnchor,constant: -2).isActive = true
        invalidImage?.leftAnchor.constraint(equalTo: backgorundView.leftAnchor,constant: 2).isActive = true
        invalidImage?.rightAnchor.constraint(equalTo: backgorundView.rightAnchor,constant: -2).isActive = true
        backgorundView.contentMode = .scaleAspectFit
        maskView.addSubview(backgorundView)
        maskView.contentMode = .left
        
        if #available(iOS 13.0, *) {
            backgorundView.heightAnchor.set(to: 20.0)
            backgorundView.widthAnchor.set(to: 20.0)
            maskView.heightAnchor.set(to: 20.0)
            maskView.widthAnchor.set(to: 22.0)
        }
        return maskView
    }
    
    @objc func invalidButtonAction() {
        delegate?.invalidButtonAction(buttonAction: true)
    }

    @IBAction func textFielEditingChanged(_ sender: Any) {
        if delegate != nil {
            copyButton?.isEnabled = fieldTextField.text != ""
            delegate?.addFieldTextFieldChange(for: fieldTextField.text ?? "", indexPath: self.indexPath)
            copyButton?.setValueForCopy(fieldTextField.text ?? "")
        }
        delegate?.invalidImage(isHidden: invalidImage?.isHidden ?? false)
    }
}


// MARK: - QRButton delegate
extension AddAddressTableViewCell: QRButtonDelegate {
    
    func scanResult(text: String) {
        self.fieldTextField.text = text
        delegate?.addFieldTextFieldChange(for: fieldTextField.text ?? "", indexPath: self.indexPath)
        guard text.isEmpty else {
            invalidImage?.isHidden = true
            copyButton?.isEnabled = true
            copyButton?.setValueForCopy(text)
            return
        }
    }
    
    func showInvalidIcon() {
        invalidImage?.isHidden = false
        copyButton?.isHidden = true
    }
}


