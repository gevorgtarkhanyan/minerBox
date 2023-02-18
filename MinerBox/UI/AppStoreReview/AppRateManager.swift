//
//  AppRateManager.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 2/6/20.
//  Copyright © 2020 WitPlex. All rights reserved.
//

import Foundation
import UIKit

class AppRateManager {
    static let shared = AppRateManager()
    private init() {}
    
    public func setupRateApp() {
           if (UserDefaults.standard.value(forKey: Constants.lastTimeInterval) as? TimeInterval) != nil {
               if let days = getDaysAppUsed() {
                   if days >= Constants.showRateAppLastDays {
                    AppRateRequest.shared.requestReviewIfAppropriate()
                       UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: Constants.lastTimeInterval)
                   }
               }
           } else {
               if let appOpenedCount = UserDefaults.standard.value(forKey: Constants.appOpenedCount) as? Int {
                   if appOpenedCount == Constants.showRateAppOpenedTime {
                    AppRateRequest.shared.requestReviewIfAppropriate()
                       if (UserDefaults.standard.value(forKey: Constants.lastTimeInterval) as? TimeInterval) == nil {
                           let date = Date()
                           let interval = date.timeIntervalSince1970
                           UserDefaults.standard.set(interval, forKey: Constants.lastTimeInterval)
                       }
                   }
               }
           }
       }

    
    private func getDaysAppUsed() -> Int? {
        if let savedTimeInterval = UserDefaults.standard.value(forKey: Constants.lastTimeInterval) as? TimeInterval {
            let currentDate = Date()
            
            let intervalDate = currentDate.timeIntervalSince1970 - savedTimeInterval
            let usingAppTime = Date(timeIntervalSince1970: intervalDate)
            let calendar = Calendar.current
            
            let days = calendar.component(.day, from: usingAppTime)
            return days
        }
        return nil
    }
    
}
