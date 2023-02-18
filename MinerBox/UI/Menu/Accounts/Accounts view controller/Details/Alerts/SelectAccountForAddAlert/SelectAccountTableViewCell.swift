//
//  SelectAccountTableViewCell.swift
//  MinerBox
//
//  Created by Gevorg Tarkhanyan on 04.08.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit

class SelectAccountTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var ImageView: BaseImageView!
    
    @IBOutlet weak var accountNameLabel: BaseLabel!
    
    @IBOutlet weak var SubNameLabel: BaseLabel!
    
    fileprivate var indexPath: IndexPath = .zero
    
    static var height: CGFloat {
        return 44
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear    }
    
    public func setData(model: PoolAccountModel, indexPath: IndexPath) {
        
        getLogoImage(model: model, indexPath: indexPath)
        accountNameLabel.setLocalizableText(model.poolAccountLabel)
        SubNameLabel.setLocalizableText(model.poolName)
    }
    
    fileprivate func getLogoImage(model: PoolAccountModel, indexPath: IndexPath) {
        guard let pool = DatabaseManager.shared.getPool(id: model.poolType) else { return }
        ImageView.sd_setImage(with: URL(string: Constants.HttpUrlWithoutApi + pool.poolLogoImagePath), completed: nil)
    }
    
}
