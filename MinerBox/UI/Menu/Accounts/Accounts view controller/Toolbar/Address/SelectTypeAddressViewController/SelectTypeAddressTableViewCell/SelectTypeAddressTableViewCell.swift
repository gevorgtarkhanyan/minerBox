//
//  SelectTypeAddressTableViewCell.swift
//  MinerBox
//
//  Created by Gevorg Tarkhanyan on 07.07.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit

class SelectTypeAddressTableViewCell: BaseTableViewCell {

    @IBOutlet weak var TypeImage: UIImageView!
    @IBOutlet weak var TypeLabel: UILabel!
    
    static var height: CGFloat = 44
    private var indexPath: IndexPath = .zero
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
    }

    func SetData(type: String, poolType: PoolTypeModel, indexPath: IndexPath) {
            TypeImage.sd_setImage(with: URL(string: Constants.HttpUrlWithoutApi + poolType.poolLogoImagePath), completed: nil)
            TypeLabel.text = type
}
}
