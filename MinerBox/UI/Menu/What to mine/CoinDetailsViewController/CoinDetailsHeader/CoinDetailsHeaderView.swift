//
//  CoinDetailsHeaderView.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/31/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class CoinDetailsHeaderView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageParentView: UIView!
    @IBOutlet weak var coinImageView: UIImageView!
    @IBOutlet weak var nameLabel: BaseLabel!
    @IBOutlet weak var symbolLabel: BaseLabel!
    @IBOutlet weak var borderBottomView: UIView!
    @IBOutlet weak var CoinDetailsView: UIView!
    @IBOutlet weak var ToRightImageView: UIImageView!
    static var height: CGFloat {
        return 100
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
        Bundle.main.loadNibNamed("CoinDetailsHeaderView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.backgroundColor = darkMode ? .viewDarkBackground: .sectionHeaderLight
        contentView.roundCorners([.topLeft, .topRight], radius: 10)
        imageParentView.layer.cornerRadius = CGFloat(10)
        borderBottomView.backgroundColor = .separator
        CoinDetailsView.backgroundColor = darkMode ? .black .withAlphaComponent(0.5) : .white
        let image = UIImage(named: "ToRight")?.withRenderingMode(.alwaysTemplate)
        ToRightImageView?.image = image
        ToRightImageView?.tintColor = darkMode ? .white : .black
        nameLabel.textColor = darkMode ? .white : .black
        symbolLabel.textColor = darkMode ? .white : .black
        
    }
    
    func setupHeader(_ data: CoinTableViewDataModel) {
        coinImageView.sd_setImage(with: URL(string: data.imageName), completed: nil)
        nameLabel.text = data.coinName
        symbolLabel.text = data.coinSymbol
        
    }
}
