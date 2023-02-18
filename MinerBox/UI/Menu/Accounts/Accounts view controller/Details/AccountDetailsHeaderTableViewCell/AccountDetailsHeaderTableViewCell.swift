//
//  AccountDetailsHeaderTableViewCell.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 16.08.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

class AccountDetailsHeaderTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var nameLabbel: BaseLabel!
    @IBOutlet weak var valueLabbel: BaseLabel!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var copyButton: CopyButton!
    @IBOutlet weak var qrShowButton: QRShowButton!
    
    @IBOutlet weak var QRBackgroundView: UIView!
    
    @IBOutlet weak var noLoadedView: UIView!
    @IBOutlet weak var noLoadedInfoButton: BaseButton!
    fileprivate let activityIndicatorForCell = UIActivityIndicatorView()
    
    static var height: CGFloat = 28

    fileprivate var indexPath: IndexPath = .zero
    fileprivate var invalidCredential = false
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialSetup()
        
    }
    
    func initialSetup() {
        backgroundColor = darkMode ? .viewDarkBackground : .sectionHeaderLight
        qrShowButton.setController(UIApplication.getTopViewController() ?? UIViewController())
        copyButton.setController(UIApplication.getTopViewController() ?? UIViewController())
        activityIndicatorForCell.isHidden = true
        noLoadedInfoButton.addTarget(self, action: #selector(noLoadedInfoButtonAction ), for: .touchUpInside)
    }
    
    fileprivate func startLoad() {
        self.activityIndicatorForCell.startAnimating()
        self.activityIndicatorForCell.color = .barSelectedItem
        self.noLoadedView.addSubview(activityIndicatorForCell)
        self.activityIndicatorForCell.frame =  noLoadedView.bounds
        contentView.layoutIfNeeded()
}
    
    @objc func noLoadedInfoButtonAction() {
        if invalidCredential  {
            UIApplication.getTopViewController()?.showAlertView(nil, message: "Pool Address Invalid!".localized(), completion: nil)
        } else {
            UIApplication.getTopViewController()?.showToastAlert("Out of date!".localized(), message: nil)
        }
    }
}

// MARK: - Set data
extension AccountDetailsHeaderTableViewCell {
    public func setData(data: DetailsHeader, indextPath: IndexPath, urlParamAsId: String = "",isloadedEnd:Bool, model: PoolSettingsModel, invalidCredentials:Bool) {
        
        self.indexPath = indextPath
        self.invalidCredential = invalidCredentials
        
        self.nameLabbel.setLocalizableText(data.name ?? "")
        self.nameLabbel.addSymbolAfterText(":")
        
        if data.name == "payment_method" || data.name == "last_updated" || data.name == "next_payout_time" || data.name == "Account" || data.name == "login_email" {
            self.valueLabbel.setLocalizableText(data.value ?? "")
        } else {
            if data.value != "" {
            self.valueLabbel.setLocalizableText(data.value?.showPoolId(idFormat: urlParamAsId) ?? "")
            } else {
                self.valueLabbel.setLocalizableText(data.value ?? "")
            }
        }
        
        self.buttonsStackView.isHidden =  data.isButtonShow ? false : true
            
            if !data.isloaded && data.name == "last_updated" || invalidCredentials && data.name == "last_updated" {
            if isloadedEnd {
                self.noLoadedInfoButton.isHidden = false
            } else {
                if !invalidCredentials {
                    self.noLoadedInfoButton.isHidden = true
                    self.startLoad()
                } else {
                    self.noLoadedInfoButton.isHidden = false
                }
            }
        } else {
            self.noLoadedInfoButton.isHidden = true
        }
            
        qrShowButton.setValueForQR(data.value ?? "")
        copyButton.setValueForCopy(data.value ?? "")
    }
}

