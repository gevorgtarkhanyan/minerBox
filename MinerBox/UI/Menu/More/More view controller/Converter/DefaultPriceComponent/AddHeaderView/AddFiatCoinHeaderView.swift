//
//  AddFiatCoinHeaderView.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 22.03.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

class AddFiatCoinHeaderView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var nameLabel: BaseLabel!
    
    @IBOutlet weak var addImgeView: UIImageView!
    
    static var height: CGFloat {
        return 35
    }
    
    init(frame: CGRect, tag: Int) {
        super.init(frame: frame)
        
        self.tag = tag
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("AddFiatCoinHeaderView", owner: self, options: nil)
        
//        backgroundColor = .tableCellBackground
        
        contentView.backgroundColor = darkMode ? .viewDarkBackground : .sectionHeaderLight
        contentView.roundCorners([.topLeft, .topRight], radius: 10)
        addSubview(contentView)
        contentView.frame = self.bounds
        roundCorners([.topLeft, .topRight], radius: 10)
        nameLabel.textColor = .barSelectedItem
        nameLabel.text = tag == 0 ? "fiat".localized() : "coin_sort_coin".localized()
    }
    
}
