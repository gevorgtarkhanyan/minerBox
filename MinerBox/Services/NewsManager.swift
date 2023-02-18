//
//  NewsManager.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 30.11.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation
import Alamofire

class NewsManager {
    
    static let shared = NewsManager()
    
    fileprivate var currentUser: UserModel? {
        return DatabaseManager.shared.currentUser
    }
    
    fileprivate var newsListApi: String? {
        guard let user = currentUser else { return "news/list" }
        return "news/\(user.id)/list"
    }
    fileprivate var newsApi: String? {
        return "news"
    }
    fileprivate var sourceApi: String {
        guard let user = currentUser else { return "" }
        return "news/\(user.id)/sources"
    }
    fileprivate var addSourceApi: String {
        guard let user = currentUser else { return "" }
        return "news/\(user.id)/addSource"
    }
    fileprivate var removeSourceApi: String {
        guard let user = currentUser else { return "" }
        return "news/\(user.id)/removeSource"
    }
    fileprivate var newsDetailApi: String {
        return "api/news/"
    }
    
    
    private init(){}
    
    func getNews(searchText: String?,skip: Int = 0,tab: Int,success: @escaping([NewsModel], Int) -> Void, failer: @escaping(String) -> Void) {
        
        var params = ["tab": "\(tab)","skip": "\(skip)", "limit": Constants.newslimit] as [String : Any]
        
        if let searchText = searchText {
            params["search"] = searchText
        }
        
        NetworkManager.shared.request(method: .get, endpoint: newsListApi ?? "", params: params,success: { (json) in
            if let status = json.value(forKey: "status") as? Int, status == 0, let jsonData = json["data"] as? [String: Any],
               let result = jsonData["results"] as? [NSDictionary]{
                
                let count = jsonData["count"] as? Int ?? 0
                let news = result.map { NewsModel(json: $0) }
                success(news,count)
         
            } else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
            }
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
        
    }
    
    public func putLikeOrDisLikeToBackend( userActionType: UserAction, userAction: Double, _id: String, success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        
        var endPoint = newsApi! + "/\(_id)/\(currentUser!.id)/"
        
        switch userActionType {
        case .like:
            endPoint +=  UserAction.like.rawValue
        case .unlike:
            endPoint +=  UserAction.unlike.rawValue
        case .dislike:
            endPoint +=  UserAction.dislike.rawValue
        case .undislike:
            endPoint +=  UserAction.undislike.rawValue
        }
        
        let param = ["userAction" : userAction]
        
        NetworkManager.shared.request(method: .put, endpoint: endPoint, params: param, encoding: URLEncoding.queryString, success: { _ in
            success()
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    public func putBookmarkState( isBookmarked: Bool, _id: String, success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        
        let endPoint = newsApi! + "/\(_id)/\(currentUser!.id)" + (isBookmarked ? "/unbookmark" :  "/bookmark")
        
        NetworkManager.shared.request(method: .put, endpoint: endPoint, success: { _ in
            success()
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    public func getSources( success: @escaping(SourceModel) -> Void, failer: @escaping(String) -> Void) {
        
        NetworkManager.shared.request(method: .get, endpoint: sourceApi, success: { (json) in
            if let status = json.value(forKey: "status") as? Int, status == 0, let jsonData = json["data"] as? NSDictionary {
                
                let sources = SourceModel(json: jsonData)
                success(sources)
         
            } else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
            }
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    public func addSource( source: String, success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        
        let param = ["source" : source]

        NetworkManager.shared.request(method: .put, endpoint: addSourceApi, params: param, encoding: URLEncoding.queryString, success: { _ in
            success()
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    public func removeSource( source: String,  success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        
        let param = ["source" : source]

        NetworkManager.shared.request(method: .put, endpoint: removeSourceApi, params: param, encoding: URLEncoding.queryString, success: { _ in
            success()
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    public func getNewsDetail(newsId: String,  success: @escaping(NewsModel) -> Void, failer: @escaping(String) -> Void) {
        
        let endPoint = newsDetailApi + newsId
        
        NetworkManager.shared.requestNews(method: .get, endpoint: endPoint , success: { (json) in
            if let status = json.value(forKey: "status") as? Int, status == 0, let jsonData = json["data"] as? NSDictionary
               {
                let news =  NewsModel(json: jsonData)
                success(news)
         
            } else {
                let message = json["description"] as? String ?? "unknown_error"
                failer(message.localized())
            }
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    public func patchNewsViews( _id: String, success: @escaping() -> Void, failer: @escaping(String) -> Void) {
        
        let endPoint = "news/" + _id + "/watched"
        
        NetworkManager.shared.request(method: .patch, endpoint: endPoint, success: { _ in
            success()
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
}

//Helper

enum UserAction: String {
    case like
    case unlike
    case dislike
    case undislike
}
