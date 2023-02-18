//
//  AddPoolTableViewCell.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 12.08.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

protocol AddPoolTableViewCellDelegate: AnyObject {
    func addPoolTextFieldChange(for text: String, indexPath: IndexPath?)
    func invalidButtonAction(buttonAction: Bool)
    func invalidImage(isHidden: Bool)
}

class AddPoolTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var textField: BaseTextField!
    @IBOutlet weak var qrScanButtons: QRScanButton!
    
    @IBOutlet weak var qrBackGroundView: BaseView!
    @IBOutlet weak var qrScanHeightConstraits: NSLayoutConstraint!
    @IBOutlet weak var textFieldQrDistance: NSLayoutConstraint!
    @IBOutlet weak var invalidParametrIcon: UIImageView!
    public var copyButton: CopyButton? = CopyButton()
    @IBOutlet weak var qrHeigthConstraits: NSLayoutConstraint!
    @IBOutlet var invalidIconConstraint: NSLayoutConstraint!
    
    var indexPath: IndexPath?
    var placeHolder = ""
    weak var delegate: AddPoolTableViewCellDelegate?
    
    static var height: CGFloat = 49
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialSetup()
        copyButton?.isEnabled = false
    }
    
    func initialSetup() {
        qrBackGroundView.roundCorners(radius: 5)
        qrBackGroundView.backgroundColor = darkMode ? .viewDarkBackground: .sectionHeaderLight
        backgroundColor = .none
        qrScanButtons.delegate = self
        qrScanButtons.clipsToBounds = true
        qrScanButtons.layer.cornerRadius = 5
        copyButton?.setController(UIApplication.getTopViewController() ?? UIViewController())
        textField.rightView = getQRscanButton()
        textField.rightViewMode = .always
        let tap = UITapGestureRecognizer(target: self, action: #selector(invalidButtonAction))
        invalidParametrIcon!.addGestureRecognizer(tap)
        invalidParametrIcon!.isUserInteractionEnabled = true
        
    }
    
    @IBAction func textFielEditingChanged(_ sender: Any) {
        if delegate != nil {
            copyButton?.isEnabled = textField.text != ""
            delegate?.addPoolTextFieldChange(for: textField.text ?? "", indexPath: self.indexPath)
            copyButton?.setValueForCopy(textField.text ?? "")
        }
        delegate?.invalidImage(isHidden: invalidParametrIcon?.isHidden ?? false)
    }
    
    @objc func invalidButtonAction() {
        delegate?.invalidButtonAction(buttonAction: true)
    }
    
    func getQRscanButton() -> UIView {
        
        let backgorundView = BaseView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let maskView = UIView(frame:  CGRect(x: 0, y: 0, width: 22, height: 20))
        copyButton?.backgroundColor = .clear
        maskView.backgroundColor = .clear
        backgorundView.backgroundColor = .clear
        backgorundView.roundCorners(radius: 5)
        backgorundView.addSubview(copyButton ?? UIView())
        copyButton?.translatesAutoresizingMaskIntoConstraints = false
        copyButton?.topAnchor.constraint(equalTo: backgorundView.topAnchor,constant: 0).isActive = true
        copyButton?.bottomAnchor.constraint(equalTo: backgorundView.bottomAnchor,constant: 0).isActive = true
        copyButton?.leftAnchor.constraint(equalTo: backgorundView.leftAnchor,constant: 0).isActive = true
        copyButton?.rightAnchor.constraint(equalTo: backgorundView.rightAnchor,constant: 0).isActive = true
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
    
}

// MARK: - Set data
extension AddPoolTableViewCell {
    
    public func setData(placeHolder: String, indexPath: IndexPath, oldAccountText: String = "") {
        self.indexPath = indexPath
        self.placeHolder = placeHolder
        self.indexPath = indexPath
        self.textField.text = oldAccountText
        self.copyButton?.setValueForCopy(oldAccountText)
        if placeHolder.contains("input") {
            self.textField.setPlaceholder(placeHolder.localized())
        } else {
            self.textField.setPlaceholder( "input".localized() + " " + placeHolder.localized())
        }
        if placeHolder == "optional_input_label" {
            self.qrScanButtons.isHidden = true
            self.qrHeigthConstraits.constant = 0
            self.copyButton?.isHidden = true
            self.textFieldQrDistance.constant = 0
        } else {
            self.qrScanButtons.isHidden = false
            self.qrHeigthConstraits.constant = 35
            self.copyButton?.isHidden = false
            self.textFieldQrDistance.constant = 5
        }
    }
}


// MARK: - QRButton delegate
extension AddPoolTableViewCell: QRButtonDelegate {
    func scanResult(text: String) {
        self.textField.text = text
        delegate?.addPoolTextFieldChange(for: textField.text ?? "", indexPath: self.indexPath)
        invalidParametrIcon.isHidden = true
        copyButton?.isEnabled = true
    }
}
