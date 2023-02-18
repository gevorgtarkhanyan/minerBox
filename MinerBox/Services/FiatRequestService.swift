//
//  FiatRequestServiece.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/22/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class FiatRequestService {
    static let shared = FiatRequestService()
    
    private var fiatAPI = "exchangeRates/get"
        
    private init() {}
    
    // MARK: -- Get Fiat List
    func getFiatList(success: @escaping([FiatModel]) -> Void, failer: @escaping(String) -> Void) {
        var rateList: [FiatModel] = []
        NetworkManager.shared.request(method: .get, endpoint: fiatAPI, success: { (json) in
            if let status = json.value(forKey: "status") as? Int, status == 0,
                let data = (json["data"] as? NSDictionary) {
                if let rates = data["rates"] as? [NSDictionary] {
                    RealmWrapper.sharedInstance.deleteObjectsFromRealmDB(FiatModel.self)
                    for rate in rates {
                        RealmWrapper.sharedInstance.addObjectInRealmDB(FiatModel(json: rate))
                        rateList.append(FiatModel(json: rate))
                    }
                    success(rateList)
                }
            } else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                debugPrint(message.localized())
            }
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
}
