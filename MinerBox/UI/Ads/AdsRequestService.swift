//
//  AdsRequestService.swift
//  MinerBox
//
//  Created by Vazgen Hovakinyan on 09.03.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

enum AdsEndPointEnum: String, CaseIterable {
    case account = "95260a4cafeebc8f751"
    case coins = "17460a4c948b090e222"
    case whatToMine = "94560a4cb0f68edc229"
    case converter = "13460b88d48c7def739"
}

class AdsRequestService {
    
    // MARK: - Properties
    
    static let shared = AdsRequestService()
    
    // MARK: - Endpoints
    
    fileprivate let activeZones = "ad-providers/zones"
    fileprivate let adsSetting = "ad-providers/ad"
    fileprivate let adsAction =  "ad-providers/provider_id/stats"

    
    // MARK: - Requests
    
    func getZoneList(success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        
        let param = ["subscribed": DatabaseManager.shared.currentUser?.isSubscribted ?? false]
        
        NetworkManager.shared.request(method: .get, endpoint: activeZones, params: param, encoding: URLEncoding.queryString) { (json) in
            
            guard let status = json.value(forKey: "status") as? Int, status == 0, let data = json["data"] as? NSDictionary else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            ZoneIdsManager.shared.removeAdsZoneByFolder()
            
            let activeZoneData = data["activeZones"] as? [NSDictionary] ?? []
            for item in activeZoneData {
                ZoneIdsManager.shared.addZoneToFile(ActiveZoneModel(json: item))
            }
            success()
            
        } failure: { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func getAdsFromServer(success: @escaping(NSDictionary) -> Void, zoneName: String, failer: @escaping(String) -> Void) {
        
        NetworkManager.shared.cancelTask(urlPath: adsSetting)
        NetworkManager.shared.cancelTask(urlPath: Constants.HttpsCoinzilla)
        
        let param = ["zone": zoneName,"subscribed": DatabaseManager.shared.currentUser?.isSubscribted ?? false, "deviceType": "\(1)"] as [String : Any]
        
        NetworkManager.shared.request(method: .get, endpoint: adsSetting, params: param, encoding: URLEncoding.queryString, success: { (json) in
            
             guard let data = json["data"] as? NSDictionary else {
                 let message = json["description"] as? String ?? "unknown_error"
                 failer(message.localized())
                 return
             }
             success(data)
         }) { (error) in
             failer(error)
             debugPrint(error)
         }
     }
    
    func getAdsFromCoinzila(success: @escaping(AdsModel) -> Void, endpoint: String, failer: @escaping(String) -> Void) {
        
        NetworkManager.shared.cancelTask(urlPath: adsSetting)
        NetworkManager.shared.cancelTask(urlPath: Constants.HttpsCoinzilla)
        
        NetworkManager.shared.requestFromConzila(method: .get, endpoint: endpoint, success: { (json) in
            
             guard let data = json["ad"] as? NSDictionary else {
                 let message = json["description"] as? String ?? "unknown_error"
                 failer(message.localized())
                 return
             }
             let adse = AdsModel(json: data)
             success(adse)
         }) { (error) in
             failer(error)
             debugPrint(error)
         }
     }
    
    func putAdsTrackForServer(zone: String, providerId: String, actionType: ActionType ) {
        
        var endpoint = adsAction
        endpoint = endpoint.replacingOccurrences(of: "provider_id", with: "\(providerId)")

        let params = ["actionType": actionType.rawValue, "deviceType": "\(1)", "zone": zone]
        
        NetworkManager.shared.request(method: .patch, endpoint: endpoint, params: params, encoding: URLEncoding.queryString, success: { _ in
            debugPrint("Ads Track Success")
        }) { (error) in
            debugPrint(error)
        }
    }
    
    func postForCoinzileInpression(url: String) {
        
        if let url = URL(string: url) {
            NetworkManager.shared.requestToAlamofire(method: .post, url: url)
        }
    }
}
