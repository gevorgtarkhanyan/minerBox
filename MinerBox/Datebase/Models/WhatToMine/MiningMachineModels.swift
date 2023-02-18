//
//  MiningMachineModels.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 11/7/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class MiningMachineModels: NSObject, Codable {
    var modelId: Double
    var name: String
    var selected: Bool
    var disabled: Bool
    var count: Double
    
    init(json: NSDictionary?) {
        let json = json ?? NSDictionary()
        self.name = json.value(forKey: "name") as? String  ?? ""
        self.modelId = json.value(forKey: "modelId") as? Double ?? 0
        self.selected = json.value(forKey: "selected") as? Bool ?? false
        self.disabled = json.value(forKey: "disabled") as? Bool ?? false
        self.count = json.value(forKey: "count") as? Double ?? 0
        super.init()
    }
}
