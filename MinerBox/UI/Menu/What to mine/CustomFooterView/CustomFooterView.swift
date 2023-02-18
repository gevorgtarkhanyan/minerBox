//
//  CustomFooterView.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 11/5/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class CustomFooterView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet var borderTopView: UIView!
    
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
        Bundle.main.loadNibNamed("CustomFooterView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.backgroundColor = .tableCellBackground
        borderTopView.backgroundColor = .cellTrailingFirst
        contentView.roundCorners([.bottomLeft, .bottomRight], radius: 10)
    }
}
