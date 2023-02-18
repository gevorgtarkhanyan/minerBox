//
//  PoolInfoSecionView.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 10.08.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

class PoolInfoSecionView: BaseTableViewCell {
    
    // MARK: - Views
    
    @IBOutlet fileprivate weak var logoBackgroundView: UIView!
    @IBOutlet fileprivate weak var logoImageView: UIImageView!
    @IBOutlet weak var logoWidthConstraits: NSLayoutConstraint!
    
    
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet fileprivate weak var coinNameLabel: BaseLabel!
    @IBOutlet fileprivate weak var coinCurrencyLabel: BaseLabel!
    @IBOutlet weak var algoMinersOrWorkersLabel: BaseLabel!
    @IBOutlet weak var algosHashrateLabel: BaseLabel!
    @IBOutlet weak var sortedValueLabel: BaseLabel!
    
    
    
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
        arrowButton.backgroundColor = .clear
        if darkMode {
            arrowButton.setImage(UIImage(named: "arrow_down"), for: .normal)
        } else {
            arrowButton.setImage(UIImage(named: "arrow_down")?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        
    }
}

// MARK: - Set data
extension PoolInfoSecionView {
    
    public func setData(rows: ExpandableRowsForPoolInfo,IndexPath: IndexPath, isAlgos: Bool = false, sortedName: String) {
        self.indexPath = IndexPath
        coinNameLabel.setLocalizableText(rows.coinName)
        coinCurrencyLabel.setLocalizableText(rows.coinCurrency)
        algoMinersOrWorkersLabel.isHidden = true
        sortedValueLabel.isHidden = true
        algosHashrateLabel.isHidden = true
        logoImageView.tag = IndexPath.row
        
        if isAlgos {
            let components = sortedName.components(separatedBy: " ")
            
            algoMinersOrWorkersLabel.isHidden = false
            sortedValueLabel.isHidden = false
            algosHashrateLabel.isHidden = false
            
            if sortedName == "name" {sortedValueLabel.setLocalizableText("") }
            
            if let hashrate = rows.rows.filter({$0.name == "hashrate"}).first {
                algosHashrateLabel.setLocalizableText(hashrate.value)
            }
            if let activeWorkers = rows.rows.filter({$0.name == "active_workers"}).first {
                algoMinersOrWorkersLabel.setLocalizableText(activeWorkers.value)
            }
            if let activeMiners = rows.rows.filter({$0.name == "active_miners"}).first {
                algoMinersOrWorkersLabel.setLocalizableText(activeMiners.value)
            }
            if let sortedValue = rows.rows.filter({$0.name == sortedName}).first {
                if sortedName != "name" && sortedName != "hashrate" && sortedName != "active_workers" && sortedName != "active_miners" {
                    sortedValueLabel.setLocalizableText(sortedValue.value)
                }
                else {
                    sortedValueLabel.setLocalizableText("")
                }
            } else if components.count > 1 {  // ForMiningModes Types
                if let sortedValue = rows.rows.filter({$0.name.localized() == components[1] && $0.systemTyoe == components[0] }).first  {
                    sortedValueLabel.setLocalizableText(sortedValue.value)
                }
            }
        } else {
            algosHashrateLabel.isHidden = false
            algoMinersOrWorkersLabel.isHidden = false
            
            
            if let hashrate = rows.rows.filter({$0.name == "hashrate"}).first {
                algosHashrateLabel.setLocalizableText(hashrate.value)
            }
            if let activeWorkers = rows.rows.filter({$0.name == "active_workers"}).first {
                algoMinersOrWorkersLabel.setLocalizableText(activeWorkers.value)
            }
            if let activeMiners = rows.rows.filter({$0.name == "active_miners"}).first {
                algoMinersOrWorkersLabel.setLocalizableText(activeMiners.value)
            }
            
            if let sortedValue = rows.rows.filter({$0.name == sortedName}).first {
                if sortedName != "name" && sortedName != "hashrate" && sortedName != "active_workers" && sortedName != "active_miners" {
                    sortedValueLabel.isHidden = false
                    sortedValueLabel.setLocalizableText(sortedValue.value)
                }
                else {
                    sortedValueLabel.setLocalizableText("")
                }
            }
        }
        
        guard  rows.coinImagePath != "" else {
            logoBackgroundView.isHidden = true
            logoWidthConstraits.constant = 0
            return
        }
        logoWidthConstraits.constant = 30
        logoBackgroundView.isHidden = false
        logoImageView.sd_setImage(with: URL(string: Constants.HttpUrlWithoutApi + "images/coins/" + rows.coinImagePath), placeholderImage: UIImage(named: "empty_coin"))

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
