//
//  TabBarRuningPage.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/24/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class TabBarRuningPage: NSObject {

    // MARK: - Properties
    fileprivate(set) var selectedPage = TabBarRuningPageType.accounts
    fileprivate(set) var lastSelectedPage = TabBarRuningPageType.accounts


    // MARK: - Static
    static let shared = TabBarRuningPage()

    // MARK: - Init
    fileprivate override init() {
        super.init()
    }
}

// MARK: - Public methods
extension TabBarRuningPage {
    public func changePage(to type: TabBarRuningPageType) {
        selectedPage = type
    }
    public func changeLastPage(to type: TabBarRuningPageType) {
        lastSelectedPage = type
    }
}

// MARK: - Helpers
enum TabBarRuningPageType: Int {
    case accounts
    case coin
    case notifications
    case whatToMine
    case settings
    case customTabBar
}

