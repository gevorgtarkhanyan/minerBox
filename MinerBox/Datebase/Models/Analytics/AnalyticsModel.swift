//
//  AnalyticsModel.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 2/14/20.
//  Copyright © 2020 WitPlex. All rights reserved.
//

import Foundation

class AnalyticsModel: NSObject, Codable {
    var id: String
    var percent: Double
    var subItems: [String: Double]
    var name: String
    var symbol: String
    
    init(json: NSDictionary?) {
        let json = json ?? NSDictionary()
        self.id = json.value(forKey: "id") as? String ?? ""
        self.percent = json.value(forKey: "percent") as? Double ?? 0
        self.subItems = json.value(forKey: "subItems") as? [String: Double] ?? [:]
        self.name = json.value(forKey: "name") as? String ?? ""
        self.symbol = json.value(forKey: "symbol") as? String ?? ""
        
        super.init()
    }
    
}


//{
//         "id": "bitcoin",
//         "percent": 4.91,
//         "name": "Bitcoin",
//         "symbol": "BTC"
//      },
