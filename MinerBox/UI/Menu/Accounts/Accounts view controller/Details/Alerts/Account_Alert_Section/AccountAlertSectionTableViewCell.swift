//
//  AccountAlertSectionTableViewCell.swift
//  MinerBox
//
//  Created by Gevorg Tarkhanyan on 29.03.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit

protocol AccountAlertSectionTableViewCellDelegate: AnyObject {
    func sectionHeaderSelected(section: Int, show: Bool)
}

class AccountAlertSectionTableViewCell: BaseTableViewCell {
    
    
    @IBOutlet weak var cellSwipingView: UIView!
    @IBOutlet weak var CellDataView: UIView!
    @IBOutlet weak var accountArrowButton: BaseButton!
    @IBOutlet weak  var alertTypeLabel: BaseLabel!
    @IBOutlet weak  var currentValueLabel: BaseLabel!
    @IBOutlet weak  var countLabel: BaseLabel!
    
    weak var delegate: AccountAlertSectionTableViewCellDelegate?
    
    static var height: CGFloat = 50
    var indexPath: IndexPath?
    var shows = false
    
    let rates = UserDefaults.standard.value(forKey: "\(DatabaseManager.shared.currentUser?.id ?? "" )/rates") as? [String:Double]
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        showAccountSwipeView(false)
    }
    
    func initialSetup() {
        backgroundColor = .clear
        CellDataView?.backgroundColor = darkMode ? .viewDarkBackground : .sectionHeaderLight
        cellSwipingView?.backgroundColor = .red
        setInitialValuesArrow(show: shows)
        cellSwipingView?.alpha = 0
        accountArrowButton?.isUserInteractionEnabled = false
        
        if darkMode {
            accountArrowButton.setImage(UIImage(named: "arrow_down"), for: .normal)
        } else {
            accountArrowButton.setImage(UIImage(named: "arrow_down")?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        
    }
    
    func accountSetupCell(_ data: AccountAlertCellAsSectionDataModel, for indexPath: IndexPath, expanded: Bool) {
        alertTypeLabel.setLocalizableText(data.alertType)
        currentValueLabel.setLocalizableText(data.CurrentValue)
        let enabledAlerts = data.models.filter { $0.isEnabled }
        countLabel.setLocalizableText("\(enabledAlerts.count)/\(data.models.count)")
        self.indexPath = indexPath
    }
    
    fileprivate func rotateArrow(angle: CGFloat) {
        if accountArrowButton?.transform != CGAffineTransform(rotationAngle: angle) {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.accountArrowButton?.transform = CGAffineTransform(rotationAngle: angle)
            }
        }
    }
    func animateArrow(expanded: Bool) {
        rotateArrow(angle: expanded ? .pi : 0)
    }
}

// MARK: - Set data
extension AccountAlertSectionTableViewCell {
    public func setData(alertType: AccountAlertType, value: Double, enabledAlertsCount: Int, allAlertsCount: Int,account: PoolAccountModel) {
        alertTypeLabel?.setLocalizableText(alertType.rawValue)
        countLabel?.setLocalizableText("\(enabledAlertsCount)/\(allAlertsCount)")
        switch alertType {
        case .hashrate:
            currentValueLabel?.setLocalizableText(value.textFromHashrate(account: account))
        case .worker:
            currentValueLabel?.setLocalizableText(value.getFormatedString(maximumFractionDigits: 3))
        case .reportedHashrate:
            currentValueLabel?.setLocalizableText(value.textFromHashrate(account: account))
        }
    }
    func controlRoundCornersAccount(expanded: Bool) {
        if expanded {
            CellDataView?.roundCorners([.bottomLeft, .bottomRight], radius: 0)
            CellDataView?.roundCorners([.topLeft, .topRight], radius: 10)
        } else {
            CellDataView?.roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10)
        }
    }
    func setInitialValuesArrow(show: Bool) {
        rotateArrow(angle: 0)
        controlRoundCornersAccount(expanded: show)
    }
    func showAccountSwipeView(_ bool: Bool) {
        if bool {
            cellSwipingView.alpha = 1
        } else {
            cellSwipingView.alpha = 0
        }
    }
}
