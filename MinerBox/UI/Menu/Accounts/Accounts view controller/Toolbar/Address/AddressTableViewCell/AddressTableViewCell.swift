//
//  WalletTableViewCell.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 08.02.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit

protocol AddressTableViewCellDelegate: AnyObject {
    func buttonSelect(indexpath: IndexPath)
    func exchangeButtonSelect(indexpath: IndexPath)
    func explorerButtonSelect(indexpath: IndexPath)
    
}

class AddressTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var explorerButton: AreaButton!
    @IBOutlet weak var coinBackgroundView: UIView!
    @IBOutlet weak var coinIconeImageView: BaseImageView!
    @IBOutlet weak var coinCurrencyLabel: BaseLabel!
    @IBOutlet weak var coinLabel: BaseLabel!
    @IBOutlet weak var descriptLabel: BaseLabel!
    @IBOutlet weak var exchangeButton: AreaButton!
    @IBOutlet weak var detailButton: BaseButton!
    @IBOutlet weak var checkmarkButton: UIButton!
    @IBOutlet weak var checkMarkBackgroundWidthContraits: NSLayoutConstraint!
    @IBOutlet weak var loadedButton: UIButton!
    
    typealias DetailsData = [(name: String, value: String, showQrCopy: Bool)]
    
    weak var delegate: AddressTableViewCellDelegate?
    private var indexPath: IndexPath = .zero
    
    private var address: AddressModel = AddressModel()
    static var height: CGFloat = 44
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialSetup()
    }
    override func draw(_ rect: CGRect) {
        self.addSeparatorView(from: self, to: self)
    }
    
    private func initialSetup() {
        self.coinBackgroundView.roundCorners(radius: 5)
        self.coinIconeImageView.roundCorners(radius: 10)
        self.checkmarkButton.addTarget(self, action: #selector(buttonSelect), for: .touchUpInside)
        self.loadedButton.tintColor = .red
        self.checkmarkButton.tintColor = .barSelectedItem
        self.exchangeButton.tintColor = .barSelectedItem
        self.exchangeButton.addTarget(self, action: #selector(exchangeButtonSelect), for: .touchUpInside)
        self.detailButton.setImage(UIImage(named: "account_details")?.withRenderingMode(.alwaysTemplate), for: .normal)
        let leftInset = self.frame.width - detailButton.frame.width + exchangeButton.frame.width
        self.exchangeButton.setTouchInset(insets: UIEdgeInsets(top: 0, left: -leftInset, bottom: 0, right: 0))
        self.explorerButton.setTouchInset(insets: UIEdgeInsets(top: 0, left: -leftInset, bottom: 0, right: 0))
    }
    
    func setData(address: AddressModel, isSelectingMode: Bool, indexPath: IndexPath, loadedEnd: Bool, showExplorerIcon: Bool) {
        self.indexPath = indexPath
        self.address = address
        self.coinLabel.setLocalizableText(address.coinName)
        self.coinCurrencyLabel.setLocalizableText(address.currency)
        self.descriptLabel.setLocalizableText(address.description)
        self.coinIconeImageView.sd_setImage(with: URL(string: Constants.HttpUrlWithoutApi + "images/coins/" + address.coinId + ".png"), placeholderImage: UIImage(named: "empty_coin"))
        self.detailButton.addTarget(self, action: #selector(openPopUp), for: .touchUpInside)
        self.explorerButton.addTarget(self, action: #selector(explorerButtonSelect), for: .touchUpInside)
        self.checkMarkBackgroundWidthContraits.constant = isSelectingMode ? 44 : 0
        self.checkmarkButton.setImage(address.isSelected ? UIImage(named: "cell_checkmark"): UIImage(named:"Slected"), for: .normal)
        self.checkmarkButton.isHidden = !isSelectingMode
        self.loadedButton.addTarget(self, action: #selector(noLoadedButtonAction), for: .touchUpInside)
        if address.type == "coin" {
            self.explorerButton.isHidden = !showExplorerIcon
            self.coinLabel.isHidden = false
        } else {
            self.coinLabel.isHidden = true
            self.explorerButton.isHidden = true
            self.coinIconeImageView.sd_setImage(with: URL(string: Constants.HttpUrlWithoutApi + address.poolLogoImagePath), completed: nil)
            self.coinCurrencyLabel.setLocalizableText(address.poolName)
        }
        
        if address.hasWallet && address.walletLoaded != nil {
            if !address.walletLoaded! {
                self.loadedButton.isHidden = true
                if loadedEnd {
                    self.loadedButton.isHidden = false
                    Loading.shared.endLoadingForView(with: self.loadedButton)
                } else {
                    self.exchangeButton.isHidden = true
                    Loading.shared.startLoadingForView(with: self.loadedButton,scalePoint: 1)
                }
            } else {
                self.exchangeButton.isHidden = false
            }
        } else {
            Loading.shared.endLoadingForView(with: self.loadedButton)
            self.loadedButton.isHidden = true
            self.exchangeButton.isHidden = !address.hasWallet
        }
    }
    
    func configCredentialData(address: AddressModel) {
        var rows = DetailsData()
        
        guard let addressTypes = RealmWrapper.sharedInstance.getAllObjectsOfModel(AddressType.self) as? [AddressType], let addressType = addressTypes.filter({$0.typeName.lowercased() == address.type.lowercased()}).first else { return }
        
        for filed in addressType.fields {
            rows.append((name: filed.placeholder, value: address.credentials[filed.id] ?? "", showQrCopy: true))
        }
        
        guard let popVC = PopUpInfoViewController.initializeStoryboard() else { return }
        popVC.setData(rows: rows)
        UIApplication.getTopViewController()?.present(popVC, animated: true)
    }
    
    @objc func openPopUp(){
        self.configCredentialData(address: self.address)
    }
    
    @objc func exchangeButtonSelect() {
        if delegate != nil {
            self.delegate?.exchangeButtonSelect(indexpath: indexPath)
        }
    }
    
    @objc func explorerButtonSelect() {
        if delegate != nil {
            self.delegate?.explorerButtonSelect(indexpath: indexPath)
        }
    }
    
    @objc func buttonSelect() {
        if delegate != nil {
            self.delegate?.buttonSelect(indexpath: indexPath)
        }
    }
    @objc func noLoadedButtonAction() {
        self.loadedButton.titleLabel?.text = ""
        UIApplication.getTopViewController()?.showToastAlert("Out of date!".localized(), message: nil)
    }
}
