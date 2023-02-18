//
//  InfoLabel.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/2/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class InfoLabel: UILabel {

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        awakeFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Awake from NIB
    override func awakeFromNib() {
        super.awakeFromNib()
        defaultSetup()
    }
}

// MARK: - Default setup
extension InfoLabel {
    fileprivate func defaultSetup() {
        textColor = .white
        changeFontSize(to: font.pointSize)
    }
}

// MARK: - Set data
extension InfoLabel {
    public func changeFontSize(to value: CGFloat) {
        font = Constants.regularFont.withSize(value)
        adjustsFontSizeToFitWidth = true
    }
}
