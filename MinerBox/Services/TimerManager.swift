//
//  TimerManager.swift
//  MinerBox
//
//  Created by Vazgen Hovakinyan on 04.05.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation
import UIKit


class TimerManager: NSObject {

    static let shared = TimerManager()
    
    private override init() {}
    
    private var oldDate = Date()
    
    public enum Item: String {
        case welcome
        case community
        case addressType
        case adsHide
        case fiats
        case zoneList
        case coinWidget
        case accountWidget
        case myNews
        case topNews
        case allNews
        case tweetNews
        case sendDeviceInfo


        
        var defaultsKey: String {
            return "timerManager/" + rawValue
        }
        
        var duration: Int {
            switch self {
            case .welcome, .community, .addressType:
                return 86400 // oneDayInSecond
            case .zoneList:
                return 300 // 5 minute
            case .fiats:
                return 30 * 60
            case .coinWidget:
                return 60
            case .accountWidget:
                return 60
            case .myNews, .topNews, .allNews, .tweetNews:
                return 60
            case .sendDeviceInfo:
                return 43200
            default:
                return 0
            }
        }
    }
    
    public func setDurationTime(item: Item, additionalKey: String = "") {
        UserDefaults.shared.set(Date(), forKey: item.defaultsKey + additionalKey )
    }
    
    public func isLoadingTime(item: Item, duration: Int? = nil, additionalKey: String = "", updateTime: Bool = true) -> Bool {
        let newDuration = duration ?? item.duration
        return isRefreshRequired(key: item.defaultsKey + additionalKey , duration: newDuration, updateTime: updateTime)
    }
    
    public func resetTime(item: Item) {
        UserDefaults.shared.removeObject(forKey: item.defaultsKey)
    }
    
    public func failed(_ item: Item) {
        UserDefaults.shared.set(oldDate, forKey: item.defaultsKey)
    }

    private func isRefreshRequired(key: String, duration: Int, updateTime: Bool) -> Bool {
        if let lastRefreshDate = UserDefaults.shared.object(forKey: key) as? Date {
            if let diff = Calendar.current.dateComponents([.second], from: lastRefreshDate, to: Date()).second, diff > duration {
                guard updateTime else { return true }
                oldDate = lastRefreshDate
                UserDefaults.shared.set(Date(), forKey: key)
                return true
            } else {
                return false
            }
        } else {
            UserDefaults.shared.set(Date(), forKey: key)
            return true
        }
    }
}
