//
//  WelcomeMessageNotificationModel.swift
//  MinerBox
//
//  Created by Vazgen Hovakinyan on 28.04.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

class WelcomeMessageNotificationModel: NSObject, Codable {
    
    var content:  String
    var sentDate: Double
    let type: String?
    
    
    init(json: NSDictionary) {

        self.content = json.value(forKey: "date") as? String ?? ""
        self.sentDate = Date().timeIntervalSince1970
        self.type = NotificationType.welcomeMessage.rawValue
        
        super.init()
        NotificationManager.shared.writeWelcomeMessageToFile(notification: self)
        
    }
    
    public func getJsonData() -> Data? {
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(self)
            return jsonData
        } catch {
            debugPrint("Can't convert notification model to json: \(error.localizedDescription)")
        }
        return nil
    }
}
