//
//  TransactionTableHeaderView.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 03.03.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import Foundation
import UIKit

class TransactionTableHeaderView: UIView {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet var contentView: BaseView!
    
    static var height: CGFloat = 14

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()

        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("TransactionTableHeaderView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dateLabel.textColor = darkMode ? .lightGray : .gray
    }
    
    func setData(startDate: String, endDate: String) {
        dateLabel.text = startDate + " - " + endDate
    }
    
}
