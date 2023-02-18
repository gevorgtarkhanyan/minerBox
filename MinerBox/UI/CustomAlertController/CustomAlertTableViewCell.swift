//
//  CustomAlertTableViewCell.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/17/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

protocol CustomAlertTableViewCellDelegate: class {
    func buttonTapped(indexPath: IndexPath) -> Void
}

class CustomAlertTableViewCell: BaseTableViewCell {

    @IBOutlet weak var alertImageView: UIImageView!
    @IBOutlet weak var buttonOutlet: LoginButton!
    var indexPath: IndexPath!
    
    weak var delegate: CustomAlertTableViewCellDelegate?
    
    static var height: CGFloat {
        return 50
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }
    
    func initialSetup() {
        backgroundColor = darkMode ? .viewDarkBackground : .viewLightBackground
    }
    
    func setupCell(cellData: CustomAlertModel) {
        if let imageName = cellData.imageName {
            alertImageView.image = UIImage(named: imageName)
        }
        buttonOutlet.setTitle(cellData.actionTitle, for: .normal)
        buttonOutlet.changeFontSize(to: 20)
        if cellData.isCanseledStyle {
            buttonOutlet.changeTitleColor(color: .systemRed)
        }
    }

    @IBAction func buttonTapped() {
        delegate?.buttonTapped(indexPath: indexPath)
    }
    
}
