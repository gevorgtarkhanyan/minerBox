//
//  WhatToMineRequestService.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 11/7/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import Alamofire

class WhatToMineRequestService {
    static let shared = WhatToMineRequestService()
    private init() {}
    
    private var user: UserModel? {
        return DatabaseManager.shared.currentUser
    }
    
    private var defaultsApiWithLogIn: String? {
        if user != nil {
            return "whatmine/\(user!.id)/defaults"
        }
        return nil
    }
    
    private var calculateApi: String? {
        if user != nil {
            return "whatmine/\(user!.id)/calculate"
        }
        return nil
    }
    
    private var defaultsApiWithoutLogIn = "whatmine/defaults"
    private var modelsApi = "whatmine/models/"
    private var algorithmsApi = "whatmine/algos/"
    private var settingsApi = "whatmine/settings"
    
    func calculateSettingsData(success: @escaping(MiningDefaultsModel) -> Void, calculatedData: MiningCalculationModel) {
        let data = calculatedData.asDictionary
        
        if let userId = data["userId"],
            let isByModel = data["isByModel"],
            let cost = data["cost"],
            let difficulty = data["difficulty"] {
            
            var parameters: [String: Any] = ["isByModel": isByModel,
                                             "cost": cost,
                                             "difficulty": difficulty,
                                             "userId": userId]
            
            parameters["models"] = data["models"]
            parameters["algos"] = data["algos"]
            
            
            NetworkManager.shared.request(method: .post, endpoint: calculateApi!, params: parameters, encoding: JSONEncoding.default, success: { (dictionary) in
                if let status = dictionary.value(forKey: "status") as? Int,
                    status == 0,
                    let data = (dictionary["data"] as? NSDictionary) {
                    if let _ = data["calculatedBy"] as? NSDictionary, let _ = data["coins"] as? [NSDictionary] {
                        debugPrint("All settings data sended to backend")
                        
                        if let rates = data["rates"] as? NSDictionary {
                            UserDefaults.standard.setValue(rates, forKey: "\(self.user?.id ?? "" )/rates")
                        }
                        
                        success(MiningDefaultsModel(json: data))
                    }
                } else {
                    let message = dictionary["description"] as? String ?? "unknown_error"
                    debugPrint(message.localized())
                }
            }){ (error) in
                debugPrint(error.localized())
            }
        }
        
    }
    
    func getMiningDefaultsData(success: @escaping(MiningDefaultsModel) -> Void, failer: @escaping(String) -> Void) {
        let endpoint = user != nil ? defaultsApiWithLogIn! : defaultsApiWithoutLogIn

        NetworkManager.shared.request(method: user != nil ? .get : .post, endpoint: endpoint, params: Locale.param, success: { (json) in
            if let status = json.value(forKey: "status") as? Int,
                status == 0,
                let data = (json["data"] as? NSDictionary) {
                if let _ = data["calculatedBy"] as? NSDictionary, let _ = data["coins"] as? [NSDictionary] {
                    success(MiningDefaultsModel(json: data))
                }
                if let rates = data["rates"] as? NSDictionary {
                    UserDefaults.standard.setValue(rates, forKey: "\(self.user?.id ?? "" )/rates")
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
    
    func getMiningSettingsData(success: @escaping(MiningSettingsModels) -> Void, failer: @escaping(String) -> Void) {
        NetworkManager.shared.request(method: .get, endpoint: settingsApi, success: { (json) in
            if let status = json.value(forKey: "status") as? Int,
                status == 0,
                let data = (json["data"] as? NSDictionary) {
                success(MiningSettingsModels(json: data))
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
    
    func getMiningAlgorithmsData(type: String = "GPU", difficulty: String = "current",success: @escaping([MiningAlgorithmsModel]) -> Void, failer: @escaping(String) -> Void) {
        let endPoint = algorithmsApi + type + "/" + difficulty
        NetworkManager.shared.request(method: .get, endpoint: endPoint, success: { (json) in
            if let status = json.value(forKey: "status") as? Int,
                status == 0,
                let data = (json["data"] as? [NSDictionary]) {
                var algosData: [MiningAlgorithmsModel] = []
                algosData = data.map { MiningAlgorithmsModel(json: $0) }
                success(algosData)
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
    
    func getMiningMachineModelsData(difficulty: String = "current", success: @escaping([MiningMachineModels]) -> Void, failer: @escaping(String) -> Void) {
        let endPoint = modelsApi + difficulty
        NetworkManager.shared.request(method: .get, endpoint: endPoint, success: { (json) in
            if let status = json.value(forKey: "status") as? Int,
                status == 0,
                let data = (json["data"] as? [NSDictionary]) {
                var modelsData: [MiningMachineModels] = []
                modelsData = data.map { MiningMachineModels(json: $0) }
                success(modelsData)
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
