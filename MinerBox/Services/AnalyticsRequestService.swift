//
//  AnalyticsRequestService.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 2/14/20.
//  Copyright © 2020 WitPlex. All rights reserved.
//

import UIKit
import Alamofire

protocol AnalyticsRequestServiceProtocol {
    func getAnalyticsData(type: String, success: @escaping([AnalyticsModel]) -> Void, failer: @escaping(String) -> Void)
}

class AnalyticsRequestService: AnalyticsRequestServiceProtocol {
    
    static let shared = AnalyticsRequestService()
    private init() {}
    
    private var user: UserModel? {
        return DatabaseManager.shared.currentUser
    }
    
    private var analyticsWithoutUser = "analytics/list"
    private var analyticsWithUser: String? {
        if user != nil {
            return "analytics/" + user!.id + "/list"
        }
        return nil
    }
    
    func getAnalyticsData(type: String, success: @escaping ([AnalyticsModel]) -> Void, failer: @escaping (String) -> Void) {
        let endpoint = (analyticsWithUser != nil) ? analyticsWithUser! : analyticsWithoutUser
        let params = ["type": type]
        
        NetworkManager.shared.request(method: .post, endpoint: endpoint, params: params, encoding: JSONEncoding.default, success: { (json) in
            if let status = json.value(forKey: "status") as? Int, status == 0, let jsonData = json["data"] as? [NSDictionary] {
                let analytics = jsonData.map { AnalyticsModel(json: $0) }
                success(analytics)
            } else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message)
            }
        }) { (error) in
            failer(error)
        }
    }
}
