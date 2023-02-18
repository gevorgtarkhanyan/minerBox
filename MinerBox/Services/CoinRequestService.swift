
//
//  CoinRequestService.swift
//  MinerBox
//
//  Created by Haykaz Melikyan on 7/10/18.
//  Copyright © 2018 WitPlex. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire

class CoinRequestService {

    // MARK: - Properties
    static let shared = CoinRequestService()

    fileprivate var currentUser: UserModel? {
        return DatabaseManager.shared.currentUser
    }

    // MARK: - Endpoints
    fileprivate let coinList            = "coin/list"
    fileprivate let getHistory          = "v2/coin/getHistory/coin_id/time_period"
    fileprivate let manyCoin            = "v2/coin/manyCoin"
    fileprivate let coinLimitationAPI   = "converter/configs"

    fileprivate var getFavorites: String? {
        guard let user = currentUser else { return nil }
        return "v2/userSettings/\(user.id)/coinFavorite/list"
    }
    
    fileprivate var deleteCoinFromFavorites: String? {
        guard let user = currentUser else { return nil }
        return "userSettings/\(user.id)/coinFavorite/delete"
    }

    fileprivate var addCoinToFavorites: String? {
        guard let user = currentUser else { return nil }
        return "userSettings/\(user.id)/coinFavorite/add"
    }
    
    fileprivate func getDetails(_ coinId: String) -> String {
        return "v2/coin/\(coinId.urlEncoded())/details"
    }
    
    fileprivate func getPriceDetails(_ coinId: String) -> String {
        return "v2/coin/\(coinId.urlEncoded())/getPriceDetails"
    }
    
    fileprivate func getDatePrice(_ coinId: String) -> String {
        return "coin/\(coinId)/getDatePrice"
    }
    
}

// MARK: - Requests
extension CoinRequestService {
    func getCoinsList(
        skip: Int = 0,
        searchText: String? = nil,
        sort: CoinSortModel? = nil,
        filters: [CoinFilterModel]? = nil,
        favoriteCoins: [CoinModel]? = nil,
        success: @escaping([CoinModel], [CoinModel], Int) -> Void,
        failer: @escaping(String) -> Void) {
        
        var parametrs: [String: Any] = ["skip": skip, "limit": Constants.limit]
        if let searchText = searchText {
            NetworkManager.shared.cancelTask(urlPath: coinList)
            parametrs["search"] = searchText
        }
        if let sort = sort {
            parametrs["sort"] = sort.requestDescription
        }
        if let filters = filters {
            var filterParametrs = ""
            filters.forEach {
                filterParametrs += $0.requestDescription
                filterParametrs += ","
            }
            
            filterParametrs.removeLast()
            filterParametrs = "[\(filterParametrs)]"
            parametrs["filter"] = filterParametrs
        }
        
        var coinRequestEnded = false
        var favoriteRequestEnded = false
        var allCoins = [CoinModel]()
        var favorites = [CoinModel]()
        var allCount = 0
        
        if let favoriteCoins = favoriteCoins {
            favorites = favoriteCoins
        }
        
        getCoins(parametrs: parametrs, success: { (coins, count) in
            allCoins = coins
            allCount = count
            if favoriteRequestEnded {
                success(self.configCoins(coins: allCoins, favorites: favorites), favorites, allCount)
            } else {
                coinRequestEnded = true
            }
        }) { (error) in
            failer(error)
        }
        
        if let _ = currentUser, favoriteCoins == nil {
            getFavoritesCoins(success: { (coins) in
                favorites = coins
                
                if coinRequestEnded {
                    success(self.configCoins(coins: allCoins, favorites: coins), favorites, allCount)
                } else {
                    favoriteRequestEnded = true
                }
            }) { (error) in
                failer(error)
            }
        } else {
            favoriteRequestEnded = true
        }
    }
    
    func getShortList(skip: Int, searchText: String? = nil, success: @escaping([CoinModel], Int) -> Void, failer: @escaping(String) -> Void) {
        var parametrs: [String: Any] = ["skip": skip, "limit": Constants.limit, "short": 1]
        if let searchText = searchText {
            NetworkManager.shared.cancelTask(urlPath: coinList)
            parametrs["search"] = searchText
        }
        requestWithCurrency(method: .post, endpoint: coinList, params: parametrs, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0,
                  let jsonData = json["data"] as? [String: Any],
                  let count = jsonData["count"] as? Int,
                  let result = jsonData["results"] as? [NSDictionary] else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            
            let coins = result.map { CoinModel(json: $0) }
            success(coins, count)
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    fileprivate func getCoins(parametrs: [String: Any]?, success: @escaping([CoinModel], Int) -> Void, failer: @escaping(String) -> Void) {
        requestWithCurrency(method: .post, endpoint: coinList, params: parametrs, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0,
                  let jsonData = json["data"] as? [String: Any],
                  let result = jsonData["results"] as? [NSDictionary] else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            let count = jsonData["count"] as? Int ?? 0
            
            if let rates = jsonData["rates"] as? NSDictionary {
                UserDefaults.standard.setValue(rates, forKey: "\(self.currentUser?.id ?? "" )/rates")
            }
  
            let coins = result.map { CoinModel(json: $0) }
            
            success(coins, count)
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func getCoin(coinID: String = "bitcoin", success: @escaping(CoinModel) -> Void, failer: @escaping(String) -> Void) {
        requestWithCurrency(method: .post, endpoint: getDetails(coinID), success: { (json) in
            if let status = json.value(forKey: "status") as? Int, status == 0, let jsonData = json["data"] as? NSDictionary {
                
                if let rates = jsonData["rates"] as? NSDictionary {
                    UserDefaults.standard.setValue(rates, forKey: "\(self.currentUser?.id ?? "" )/rates")
                }
                let coin = CoinModel(json: jsonData)
                
                success(coin)
            } else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
            }
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func getPrice(coinID: String = "bitcoin", success: @escaping(CoinPrice) -> Void, failer: @escaping(String) -> Void) {
        requestWithCurrency(method: .post, endpoint: getPriceDetails(coinID), success: { (json) in
            if let status = json.value(forKey: "status") as? Int, status == 0, let jsonData = json["data"] as? NSDictionary {
                let coinPrice = CoinPrice(json: jsonData)
                
                if let rates = jsonData["rates"] as? NSDictionary {
                    UserDefaults.standard.setValue(rates, forKey: "\(self.currentUser?.id ?? "" )/rates")
                }
                
                success(coinPrice)
            } else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
            }
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func getManyCoin(with params: [String], success: @escaping([CoinModel]) -> Void, failer: @escaping(String) -> Void) {
        var paramsToStr = ""
        params.forEach {
            paramsToStr += $0
            paramsToStr += ", "
        }
        paramsToStr.removeLast(2)
        let parametr = ["coinIds": paramsToStr] as [String: Any]
        
        requestWithCurrency(method: .post, endpoint: manyCoin, params: parametr) { (json) in
            if let status = json.value(forKey: "status") as? Int, status == 0,
               let jsonData = json.value(forKey: "data") as? NSDictionary,
               let result = jsonData["results"] as? [NSDictionary] {
                
                if let rates = jsonData["rates"] as? NSDictionary {
                    UserDefaults.standard.setValue(rates, forKey: "\(self.currentUser?.id ?? "" )/rates")
                }
                
                let coins = result.map { CoinModel(json: $0)}
                success(coins)
            } else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
            }
        } failure: { (error) in
            failer(error)
        }
    }
    
    func getFreeCoinLimitation(success: @escaping(Int) -> Void, failer: @escaping(String) -> Void) {
        NetworkManager.shared.request(method: .get, endpoint: coinLimitationAPI, success: { (json) in
            if let status = json.value(forKey: "status") as? Int, status == 0, let jsonData = json["data"] as? Int {
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

    func getFavoritesCoins(success: @escaping([CoinModel]) -> Void, failer: @escaping(String) -> Void) {
        guard let endpoint = getFavorites else {
            debugPrint("Not loged in. Developer issue")
            return
        }

        requestWithCurrency(method: .post, endpoint: endpoint, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0, let jsonData = json.value(forKey: "data") as? NSDictionary,
                  let result = jsonData["results"] as? [NSDictionary]  else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            

            if let rates = jsonData["rates"] as? NSDictionary {
                UserDefaults.standard.setValue(rates, forKey: "\(self.currentUser?.id ?? "" )/rates")
            }
            RealmWrapper.sharedInstance.deleteObjectsFromRealmDB(FavoriteCoinModel.self)

            let favorites = result.map { CoinModel(json: $0)      }
            _ =  result.map {  RealmWrapper.sharedInstance.addObjectInRealmDB(FavoriteCoinModel(json: $0)) }
            favorites.forEach { $0.isFavorite = true }
            success(favorites)
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }

    func deleteFromFavorites(userId: String, coinId: String, success: @escaping(String) -> Void, failer: @escaping(String) -> Void) {
        guard let endpoint = deleteCoinFromFavorites else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        let params = ["coinId": coinId]
        debugPrint("Parameters ---- \(params)")
        
        NetworkManager.shared.request(method: .post, endpoint: endpoint, params: params, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0
                  else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            RealmWrapper.sharedInstance.deleteObjectsFromRealmDB(FavoriteCoinModel.self)
            
            
            success("deleted_from_favorite".localized())
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }

    func addToFavorites(userId: String, coinId: String, success: @escaping(CoinModel,String) -> (), failer: @escaping(String) -> Void) {
        guard let endpoint = addCoinToFavorites else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        let params = ["coinId": coinId]
        
        NetworkManager.shared.request(method: .post, endpoint: endpoint, params: params, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0,
                  let data = json.value(forKey: "data") as? NSDictionary else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            RealmWrapper.sharedInstance.addObjectInRealmDB(FavoriteCoinModel(json: data))
            let coin = CoinModel(json: data)
            success(coin,"added_to_favorite".localized())
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }

    func getCoinGraph(coinId: String, period: String, success: @escaping([CoinGraphModel]) -> Void, failer: @escaping(String) -> Void) {
        var endpoint = getHistory
        endpoint = endpoint.replacingOccurrences(of: "coin_id", with: coinId.urlEncoded())
        endpoint = endpoint.replacingOccurrences(of: "time_period", with: "\(period)")

        requestWithCurrency(method: .post, endpoint: endpoint, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0,
                  let jsonData = json.value(forKey: "data") as? NSDictionary,
                  let result = jsonData["results"] as? [NSDictionary] else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }

            let filteredData = result.filter({ (item) -> Bool in
                if let _ = item.value(forKey: "date") as? Double, let _ = item.value(forKey: "usd") as? Double, let _ = item.value(forKey: "btc") as? Double {
                    return true
                }
                return false
            })
            
            if let rates = jsonData["rates"] as? NSDictionary {
                UserDefaults.standard.setValue(rates, forKey: "\(self.currentUser?.id ?? "" )/rates")
            }

            let graphData = filteredData.map { CoinGraphModel(date: $0["date"] as! Double, usd: ($0["usd"] as! Double)) }
            success(graphData)
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func getDatePrice(_ coinId: String, date: Double, success: @escaping(CoinDatePrice) -> Void, failer: @escaping(String) -> Void) {
        let params = ["date": date]
        requestWithCurrency(method: .post, endpoint: getDatePrice(coinId), params: params) { json in
            guard let status = json.value(forKey: "status") as? Int, status == 0,
                  let jsonData = json.value(forKey: "data") as? NSDictionary else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            success(CoinDatePrice(json: jsonData))
        } failure: { error in
            failer(error.localized())
        }
    }
    
    //MARK: - Main
    private func requestWithCurrency(method: HTTPMethod,
                 secure: Bool = false,
                 endpoint: String,
                 params: Parameters? = nil,
                 encoding: ParameterEncoding = URLEncoding.default,
                 success: @escaping(NSDictionary) -> Void,
                 failure: @escaping(String) -> Void) {
        
        var newParams = params ?? [:]
        newParams["cur"] = Locale.appCurrency
        
        NetworkManager.shared.request(method: method, secure: secure, endpoint: endpoint, params: newParams, encoding: encoding, success: success, failure: failure)
    }
}

// MARK: - Actions
extension CoinRequestService {
    fileprivate func configCoins(coins: [CoinModel], favorites: [CoinModel]) -> [CoinModel] {
        coins.forEach { (coin) in
            coin.isFavorite = favorites.contains(where: { $0.coinId == coin.coinId })
        }
        return coins
    }
}



