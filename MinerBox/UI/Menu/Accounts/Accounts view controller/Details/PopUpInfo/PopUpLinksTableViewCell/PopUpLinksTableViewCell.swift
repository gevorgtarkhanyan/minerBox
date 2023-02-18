//
//  PopUpLinksTableViewCell.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 11.03.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit

class PopUpLinksTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var linkButton: UIButton!
    private var link: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.linkButton.tintColor = .barSelectedItem
        self.linkButton.addTarget(self, action: #selector(openWebsiteUrl), for: .touchUpInside)
        self.linkButton.titleLabel?.numberOfLines = 1
        self.backgroundColor = .clear
    }
    
    func setDate(link: String) {
        self.linkButton.setTitle(link, for: .normal)
        self.link = link
    }
    
    @objc func openWebsiteUrl () {
        guard link != nil else { return }
        
        if let _link = URL(string: link!), UIApplication.shared.canOpenURL(_link) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(_link, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(_link)
            }
        }
    }
}
