//
//  MiningAlgorithmsModel.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 11/7/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class MiningAlgorithmsModel: NSObject, Codable {
    var name: String
    var unit: String
    var sourceName: String
    var type: String
    var algoId: Double
    var hs: Double
    var w: Double
    var source: Double
    var selected: Bool
    var disabled: Bool
    
    init(json: NSDictionary?) {
        let json = json ?? NSDictionary()
        self.name = json.value(forKey: "name") as? String ?? ""
        self.unit = json.value(forKey: "unit") as? String ?? ""
        self.sourceName = json.value(forKey: "sourceName") as? String ?? ""
        self.type = json.value(forKey: "type") as? String ?? ""
        self.algoId = json.value(forKey: "algoId") as? Double ?? 0
        self.hs = json.value(forKey: "hs") as? Double ?? 0
        self.w = json.value(forKey: "w") as? Double ?? 0
        self.source = json.value(forKey: "source") as? Double ?? 0
        self.selected = json.value(forKey: "selected") as? Bool ?? false
        self.disabled = json.value(forKey: "disabled") as? Bool ?? false
        super.init()
    }
    
}
