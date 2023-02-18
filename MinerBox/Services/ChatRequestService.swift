//
//  ChatRequestService.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 01.04.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation

class ChatRequestService {
    
    static let shared = ChatRequestService()
    private var user: UserModel? {
        return DatabaseManager.shared.currentUser
    }
    var key: String {
        return self.user == nil ? "chat" : "\(self.user!.id)chat"
    }
    
    //endpoints
    private let isOnline = "restapi/isonlinedepartment/1"
    private let newChat = "restapi/chat"
    let updateChatAttributes = "restapi/updatechatattributes"
    func chatInfo() -> String? {
        guard let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox"),
              let chatData = userDefaults.object(forKey: key) as? NSDictionary else { return nil}
        
        let chat = Chat(with: chatData)
        return "restapi/chat/\(chat.id)"
    }
    
    //Parametrs
    func toJson(val: String) -> [String: Any] {
        return ["val": val]
    }

    func startChat() -> String {
        var name = "Visitor"
        if let user = user {
            let fullName = user.name
            let components = fullName.components(separatedBy: " ")
            name = components[0]
        }
        
        let email = user != nil ? user!.email : ""
        return Constants.HttpsChatUrl + "chat/start/(fresh)/true/(department)/1/prefill%5Bemail%5D=" + email + "&prefill%5Busername%5D=" + name
    }
    
    private func chatParams(at requestType: ChatRequestMrthod) -> [String: Any] {
        let name = user != nil ? user!.name : "Visitor"
        let email = user != nil ? user!.email : ""
        var isSubscribed = "No"
        var appVersion = "Unknown application version"
        
        if user == nil {
            isSubscribed = "No"
        } else {
            isSubscribed = user!.isSubscribted ? "Yes" : "No"
        }

        if let info = Bundle.main.infoDictionary, let shortVersion = info["CFBundleShortVersionString"] as? String {
            appVersion = shortVersion
        }
        
        if requestType == .update {
            if let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox"),
               let chatData = userDefaults.object(forKey: key) as? NSDictionary {
                
                let chat = Chat(with: chatData)
                let updateDict: [String: Any] = [
                    "hash": chat.hash,
                    "data": [
                        "Username": toJson(val: name),
                        "Email": toJson(val: email),
                        "SUBSCRIPTION": toJson(val: isSubscribed),
                        "Dev Type": toJson(val: "ios"),
                        "App ver": toJson(val: appVersion)
                    ],
                    "chat_id": chat.id
                ]
                return updateDict
            }
        }
        
        let createDict: [String: Any] = [
            "ignore_required": true,
            "ignore_bot": false,
            "department": [1],
            "fields": [
              "Username": name,
              "Email": email
            ],
            "additional_data": [
               [
                "h": true,
                "identifier": "nick",
                "key": "Username",
                "value": name
                ],
                [
                "h": true,
                "identifier": "email",
                "key": "Email",
                "value": email
                ],
                [
                "h": true,
                "key": "SUBSCRIPTION",
                "value": isSubscribed
                ],
                [
                "h": true,
                "key": "Dev Type",
                "value": "ios"
                ],
                [
                "h": true,
                "key": "App ver",
                "value": appVersion
                ]
            ]
        ]
        return createDict
    }
    
    //methods
    func checkIsOnline(success: @escaping(Bool) -> Void, failer: @escaping(String) -> Void) {
        NetworkManager.shared.requestChat(method: .get, endpoint: isOnline) { (json) in
            guard let isOnline = json["isonline"] as? Bool else { return }
            
            success(isOnline)
        } failure: { (error) in
            failer(error)
        }
    }
    
    func createChat(success: @escaping(Chat) -> Void, failer: @escaping() -> Void) {
        RequestManager.shared.makeRequest(with: chatParams(at: .create), endPoint: newChat, httpMethod: .POST) { (result) in
            guard let data = result.data else { failer(); return }
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                    guard let chatData = jsonData as? NSDictionary,
                          let result = chatData.value(forKey: "result") as? NSDictionary else { return }
                    let chat = Chat(with: result)
                    success(chat)
            } catch {
                guard let _ = result.error else { return }
                failer()
            }
        }
    }
    
    func updateChat(success: @escaping(Bool) -> Void, failer: @escaping() -> Void) {
        let urlStr = Constants.HttpsChatUrl + updateChatAttributes
        guard let url = URL(string: urlStr) else { return }
        
        RequestManager.shared.formDataRequest(url: url, params: chatParams(at: .update)) { (result) in
            guard let data = result.data else { failer(); return }
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                
                if let chatData = jsonData as? NSDictionary {
                    if let error = chatData.value(forKey: "error") as? Bool {
                        success(!error)
                    } else {
                        success(true)
                    }
                } else {
                    success(false)
                }
            } catch {
                guard let _ = result.error else { return }
                failer()
            }
        }
    }
    
    func getChatInfo(success: @escaping(Bool) -> Void) {
        guard let params = chatInfo() else { return }
        RequestManager.shared.makeRequest(endPoint: params, httpMethod: .GET) { (result) in
            guard let data = result.data else { return }
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                    guard let chatData = jsonData as? NSDictionary,
                          let result = chatData.value(forKey: "result") as? NSDictionary,
                          let hasUnread = result.value(forKey: "has_unread_op_messages") as? Bool else { return }
                    
                    success(hasUnread)
            } catch {
                guard let error = result.error else { return }
                print(error)
            }
        }
    }
}

enum ChatRequestMrthod {
    case create, update
}

