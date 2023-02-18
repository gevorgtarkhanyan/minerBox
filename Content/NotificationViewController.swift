//
//  NotificationViewController.swift
//  Content
//
//  Created by Ruben Nahatakyan on 11/28/18.
//  Copyright © 2018 WitPlex. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    // MARK: - Views
    @IBOutlet fileprivate weak var customView: UIView!
    @IBOutlet fileprivate weak var typeImageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var secondTitleLabel: UILabel!
    @IBOutlet fileprivate weak var compareImageView: UIImageView!
    @IBOutlet fileprivate weak var messageLabel: UILabel!

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func didReceive(_ notification: UNNotification) {
        configLabels(with: notification.request.content.userInfo)
    }

    override func viewDidLayoutSubviews() {
        preferredContentSize = self.customView?.frame.size ?? .zero
    }
}

// MARK: - Actions
extension NotificationViewController {
    fileprivate func configLabels(with userInfo: [AnyHashable: Any]) {
        guard let stringType = userInfo["notificationType"] as? String, let notificationType = NotificationType(rawValue: stringType) else { return }

        typeImageView.image = UIImage(named: notificationType.rawValue)
        titleLabel.text = userInfo["first_title"] as? String
        secondTitleLabel.text = userInfo["second_title"] as? String
        messageLabel.text = userInfo["received_message"] as? String
        
        if let compare = userInfo["comparison"] as? Bool {
            compareImageView.image = UIImage(named: (compare ? "comparision_down" : "comparision_up"))
        } else {
            compareImageView.removeFromSuperview()
        }
    }
}
