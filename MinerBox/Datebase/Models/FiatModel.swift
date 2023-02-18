//
//  FiatModel.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/22/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import RealmSwift

class FiatModel: Object {
    @objc dynamic var _id = UUID().uuidString
    @objc dynamic var currency: String = ""
    @objc dynamic var symbol: String = ""
    @objc dynamic var flag: String = ""
    @objc dynamic var price: Double = 0
    dynamic var changeAblePrice: Double = 0
    
    static var isSuccessfullyDownloaded: Bool?
    
    override class func primaryKey() -> String? {
        return "_id"
    }
    
    override init() {
        super.init()
    }
    
    init(json: NSDictionary?) {
        let json = json ?? NSDictionary()
        
        self.currency = json.value(forKey: "currency") as? String ?? ""
        self.symbol = json.value(forKey: "symbol") as? String ?? ""
        self.flag = json.value(forKey: "flag") as? String ?? ""
        self.price = json.value(forKey: "price") as? Double ?? 0
    }
    
}
