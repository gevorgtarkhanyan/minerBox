//
//  NotificationsTableViewCell.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/17/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import Localize_Swift

class NotificationsTableViewCell: BaseTableViewCell {

    // MARK: - Views
    @IBOutlet weak var accountLabelStackView: UIStackView!
    @IBOutlet fileprivate weak var typeImageView: UIImageView!
    @IBOutlet fileprivate weak var comparisionImageView: UIImageView?
    @IBOutlet fileprivate weak var accountNameLabel: BaseLabel!
    @IBOutlet fileprivate weak var poolNameLabel: BaseLabel!
    @IBOutlet fileprivate weak var messageLabel: BaseLabel!
    @IBOutlet fileprivate weak var timeLabel: BaseLabel!
    @IBOutlet weak var messageTextView: UITextView!
    
    // By default 41
    @IBOutlet fileprivate weak var titleStackLeftConstraint: NSLayoutConstraint?
    
   
    // MARK: -  Startup
    override func startupSetup() {
        super.startupSetup()
        
        comparisionImageView?.clipsToBounds = true
        comparisionImageView?.layer.cornerRadius = 6.5

        poolNameLabel.changeFont(to: Constants.boldFont)
        poolNameLabel.changeFontSize(to: 12)
        accountNameLabel.changeFont(to: Constants.boldFont)
    }

    override func changeColors() {
        super.changeColors()
        comparisionImageView?.backgroundColor = .tableCellBackground
    }
}

// MARK: - Set data
extension NotificationsTableViewCell {
    
    public func setLocalData(notification: LocalNotification) {
        typeImageView.image = UIImage(named:NotificationType.info.rawValue)

        timeLabel.isHidden = true
        accountLabelStackView.isHidden = true
        messageLabel.isHidden = true
        comparisionImageView?.isHidden = true
        titleStackLeftConstraint?.constant = 16
        accountLabelStackView.removeArrangedSubview(poolNameLabel)
        messageTextView.isHidden = false
        messageTextView.attributedText = notification.body.htmlAttributed(using: Constants.boldFont.withSize(11))
        messageTextView.textColor = darkMode ? .white : .black
        messageTextView.tintColor = .barSelectedItem
    }
    
    public func setData(notification: NotificationModel) {
        typeImageView.image = UIImage(named: notification.notificationType.rawValue)
        accountLabelStackView.isHidden = false
        timeLabel.isHidden = false

        if notification.notificationType == .info {
            messageLabel.isHidden = true
            comparisionImageView?.isHidden = true
            titleStackLeftConstraint?.constant = 16
            accountLabelStackView.removeArrangedSubview(poolNameLabel)
            messageTextView.isHidden = false
        } else {
            messageLabel.isHidden = false
            accountLabelStackView.addArrangedSubview(poolNameLabel)
            titleStackLeftConstraint?.constant = 41
            comparisionImageView?.image = UIImage(named: (notification.data.comparison ? "comparision_down" : "comparision_up"))
            if notification.notificationType == .payout {
                comparisionImageView?.isHidden = true
                titleStackLeftConstraint?.constant = 16
            } else {
                comparisionImageView?.isHidden = false
            }
        }

        // Config notification message and title
        poolNameLabel.setLocalizableText(notification.poolType)
        accountNameLabel.setLocalizableText(notification.data.name)

        switch notification.notificationType {
        case .info:
             accountNameLabel.setLocalizableText(notification.title)
             messageTextView.attributedText = notification.content.htmlToAttributedString
             messageTextView.textColor = darkMode ? .white : .black
             messageTextView.tintColor = .barSelectedItem
             messageTextView.font = UIFont.systemFont(ofSize: 12)
        default:
            messageLabel.text = notification.customContent
            if notification.notificationType == .coin {
                poolNameLabel.text = notification.title
            }
        }

        timeLabel.setLocalizableText(notification.sentDate.getDateFromUnixTime())
    }
}
