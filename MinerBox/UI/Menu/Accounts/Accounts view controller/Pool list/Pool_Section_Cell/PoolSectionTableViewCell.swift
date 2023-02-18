//
//  PoolSectionTableViewCell.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 11/29/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class PoolSectionTableViewCell: BaseTableViewCell {

    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var dataContainerView: UIView!
    @IBOutlet weak var iconParentView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    
    static var height: CGFloat = 44
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }

    func initialSetup() {
        dataContainerView.backgroundColor = .barSelectedItem
        dataContainerView.layer.cornerRadius = 10
        iconParentView.layer.cornerRadius = 5
        separatorView.backgroundColor = .clear
        backgroundColor = .clear
    }
    
    func setupCell(pool: PoolTypeModel) {
        nameLabel.text = pool.poolName
        arrowImageView.isHidden = pool.subPools.count == 0
        iconImageView.sd_setImage(with: URL(string: Constants.HttpUrlWithoutApi + pool.poolLogoImagePath), completed: nil)
    }
        
    func rotateArrow(angle: CGFloat) {
        if arrowImageView.transform != CGAffineTransform(rotationAngle: angle) {
            DispatchQueue.main.async {
                UIView.animate(withDuration: Constants.animationDuration) {
                    self.arrowImageView.transform = CGAffineTransform(rotationAngle: angle)
                }
            }
        }
    }
    
    func animateArrow(expanded: Bool) {
        rotateArrow(angle: expanded ? .pi : 0)
    }
}
