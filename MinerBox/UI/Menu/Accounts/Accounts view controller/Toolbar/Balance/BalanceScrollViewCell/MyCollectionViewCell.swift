//
//  MyCollectionViewCell.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 19.11.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {
    @IBOutlet var myLabel: BaseLabel?
    
    static var width: CGFloat = 100


    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = . tableSectionLight
        myLabel =  BaseLabel()
    }

}
extension MyCollectionViewCell {
    func setdata(labbel : String) {
        myLabel?.text = labbel
    }
}

