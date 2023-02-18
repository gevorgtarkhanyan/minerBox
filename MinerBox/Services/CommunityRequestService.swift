//
//  ApplicationRequestService.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 12/4/18.
//  Copyright © 2018 WitPlex. All rights reserved.
//


import UIKit

class CommunityManager {

    // MARK: - Static
    static let shared = CommunityManager()
    
    // MARK: - Endpoints
    let list = "appSettings/communityList"
}

// MARK: - Requests
extension CommunityManager {
    func getList(success: @escaping(CommunityModel) -> Void, failer: @escaping(String) -> Void) {
        NetworkManager.shared.request(method: .get, endpoint: list, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0, let dictionary = json["data"] as? NSDictionary else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            let communityModel = CommunityModel(dict: dictionary)
            self.removeFromDB()
            RealmWrapper.sharedInstance.addObjectInRealmDB(communityModel, CommunityModel.self)
            success(communityModel)
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func removeFromDB() {
        RealmWrapper.sharedInstance.deleteObjectsFromRealmDB(CommunityModel.self)
    }
}
