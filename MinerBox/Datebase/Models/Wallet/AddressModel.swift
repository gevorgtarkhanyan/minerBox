//
//  AddressModel.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 08.02.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit
import RealmSwift

class AddressModel {
    
    var _id: String = ""
    var userId: String = ""
    var type: String = ""
    var description: String = ""
    var coinId: String = ""
    var hasWallet: Bool = false
    var credentials: [String : String] = [:]
    var walletId: String = ""
    var coinName: String = ""
    var currency: String = ""
    var isSelected: Bool = false
    var poolLogoImagePath = ""
    var poolName = ""
    var walletLoaded: Bool?



    convenience init(json: NSDictionary) {
        self.init()
        self._id = json.value(forKey: "_id") as? String ?? ""
        self.userId = json.value(forKey: "userId") as? String ?? ""
        self.type = json.value(forKey: "type") as? String ?? ""
        self.description = json.value(forKey: "description") as? String ?? ""
        self.coinId = json.value(forKey: "coinId") as? String ?? ""
        self.hasWallet = json.value(forKey: "hasWallet") as? Bool ?? false
        self.credentials = json.value(forKey: "credentials") as? [String : String] ?? [:]
        self.walletId = json.value(forKey: "walletId") as? String ?? ""
        self.coinName = json.value(forKey: "coinName") as? String ?? ""
        self.currency = json.value(forKey: "currency") as? String ?? ""
        self.poolName = json.value(forKey: "poolName") as? String ?? ""
        self.walletLoaded = json.value(forKey: "walletLoaded") as? Bool ?? nil


        if let poolIcon = json.value(forKey: "poolIcon") as? String, let path = poolIcon.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            self.poolLogoImagePath = path
        }
    }
}

class AddressType: Object {
    
    @objc dynamic var _id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var typeName: String = ""
    
    var fieldItems = List<FieldModel>()
    
    var fields: [FieldModel] {
        
        if fieldItems.count == 0 {
            return []
        }
        let items = Array(fieldItems)
        return items
    }
    
    var copy: AddressType {
        return AddressType(name: self.name,typeName: self.typeName, _fileds: self.fields)
    }
    
    open override class func primaryKey() -> String? {
        return "_id"
    }
    
   convenience init (json: NSDictionary) {
        self.init()
       
        self.name = json.value(forKey: "type") as? String ?? ""
        self.typeName = json.value(forKey: "name") as? String ?? ""
        if let fieldsJson =  json.value(forKey: "fields") as? [NSDictionary] {
            fieldsJson.forEach { self.fieldItems.append((FieldModel(json: $0)))}
        }
    }
    
    convenience init(name: String, typeName: String = "", _fileds: [FieldModel] = []) {
        self.init()
        self.name = name
        self.typeName = typeName
        _fileds.forEach { field in
            self.fieldItems.append(field.copy)
        }
    }
}

class FieldModel: Object {
    
    @objc dynamic var _id: String = UUID().uuidString
    @objc dynamic var placeholder: String = ""
    @objc dynamic var acceptChars: String? = nil
    @objc dynamic var id: String = ""
    @objc dynamic var inputFieldText: String = ""

    open override class func primaryKey() -> String? {
        return "_id"
    }
    
    var copy: FieldModel {
        return FieldModel(id: self.id, inputFieldText: self.inputFieldText, placeholder: self.placeholder, acceptChars: self.acceptChars)
    }
    
    convenience init(json: NSDictionary) {
        self.init()

        self.placeholder = json.value(forKey: "placeholder") as? String ?? ""
        self.acceptChars = json.value(forKey: "acceptChars") as? String ?? nil
        self.id = json.value(forKey: "id") as? String ?? ""
    }
    
    convenience  init(id: String, inputFieldText: String, placeholder: String = "", acceptChars: String? = nil ) {
        self.init()

        self.id = id
        self.inputFieldText = inputFieldText
        self.placeholder = placeholder
        self.acceptChars = acceptChars
    }
}

class AddressLinkModel {
    
    var coinId: String = ""
    var addressLinks: [String] = []

    init (json: NSDictionary) {
        self.coinId = json.value(forKey: "coinId") as? String ?? ""
        self.addressLinks = json.value(forKey: "addressLinks") as? [String] ?? []
    }
}
