//
//  Currency.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 18.02.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import Foundation

class Currency {
    var name: String
    var icon: String
    var cost : Double
    
    init(json: NSDictionary) {
        self.name = json.value(forKey: "cur") as? String ?? "-"
        self.icon = json.value(forKey: "flag") as? String ?? "-"
        self.cost = json.value(forKey: "cost") as? Double ?? 2
    }
    
    var iconPath: String {
        return icon.contains("http") ? icon : Constants.HttpUrlWithoutApi + "images/flags/" + icon
    }
}
