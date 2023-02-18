//
//  ChatButton.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 27.04.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

class ChatButton: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ChatButton", owner: self, options: nil)
        
        addSubview(contentView)
        self.layer.cornerRadius = 10
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        initialSetup()
    }
    
    private func initialSetup() {
        self.isHidden = true
        self.backgroundColor = .clear
        contentView.backgroundColor = .barSelectedItem
        badgeView.backgroundColor = .red
        
        contentView.layer.cornerRadius = contentView.frame.height / 2
        badgeView.layer.cornerRadius = badgeView.frame.height / 2
        badgeView.alpha = 0
    }
    
    //MARK: - Public
    public var isEnubled: Bool = true {
        willSet(newValue) {
            for recognizer in gestureRecognizers ?? [] {
                recognizer.isEnabled = newValue
            }
        }
    }
    
    public func setBadgeValue(with hasUnread: Bool) {
        badgeView.alpha = hasUnread ? 1 : 0
    }
    
    public func setup(with isOnline: Bool? = nil) {
        if let isOnline = isOnline {
            let chatImageName = isOnline ? "chat_online" : "chat_offline"
            self.isHidden = false
            let chatImage = UIImage(named: chatImageName)
            let tintedImage = chatImage?.withRenderingMode(.alwaysTemplate)
            self.iconImageView.image = tintedImage
            self.iconImageView.tintColor = .white
        } else {
            self.isHidden = true
        }
    }
}
