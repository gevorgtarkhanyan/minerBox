//
//  Locale extention.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 13.09.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation

extension Locale {
    static var appCurrency: String {
        set {
            if let user = DatabaseManager.shared.currentUser {
                RealmWrapper.sharedInstance.updateObjects {
                    user.currency = newValue
                }
            } else {
                UserDefaults.shared.setValue(newValue, forKeyPath: "appCurrency")
            }
        }
        
        get {
            if let user = DatabaseManager.shared.currentUser {
                if user.currency == "" {return "USD"}
                return user.currency
            }
            return UserDefaults.shared.object(forKey: "appCurrency") as? String ?? "USD"
        }
    }
    
    static var appCurrencySymbol: String {
        return getCurrencySymbol(cur: Locale.appCurrency)
    }
    
    static var param: [String: String] {
        return ["cur": Locale.appCurrency]
    }
    
    static func getCurrencySymbol(cur: String) -> String {
        var candidates: [String] = []
        let locales: [String] = NSLocale.availableLocaleIdentifiers
        for localeID in locales {
            guard let symbol = findMatchingSymbol(localeID: localeID, currencyCode: cur) else {
                continue
            }
            if symbol.count == 1 {
                return symbol
            }
            candidates.append(symbol)
        }
        let sorted = sortAscByLength(list: candidates)
        if sorted.count < 1 {
            return ""
        }
        return sorted[0]
    }
    
    //MARK: - HELPER
    static private func findMatchingSymbol(localeID: String, currencyCode: String) -> String? {
        let locale = Locale(identifier: localeID as String)
        guard let code = locale.currencyCode else {
            return nil
        }
        if code != currencyCode {
            return nil
        }
        guard let symbol = locale.currencySymbol else {
            return nil
        }
        return symbol
    }
    
    static private func sortAscByLength(list: [String]) -> [String] {
        return list.sorted(by: { $0.count < $1.count })
    }
}

