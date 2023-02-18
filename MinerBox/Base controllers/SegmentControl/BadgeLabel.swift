//
//  BadgeLabel.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/17/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class BadgeLabel: UIView {

    // MARK: - Views
    fileprivate var label: UILabel!

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        awakeFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Awake from NIB
    override func awakeFromNib() {
        super.awakeFromNib()
        defaultSetup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
}

// MARK: - Startup
extension BadgeLabel {
    fileprivate func defaultSetup() {
        addLabel()
        addWidthAnchor()
        clipsToBounds = true
        backgroundColor = .badge
        isUserInteractionEnabled = false
        
        setBadgeCount(0)
    }

    fileprivate func addLabel() {
        label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        label.textColor = .white
        label.font = Constants.regularFont.withSize(12)

        label.topAnchor.constraint(equalTo: topAnchor, constant: 1).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
        label.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
    }

    fileprivate func addWidthAnchor() {
        widthAnchor.constraint(lessThanOrEqualToConstant: 50).isActive = true
    }
}

// MARK: - Public methods
extension BadgeLabel {
    public func setBadgeCount(_ count: Int) {
        label.text = "\(count)"
        UIView.animate(withDuration: Constants.animationDuration) {
            self.alpha = count == 0 ? 0 : 1
        }
    }
}
