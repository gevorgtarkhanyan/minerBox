//
//  RewardsTableViewCell.swift
//  MinerBox
//
//  Created by Marina on 4/7/20.
//  Copyright © 2020 WitPlex. All rights reserved.
//

import UIKit

protocol ConverterButtonDelegate {
    func converterButtonTapped(indexPath: IndexPath)
}

class RewardsTableViewCell: BaseTableViewCell {

    // MARK: - Views
    @IBOutlet fileprivate weak var periodLabel: BaseLabel!
    @IBOutlet fileprivate weak var blocksLabel: BaseLabel?
    @IBOutlet fileprivate weak var luckLabel: BaseLabel!
    @IBOutlet fileprivate weak var coinLabel: BaseLabel!
    @IBOutlet fileprivate weak var converterButton: UIButton!
    @IBOutlet private weak var converterButtonTrailingCostraint: NSLayoutConstraint!
    
    fileprivate var indexPath: IndexPath!
    var delegate: ConverterButtonDelegate?
    
    override func changeColors() {
        backgroundColor = .clear
        let image = UIImage(named: "details_converter_white")?.withRenderingMode(.alwaysTemplate)
        converterButton.setImage(image, for: .normal)
        converterButton.tintColor = darkMode ? .white : .darkGray
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if UIDevice.current.userInterfaceIdiom == .pad {
            converterButtonTrailingCostraint.constant = 50
        } else {
            converterButtonTrailingCostraint.constant = 16
        }
    }
    
    @IBAction func converterButtonTapped(_ sender: UIButton) {
        delegate?.converterButtonTapped(indexPath: indexPath)
    }
    
}

// MARK: - Set data
extension RewardsTableViewCell {
    public func setData(reward: Reward, indexPath: IndexPath, coinsValue: [Double], rewardsBlockExist: Bool) {
        self.indexPath = indexPath
        periodLabel.setLocalizableText(reward.period.secondsToDayHr())
        coinLabel.setLocalizableText(coinsValue[indexPath.row].getString())
        
        if rewardsBlockExist {
            blocksLabel?.setLocalizableText(reward.blocks?.getString() ?? "")
        } else {
            blocksLabel?.removeFromSuperview()
        }
        
        guard reward.luckPer != -1 else {
            luckLabel?.removeFromSuperview()
            return
        }

        luckLabel.setLocalizableText(reward.luckPer.getString())
    }
}
