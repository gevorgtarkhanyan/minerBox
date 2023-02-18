//
//  CustomHeaderWhatMineView.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 11/21/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class CustomHeaderWhatMineView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var borderBottomView: UIView!
    
    static var height: CGFloat {
        return 14
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("CustomHeaderWhatMineView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.backgroundColor = darkMode ? .viewDarkBackground : .sectionHeaderLight
        borderBottomView.backgroundColor = .clear
        contentView.roundCorners([.topLeft, .topRight], radius: 10)
    }
}
