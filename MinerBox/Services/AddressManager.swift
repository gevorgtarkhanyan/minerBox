//
//  WalletManager.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 08.02.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import Foundation
import Alamofire

class AddressManager {
    
    static let shared = AddressManager()
    
    fileprivate var currentUser: UserModel? {
        return DatabaseManager.shared.currentUser
    }
    private init(){}
    
    fileprivate var addressApi: String? {
        guard let user = currentUser else { return nil }
        return "addresses/\(user.id)"
    }

    fileprivate var addressV2Api: String? {
        guard let user = currentUser else { return nil }
        return "v2/addresses/\(user.id)"
    }
    
    fileprivate var addressListApi: String? {
        return "addresses/types"
    }
    fileprivate var fields: [String:String] = [:]

    
    func getAddressList(success: @escaping([AddressModel],[AddressLinkModel]) -> Void, failer: @escaping(String) -> Void) {
        
        let params = ["linkType" : "address"] as [String : Any]

        NetworkManager.shared.request(method: .get, endpoint: addressV2Api  ?? "",params: params ,encoding: URLEncoding.queryString, success: { (json) in
            if let status = json.value(forKey: "status") as? Int, status == 0, let jsonData = json["data"] as? NSDictionary {
                
                if let addressJson =  jsonData.value(forKey: "addresses") as? [NSDictionary] {
                    
                    var addressLinks = [AddressLinkModel]()
                    
                    let addresses = addressJson.map { AddressModel(json: $0) }
    
                    if let liksJson  = jsonData.value(forKey: "addressLinks") as? [NSDictionary] {
                        addressLinks = liksJson.map { AddressLinkModel(json: $0) }
                    }
                    
                    success(addresses,addressLinks)

                }
            } else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
            }
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func getFiltedAddressList(poolType: Int, subPoolId: Int, success: @escaping([AddressModel]) -> Void, failer: @escaping(String) -> Void) {
        
        let params = ["poolType" : poolType,"subItemId" : subPoolId ] as [String : Any]
        
        NetworkManager.shared.request(method: .get, endpoint: addressV2Api  ?? "", params: params ,encoding: URLEncoding.queryString, success: { (json) in
            if let status = json.value(forKey: "status") as? Int, status == 0, let jsonData = json["data"] as? NSDictionary{
                if let addressJson =  jsonData.value(forKey: "addresses") as? [NSDictionary] {
                    let addresses = addressJson.map { AddressModel(json: $0) }
                    success(addresses)
                }
            } else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
            }
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func getAddressTypies(success: @escaping([AddressType]) -> Void, failer: @escaping(String) -> Void) {
        
        let isAddresTypesNeedUpdate = TimerManager.shared.isLoadingTime(item: .addressType)
        
        guard isAddresTypesNeedUpdate else {
            
            var address = [AddressType]()

            if let realAddress = RealmWrapper.sharedInstance.getAllObjectsOfModel(AddressType.self) as? [AddressType] {
                realAddress.forEach({address.append($0.copy)})
                success(address)
            } else {
                debugPrint("no address type")
            }
            return
        }
        
        NetworkManager.shared.request(method: .get, endpoint: addressListApi ?? "",success: { (json) in
            if let status = json.value(forKey: "status") as? Int, status == 0, let jsonData = json["data"] as? [NSDictionary]{
                
                RealmWrapper.sharedInstance.deleteObjectsFromRealmDB(AddressType.self)

                let address = jsonData.map { address -> AddressType in
                    RealmWrapper.sharedInstance.addObjectInRealmDB(AddressType(json: address))
                    return AddressType(json: address)
                }
                
                success(address)
         
            } else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
            }
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }


    func addAddress(addressType: AddressType, selectedCoin: CoinModel? = nil, description: String, success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        
        self.fields.removeAll()

        var params: [String: Any] = ["type": addressType.name, "description": description]
        
        if selectedCoin != nil {
            params["coinId"] = selectedCoin?.coinId
            params["coinName"] = selectedCoin?.name
            params["currency"] = selectedCoin?.symbol
        }
        
        for field in addressType.fields {
            self.fields[field.id] = field.inputFieldText
        }
        
        params["credentials"] = self.fields
        
        NetworkManager.shared.request(method: .post, endpoint: addressApi ?? "", params: params, encoding: JSONEncoding.prettyPrinted, success: { (json) in
            if let status = json.value(forKey: "status") as? Int, status == 0 {
                success()
            } else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
            }
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func editAddress(addressId: String, addressType: AddressType, selectedCoin: CoinModel? = nil, description: String, success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        
        self.fields.removeAll()
        
        let endPoint = (addressApi ?? "") + "/\(addressId)"

        var params: [String: Any] = ["type": addressType.name, "description": description]
        
        if selectedCoin != nil && addressType.name == "coin" {
            params["coinId"] = selectedCoin?.coinId
            params["coinName"] = selectedCoin?.name
            params["currency"] = selectedCoin?.symbol
        }
        
        for field in addressType.fields {
            self.fields[field.id] = field.inputFieldText
        }
        
        params["credentials"] = self.fields
        
        NetworkManager.shared.request(method: .put, endpoint: endPoint, params: params, encoding: JSONEncoding.prettyPrinted, success: { (json) in
            if let status = json.value(forKey: "status") as? Int, status == 0 {
                success()
            } else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
            }
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func removeAddress(addressId: String, success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        
        let endPoint = (addressApi ?? "") + "/\(addressId)"
        
        NetworkManager.shared.request(method: .delete, endpoint: endPoint, success: { (json) in
            if let status = json.value(forKey: "status") as? Int, status == 0 {
                success()
            } else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
            }
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func updateAddressOrder(oldOrder: Int, newOrder: Int, success: @escaping() -> Void, failer: @escaping(String) -> Void){
        let endPoint =  (addressApi ?? "") + "/order"
        let params: [String: Any] = ["oldOrder": oldOrder, "newOrder": newOrder]
        
        NetworkManager.shared.request(method: .put, endpoint: endPoint, params: params, encoding: JSONEncoding.prettyPrinted, success: { (json) in
            if let status = json.value(forKey: "status") as? Int, status == 0 {
                success()
            } else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
            }
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
}
