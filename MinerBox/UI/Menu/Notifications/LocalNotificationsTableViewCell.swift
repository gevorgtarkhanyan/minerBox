////
////  LocalNotificationsTableViewCell.swift
////  MinerBox
////
////  Created by Vazgen Hovakinyan on 29.04.21.
////  Copyright © 2021 WitPlex. All rights reserved.
////
//
//import UIKit
//import Localize_Swift
//
//class LocalNotificationsTableViewCell: BaseTableViewCell {
//
//    // MARK: - Views
//    @IBOutlet weak var accountLabelStackView: UIStackView!
//    @IBOutlet fileprivate weak var typeImageView: UIImageView!
//    @IBOutlet fileprivate weak var comparisionImageView: UIImageView?
//    @IBOutlet fileprivate weak var accountNameLabel: BaseLabel!
//    @IBOutlet fileprivate weak var poolNameLabel: BaseLabel!
//    @IBOutlet fileprivate weak var messageLabel: BaseLabel!
//    @IBOutlet fileprivate weak var timeLabel: BaseLabel!
//    @IBOutlet weak var messageTextView: UITextView!
//
//    @IBOutlet weak var timeLabbelTopConstraits: NSLayoutConstraint!
//    // By default 41
//    @IBOutlet fileprivate weak var titleStackLeftConstraint: NSLayoutConstraint?
//
//    // MARK: -  Startup
//    override func startupSetup() {
//        super.startupSetup()
//
//        comparisionImageView?.clipsToBounds = true
//        comparisionImageView?.layer.cornerRadius = 6.5
//
//        poolNameLabel.changeFont(to: Constants.boldFont)
//        poolNameLabel.changeFontSize(to: 12)
//        accountNameLabel.changeFont(to: Constants.boldFont)
//    }
//
//    override func changeColors() {
//        super.changeColors()
//        comparisionImageView?.backgroundColor = .tableCellBackground
//    }
//}
//
//// MARK: - Set data
//extension NotificationsTableViewCell {
//    public func setData(notification: LocalNotification) {
//        typeImageView.image = UIImage(named: notification.notificationType.rawValue)
//
//        if notification.notificationType == .info {
//            messageLabel.isHidden = true
//            timeLabbelTopConstraits?.constant = 0
//            comparisionImageView?.isHidden = true
//            titleStackLeftConstraint?.constant = 16
//            accountLabelStackView.removeArrangedSubview(poolNameLabel)
//            messageTextView.isHidden = false
//         //   messageTextView.contentMode.
//        } else {
//            messageLabel.isHidden = false
//            timeLabbelTopConstraits?.constant = 10
//            accountLabelStackView.addArrangedSubview(poolNameLabel)
//            titleStackLeftConstraint?.constant = 41
//            comparisionImageView?.image = UIImage(named: (notification.data.comparison ? "comparision_down" : "comparision_up"))
//            if notification.notificationType == .payout {
//                comparisionImageView?.isHidden = true
//                titleStackLeftConstraint?.constant = 16
//            } else {
//                comparisionImageView?.isHidden = false
//            }
//        }
//
//        // Config notification message and title
//        poolNameLabel.setLocalizableText(getPoolType(from: notification.title))
//        accountNameLabel.setLocalizableText(notification.data.name)
//
//        switch notification.notificationType {
//        case .hashrate:
//            if notification.data.isAuto {
//                messageLabel.setLocalizableText("notificaiton_auto_hashrate_changed")
//                messageLabel.setOldAndCurrentValues(xxx: notification.data.alertValue.textFromHashrate(), yyy: notification.data.currentValue.textFromHashrate())
//            } else {
//                let message = notification.data.comparison ? "notification_hashrate_less_than" : "notification_hashrate_greater_than"
//                messageLabel.setLocalizableText(message)
//                messageLabel.setOldAndCurrentValues(xxx: notification.data.alertValue.textFromHashrate(), yyy: notification.data.currentValue.textFromHashrate())
//            }
//        case .worker:
//            if notification.data.isAuto {
//                messageLabel.setLocalizableText("notificaiton_auto_worker_changed")
//                messageLabel.setOldAndCurrentValues(xxx: notification.data.alertValue.getString(), yyy: notification.data.currentValue.getString())
//            } else {
//                let message = notification.data.comparison ? "notification_workers_less_than" : "notification_workers_greater_than"
//                messageLabel.setLocalizableText(message)
//                messageLabel.setOldAndCurrentValues(xxx: notification.data.alertValue.getString(), yyy: notification.data.currentValue.getString())
//            }
//        case .coin:
//            let message = notification.data.comparison ? "notification_coin_less_than" : "notification_coin_greater_than"
//            messageLabel.setLocalizableText(message)
//            messageLabel.setOldAndCurrentValues(xxx: notification.data.alertValue.getString() + " $", yyy: notification.data.currentValue.getString() + " $")
//        case .info:
//             accountNameLabel.setLocalizableText(notification.title)
//             messageTextView.attributedText = notification.content.htmlToAttributedString
//             messageTextView.textColor = darkMode ? .white : .black
//             messageTextView.tintColor = .barSelectedItem
//             messageTextView.font = UIFont.systemFont(ofSize: 12)
//
//         case .payout:
//            messageLabel.setLocalizableText("new_payout_detected")
//            messageLabel.setOldAndCurrentValues(xxx: notification.data.value.getString() + " " + notification.data.currency, yyy: "")
//        }
//
//        timeLabel.setLocalizableText(notification.sentDate.getDateFromUnixTime())
//    }
//}
//
//// MARK: - Actions
//extension NotificationsTableViewCell {
//    fileprivate func getPoolType(from title: String) -> String {
//        let components = title.components(separatedBy: ",")
//        if components.indices.contains(1), let pool = Int(components[0]), let subPool = Int(components[1]) {
//            return getTitle(pool: pool, subPool: subPool)
//        } else if components.indices.contains(0), let pool = Int(components[0]) {
//            return getTitle(pool: pool, subPool: nil)
//        }
//        return ""
//    }
//
//    fileprivate func getTitle(pool: Int, subPool: Int?) -> String {
//        guard let pool = getPool(id: pool, subPoolId: subPool) else { return "" }
//        return subPool == nil ? pool.name : "\(pool.name) / \(pool.subPoolName)"
//    }
//
//    fileprivate func getPool(id: Int, subPoolId: Int?) -> (name: String, subPoolName: String)? {
//        do {
//            let url = Constants.fileManagerURL
//            let poolListUrl = url.appendingPathComponent("PoolList")
//            let data = try Data(contentsOf: poolListUrl)
//
//            guard let dict = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [NSDictionary] else { return nil }
//
//            var poolName = ""
//            var subPoolName = ""
//            for pool in dict {
//                guard let poolId = pool.value(forKey: "poolId") as? Int, poolId == id else { continue }
//
//                poolName = pool.value(forKey: "poolName") as? String ?? ""
//                if let subItems = pool.value(forKey: "subItems") as? [NSDictionary], let subId = subPoolId {
//                    for subitem in subItems {
//                        if let id = subitem.value(forKey: "id") as? Int, id == subId {
//                            subPoolName = subitem.value(forKey: "name") as? String ?? ""
//                        }
//                    }
//                }
//            }
//            return (name: poolName, subPoolName: subPoolName)
//        } catch {
//            debugPrint(error.localizedDescription)
//        }
//
//        return nil
//    }
//}
