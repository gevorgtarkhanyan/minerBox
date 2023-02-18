//
//  NotificationRuningPage.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/31/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class NotificationRuningPage: NSObject {

    // MARK: - Properties
    fileprivate(set) var selectedPage = NotificationRuningPageType.coin

    // MARK: - Static
    static let shared = NotificationRuningPage()

    // MARK: - Init
    fileprivate override init() {
        super.init()
    }
}

// MARK: - Public methods
extension NotificationRuningPage {
    public func changePage(to type: NotificationRuningPageType) {
        selectedPage = type
    }
}

// MARK: - Helpers
enum NotificationRuningPageType: Int {
    case coin
    case pool
    case info
}

