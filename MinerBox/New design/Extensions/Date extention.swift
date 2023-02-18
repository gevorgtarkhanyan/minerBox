//
//  Date extention.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 08.12.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation

extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    
    var hourAfter: Date {
        return Calendar.current.date(byAdding: .minute, value: 1, to: self)!
    }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var year: Int {
        return Calendar.current.component(.year,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    //New Year
    var christmasIconStartDay: Date? {
        var component = DateComponents()
        component.year = month == 1 ?  year - 1 : year
        component.month = 12
        component.day  = 15

        return Calendar.current.date(from: component)
    }

    var christmasIconEndDay: Date? {
        var component = DateComponents()
        component.year = month == 1 ? year : year + 1
        component.month = 1
        component.day  = 15
        return Calendar.current.date(from: component)
    }
    
    var isChristmasDay: Bool {
        guard let startDate = christmasIconStartDay, let endDate = christmasIconEndDay else { return false }
        return self >= startDate && self <= endDate
    }
    
    var startOfMonth: Date {

        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)

        return  calendar.date(from: components)!
    }
    var endOfMonth: Date {
         var components = DateComponents()
         components.month = 1
         components.second = -1
         return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
     }
}
