//
//  RequestManager.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 26.04.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation

class RequestManager {
    static let shared = RequestManager()
    
    func makeRequest(with parametrs: [String: Any]? = nil, endPoint: String, httpMethod: HttpMethod, completion: @escaping (_ result: Results) -> Void) {
        let urlString = Constants.HttpsChatUrl + endPoint
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.addValue(Constants.ChatAuthKey, forHTTPHeaderField: "authorization:Basic")
        request.httpMethod = httpMethod.rawValue
        
        if let parametrs = parametrs {
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parametrs, options: []) else { return }
            request.httpBody = httpBody
        }

//        let sesion = URLSession.shared
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            completion(Results(with: data,
                               response: response,
                               error: error))
        }.resume()
    }
    
    //MARK: - Form Data for the update
    func formDataRequest(url: URL, params: [String: Any], completion: @escaping (_ result: Results) -> Void) {
        var request = URLRequest(url: url)
        request.addValue(Constants.ChatAuthKey, forHTTPHeaderField: "authorization:Basic")
        request.httpMethod = "POST"
        
        let postString = self.getPostString(params: params)
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                completion(Results(with: data,
                                   response: response,
                                   error: error))
        }
        task.resume()
    }
    
    private func getPostString(params: [String:Any]) -> String {
        var data = [String]()
        for(key, value) in params {
            data.append(key + "=\(value)")
        }
        return data.map { String($0) }.joined(separator: "&")
    }
    
}

struct Results {
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    init(with data: Data?, response: URLResponse?, error: Error?) {
        self.data = data
        self.response = response
        self.error = error
    }
    
    init(withError error: Error) {
        self.error = error
    }
}

enum HttpMethod: String {
    case GET, POST, PUT
}
