//
//  PoolRequestService.swift
//  MinerBox
//
//  Created by Haykaz Melikyan on 7/27/18.
//  Copyright © 2018 WitPlex. All rights reserved.
//

import UIKit
import Alamofire

class PoolRequestService {
    
    // MARK: - Properties
    static let shared = PoolRequestService()
    
    fileprivate var currentUser: UserModel? {
        return DatabaseManager.shared.currentUser
    }
    
    fileprivate var notificationToken: String {
        return UserDefaults.standard.string(forKey: "notificationToken") ?? ""
    }
    
    // MARK: - Endpoints
    fileprivate let poolList = "type/poolTypeList"
    
    fileprivate var accountList: String? {
        guard let user = currentUser else { return nil }
        return "poolAccount/\(user.id)/list"
    }
    
    fileprivate var poolStatistics: String? {
        guard let user = currentUser else { return nil }
        return "poolData/pool_type_id/\(user.id)/stats"
    }
    
    fileprivate var accountSettings: String? {
        guard let user = currentUser else { return nil }
        return "poolData/pool_type_id/\(user.id)/pool_id/settings"
    }
    
    fileprivate var accountPayouts: String? {
        guard let user = currentUser else { return nil }
        return "poolData/pool_type_id/\(user.id)/pool_id/payouts"
    }
    
    fileprivate var accountAlerts: String? {
        guard let user = currentUser else { return nil }
        return "poolAlert/pool_type_id/\(user.id)/list"
    }
    
    fileprivate var updateAlert: String? {
        guard let user = currentUser else { return nil }
        return "poolAlert/pool_type_id/\(user.id)/alert_id/update"
    }
    
    fileprivate var addAlert: String? {
        guard let user = currentUser else { return nil }
        return "poolAlert/pool_type_id/\(user.id)/add"
    }
    
    fileprivate var deleteAlert: String? {
        guard let user = currentUser else { return nil }
        return "poolAlert/pool_type_id/\(user.id)/pool_id/delete"
    }
    
    fileprivate var checkAccountStatus: String? {
        guard let user = currentUser else { return nil }
        return "poolData/pool_id/\(user.id)/status"
    }
    
    fileprivate var addAccount: String? {
        guard let user = currentUser else { return nil }
        return "poolAccount/\(user.id)/add"
    }
    
    fileprivate var editAccount: String? {
        guard let user = currentUser else { return nil }
        return "poolAccount/\(user.id)/pool_id/update"
    }
    
    fileprivate var activateAccount: String? {
        guard let user = currentUser else { return nil }
        return "poolAccount/\(user.id)/pool_id/activate"
    }
    
    fileprivate var getHistory: String? {
        guard let user = currentUser else { return nil }
        return "poolData/pool_type_id/\(user.id)/pool_id/history"
    }
    
    fileprivate var accountWorkers: String? {
        guard let user = currentUser else { return nil }
        return "poolData/pool_type_id/\(user.id)/pool_id/workers"
    }
    
    fileprivate var deleteAccount: String? {
        guard let user = currentUser else { return nil }
        return "poolAccount/\(user.id)/pool_id/delete"
    }
    
    fileprivate var accountUpdateOrders: String? {
        guard let user = currentUser else { return nil }
        return "poolAccount/\(user.id)/updateOrders"
    }
    
    fileprivate var accountsBalance: String? {
        guard let user = currentUser else { return nil }
        return  "poolAccount/\(user.id)/balanceInfo"
    }
    
    fileprivate var newAccountsBalance: String? {
        guard let user = currentUser else { return nil }
        return  "v2/poolAccount/\(user.id)/balanceInfo"
    }
    
    fileprivate var deleteByAlertType: String? {
        guard let user = currentUser else { return nil }
        return "PoolAlert/pool_type_id/\(user.id)/deleteByAlertType"
    }
    
    fileprivate var extra: [String:String] = [:]
    
}

// MARK: - Requests
extension PoolRequestService {
    public func getTypeList(success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        NetworkManager.shared.request(method: .get, endpoint: poolList, params: nil, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0, let data = json["data"] as? [NSDictionary] else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            self.savePoolDictToFile(dict: data)
            DispatchQueue.main.async {
                RealmWrapper.sharedInstance.deletePoolTypeModelsFromDB()
                
                for (index, item) in data.enumerated() {
                    ResponceHandler().createAndSavePoolsType(dict: item, key: index)
                }
                success()
            }
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func getAccounts(success: @escaping([PoolAccountModel]) -> Void, failer: @escaping(String) -> Void) {
        guard let endpoint = accountList else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        
        NetworkManager.shared.request(method: .get, endpoint: endpoint, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0, let data = json["data"] as? [NSDictionary] else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            
            //            RealmWrapper.sharedInstance.deleteObjectsFromRealmDB(KitWidgetAccountModel.self)
            //            RealmWrapper.sharedInstance.deleteObjectsFromRealmDB(PoolAccountModel.self)
            //            data.forEach { ResponceHandler().createAndSavePoolAccount(dict: $0) }
            
            
            let accounts = data.map { PoolAccountModel(json: $0) }
            
            DispatchQueue.main.async {
                if let accountsFromDB = DatabaseManager.shared.allPoolAccounts {
                    accounts.forEach({
                        //                    RealmWrapper.sharedInstance.addObjectInRealmDB(KitWidgetAccountModel(name: $0.poolAccountLabel, accountId: $0.id),KitWidgetAccountModel.self)
                        if !accountsFromDB.contains($0)  {
                            RealmWrapper.sharedInstance.addObjectInRealmDB($0)
                        }
                    })
                    accountsFromDB.forEach({
                        if !accounts.contains($0) {
                            ResponceHandler().removePoolAccount(poolId: $0.id)
                        }
                    })
                }
                success(accounts.sorted { $0.order < $1.order })
            }
            //Compare Backend Accounts with RealmDBAccounts
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func getPoolStatistics(poolType: Int, poolSubItem: Int, success: @escaping(PoolStatsModel) -> Void, failer: @escaping(String) -> Void) {
        guard var endpoint = poolStatistics else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        
        endpoint = endpoint.replacingOccurrences(of: "pool_type_id", with: "\(poolType)")
        let params = ["poolSubItem": "\(poolSubItem)"]
        
        NetworkManager.shared.request(method: .post, endpoint: endpoint, params: params, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0, let data = json["data"] as? NSDictionary else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            if let rates = json["rates"] as? NSDictionary {
                UserDefaults.standard.setValue(rates, forKey: "\(self.currentUser?.id ?? "" )/rates")
            }
            success(PoolStatsModel(json: data))
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func getAccountSettings(poolId: String, poolType: Int, success: @escaping(PoolSettingsModel) -> Void, failer: @escaping(String) -> Void) {
        guard var endpoint = accountSettings else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        endpoint = endpoint.replacingOccurrences(of: "pool_type_id", with: "\(poolType)")
        endpoint = endpoint.replacingOccurrences(of: "pool_id", with: "\(poolId)")
        
        let params = ["short": 1]
        
        
        guard let pool = DatabaseManager.shared.getPool(id: poolType) else {
            failer("Pool does not exist")
            return
        }
        
        NetworkManager.shared.request(method: .post, endpoint: endpoint, params: params, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0, let data = json["data"] as? NSDictionary else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            if let rates = data["rates"] as? NSDictionary {
                UserDefaults.standard.setValue(rates, forKey: "\(self.currentUser?.id ?? "" )/rates")
            }
            let accountSettings = PoolSettingsModel(json: data, extHashrate: pool.extHashrate, extWorkers: pool.extWorkers, extShares: pool.extShares, extBalance: pool.extBalance, extGroupWorkers: pool.extGroups, extBlocks: pool.extBlocks)
            
            // Check for worker groups
            if let workerGroups = data.value(forKey: "groups") as? [NSDictionary] {
                for workerGroup in workerGroups {
                    accountSettings.addWorkerGroup(WorkerGroup(json: workerGroup))
                }
            }
            
            //Check for rewards
            if let sumRewards = data.value(forKey: "sumRewards") as? [NSDictionary] {
                for sumReward in sumRewards {
                    accountSettings.addReward(Reward(json: sumReward))
                }
            }
            
            //Check for estimation
            if let estimations = data.value(forKey: "estimations") as? [NSDictionary] {
                
                if let rates = data["rates"] as? NSDictionary {
                    UserDefaults.standard.setValue(rates, forKey: "\(self.currentUser?.id ?? "" )/rates")
                }
                
                for estimation in estimations {
                    accountSettings.addEstimation(Estimation(json: estimation))
                }
            }
            
            Cacher.shared.accountSettings = accountSettings
            success(accountSettings)
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func getAccountPayments(poolId: String, poolType: Int, type: PoolPaymentType ,successArray: @escaping([PoolPaymentModel]) -> Void, failer: @escaping(String) -> Void) {
        guard var endpoint = accountPayouts else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        endpoint = endpoint.replacingOccurrences(of: "pool_type_id", with: "\(poolType)")
        endpoint = endpoint.replacingOccurrences(of: "pool_id", with: "\(poolId)")
        
        let params = ["type": type.rawValue]
        
        NetworkManager.shared.request(method: .post, endpoint: endpoint, params: params , success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0, let data = json["data"] as? [NSDictionary] else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            
            let payouts = data.map { PoolPaymentModel(json: $0) }
            self.getPayoutDurations(payouts)
            successArray(payouts)
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func getPoolAccountAlerts(poolType: Int, poolId: String, success: @escaping([PoolAlertModel]) -> Void, failer: @escaping(String) -> Void) {
        guard var endpoint = accountAlerts else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        endpoint = endpoint.replacingOccurrences(of: "pool_type_id", with: "\(poolType)")
        let params = ["poolId": poolId]
        
        NetworkManager.shared.request(method: .post, endpoint: endpoint, params: params, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0, let data = json["data"] as? [NSDictionary] else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            let alertArray = data.map { PoolAlertModel(json: $0) }
            success(alertArray)
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func updateAutomatPoolAlert(poolType: Int, alertType: Int,alertId: String, isEnabled: Bool, success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        guard var endpoint = updateAlert else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        endpoint = endpoint.replacingOccurrences(of: "pool_type_id", with: "\(poolType)")
        endpoint = endpoint.replacingOccurrences(of: "alert_id", with: "\(alertId)")
        let params = ["enabled": "\(isEnabled)", "alertType": alertType] as [String : Any]
        
        NetworkManager.shared.request(method: .put, endpoint: endpoint, params: params, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0 else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            success()
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    // value - sending count
    // comparison - great(0) or less(1)
    // alertType - hashrate(0) or worker(1)
    func addAccountAlert(poolId: String, count: Double, isRepeat: Bool, isEnabled: Bool, comparison: Int, alertType: Int, poolType: Int, success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        guard var endpoint = addAlert else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        endpoint = endpoint.replacingOccurrences(of: "pool_type_id", with: "\(poolType)")
        let params = ["poolId": poolId, "value": "\(count)", "repeat": "\(isRepeat)", "enabled": "\(isEnabled)", "comparison": "\(comparison)", "alertType": "\(alertType)"]
        
        NetworkManager.shared.request(method: .post, endpoint: endpoint, params: params, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0 else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            success()
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func updatePoolAlert(alertId: String, count: Double, isRepeat: Bool, isEnabled: Bool, comparison: Int, poolType: Int, success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        guard var endpoint = updateAlert else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        endpoint = endpoint.replacingOccurrences(of: "pool_type_id", with: "\(poolType)")
        endpoint = endpoint.replacingOccurrences(of: "alert_id", with: "\(alertId)")
        let params = ["value": "\(count)", "repeat": "\(isRepeat)", "enabled": "\(isEnabled)", "comparison": "\(comparison)"]
        
        NetworkManager.shared.request(method: .put, endpoint: endpoint, params: params, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0 else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            success()
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func deleteAccountAllert(poolId: String, poolType: Int, success: @escaping(String) -> Void, failer: @escaping(String) -> Void) {
        guard var endpoint = deleteAlert else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        endpoint = endpoint.replacingOccurrences(of: "pool_type_id", with: "\(poolType)")
        endpoint = endpoint.replacingOccurrences(of: "pool_id", with: "\(poolId)")
        
        NetworkManager.shared.request(method: .delete, endpoint: endpoint, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0 else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            success("deleted".localized())
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func deleteByAlertType(poolType: Int, poolId: String, alertType: Int, success: @escaping(String) -> Void, failer: @escaping(String) -> Void) {
        guard var endpoint = deleteByAlertType else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        endpoint = endpoint.replacingOccurrences(of: "pool_type_id", with: "\(poolType)")
        let params = ["poolId": poolId, "alertType": alertType] as? [String: Any]
        
        
        NetworkManager.shared.request(method: .delete, endpoint: endpoint, params: params, encoding: URLEncoding.queryString ,success: { (json) in
            guard let status = json["status"] as? Int, status == 0 else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            success("deleted".localized())
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
        
    }
    
    func checkAccountStatusRequest(apiKey: String, poolId: Int, subPoolId: Int?, extras:[Extra] = [], success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        guard var endpoint = checkAccountStatus else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        self.extra.removeAll()
        
        endpoint = endpoint.replacingOccurrences(of: "pool_id", with: "\(poolId)")
        
        var params = ["poolAccountId": apiKey, "poolSubItem": "\(subPoolId ?? 0)"] as [String : Any]
        
        for _extra in extras {
            self.extra[_extra.extraId] = _extra.text
        }
        
        params["extras"] = self.extra
        
        NetworkManager.shared.request(method: .post, endpoint: endpoint, params: params, encoding: JSONEncoding.prettyPrinted, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0 else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            success()
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
        
    }
    
    func addPoolAccountRequest(apiKey: String, poolId: Int, subPoolId: Int?, extras:[Extra] = [], label: String, success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        guard let endpoint = addAccount else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        self.extra.removeAll()
        
        var params = ["poolAccountId": apiKey, "poolType": "\(poolId)", "poolSubItem": "\(subPoolId ?? 0)", "poolAccountLabel": label, "poolAccountPassword": ""] as [String : Any]
        
        for _extra in extras {
            
            self.extra[_extra.extraId] = _extra.text
            
        }
        
        params["extras"] = self.extra
        
        NetworkManager.shared.request(method: .post, endpoint: endpoint, params: params,encoding: JSONEncoding.prettyPrinted, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0 ,let data = json["data"] as? NSDictionary else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            DispatchQueue.main.async {
                ResponceHandler().createAndSavePoolAccount(dict: data)
                success()
            }
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func updatePoolAccountRequest(apiKey: String, poolType: Int, poolId: String, subPoolId: Int?, extras:[Extra] = [], label: String, success: @escaping() -> Void, failer: @escaping(String) -> ()) {
        guard var endpoint = editAccount else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        self.extra.removeAll()
        
        endpoint = endpoint.replacingOccurrences(of: "pool_id", with: "\(poolId)")
        
        var params = ["poolAccountId": apiKey, "poolType": "\(poolType)", "id": poolId, "poolSubItem": "\(subPoolId ?? 0)", "poolAccountLabel": label, "poolAccountPassword": ""] as [String : Any]
        
        for _extra in extras {
            
            self.extra[_extra.extraId] = _extra.text
            
        }
        params["extras"] = self.extra
        
        
        NetworkManager.shared.request(method: .put, endpoint: endpoint, params: params, encoding: JSONEncoding.prettyPrinted, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0 else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            DispatchQueue.main.async {
                ResponceHandler().updatePoolAccount(poolId: poolId, poolAccountId: apiKey, poolAccountLabel: label)
                success()
            }
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func activatePoolAccountRequest(poolId: String, success: @escaping() -> (), failer: @escaping(String) -> Void) {
        guard var endpoint = activateAccount else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        endpoint = endpoint.replacingOccurrences(of: "pool_id", with: "\(poolId)")
        
        NetworkManager.shared.request(method: .post, endpoint: endpoint, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0 else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            success()
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func deletePoolAccount(poolId: String, success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        guard var endpoint = deleteAccount else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        endpoint = endpoint.replacingOccurrences(of: "pool_id", with: "\(poolId)")
        
        NetworkManager.shared.request(method: .delete, endpoint: endpoint, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0 else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            DispatchQueue.main.async {
                ResponceHandler().removePoolAccount(poolId: poolId)
                success()
            }
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func getAccountHistory(poolId: String, poolType: Int, type: Int, success: @escaping([PoolGraphModel]) -> Void, failer: @escaping(String) -> Void) {
        guard var endpoint = getHistory else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        endpoint = endpoint.replacingOccurrences(of: "pool_id", with: "\(poolId)")
        endpoint = endpoint.replacingOccurrences(of: "pool_type_id", with: "\(poolType)")
        
        let param = ["type" : type ]
        
        NetworkManager.shared.request(method: .post, endpoint: endpoint, params: param, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0, let data = json["data"] as? [NSDictionary] else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            let history = data.map { PoolGraphModel(json: $0) }
            success(history)
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func getAccountWorkersList(poolId: String, poolType: Int, success: @escaping([PoolWorkerModel]) -> Void, failer: @escaping(String) -> Void) {
        guard var endpoint = accountWorkers else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        endpoint = endpoint.replacingOccurrences(of: "pool_id", with: "\(poolId)")
        endpoint = endpoint.replacingOccurrences(of: "pool_type_id", with: "\(poolType)")
        
        NetworkManager.shared.request(method: .post, endpoint: endpoint, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0, let data = json["data"] as? [NSDictionary] else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            let workers = data.map { PoolWorkerModel(json: $0) }
            success(workers)
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    //MARK: - Balance
    func getPoolsBalance( success: @escaping([PoolBalanceModel]) -> Void, failer: @escaping(String) -> Void) {
        
        guard let endpoint = newAccountsBalance else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        let param = ["widget" : "0"]
        
        NetworkManager.shared.request(method: .get, endpoint: endpoint, params: param, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0, let data = json["data"] as? [NSDictionary] else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            
            let poolWithBalances = data.map { PoolBalanceModel(json: $0) }
            success(poolWithBalances)
            
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func getBalanceForWidgetFromServer ( success: @escaping([WidgetBalanceModel]) -> Void, failer: @escaping(String) -> Void) {
        
        guard let endpoint = accountsBalance else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        let param = ["widget" : "1"]
        
        NetworkManager.shared.request(method: .get, endpoint: endpoint, params: param, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0, let data = json["data"] as? [NSDictionary] else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            
            let widgetBalances = data.map { WidgetBalanceModel(json: $0) }
            success(widgetBalances)
            
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func updateOrders(params: [String: String], failer: @escaping(String) -> Void) {
        guard let endpoint = accountUpdateOrders else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        
        let body = ["poolAccounts": params]
        
        NetworkManager.shared.request(method: .put, endpoint: endpoint, params: body, encoding: JSONEncoding.default, success: { (dict) in
            debugPrint("Success order")
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
}

// MARK: - Actions
extension PoolRequestService {
    fileprivate func savePoolDictToFile(dict: [NSDictionary]) {
        do {
            let data: Data?
            if #available(iOS 11.0, *) {
                data = try NSKeyedArchiver.archivedData(withRootObject: dict, requiringSecureCoding: false)
            } else {
                data = NSKeyedArchiver.archivedData(withRootObject: dict)
            }
            let url = Constants.fileManagerURL
            let poolListUrl = url.appendingPathComponent("PoolList")
            try data?.write(to: poolListUrl)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    fileprivate func getPayoutDurations(_ payouts: [PoolPaymentModel]) {
        guard payouts.count > 1 else { return }
        
        var prevDate: Date!
        for i in stride(from: payouts.count - 1, through: 0, by: -1) {
            let item = payouts[i]
            var paidDate =  Date(timeIntervalSince1970: item.paidOn)
            if item.dateUnix != 0 {
                paidDate = Date(timeIntervalSince1970: item.dateUnix)
            }
            if item.timestamp != 0 {
                paidDate = Date(timeIntervalSince1970: item.timestamp)
            }
            if prevDate != nil {
                let duration = self.daysBetweenDates(expireDate: prevDate, currentDate: paidDate)
                item.duration = duration
            }
            prevDate = paidDate
        }
        payouts.last?.duration = ""
    }
    
    func daysBetweenDates(expireDate: Date, currentDate: Date) -> String {
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.month, .day, .hour, .minute, .second], from: expireDate, to: currentDate)
        guard let month = components.month, let day = components.day, let hour = components.hour, let minute = components.minute, let second = components.second else { return "" }
        var duration = ""
        
        if month != 0 {
            duration += "\(month)" + "M".localized() + " "
        }
        
        if day != 0 {
            duration += "\(day)" + "D".localized() + " "
        }
        
        if hour != 0 {
            duration += "\(hour)" + "hr".localized() + " "
        }
        
        if minute != 0 {
            duration += "\(minute)" + "min".localized() + " "
        }
        
        if second != 0 {
            duration += "\(second)" + "sec".localized()
        } else if duration.isEmpty {
            duration = "\(second)" + "sec".localized()
        }
        
        return duration
    }
}

