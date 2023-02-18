//
//  Double Extension.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 1/25/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import Localize_Swift

extension Double {
    func textFromHashrate(withLetters: Bool = true, account: PoolAccountModel? = nil, accountFromWidget: WidgetAccountModel? = nil, hsUnit: String = "", difficulty: Bool = false) -> String {
        var count = 0
        var newNumber = self
        if newNumber > 0 {
            for _ in 1...7 {
                if (newNumber / 1000) >= 1 {
                    newNumber = newNumber / 1000
                    count += 1
                } else {
                    break
                }
            }
        }
        //        var letters = ""
        var hsUnit = hsUnit
        if let poolAccount = account {
            hsUnit = poolAccount.hsUnit
        }
        
        if let poolAccount = accountFromWidget {
            hsUnit = poolAccount.hsUnit
        }
        
        let lettersList = [" H/s", " KH/s", " MH/s", " GH/s", " TH/s", " PH/s", " EH/s", " ZH/s"]
        let lettersWithouthHsList = lettersList.map { $0.replacingOccurrences(of: "H/s", with: hsUnit) }
        
        // to reduce the fractional part
        if let updatedDouble = newNumber.getString().toDouble() {
            newNumber = updatedDouble
        }
        
        let numberStr = floor(newNumber) == newNumber ? Int(newNumber).getFormatedString() : newNumber.getFormatedString()
        let letters = hsUnit != "" || difficulty ?  lettersWithouthHsList[count] : lettersList[count]
        
        return withLetters ? numberStr + letters : numberStr
    }
    
    func formatUsingAbbrevation () -> String {
        let numFormatter = NumberFormatter()
        
        typealias Abbrevation = (threshold:Double, divisor:Double, suffix:String)
        let abbreviations:[Abbrevation] = [(0, 1, ""),
                                           (1000.0, 1000.0, "K"),
                                           (100_000.0, 1_000_000.0, "M"),
                                           (100_000_000.0, 1_000_000_000.0, "B")]
        // you can add more !
        
        let startValue = Double (abs(self))
        let abbreviation:Abbrevation = {
            var prevAbbreviation = abbreviations[0]
            for tmpAbbreviation in abbreviations {
                if (startValue < tmpAbbreviation.threshold) {
                    break
                }
                prevAbbreviation = tmpAbbreviation
            }
            return prevAbbreviation
        } ()
        
        let value = Double(self) / abbreviation.divisor
        numFormatter.positiveSuffix = abbreviation.suffix
        numFormatter.negativeSuffix = abbreviation.suffix
        numFormatter.allowsFloats = true
        numFormatter.minimumIntegerDigits = 1
        numFormatter.minimumFractionDigits = 0
        numFormatter.maximumFractionDigits = 1
        
        return numFormatter.string(from: NSNumber (value:value))!
    }
    
    func textFromUnixTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MMM/yyyy HH:mm"
        formatter.locale = Locale(identifier: Localize.currentLanguage())
        formatter.string(from: Date(timeIntervalSince1970: TimeInterval(self)))
        return formatter.string(from: Date(timeIntervalSince1970: TimeInterval(self)))
    }
    
    func secondsToHrMinSec() -> String {
        let seconds = Int(self)
        let month = seconds / 1_036_800
        let day = seconds % 1_036_800 / 86400
        let dayMnacord = (seconds % 1_036_800) % 86400
        let (hour, minute, second) = (dayMnacord / 3600, (dayMnacord % 3600) / 60, (dayMnacord % 3600) % 60)
        
        if month > 0 {
            return "\(month) " + "M".localized() + " \(day) " + "D".localized()
        } else if day > 0 {
            return "\(day) " + "D".localized() + " \(hour) " + "hr".localized()
        } else if hour > 0 {
            return "\(hour) " + "hr".localized() + " \(minute) " + "min".localized()
        } else if minute > 0 {
            return "\(minute) " + "min".localized() + " \(second) " + "sec".localized()
        } else if second > 0 {
            return "\(second) " + "sec".localized()
        } else {
            return ""
        }
    }
    
    func secondsToDayHr() -> String {
        let seconds = Int(self)
        
        //to show 24 Hour insted of 1 Day
        let day = seconds > 86400 ? seconds / 86400 : 0
        let hour = seconds > 86400 ? seconds % 86400 / 3600 : seconds / 3600
        var date = "";
        
        if day > 0 {
            date = "\(day) " + "day".localized();
            if hour > 0 {
                date += " \(hour) " + "hour".localized()
            }
        } else if hour > 0 {
            date = "\(hour) " + "hour".localized()
        }
        
        return date
    }
    
    func getString() -> String {
        guard !self.isNaN else { return "0" }
        
        var doubleString = String(self)
        var largeNumber = self
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        if self < 1 && self != 0 && self > -1 {
            doubleString = String(format: "%f", self)
            numberFormatter.maximumFractionDigits = 6
            //for the small number 2.1e-14
            if numberFormatter.string(from: NSNumber(value: largeNumber)) == "0" {
                largeNumber = largeNumber > 0 ? 0.000001 : -0.000001
            } else {
                largeNumber = Double(doubleString) ?? self
            }
        }
        
        if let str = numberFormatter.string(from: NSNumber(value: largeNumber)) {
            doubleString = str
        }
        return doubleString
    }
    
    func getFormatedString(maximumFractionDigits: Int = 3) -> String {
        var doubleString = String(self)
        var largeNumber = self
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = maximumFractionDigits
        
        
        if self < 1 && self != 0 && self > -1 {
            doubleString = String(format: "%f", self)
            if maximumFractionDigits == 3 {
                numberFormatter.maximumFractionDigits = 6
            }
            //for the small number 2.1e-14
            if numberFormatter.string(from: NSNumber(value: largeNumber)) == "0" {
                largeNumber = largeNumber > 0 ? 0.000001 : -0.000001
            } else {
                largeNumber = Double(doubleString) ?? self
            }
            
        }
        
        if let str = numberFormatter.string(from: NSNumber(value: largeNumber)) {
            doubleString = str
        }
        
        return doubleString
    }
    
    func getFormatedStringForTextField(char: String = "") -> String {
        
        
        var doubleString =  String(self)
        
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = Int(Int32.max)
        
        if let str = numberFormatter.string(from: NSNumber(value: self)) {
            doubleString = str
        }
        
        return doubleString + char
    }
    
    
    
    
    func dateFromMilliseconds() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(self) / 1000)
    }
    
    func getDateFromUnixTime(withoutTime: Bool = false) -> String {
        guard self > 0 else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = withoutTime ? "dd/MM/yy" : "dd/MM/yy HH:mm"
        formatter.locale = Locale(identifier: Localize.currentLanguage())
        return formatter.string(from: Date(timeIntervalSince1970: TimeInterval(self)))
    }
    
    func getDayInDate() -> Int {
        guard self > 0 else { return 0 }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        formatter.locale = Locale(identifier: Localize.currentLanguage())
        return Int(formatter.string(from: Date(timeIntervalSince1970: TimeInterval(self)))) ?? 0
    }
    
    func getMonthInDate() -> Int {
        guard self > 0 else { return 0 }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        formatter.locale = Locale(identifier: Localize.currentLanguage())
        return Int(formatter.string(from: Date(timeIntervalSince1970: TimeInterval(self)))) ?? 0
    }
    func getYearInDate() -> Int {
        guard self > 0 else { return 0 }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        formatter.locale = Locale(identifier: Localize.currentLanguage())
        return Int(formatter.string(from: Date(timeIntervalSince1970: TimeInterval(self)))) ?? 0
    }
    
    func textFromCredit() -> String {
        var count = -1
        var newNumber = self
        
        if newNumber > 0 {
            for _ in 0..<8 {
                if newNumber / 1000 > 1 {
                    newNumber = newNumber / 1000
                    count += 1
                } else {
                    break
                }
            }
        }
        
        let letters = [" K", " M", " G", " T", " P", " E", " Z", " Y"]
        
        let x = Int(newNumber * 1000)
        newNumber = Double(x) / 1000
        
        let numberStr = floor(newNumber) == newNumber ? String(Int(newNumber)) : String(newNumber)
        
        let letter = count != -1 ? letters[count] : ""
        
        return numberStr + letter
    }
    
    mutating func roundUpToDecimal(_ fractionDigits: Int) {
        let multiplier = pow(10, Double(fractionDigits))
        let fractionAdd = 1 / multiplier
        
        let newSelf = Darwin.round(self * multiplier) / multiplier
        self = newSelf >= self ? newSelf : newSelf + fractionAdd
    }
    
    func removeZerosFromEnd() -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 16 //maximum digits in Double after dot (maximum precision)
        return String(formatter.string(from: number) ?? "")
    }
    
    //MARK: - Temperature
    /// in phone settings
    static var phoneTemperatureUnit: String {
        let temp = 37.7.getPhonTemperature()
        return String(temp.suffix(2))
    }
    
    /// in app settings
    static var temperatureUnit: String {
        let temp = 37.7.getTemperature()
        return String(temp.suffix(2))
    }
    
    func getTemperature() -> String {
        let temperatureUnit = UserDefaults.shared.object(forKey: "temperatureUnit") as? String
        if let temperatureUnit = temperatureUnit {
            if temperatureUnit == "°C" {
                return "\(self)°C"
            } else {
                return "\((self * 1.8) + 32)°F"
            }
        } else {
            return getPhonTemperature()
        }
    }
    
    private func getPhonTemperature() -> String {
        if #available(iOS 10.0, *) {
            let formatter = MeasurementFormatter()
            let td = Measurement(value: self, unit: UnitTemperature.celsius)
            return formatter.string(from: td)
        } else {
            return "\(self)°C"
        }
    }
}

