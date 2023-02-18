//
//  MoreTableViewCell.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/9/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

@objc protocol MoreTableViewCellDelegate: AnyObject {
    @objc optional func switchTapped(indexPath: IndexPath, sender: BaseSwitch)
    @objc optional func cellTappedFiveTimes(indexPath: IndexPath)
}

class MoreTableViewCell: BaseTableViewCell {

    // MARK: - Viewsc
    @IBOutlet fileprivate weak var nameLabel: BaseLabel!
    @IBOutlet  weak var iconImageView: UIImageView!
    @IBOutlet fileprivate weak var infoLabel: BaseLabel!
    @IBOutlet fileprivate weak var settingSwitch: BaseSwitch?
    

    // MARK: - Properties
    weak var delegate: MoreTableViewCellDelegate?

    fileprivate var indexPath: IndexPath = .zero

    // MARK: - Static
    static var height: CGFloat = 44

    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        settingSwitch?.isHidden = true
        infoLabel?.isHidden = true
    }
}

// MARK: - Startup default setup
extension MoreTableViewCell {
    override func startupSetup() {
        super.startupSetup()
        configIconImage()
        configInfoLabel()
        configSwitch()

        addGestureRecognizers()
    }

    fileprivate func configIconImage() {
        iconImageView.clipsToBounds = true
        iconImageView.layer.cornerRadius = 6.5
    }
    
    fileprivate func configInfoLabel() {
        infoLabel?.isHidden = true
    }

    fileprivate func configSwitch() {
        settingSwitch?.isHidden = true
        settingSwitch?.addTarget(self, action: #selector(switchAction(_:)), for: .valueChanged)
    }

    fileprivate func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tap.numberOfTapsRequired = 5
        addGestureRecognizer(tap)
    }
}

// MARK: - Actions
extension MoreTableViewCell {
    @objc fileprivate func switchAction(_ sender: BaseSwitch) {
        delegate?.switchTapped?(indexPath: indexPath, sender: sender)
    }

    @objc fileprivate func tapAction(_ sender: UITapGestureRecognizer) {
        delegate?.cellTappedFiveTimes?(indexPath: indexPath)
    }
}

// MARK: - Set data
extension MoreTableViewCell {
    public func setData(title: String, indexPath: IndexPath, currentYear: Int? = nil) {
        
        let websiteName = "MinerBox"
        
        self.indexPath = indexPath
        iconImageView.image = UIImage(named: title)
        nameLabel.setLocalizableText(title == "about_app_website" ? websiteName : title)

        switch title {
        case "about_app_website":
            nameLabel.text = websiteName
        case "more_profile":
            nameLabel.setLocalizableText(DatabaseManager.shared.currentUser?.name ?? title)
        default:
            nameLabel.setLocalizableText(title)
        }

        if title == "about_app_version" {
            #if DEBUG
                nameLabel.addSymbolAfterText(": \(Bundle.main.releaseVersionNumber) Developer version")
            #else
                nameLabel.addSymbolAfterText(": \(Bundle.main.releaseVersionNumber)")
            #endif
        } else {
            nameLabel.addSymbolAfterText("")
        }
    }

    public func showInfoLabel(text: String?) {
        infoLabel?.isHidden = false
        infoLabel?.text = text
    }

    public func showSwitch(for indexPath: IndexPath, isOn: Bool) {
        self.indexPath = indexPath
        settingSwitch?.isHidden = false
        settingSwitch?.setOn(isOn, animated: true)
    }
}
