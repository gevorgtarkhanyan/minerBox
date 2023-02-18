//
//  TabBarCollectionViewCell.swift
//  MinerBox
//
//  Created by Gevorg Tarkhanyan on 23.08.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit

class TabBarCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var tabBarImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
       tabBarImageView.roundCorners(radius: 10)
    }

   
}
