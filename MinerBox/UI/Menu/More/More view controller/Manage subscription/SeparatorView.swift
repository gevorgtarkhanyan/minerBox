//
//  SeparatorView.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/19/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class SeparatorView: UIView {
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .separator
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Awake from NIB
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .separator
    }
}
