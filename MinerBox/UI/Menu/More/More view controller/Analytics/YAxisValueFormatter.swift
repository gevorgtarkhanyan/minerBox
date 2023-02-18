//
//  YAxisValueFormatter.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 2/17/20.
//  Copyright © 2020 WitPlex. All rights reserved.
//

import Foundation
import Charts

class YAxisValueFormatter: NSObject, IAxisValueFormatter {
    
    var formatter = NumberFormatter()
    
    override init() {
        super.init()
        setupFormatting()
    }
    
    private func setupFormatting() {
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        formatter.positiveSuffix = " %"
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return formatter.string(from: NSNumber(floatLiteral: value)) ?? ""
    }
    
}
