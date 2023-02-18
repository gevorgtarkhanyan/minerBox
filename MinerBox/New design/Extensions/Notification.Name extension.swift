//
//  Notification.Name extension.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/24/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import Foundation

extension Notification.Name {
    static var goToTabBarPage: Notification.Name {
        return Notification.Name(rawValue: "go_to_settings")
    }
    static var reloadTabBarItems: Notification.Name {
        return Notification.Name(rawValue: "reload_items")
    }
    static var changeTransactionState: Notification.Name {
        return Notification.Name(rawValue: "change_transaction_state")
    }
    static var goToSubscriptionPage: Notification.Name {
        return Notification.Name(rawValue: "go_to_subscription")
    }
    static var hideAdsForSubscribeUsers: Notification.Name {
        return Notification.Name(rawValue: "hide_ads")
    }
    static var goToLoginPage: Notification.Name {
        return Notification.Name(rawValue: "go_to_login")
    }
    static var goToBackground: Notification.Name {
        return Notification.Name(rawValue: "go_to_background")
    }
    static var goToForeground: Notification.Name {
        return Notification.Name(rawValue: "go_to_foreground")
    }
    static var goToNotifationPage: Notification.Name {
        return Notification.Name(rawValue: "go_to_notification")
    }
    static var openWidgetPage: Notification.Name {
        return Notification.Name(rawValue: "open_widget_page")
    }
    static var openFromWidget: Notification.Name {
        return Notification.Name(rawValue: "open_from_widget")
    }
    static var openDynamicLinks: Notification.Name {
        return Notification.Name(rawValue: "open_dynamic_link")
    }
    static var addAlert: Notification.Name {
        return Notification.Name("addAlert")
    }
    static var addFavorite: Notification.Name {
        return Notification.Name("addFavorite")
    }
    static var deleteFavorite: Notification.Name {
        return Notification.Name("deleteFavorite")
    }
    static var  widgetSectionIsSelected : Notification.Name {
        return Notification.Name("widget_section_is_selected")
    }
    static var stopNotificationTask: Notification.Name {
        return Notification.Name("stopNotificationTask")
    }
    static var refreshTotalAccounts: Notification.Name {
        return Notification.Name("refreshTotalAccounts")
    }
    static var updateWalletData: Notification.Name {
        return Notification.Name(rawValue: "update_wallet_data")
    }
    static var updateReloadState: Notification.Name {
        return Notification.Name(rawValue: "update_reload_state")
    }
    static var likeStatusChanged: Notification.Name {
        return Notification.Name(rawValue: "like_status_changed")
    }
}
