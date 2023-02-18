//
//  SampleNotificationDelegate.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 11/28/18.
//  Copyright © 2018 WitPlex. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class SampleNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.notificationCountChanged), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.notificationReceived), object: nil, userInfo: notification.request.content.userInfo)
       
        guard
            let stringType = notification.request.content.userInfo["notificationType"] as? String,
            let _ = NotificationType(rawValue: stringType) else {
            completionHandler([])
            return
        }
        completionHandler([.alert, .sound])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
                
        guard
            let stringType = response.notification.request.content.userInfo["notificationType"] as? String,
            let notificationType = NotificationType(rawValue: stringType) else {
            completionHandler()
            return
        }
        
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            debugPrint("Dismiss Action")
        case "Snooze":
            debugPrint("Snooze")
        case "Delete":
            debugPrint("Delete")
        default:
            openNotification(type: notificationType)
        }
        
        completionHandler()
    }
    
    fileprivate func openNotification(type: NotificationType) {
        TabBarRuningPage.shared.changePage(to: .notifications)
        NotificationCenter.default.post(name: .goToTabBarPage, object: TabBarRuningPageType.notifications.rawValue)
        
        switch type {
        case .coin:
            NotificationRuningPage.shared.changePage(to: .coin)
        case .hashrate, .payout, .worker, .reportedHashrate:
            NotificationRuningPage.shared.changePage(to: .pool)
        case .info:
            NotificationRuningPage.shared.changePage(to: .info)
        }
        NotificationCenter.default.post(name: .goToNotifationPage, object: NotificationRuningPage.shared.selectedPage.rawValue)
    }
}
