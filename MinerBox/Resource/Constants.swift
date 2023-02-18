//
//  Constants.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/24/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

final class Constants {
    // MARK: - Base URL

    #if DEBUG
        static let HttpUrl = "http://173.255.240.136:3000/api/"
        static let HttpUrlWithoutApi = "http://173.255.240.136:3000/"

        static let HttpsUrl = "https://173.255.240.136:3043/api/"
        static let HttpsUrlWithoutApi = "https://173.255.240.136:3043/"
    #else
        static let HttpUrl = "http://45.33.47.25:3000/api/"
        static let HttpUrlWithoutApi = "http://45.33.47.25:3000/"
    
        static let HttpsUrl = "https://45.33.47.25:3043/api/"
        static let HttpsUrlWithoutApi = "https://45.33.47.25:3043/"
    #endif
    
    static let HttpsCoinzilla = "https://request-global.czilladx.com/serve/native-app.php?z="
    static let HttpNewsUrl =  "http://192.155.83.57:3020/"
    
    // MARK: - Realm

    static let RealmSchemaVersion: UInt64 = 101

    static var RealmDBUrl: URL {
        var directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.witplex.MinerBox")!
        directory.appendPathComponent("DB.realm")
        return directory
    }
    
    // MARK: - FileManager
    static var fileManagerURL: URL {
        let fileManager = FileManager.default
        return fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.witplex.MinerBox")!
    }

    // MARK: - Notification names
    static let themeChanged = "theme_changed_notification"
    static let subscriptionStatusChanged = "subscription_status_changed"
    static let newPoolAdded = "added_new_pool"
    static let seaarchtTextChanged = "seracht_text_changed"
    static let accountAlertAdded = "account_alert_added"
    static let userLogout = "user_logout"
    static let notificationCountChanged = "noutification_count_changed"
    static let notificationReceived = "noutification_received"
    static let successfullSubscription = "successfull_subscription"
    static let newWalletAdded = "added_new_wallet"
    //must be modified
    static let allCoinsDownloaded = "coins_downloaded"
    static let mainCoinDownloaded = "main_coin_downloaded"
    static let allFiatsDownloaded = "fiats_downloaded"
    static let coinsDownloadedFailed = "coins_downloaded_failed"
    static let fiatsDownloadedFailed = "fiats_downloaded_failed"
    
    
    // MARK: - Font
    static let boldFont     = UIFont(name: "SFProText-Bold",        size: 12)       ??   UIFont.systemFont(ofSize: 12)
    static let mediumFont   = UIFont(name: "SFProText-Medium",      size: 12)       ??   UIFont.systemFont(ofSize: 12)
    static let regularFont  = UIFont(name: "SFProText-Regular",     size: 12)       ??   UIFont.systemFont(ofSize: 12)
    static let semiboldFont = UIFont(name: "SFProText-Semibold",    size: 12)       ??   UIFont.systemFont(ofSize: 12)

    // MARK: - Animation
    static let animationDuration = 0.2

    // MARK: - Coin graph
    static let coinSettingsVertical = "coin_graph_settings_vertical"
    static let coinSettingsHorizontal = "coin_graph_settings_horizontal"
    static let coinSettingsLineGraph = "coin_graph_settings_line_graph"

    // MARK: - Application links
    static let iosLink = "https://itunes.apple.com/us/app/minerbox/id1445878254?ls=1&mt=8"
    static let androidLink = "https://play.google.com/store/apps/details?id=com.witplex.minerbox_android"
    
    static let url_open_widget = "open_widget"
    static let url_open_coinWidget = "open_coinWidget"
    static let url_open_coinAlert = "open_coinAlert"
    static let url_open_add_favorite = "open_add_favorite"
    static let url_open_account = "open_account"
    static let url_open_account_alert = "open_account_alert"
    static let url_open_coinDetail = "open_coinDetail"
    static let url_open_subscription = "open_subscription"
    static let url_open_analytics = "open_analytics"
    static let url_open_news = "open_news"
    static let url_open_whatToMine = "open_whatToMine"
    static let url_open_converter = "open_converter"
    static let url_open_selectpool = "open_selectpool"
    
    static let appOpenedCount = "appOpenedCount"
    static let lastTimeInterval = "last_date"
    static let rateShowViaOpening = "rate_show_via_opening"
    
    static let showRateAppOpenedTime = 15
    static let showRateAppLastDays = 90
    
    // MARK: - Coin Price
    static let limit = 300
    static let searchTimeInterval = 0.5
    static let refreshTimeInterval = 60
    
    // MARK: - News
    static let newslimit = 20
    
    // MARK: - Transaction
    static let transactionlimit = 20

    // MARK: - Chat
    static let HttpsChatUrl = "https://www.witplex.com/livehelperchat/lhc_web/index.php/"
    static let ChatAuthKey = "QXNrbzphY2ZiZHgxNDUhQDEyQXZl"
    
    // MARK: - Account Times
    static let singleCallTimeInterval = 5.0
    static let poolRequestTimeInterval = 20
    static let poolDetailsRequestTimeInterval = 24
    
    // MARK: - Account
    static let separatorHeight = CGFloat(0.5)

}

// MARK: - Notification types
enum NotificationType: String {
    case hashrate = "hashrate_alert"
    case reportedHashrate = "repHash_alert"
    case worker = "worker_alert"
    case coin = "coin_alert"
    case info = "info_alert"
    case payout = "payout_alert"
}
