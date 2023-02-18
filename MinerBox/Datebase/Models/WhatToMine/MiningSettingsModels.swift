//
//  MiningSettingsModels.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 11/7/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class MiningSettingsModels: NSObject, Codable {
    var difficulties: [SettingsDifficulties] = []
    
    func addDifficulties(_ diff: SettingsDifficulties) {
        difficulties.append(diff)
    }
    
    convenience init(json: NSDictionary) {
        self.init()
        if let difficulty = json.value(forKey: "difficulties") as? [NSDictionary] {
            difficulty.forEach { self.addDifficulties(SettingsDifficulties(json: $0)) }
        }
    }
}

class SettingsDifficulties: NSObject, Codable {
    var value: String
    var defaults: Bool
    
    init(json: NSDictionary?) {
        let json = json ?? NSDictionary()
        
        self.value = json.value(forKey: "value") as? String ?? ""
        self.defaults = json.value(forKey: "default") as? Bool ?? false
        super.init()
    }
}
