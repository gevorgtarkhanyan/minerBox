//
//  UserDevaults extention .swift
//  MinerBox
//
//  Created by Armen Gasparyan on 10.09.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation

extension UserDefaults {
    static var shared: UserDefaults {
        let userId = DatabaseManager.shared.currentUser?.id
        let user = userId == nil ? "" : userId! + "."
        return UserDefaults(suiteName: "\(user)group.com.witplex.MinerBox")!
    }
    static var sharedForWidget: UserDefaults {
        return UserDefaults(suiteName: "group.com.witplex.MinerBox")!
    }
}
