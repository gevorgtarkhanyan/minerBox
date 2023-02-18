//
//  AlertRequestService.swift
//  MinerBox
//
//  Created by Haykaz Melikyan on 7/18/18.
//  Copyright © 2018 WitPlex. All rights reserved.
//

import Foundation
import Alamofire

class AlertRequestService {

    // MARK: - Static
    static let shared = AlertRequestService()

    // MARK: - Properties
    var currentUser: UserModel? {
        return DatabaseManager.shared.currentUser
    }

    // MARK: - Endpoints
    fileprivate var alertList: String? {
        guard let user = currentUser else { return nil }
        return "v2/coinAlert/\(user.id)/list"
    }

    fileprivate var addAlert: String? {
        guard let user = currentUser else { return nil }
        return "coinAlert/\(user.id)/add"
    }

    fileprivate var editAlert: String? {
        guard let user = currentUser else { return nil }
        return "coinAlert/\(user.id)/alert_id/update"
    }

    fileprivate var deleteAlert: String? {
        guard let user = currentUser else { return nil }
        return "coinAlert/\(user.id)/alert_id/delete"
    }
    
    fileprivate var deleteAlerts: String? {
        guard let user = currentUser else { return nil }
        return "coinAlert/\(user.id)/deleteAllByCoin"
    }
    
}

// MARK: - Requests
extension AlertRequestService {
    func getCoinAlerts(success: @escaping([AlertModel]) -> Void, failer: @escaping(String) -> Void) {
        guard let endpoint = alertList else {
            debugPrint("Not loged in. Developer issue")
            return
        }

        NetworkManager.shared.request(method: .post, endpoint: endpoint, success: { (json) in
            guard let status = json["status"] as? Int, status == 0, let jsonData = json["data"] as? NSDictionary,
                let results = jsonData["results"] as? [NSDictionary] else {
                
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            if let rates = jsonData["rates"] as? NSDictionary {
                UserDefaults.standard.setValue(rates, forKey: "\(self.currentUser?.id ?? "" )/rates")
            }
            
            var alerts = [AlertModel]()
            
            _ = results.map {
                
                if   let alertsJson = $0["alerts"] as? [NSDictionary] {
                    for alert in alertsJson {
                        alerts.append(AlertModel(json: $0, alertJson: alert))
                    }
                }
            }
            success(alerts)
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }

    func addAlertRequest(coinId: String, value: Double, isRepeat: Bool, enabled: Bool, comparison: Int, success: @escaping(String, NSDictionary) -> Void, failer: @escaping(String) -> Void) {
        guard let endpoint = addAlert else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        let params: [String: Any] = ["coinId": coinId, "value": value, "repeat": "\(isRepeat)", "enabled": "\(enabled)", "comparison": "\(comparison)"]
        NetworkManager.shared.request(method: .post, endpoint: endpoint, params: params, success: { (json) in
            guard let status = json["status"] as? Int, status == 0,
                  let data = json["data"] as? NSDictionary else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            
            success("successfully_added".localized(), data)
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }

    func editAlertRequest(alertId: String, value: Double, isRepeat: Bool, enabled: Bool, comparison: Int, success: @escaping(String, NSDictionary) -> Void, failer: @escaping(String) -> Void) {

        guard var endpoint = editAlert else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        endpoint = endpoint.replacingOccurrences(of: "alert_id", with: "\(alertId)")
        let params: [String: Any] = ["value": value, "repeat": "\(isRepeat)", "enabled": "\(enabled)", "comparison": "\(comparison)"]

        NetworkManager.shared.request(method: .put, endpoint: endpoint, params: params, success: { (json) in
            guard let status = json["status"] as? Int, status == 0,
                  let data = json["data"] as? NSDictionary else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            success("successfully_updated".localized(), data)
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }

    func removeAlertRequest(alertId: String, success: @escaping(String) -> Void, failer: @escaping(String) -> Void) {
        guard var endpoint = deleteAlert else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        endpoint = endpoint.replacingOccurrences(of: "alert_id", with: "\(alertId)")

        NetworkManager.shared.request(method: .delete, endpoint: endpoint, success: { (json) in
            guard let status = json["status"] as? Int, status == 0 else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            success("coin_alert_deleted".localized())
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func removeAlertsRequest(coinId: String, success: @escaping(String) -> Void, failer: @escaping(String) -> Void) {
        guard let endpoint = deleteAlerts else {
            debugPrint("Not loged in. Developer issue")
            return
        }

        let params = ["coinId": coinId]

        NetworkManager.shared.request(method: .post, endpoint: endpoint, params: params, success: { (json) in
            guard let status = json["status"] as? Int, status == 0 else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            success("coin_alert_deleted".localized())
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    

}
