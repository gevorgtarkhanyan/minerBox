//
//  SelectCriptoTableViewCell.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/22/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class SelectCriptoTableViewCell: BaseTableViewCell {

    @IBOutlet weak var criptoImageView: UIImageView!
    @IBOutlet weak var criptoNameLabel: BaseLabel!
    @IBOutlet weak var imageParentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialSetup()
    }
    
    func initialSetup() {
        backgroundColor = .tableCellBackground
        imageParentView.layer.cornerRadius = CGFloat(5)
    }
    
    func setupFiatData(_ data: FiatModel) {
        criptoNameLabel.text = data.currency
        criptoImageView.sd_setImage(with: URL(string: data.flag), completed: nil)
    }
}
