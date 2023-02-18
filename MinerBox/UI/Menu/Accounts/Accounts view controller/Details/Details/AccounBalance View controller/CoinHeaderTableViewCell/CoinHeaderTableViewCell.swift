//
//  CoinHeaderTableViewCell.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 17.08.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

protocol CoinHeaderTableViewCellDelegate: AnyObject {
    func rightArrowTapped(index: Int)
}

class CoinHeaderTableViewCell: BaseTableViewCell {

    // MARK: - Views
    @IBOutlet fileprivate weak var logoBackgroundView: UIView!
    @IBOutlet fileprivate weak var logoImageView: UIImageView!
    @IBOutlet weak var logoWidthConstraits: NSLayoutConstraint!
    
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var rightArrowButton: UIButton!
    @IBOutlet fileprivate weak var coinNameLabel: BaseLabel!
    @IBOutlet fileprivate weak var coinCurrencyLabel: BaseLabel!
    
    weak var delegate: CoinHeaderTableViewCellDelegate?
    
    // MARK: - Static
    static var height: CGFloat = 50
    private var indexPath: IndexPath = .zero
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }
    
    func initialSetup() {
        backgroundColor =  darkMode ? .viewDarkBackground: .sectionHeaderLight
        roundCorners([.topLeft, .topRight ,.bottomLeft ,.bottomRight], radius: 10)
        logoBackgroundView.layer.cornerRadius = 6.5
        logoImageView.layer.cornerRadius = logoBackgroundView.layer.cornerRadius
        setupButtons()
    }
    
    private func setupButtons() {
        arrowButton.backgroundColor = .clear
    
        arrowButton.setImage(UIImage(named: "arrow_down")?.withRenderingMode(.alwaysTemplate), for: .normal)
        rightArrowButton.setImage(UIImage(named: "details_section_header_arrow")?.withRenderingMode(.alwaysTemplate), for: .normal)
        arrowButton.tintColor = darkMode ? .white : .black
        rightArrowButton.tintColor = darkMode ? .white : .black
        
      //  rightArrowButton.isHidden = Cacher.shared.accountSettings?.recentCredits.isEmpty ?? true
        rightArrowButton.addTarget(self, action: #selector(rightArrowButtonTapped), for: .touchUpInside)
    }
    
    @objc func rightArrowButtonTapped() {
        delegate?.rightArrowTapped(index: tag)
    }
}

// MARK: - Set data
extension CoinHeaderTableViewCell {
    public func setData(rows: ExpandableRows,IndexPath: IndexPath, hideRightArrowButton: Bool) {
        self.indexPath = IndexPath
        self.rightArrowButton.isHidden = hideRightArrowButton
        coinNameLabel.setLocalizableText(rows.coinName)
        coinCurrencyLabel.setLocalizableText(rows.coinCurrency)
        logoImageView.tag = IndexPath.row
        tag = indexPath.section

        logoWidthConstraits.constant = 30
        logoBackgroundView.isHidden = false
        if rows.coinImagePath != "" {
            logoImageView.sd_setImage(with: URL(string: Constants.HttpUrlWithoutApi + "images/coins/" + rows.coinImagePath), placeholderImage: UIImage(named: "empty_coin"))
        } else {
            logoImageView.sd_setImage(with: URL(string: Constants.HttpUrlWithoutApi + "images/coins/" + rows.coinId + ".png"), placeholderImage: UIImage(named: "empty_coin"))
        }
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
}
