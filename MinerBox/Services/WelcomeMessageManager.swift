//
//  WelcomeMessageManager.swift
//  MinerBox
//
//  Created by Vazgen Hovakinyan on 04.05.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation
import UIKit

class WelcomeMessageManager {
    static let shared = WelcomeMessageManager()
    
    func getWelcomeMessageWithURL() {
        self.checkWelcomeMessageRequest()
    }
    
    private func checkWelcomeMessageRequest() {
        let isOver24Hors = TimerManager.shared.isLoadingTime(item: .welcome)
        if isOver24Hors || DatabaseManager.shared.communityModel == nil {
            getWelcomeNotificationFromServer()
        }
    }
    
    private  func getWelcomeNotificationFromServer() {
        LocalNotificationManager.shared.getWelcomeNotification {(welcomeMessage) in
            LocalNotificationManager.shared.setNotification(5, of: .seconds, repeats: false, title: "", body: self.changeLinkUrls(content: welcomeMessage), userInfo: ["notificationType" : NotificationType.info.rawValue])
        } failer: { (error) in
            print(error)
        }
    }
    private func changeLinkUrls(content: String) -> String {
        guard let community = DatabaseManager.shared.communityModel else { return "" }
        
        var changeFaceIdContent = ""
        var changeTelegramIdContent = ""
        let faceappString = "fb://profile/\(community.facebookID)"
        let telegramString = "tg://resolve?domain=joinchat/HMRTnxA3Wcj0GrtaKwYzZQ"
        
        guard let faceAppURL = URL(string: faceappString) else { return "" }
        if UIApplication.shared.canOpenURL(faceAppURL) {
            changeFaceIdContent = (content.replacingOccurrences(of: "facebookId", with: faceappString))
        } else {
            //redirect to browser because the user doesn't have application
            changeFaceIdContent = (content.replacingOccurrences(of: "facebookId", with: community.facebookURL))
        }
        
        guard let teleAppURL = URL(string: telegramString) else { return "" }
        if UIApplication.shared.canOpenURL(teleAppURL) {
            changeTelegramIdContent = (changeFaceIdContent.replacingOccurrences(of: "telegramUrl", with: telegramString))
        } else {
            //redirect to browser because the user doesn't have application
            changeTelegramIdContent = (changeFaceIdContent.replacingOccurrences(of: "telegramUrl", with: community.telegramURL))
        }
        return changeTelegramIdContent
    }
    
    
}
