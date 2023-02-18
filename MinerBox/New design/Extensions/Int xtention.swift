//
//  Int xtention.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 20.04.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation

extension Int {
    func getFormatedString() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
//        numberFormatter.maximumFractionDigits = 20
        
        if let str = numberFormatter.string(from: NSNumber(value: self)) {
            return str
        }
        
        return String(self)
    }
}

extension UInt64 {
     func getFormatedString() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
//        numberFormatter.maximumFractionDigits = 20
        
        if let str = numberFormatter.string(from: NSNumber(value: self)) {
            return str
        }
        
        return String(self)
    }
    
    func textFromHashrate(withLetters: Bool = true, account: PoolAccountModel? = nil, accountFromWidget: WidgetAccountModel? = nil, hsUnit: String = "", difficulty: Bool = false) -> String {
        var count = 0
        var newNumber = self
        if newNumber > 0 {
            for _ in 1...7 {
                guard (newNumber / 1000) >= 1 else { break }
                
                newNumber = newNumber / 1000
                count += 1
            }
        }
        
        var hsUnit = hsUnit
        if let poolAccount = account {
            if poolAccount.poolSubItem == 0 {
                hsUnit = poolAccount.poolTypeHsUnit
            } else {
                hsUnit = poolAccount.poolSubItemHsUnit
            }
        }

        if let poolAccount = accountFromWidget {
            if poolAccount.poolSubItem == 0 {
                hsUnit = poolAccount.poolTypeHsUnit
            } else {
                hsUnit = poolAccount.poolSubItemHsUnit
            }
        }

        let lettersList = [" H/s", " KH/s", " MH/s", " GH/s", " TH/s", " PH/s", " EH/s", " ZH/s"]
        let lettersWithouthHsList = lettersList.map { $0.replacingOccurrences(of: "H/s", with: hsUnit) }

        let numberStr = newNumber.getFormatedString()
        let letters = hsUnit != "" || difficulty ?  lettersWithouthHsList[count] : lettersList[count]

        return withLetters ? numberStr + letters : numberStr
    }
}

