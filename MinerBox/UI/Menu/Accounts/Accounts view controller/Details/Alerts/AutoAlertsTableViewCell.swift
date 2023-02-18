//
//  AutoAlertsTableViewCell.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/4/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

protocol AutoAlertsTableViewCellDelegate: AnyObject {
    func switchSelected(indexPath: IndexPath, isOn: Bool, response: @escaping(Bool) -> ())
}

class AutoAlertsTableViewCell: BaseTableViewCell {

    // MARK: - Views
    @IBOutlet weak var alertLabel: BaseLabel!
    @IBOutlet weak var alertSwitch: BaseSwitch!

    // MARK: - Properties
    fileprivate var indexPath = IndexPath(row: 0, section: 0)

    weak var delegate: AutoAlertsTableViewCellDelegate?

    // MARK: - Awake from NIB
    override func awakeFromNib() {
        super.awakeFromNib()
        startupSetup()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 0)
    }
}

// MARK: - Startup default setup
extension AutoAlertsTableViewCell {
    override func startupSetup() {
        super.startupSetup()
        addSwitchAction()
    }

    fileprivate func addSwitchAction() {
        alertSwitch.addTarget(self, action: #selector(switchAction(_:)), for: .valueChanged)
    }

    @objc fileprivate func switchAction(_ sender: BaseSwitch) {
        delegate?.switchSelected(indexPath: indexPath, isOn: sender.isOn, response: { (swiched) in
            if sender.isOn, !swiched {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                    sender.setOn(!sender.isOn, animated: true)
                })
            }
        })
    }
}

// MARK: - Set data
extension AutoAlertsTableViewCell {
    public func setData(name: String, indexPath: IndexPath, switchIsOn: Bool, last: Bool) {
        self.indexPath = indexPath
        alertLabel.setLocalizableText(name)
        alertSwitch.setOn(switchIsOn, animated: false)
        configBackgroundCorner(lastRow: last)
    }
}

// MARK: - Actions
extension AutoAlertsTableViewCell {
    fileprivate func configBackgroundCorner(lastRow: Bool) {
        if indexPath.row == 0 && lastRow {
            roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10)
        } else if indexPath.row == 0 {
            roundCorners([.topLeft, .topRight], radius: 10)
        } else if lastRow {
            roundCorners([.bottomLeft, .bottomRight], radius: 10)
        }
    }
}
