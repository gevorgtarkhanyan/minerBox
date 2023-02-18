//
//  CoinAlertSectionTableViewCell.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 11/22/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class CoinAlertSectionTableViewCell: BaseTableViewCell {
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var iconParentView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var rankLabel: BaseLabel!
    @IBOutlet weak var coinSymbolLabel: BaseLabel!
    @IBOutlet weak var coinNameLabel: BaseLabel!
    @IBOutlet weak var priceLabel: BaseLabel!
    @IBOutlet weak var notifyInfoLabel: BaseLabel!
    @IBOutlet weak var swipingView: UIView!
    @IBOutlet weak var dataCoverView: UIView!
    
    static var height: CGFloat = 50
    var indexPath: IndexPath?
    var show = false
    
    let rates = UserDefaults.standard.value(forKey: "\(DatabaseManager.shared.currentUser?.id ?? "" )/rates") as? [String:Double]

    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        showSwipeView(false)
    }
    
    func initialSetup() {
        iconParentView.layer.cornerRadius = 10
        backgroundColor = .clear
        dataCoverView.backgroundColor = darkMode ? .viewDarkBackground : .sectionHeaderLight
        swipingView.backgroundColor = .red
        setInitialValues(show: show)
        swipingView.alpha = 0
        arrowButton.isUserInteractionEnabled = false
        
        if darkMode {
            arrowButton.setImage(UIImage(named: "arrow_down"), for: .normal)
        } else {
            arrowButton.setImage(UIImage(named: "arrow_down")?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    func setupCell(_ data: CoinAlertCellAsSectionDataModel, for indexPath: IndexPath, expanded: Bool) {
        rankLabel.setLocalizableText(data.rank)
//        let imagePath = data.url.contains("http") ? data.url : Constants.HttpUrlWithoutApi + "images/coins/" + data.url
        iconImageView.sd_setImage(with: URL(string: data.url), completed: nil)
        coinNameLabel.setLocalizableText(data.coinName)
        coinSymbolLabel.setLocalizableText(data.coinSymbolName)
        priceLabel.setLocalizableText(data.price)
        let enabledAlerts = data.models.filter { $0.isEnabled }
        notifyInfoLabel.setLocalizableText("\(enabledAlerts.count)/\(data.models.count)")
        self.indexPath = indexPath
    }
    
    private func rotateArrow(angle: CGFloat) {
        if arrowButton.transform != CGAffineTransform(rotationAngle: angle) {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.arrowButton.transform = CGAffineTransform(rotationAngle: angle)
            }
        }
    }
    
    func animateArrow(expanded: Bool) {
        rotateArrow(angle: expanded ? .pi : 0)
    }
    
    func controlRoundCorners(expanded: Bool) {
        if expanded {
            dataCoverView.roundCorners([.bottomLeft, .bottomRight], radius: 0)
            dataCoverView.roundCorners([.topLeft, .topRight], radius: 10)
        } else {
            dataCoverView.roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10)
        }
    }
    
    func setInitialValues(show: Bool) {
        rotateArrow(angle: 0)
        controlRoundCorners(expanded: show)
    }
    
    func showSwipeView(_ bool: Bool) {
        if bool {
            swipingView.alpha = 1
        } else {
            swipingView.alpha = 0
        }
    }
}
