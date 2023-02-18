//
//  WidgetModel.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/12/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import RealmSwift

class WidgetModel: Object {
    // MARK: - Properties
    @objc dynamic var userId: String = ""
    @objc dynamic var accountId: String = ""
    @objc dynamic var selectedBalanceType: String = ""

    
    // MARK: - Init
    convenience init(userId: String, account: PoolAccountModel) {
        self.init()
        self.userId = userId
        self.accountId = account.id
    }
}
