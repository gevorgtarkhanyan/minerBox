//
//  BalanceSectionTableViewCell.swift
//  MinerBox
//
//  Created by Vazgen Hovakinyan on 14.05.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit
import SwiftUI

protocol BalanceSectionViewDelegate: AnyObject {
    func goToDetalPage(section: Int)
    func selectedButtonTapped(for section: Int)

}

class BalanceSectionView: UIView {
    
    @IBOutlet weak var transformPoolDetailButton: UIButton!
    @IBOutlet weak var accountNameLabbel: BaseLabel!
    @IBOutlet weak var poolNameLabbel: BaseLabel!
    @IBOutlet weak var selectedButton: UIButton!
    @IBOutlet weak var selectedButtonWidthConstraits: NSLayoutConstraint!
    
    @IBOutlet var contentView: UIView!
    
    var section: Int?
    weak var delegate: BalanceSectionViewDelegate?

    static var height: CGFloat = 36


    override init(frame: CGRect) {
           super.init(frame: frame)
           commonInit()
       }
       
       required init?(coder: NSCoder) {
           super.init(coder: coder)
           commonInit()
       }
       
       private func commonInit() {
        Bundle.main.loadNibNamed("BalanceSectionView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        initialSetup()
       }

    func initialSetup() {
        
        contentView.roundCorners([.topLeft, .topRight], radius: 10)
        accountNameLabbel.font = Constants.semiboldFont.withSize(15)
        poolNameLabbel.font = Constants.regularFont.withSize(12)

    }
    
    func setData(pool: PoolBalanceModel, section: Int) {
        self.section = section
        self.selectedButtonWidthConstraits.constant = 25
        
        if pool.isSelected {
            self.selectedButton.setImage(UIImage(named: "cell_checkmark"), for: .normal)
            accountNameLabbel.isEnabled = true
            poolNameLabbel.isEnabled = true
            transformPoolDetailButton.isEnabled = true
        } else {
            accountNameLabbel.isEnabled = false
            poolNameLabbel.isEnabled = false
            transformPoolDetailButton.isEnabled = false
            self.selectedButton.setImage(UIImage(named: "Slected"), for: .normal)
        }
        self.selectedButton.addTarget(self, action: #selector(selectedButtonTapped), for: .touchUpInside)
        self.transformPoolDetailButton.addTarget(self, action: #selector(goToDetalPage), for: .touchUpInside)
        contentView.backgroundColor =  darkMode ? .viewDarkBackground: .sectionHeaderLight
        self.accountNameLabbel.setLocalizableText(pool.poolAccountLabel)
        self.poolNameLabbel.setLocalizableText("\(pool.poolTypeName)\(pool.poolSubItemName) ")
        self.transformPoolDetailButton.setImage(UIImage(named: "details_section_header_arrow")!.withRenderingMode(.alwaysTemplate), for: .normal)
        transformPoolDetailButton.tintColor = darkMode ? .sectionHeaderLight : .viewDarkBackground
    }
    
    
    // MARK: - Delegate Methods-
    @objc func goToDetalPage() {
        
        if let delegate = self.delegate,let section = section {
            delegate.goToDetalPage(section: section )

        }
    }
    @objc func selectedButtonTapped() {
        if let delegate = delegate, let section = section {
            
            delegate.selectedButtonTapped(for: section)
        }
    }
}
