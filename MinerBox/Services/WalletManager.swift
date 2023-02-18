//
//  WalletManager.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 22.02.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import Foundation
import Alamofire

class WalletManager {
    
    static let shared = WalletManager()
    
    fileprivate var currentUser: UserModel? {
        return DatabaseManager.shared.currentUser
    }
    private init(){}
    
    fileprivate var walletsApi: String? {
        guard let user = currentUser else { return nil }
        return "wallets/\(user.id)"
    }
    
    
    func getExchangies(short: Bool? = nil,walletId: String, success: @escaping(ExchangeModel) -> Void, failer: @escaping(String) -> Void) {
        
        let endPoint = (walletsApi ?? "") + "/\(walletId)"
        
        let param = ["short" : short as Any] as Parameters
        
        NetworkManager.shared.request(method: .get, endpoint: endPoint, params:  param, encoding: URLEncoding.queryString , success: { (json) in
            if let status = json.value(forKey: "status") as? Int, status == 0, let jsonData = json["data"] as? NSDictionary {
                
                
                if let rates = jsonData["rates"] as? NSDictionary {
                    UserDefaults.standard.setValue(rates, forKey: "\(self.currentUser?.id ?? "" )/rates")
                }
                
                success(ExchangeModel(json: jsonData))
                
            } else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
            }
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func updateExchangies(short: Bool? = nil,walletId: String, success: @escaping(ExchangeModel) -> Void, failer: @escaping(String) -> Void) {
        
        let endPoint = (walletsApi ?? "") + "/\(walletId)"
        
        let param = ["short" : short as Any] as Parameters
        
        NetworkManager.shared.request(method: .put, endpoint: endPoint, params:  param, encoding: URLEncoding.queryString , success: { (json) in
            if let status = json.value(forKey: "status") as? Int, status == 0, let jsonData = json["data"] as? NSDictionary {
                
                
                if let rates = jsonData["rates"] as? NSDictionary {
                    UserDefaults.standard.setValue(rates, forKey: "\(self.currentUser?.id ?? "" )/rates")
                }
                
                success(ExchangeModel(json: jsonData))
                
            } else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
            }
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func getWalletCoin(walletId: String, coinId: String, currency: String, exchange: String, success: @escaping(WalletCoinModel) -> Void, failer: @escaping(String) -> Void) {
        
        let endPoint = (walletsApi ?? "") + "/\(exchange)"
        
        let params: [String: Any] = ["walletId": walletId, "coinId": coinId, "currency": currency ]
        
        NetworkManager.shared.request(method: .post, endpoint: endPoint,params: params, encoding: JSONEncoding.default, success: { (json) in
            
            if let status = json.value(forKey: "status") as? Int, status == 0, let jsonData = json["data"] as? NSDictionary {
                
                success(WalletCoinModel(json: jsonData))
                
            } else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
            }
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func getTransactions(skip: Int = 0, walletId: String, txType: String, currency: String? = nil, status: String? = nil, startDate: Double? = nil, endDate: Double? = nil, success: @escaping(NSDictionary) -> Void, failer: @escaping(String) -> Void) {
        
        let endPoint = (walletsApi ?? "") + "/\(walletId)/transactions"
        
        var params: [String: Any] = ["walletId": walletId, "txType": txType, "skip": skip, "limit": Constants.transactionlimit]
        
        if let currency = currency {
            params["currency"] = currency
        }
        if let status = status,status != "all".localized() {
            params["status"] = status
        }
        if let startDate = startDate {
            params["startDate"] = startDate
        }
        if let endDate = endDate {
            params["endDate"] = endDate
        }
        
        NetworkManager.shared.request(method: .get, endpoint: endPoint, params: params, encoding: URLEncoding.queryString, success: { (json) in
            
            if let status = json.value(forKey: "status") as? Int, status == 0, let jsonData = json["data"] as? NSDictionary{
                success(jsonData)
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
