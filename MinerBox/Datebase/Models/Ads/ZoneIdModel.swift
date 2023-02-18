//
//  ZoneIdModel.swift
//  MinerBox
//
//  Created by Vazgen Hovakinyan on 09.03.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift


class ActiveZoneModel: NSObject, Codable {
    
   var zoneName: String = ""
   var hideDuration: Int = 0

    
    override init() {
        super.init()
    }
    
    init(json: NSDictionary?) {
        let json = json ?? NSDictionary()
        
        self.zoneName = json.value(forKey: "zone") as? String ?? ""
        self.hideDuration = json.value(forKey: "hideDuration") as? Int ?? 0
    }
    
    public func getJsonData() -> Data? {
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(self)
            return jsonData
        } catch {
            debugPrint("Can't convert notification model to json: \(error.localizedDescription)")
        }
        return nil
    }
    
}
