//
//  BaseTableViewCell.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/25/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    
    private var view: UIView?
    
    // MARK: Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        addObservers()

    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Startup default setup
extension BaseTableViewCell {
    @objc public func startupSetup() {
        selectionStyle = .none
        changeColors()
    }
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeColors), name: Notification.Name(Constants.themeChanged), object: nil)
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
