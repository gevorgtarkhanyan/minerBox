//
//  BaseCollectionViewCell.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 22.11.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    private var view: UIView?
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        awakeFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        view = UIView(frame: .zero)
        super.init(coder: aDecoder)
        setupBackground()
    }
    
    private func setupBackground() {
        view?.backgroundColor = .clear
        backgroundView = view
    }

    // MARK: - Awake from NIB
    override func awakeFromNib() {
        super.awakeFromNib()
        startupSetup()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Startup default setup
extension BaseCollectionViewCell {
    @objc public func startupSetup() {
        changeColors()
    }

    @objc public func changeColors() {
        backgroundColor = .tableCellBackground
    }
    
    @objc public func enable(on: Bool) {
        for view in contentView.subviews {
            view.isUserInteractionEnabled = on
            view.alpha = on ? 1 : 0.5
        }
    }
}
