//
//  File.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 11/20/18.
//  Copyright © 2018 WitPlex. All rights reserved.
//

import Foundation
import RealmSwift

class PoolAlertModel: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var alertType: Int = 0
    @objc dynamic var comparison: Bool = false
    @objc dynamic var isEnabled: Bool = false
    @objc dynamic var poolId: String = ""
    @objc dynamic var isRepeat: Bool = false
    @objc dynamic var value: Double = 0.0

    @objc dynamic var isAuto: Bool = false

    open override class func primaryKey() -> String? {
        return "id"
    }

    convenience init(json: NSDictionary) {
        self.init()
        self.id = json.value(forKey: "_id") as? String ?? ""
        self.alertType = json.value(forKey: "alertType") as? Int ?? 0
        self.comparison = json.value(forKey: "comparison") as? Bool ?? false
        self.isEnabled = json.value(forKey: "enabled") as? Bool ?? false
        self.poolId = json.value(forKey: "poolId") as? String ?? ""
        self.isRepeat = json.value(forKey: "repeat") as? Bool ?? false
        self.value = json.value(forKey: "value") as? Double ?? 0.0
        self.isAuto = json.value(forKey: "isAuto") as? Bool ?? false
    }
}
