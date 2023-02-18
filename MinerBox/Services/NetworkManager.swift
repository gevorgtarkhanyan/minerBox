//
//  NetworkManager.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/29/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import Alamofire
import FirebaseCrashlytics

class NetworkManager: NSObject {

    // MARK: - Properties
    private lazy var alamofireSessionManager: SessionManager? = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 25
        configuration.timeoutIntervalForResource = 25

        let trust = ServerTrustPolicyManager(policies: [
            "173.255.240.136": ServerTrustPolicy.disableEvaluation,
            "45.33.47.25": ServerTrustPolicy.disableEvaluation,
        ])

        let manager = Alamofire.SessionManager(configuration: configuration, serverTrustPolicyManager: trust)
        manager.retrier = Retrier()
        return manager
    }()

    var currentUser: UserModel? {
        return DatabaseManager.shared.currentUser
    }

    var defaultHeader: [String: String]? {
        guard let user = DatabaseManager.shared.currentUser else { return nil }
        let headerBody = ["auth": user.auth]
        return headerBody
    }
    
    var chatHeader: [String: String]? {
        let headerBody = ["authorization:Basic": Constants.ChatAuthKey]
        return headerBody
    }

    // MARK: - Static
    static let shared = NetworkManager()

    // MARK: - Init
    fileprivate override init() {
        super.init()
    }
}

// MARK: - Requests
extension NetworkManager {
    func request(method: HTTPMethod,
                 secure: Bool = false,
                 endpoint: String,
                 params: Parameters? = nil,
                 encoding: ParameterEncoding = URLEncoding.default,
                 success: @escaping(NSDictionary) -> Void,
                 failure: @escaping(String) -> Void) {
        
        Crashlytics.crashlytics().setCustomValue(endpoint, forKey: "endpoint")
        let url = secure ? URL(string: Constants.HttpsUrl + endpoint)! : URL(string: Constants.HttpUrl + endpoint)!

        alamofireSessionManager?.request(url, method: method, parameters: params, encoding: encoding, headers: defaultHeader).responseJSON { (response) -> Void in
            switch response.result {
            case .success(let value):
                guard let dictionary = value as? NSDictionary else {
                    failure("Data is not JSON")
                    return
                }
                self.checkAuthentication(json: dictionary, success: { (authenticated) in
                    if authenticated {
                        success(dictionary)
                    } else {
                        failure("Failed Authentication!")
                    }
                })
            case .failure(let error):
                guard error.localizedDescription != "cancelled" else { return }
                failure(error.localizedDescription)
            }
        }
    }
    
    func requestFromConzila(method: HTTPMethod, secure: Bool = false, endpoint: String,params: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default, success: @escaping(NSDictionary) -> Void, failure: @escaping(String) -> Void) {
        
        let url = URL(string: Constants.HttpsCoinzilla + endpoint)!

        alamofireSessionManager?.request(url, method: method, parameters: params, encoding: encoding, headers: defaultHeader).responseJSON { (response) -> Void in
            switch response.result {
            case .success(let value):
                guard let dictionary = value as? NSDictionary else {
                    failure("Data is not JSON")
                    return
                }
                self.checkAuthentication(json: dictionary, success: { (authenticated) in
                    if authenticated {
                        success(dictionary)
                    } else {
                        failure("Failed Authentication!")
                    }
                })
            case .failure(let error):
                failure(error.localizedDescription)
            }
        }
    }
    func requestNews(method: HTTPMethod, secure: Bool = false, endpoint: String,params: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default, success: @escaping(NSDictionary) -> Void, failure: @escaping(String) -> Void) {
        
        let url = URL(string: Constants.HttpNewsUrl + endpoint)!

        alamofireSessionManager?.request(url, method: method, parameters: params, encoding: encoding, headers: defaultHeader).responseJSON { (response) -> Void in
            switch response.result {
            case .success(let value):
                guard let dictionary = value as? NSDictionary else {
                    failure("Data is not JSON")
                    return
                }
                self.checkAuthentication(json: dictionary, success: { (authenticated) in
                    if authenticated {
                        success(dictionary)
                    } else {
                        failure("Failed Authentication!")
                    }
                })
            case .failure(let error):
                failure(error.localizedDescription)
            }
        }
    }
    
    func requestChat(method: HTTPMethod, endpoint: String, params: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default, success: @escaping(NSDictionary) -> Void, failure: @escaping(String) -> Void) {
        let urlString = Constants.HttpsChatUrl + endpoint
        let url = URL(string: urlString)!

        alamofireSessionManager?.request(url, method: method, parameters: params, encoding: encoding, headers: chatHeader).responseJSON { (response) -> Void in
            switch response.result {
            case .success(let value):
                guard let dictionary = value as? NSDictionary else {
                    failure("Data is not JSON")
                    return
                }
                success(dictionary)
            case .failure(let error):
                failure(error.localizedDescription)
            }
        }
    }
    
    func requestToAlamofire(method: HTTPMethod, url: URL) {
        
        alamofireSessionManager?.request(url, method: method, headers: nil).responseJSON {
            response in
            switch response.result {
            case .success:
                print(response)
                
                break
            case .failure(let error):
                
                print(error)
            }
        }
    }
}

// MARK: - Actions
extension NetworkManager {
    func checkAuthentication(json: NSDictionary, success: @escaping(Bool) -> Void) {
        guard let description = json.value(forKey: "description") as? String else {
            success(true)
            return
        }
        if description == "Failed Authentication!" || (description == "User not exist!" && currentUser != nil) {
//            if UIApplication.shared.isIgnoringInteractionEvents {
//                UIApplication.shared.endIgnoringInteractionEvents()
//            }
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Constants.userLogout)))
            success(false)
        } else {
            success(true)
        }
    }
    
    func cancelTask(urlPath: String) {
        alamofireSessionManager?.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach {
                let urlString = "\(String(describing: $0.originalRequest?.url))"
                if urlString.contains(urlPath) {
                    $0.cancel()
                }
            }
            uploadData.forEach {
                let urlString = "\(String(describing: $0.originalRequest?.url))"
                if urlString.contains(urlPath) {
                    $0.cancel()
                }
            }
            downloadData.forEach {
                let urlString = "\(String(describing: $0.originalRequest?.url))"
                if urlString.contains(urlPath) {
                    $0.cancel()
                }
            }
        }
    }
}

// MARK: - Helpers
struct AppstoreEncoding: ParameterEncoding {
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try URLEncoding().encode(urlRequest, with: parameters)
        let bodyString = parameters?.map { "\($0.0)=\($0.1)" }.joined(separator: "&")
        request.httpBody = bodyString?.data(using: String.Encoding.utf8)
        return request
    }
}

struct Retrier: RequestRetrier {
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        if error.localizedDescription.lowercased().contains("network connection was lost") {
            completion(true, 0.1)
            return
        }
        completion(false, 0.0)
    }
}
