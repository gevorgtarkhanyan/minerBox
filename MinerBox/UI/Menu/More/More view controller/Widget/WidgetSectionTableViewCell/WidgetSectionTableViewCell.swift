//
//  WidgetHeaderView.swift
//  MinerBox
//
//  Created by Vazgen Hovakinyan on 11.06.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

protocol WidgetSectionTableViewDelegate: AnyObject {
    func selectSection(IndexPathFromCel: IndexPath, selected: Bool)
}

class WidgetSectionTableViewCell: BaseTableViewCell {
    
    // MARK: - Views
    
    @IBOutlet fileprivate weak var logoBackgroundView: UIView!
    @IBOutlet fileprivate weak var logoImageView: UIImageView!
    
    
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet fileprivate weak var poolNameLabel: BaseLabel!
    @IBOutlet fileprivate weak var accountNameLabel: BaseLabel!
    @IBOutlet fileprivate weak var checkmarkImageButton: UIButton!
    
    // MARK: - Static
    static var height: CGFloat = 50
    
    private var indexPath: IndexPath = .zero
    weak var delegate: WidgetSectionTableViewDelegate?
    var checkmarkIsSelect = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }
    
    func initialSetup() {
        
        backgroundColor =  darkMode ? .viewDarkBackground: .sectionHeaderLight
        roundCorners([.topLeft, .topRight,.bottomLeft,.bottomRight], radius: 10)
        logoBackgroundView.layer.cornerRadius = 6.5
        logoImageView.layer.cornerRadius = logoBackgroundView.layer.cornerRadius
        arrowButton.backgroundColor = .clear
        if darkMode {
            arrowButton.setImage(UIImage(named: "arrow_down"), for: .normal)
        } else {
            arrowButton.setImage(UIImage(named: "arrow_down")?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        checkmarkImageButton.addTarget(self, action: #selector(selectSection), for: .touchUpInside)
        
    }
}

// MARK: - Set data
extension WidgetSectionTableViewCell {
    
    public func setData(account: PoolAccountModel,IndexPath: IndexPath, isSubscribe: Bool) {
        self.indexPath = IndexPath
        poolNameLabel.setLocalizableText(account.poolName)
        accountNameLabel.setLocalizableText(account.poolAccountLabel)
        getLogoImage(model: account)
        self.arrowButton.isHidden = account.balances.count == 0 ? true : false
        checkmarkImageButton.isEnabled = isSubscribe
        checkmarkIsSelect = account.selected
        checkmarkImageButton.setImage(account.selected ? UIImage(named: "cell_checkmark"): UIImage(named:"Slected"), for: .normal)
        
    }
    public func setData(coin: CoinModel,IndexPath: IndexPath) {
        self.indexPath = IndexPath
        poolNameLabel.setLocalizableText(coin.name)
        accountNameLabel.setLocalizableText(coin.symbol)
//        let coinIconPath = Constants.HttpUrlWithoutApi + "images/coins/" + coin.icon
        logoImageView.tag = IndexPath.row
        logoImageView.sd_setImage(with: URL(string: coin.iconPath), placeholderImage: UIImage(named: "empty_coin"))
        arrowButton.isHidden = true
        checkmarkIsSelect = coin.fvSelected
        checkmarkImageButton.isEnabled = true
        checkmarkImageButton.setImage(coin.fvSelected ? UIImage(named: "cell_checkmark"): UIImage(named:"Slected"), for: .normal)
    }
    
    fileprivate func getLogoImage(model: PoolAccountModel) {
        guard let pool = DatabaseManager.shared.getPool(id: model.poolType) else { return }
        logoImageView.sd_setImage(with: URL(string: Constants.HttpUrlWithoutApi + pool.poolLogoImagePath), completed: nil)
    }
    
    func rotateArrow(angle: CGFloat) {
        if arrowButton.transform != CGAffineTransform(rotationAngle: angle) {
            DispatchQueue.main.async {
                UIView.animate(withDuration: Constants.animationDuration) {
                    self.arrowButton.transform = CGAffineTransform(rotationAngle: angle)
                }
            }
        }
    }
    
    func animateArrow(expanded: Bool) {
        rotateArrow(angle: expanded ? .pi : 0)
    }
    
    @objc func selectSection() {
        
        if let delegate = self.delegate {
            delegate.selectSection(IndexPathFromCel: indexPath,selected: checkmarkIsSelect)
        }
        checkmarkIsSelect.toggle()
        checkmarkImageButton.setImage(checkmarkIsSelect ? UIImage(named: "cell_checkmark"): UIImage(named:"Slected"), for: .normal)
    }
}



