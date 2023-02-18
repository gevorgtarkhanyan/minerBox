//
//  WidgetBalanceModel.swift
//  MinerBox
//
//  Created by Vazgen Hovakinyan on 15.06.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation
import UIKit

class WidgetBalanceModel {
    
    var poolId: String = ""
    var params: [String] =  []

    
    convenience init(json: NSDictionary) {
        self.init()
        
        self.poolId = json.value(forKey: "_id") as? String ?? ""
        self.params = json.value(forKey: "params") as? [String] ?? []
    
    }
}



