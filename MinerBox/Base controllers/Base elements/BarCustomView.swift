//
//  BarCustomView.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/25/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class BarCustomView: UIView {

    // MARK: - Views
    fileprivate var separatorImageView: UIImageView!

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
        startupSetup()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Startup sefault setup
extension BarCustomView {
    fileprivate func startupSetup() {
        setupUI()

        changeColors()
        addObservers()
    }

    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeColors), name: Notification.Name(Constants.themeChanged), object: nil)
    }

    @objc fileprivate func changeColors() {
        /// when tag = 1 this view us cell background style
        backgroundColor = tag == 1 ? .tableCellBackground : darkMode ? .barDark : .barLight
    }
}

// MARK: - Setup UI
extension BarCustomView {
    fileprivate func setupUI() {
        separatorImageView = UIImageView(frame: .zero)
        separatorImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorImageView)

        separatorImageView.isUserInteractionEnabled = false
        separatorImageView.backgroundColor = UIColor.white.withAlphaComponent(0.15)

        separatorImageView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        separatorImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separatorImageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separatorImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        /// when tag = 1 this view us cell background style
        if tag == 1 {
            cellBackgroundSetup()
        }
    }
    
    fileprivate func cellBackgroundSetup() {
        separatorImageView.isHidden = true
        cornerRadius(radius: 10)
    }
}

// MARK: - Public methods
extension BarCustomView {
    public func changeSeparatorToTop() {
        separatorImageView.removeFromSuperview()
        addSubview(separatorImageView)

        separatorImageView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        separatorImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separatorImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separatorImageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    public func removeLayer() {
        separatorImageView.isHidden = true
    }
}
