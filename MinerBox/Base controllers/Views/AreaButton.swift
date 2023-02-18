//
//  AreaButton.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 17.03.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit

class AreaButton: UIButton {

    // MARK: - Properties
    fileprivate(set) var touchInsets = UIEdgeInsets()
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return bounds.inset(by: self.touchInsets).contains(point)
    }
    
    public func setTouchInset(insets: UIEdgeInsets) {
        self.touchInsets = insets
    }

}
