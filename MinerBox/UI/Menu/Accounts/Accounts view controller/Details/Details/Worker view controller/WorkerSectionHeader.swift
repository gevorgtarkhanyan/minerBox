//
//  WorkerSectionHeader.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/6/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class WorkerSectionHeader: UIView {

    // MARK: - Views
    fileprivate var nameLabel: BaseLabel!

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    static let height: CGFloat = 30
}

// MARK: - Setup UI
extension WorkerSectionHeader {
    fileprivate func setupUI() {
        addNameLabel()
    }

    fileprivate func addNameLabel() {
        nameLabel = BaseLabel(frame: .zero)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(nameLabel)

        nameLabel.numberOfLines = 1
        nameLabel.font = Constants.semiboldFont.withSize(15)

        nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        nameLabel.rightAnchor.constraint(greaterThanOrEqualTo: rightAnchor, constant: 10).isActive = true
    }
}

// MARK: - Set data
extension WorkerSectionHeader {
    public func setName(_ name: String) {
        nameLabel.setLocalizableText(name)
    }
}
