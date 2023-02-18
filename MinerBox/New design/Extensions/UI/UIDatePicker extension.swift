//
//  UIDatePicker extension.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 09.02.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit
import FirebaseCrashlytics

extension UIDatePicker {
    func setDateSafely(_ date: Date, animated: Bool) {
        if let minDate = minimumDate, let maxDate = maximumDate {
            if date < minDate {
                minimumDate = date
            } else if date > maxDate {
                setMaximumDateSafely(date: date)
            }
        } else if let minDate = minimumDate {
            if date < minDate {
                minimumDate = date
            }
        } else if let maxDate = maximumDate {
            if date > maxDate {
                setMaximumDateSafely(date: date)
            }
        }
        setDate(date, animated: true)
    }
    
    public func setMaximumDateSafely(date: Date?) {
        if let maxDate = date, maxDate < self.date {
            setDate(maxDate, animated: false)
        }
        maximumDate = date
    }
    
}
