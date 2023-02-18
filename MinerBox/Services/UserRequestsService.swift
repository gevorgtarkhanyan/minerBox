//
//  UserRequestsService.swift
//  MinerBox
//
//  Created by Haykaz Melikyan on 7/4/18.
//  Copyright © 2018 WitPlex. All rights reserved.
//

import UIKit
import FirebaseCrashlytics

class UserRequestsService {

    // MARK: - Properties
    static let shared = UserRequestsService()

    var currentUser: UserModel? {
        return DatabaseManager.shared.currentUser
    }

    var notificationToken: String {
        return UserDefaults.standard.string(forKey: "notificationToken") ?? ""
    }

    // MARK: - Endpoints
    let userLogin = "user/login"
    let userRegister = "user/register"
    let requestNewPool = "userRequests/newPoolRequest"
    let userVerifyPasscode = "user/verifyPassCode"
    let userForgotPassword = "user/forgotpassword"
    let userResetPassword = "user/user_id/resetPassword"

    var userLogout: String? {
        guard let user = currentUser else { return nil }
        return "user/\(user.id)/logout"
    }
    
    var userDelete: String? {
        guard let user = currentUser else { return nil }
        return "user/\(user.id)/delete"
    }

    var userUpdate: String? {
        guard let user = currentUser else { return nil }
        return "user/\(user.id)/update"
    }

    var resetPassword: String? {
        guard let user = currentUser else { return nil }
        return "user/\(user.id)/resetPassword"
    }

    var userState: String? {
        guard let user = currentUser else { return nil }
        return "user/\(user.id)/state"
    }
    
    var currencyMode: String {
        guard let user = currentUser else { return "" }
        return "user/\(user.id)/currencyMode/update"
    }
    var currencyList: String {
        return "user/currencyMode/list"
    }
}

// MARK: - Requests
extension UserRequestsService {
    public func register(email: String, name: String, password: String, success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        let params = ["email": email, "name": name, "password": password, "deviceType": "1", "deviceFCMToken": notificationToken] as [String: String]

        NetworkManager.shared.request(method: .post, endpoint: userRegister, params: params, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0, let data = json["data"] as? NSDictionary else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            ResponceHandler().createAndSaveUser(dict: data)
            self.sendDeviceInfo(force: true)
            success()
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }

    public func login(email: String, password: String, success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        let params = ["email": email, "password": password, "deviceFCMToken": notificationToken, "deviceType": "1"]
        NetworkManager.shared.request(method: .post, endpoint: userLogin, params: params, success: { (json) in
    
            guard let status = json.value(forKey: "status") as? Int, status == 0, let data = json["data"] as? NSDictionary else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            ResponceHandler().createAndSaveUser(dict: data)
            self.sendDeviceInfo(force: true)
            SubscriptionService.shared.getSubscriptionFromServer(success: {_ in
                success()
            }, failer: { (error) in
                Crashlytics.crashlytics().setCustomValue(error, forKey: "getSubcriptionFromServerError")
                failer(error)
                debugPrint(error)
            })
        }) { (error) in
            Crashlytics.crashlytics().setCustomValue(error, forKey: "loginError")
            failer(error)
            debugPrint(error)
        }
    }

    public func logout(success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        guard let endpoint = userLogout else {
            failer("Not loged in")
            return
        }

        NetworkManager.shared.request(method: .post, endpoint: endpoint, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0 else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            ResponceHandler().removeUser()
            RealmWrapper.sharedInstance.deleteObjectsFromRealmDB(FavoriteCoinModel.self)
            success()
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    public func userDelete(success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        guard let endpoint = userDelete else {
            failer("Not loged in")
            return
        }

        NetworkManager.shared.request(method: .delete, endpoint: endpoint, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0 else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            ResponceHandler().removeUser()
            RealmWrapper.sharedInstance.deleteObjectsFromRealmDB(FavoriteCoinModel.self)
            success()
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }

    func changeUsername(to newName: String, success: @escaping(String) -> Void, failer: @escaping(String) -> Void) {
        guard let endpoint = userUpdate, let user = currentUser else {
            failer("Not loged in")
            return
        }
        let params = ["name": newName]

        NetworkManager.shared.request(method: .put, endpoint: endpoint, params: params, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0, let data = json["data"] as? NSDictionary else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }

            guard let name = data["name"] as? String else {
                failer("unknown_error".localized())
                return
            }

            user.realm?.beginWrite()
            user.name = name
            do {
                try user.realm?.commitWrite()
                let message = json["description"] as? String ?? "Successfully updated"
                success(message.localized())
            } catch {
                failer("unknown_error".localized())
            }
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }

    func changePassword(oldPassword: String, newPassword: String, success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        guard let endpoint = resetPassword else {
            failer("Not loged in")
            return
        }
        let params = ["newPassword": newPassword, "password": oldPassword]

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

    func requestForNewPool(userId: String, poolName: String, success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        let params = ["userId": userId, "newPoolName": poolName]

        NetworkManager.shared.request(method: .post, endpoint: requestNewPool, params: params, success: { (json) in
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

    func checkUserState(success: @escaping() -> (), failer: @escaping(String) -> Void) {
        guard let endpoint = userState else {
            failer("Not loged in")
            return
        }

        NetworkManager.shared.request(method: .get, endpoint: endpoint, success: { (json) in
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

    func passwordReset(email: String, success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        let params = ["email": email]

        NetworkManager.shared.request(method: .post, endpoint: userForgotPassword, params: params, success: { (json) in
            if let status = json.value(forKey: "status") as? Int, status == 0 {
                success()
            } else {
                if var message = json["description"] as? String {
                    if let status = json.value(forKey: "status") as? Int, status == 315 {
                        if let jsonData = json["data"] as? NSDictionary, let attemptsTimeoutSeconds = jsonData.value(forKey: "attemptsTimeoutSeconds") as? Int {
                            var text = "You can request after xxx sec!".localized()
                            text = text.replacingOccurrences(of: "xxx", with: "\(attemptsTimeoutSeconds)")
                            message = text
                        }
                    }
                    failer(message)
                } else {
                    failer("unknown_error".localized())
                }
            }
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }

    func checkPassCode(email: String, passCode: String, userId: @escaping(String) -> Void, failer: @escaping(String) -> Void) {
        let params = ["email": email, "passCode": passCode]

        NetworkManager.shared.request(method: .post, endpoint: userVerifyPasscode, params: params, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0, let data = json["data"] as? NSDictionary, let id = data.value(forKey: "_id") as? String else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            userId(id)
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }

    func updatePasswordPost(email: String, passCode: String, userID: String, newPassword: String, successString: @escaping(String) -> Void, failer: @escaping(String) -> Void) {
        let endpoint = userResetPassword.replacingOccurrences(of: "user_id", with: userID)
        let params = ["email": email, "passCode": passCode, "newPassword": newPassword]

        NetworkManager.shared.request(method: .post, endpoint: endpoint, params: params, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0, let description = json.value(forKey: "description") as? String else {
                failer("unknown_error".localized())
                return
            }
            successString(description.localized())
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }

    func sendDeviceInfo(notificationToken: String? = nil, force: Bool = false) {
        guard let user = currentUser else {
            Crashlytics.crashlytics().setCustomValue("currentUser = nil", forKey: "currentUserState")
            return
        }
        var appVersion = "Unknown application version"
        if let info = Bundle.main.infoDictionary, let shortVersion = info["CFBundleShortVersionString"] as? String {
            appVersion = shortVersion
        }
        if (force == true) || notificationToken != nil || appVersion != UserDefaults.standard.string(forKey: "appVersion") {
            let fcmToken = notificationToken ?? UserDefaults.standard.string(forKey: "notificationToken")
            UserDefaults.standard.set(appVersion, forKey: "appVersion")

            let params = ["deviceModel": UIDevice.modelName, "appVersion": appVersion, "deviceType": "1", "deviceFCMToken": fcmToken ?? ""] as [String: String]
            let endPoint = "user/\(user.id)/deviceInfo"

            NetworkManager.shared.request(method: .post, secure: true, endpoint: endPoint, params: params, success: { (json) in
                debugPrint("device info sended: \(json)")
            }) { (error) in
                Crashlytics.crashlytics().setCustomValue(error, forKey: "sendDeviceInfoError")
                debugPrint(error)
            }
        }
    }
    
    func getCurrencyList(success: @escaping ([Currency]) -> Void, failer: @escaping (String) -> Void) {
        NetworkManager.shared.request(method: .get, endpoint: currencyList, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0,
                  let data = json["data"] as? [NSDictionary]  else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            
            var currency = [Currency]()
            
            data.forEach { currency.append( Currency(json: $0)) }
            
            success(currency)
        }) { (error) in
            failer(error.localized())
            debugPrint(error)
        }
    }
    
    func sendCurrency(_ currency: String, success: @escaping (String) -> Void, failer: @escaping (String) -> Void) {
        let params = ["currencyMode": currency]
        NetworkManager.shared.request(method: .put, endpoint: currencyMode, params: params, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0,
                  let data = json["data"] as? NSDictionary,
                  let currency = data.value(forKey: "currencyMode") as? String else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
                return
            }
            
            success(currency)
        }) { (error) in
            failer(error.localized())
            debugPrint(error)
        }
    }
}
