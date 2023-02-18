//
//  PieChartValueFormatter.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 2/17/20.
//  Copyright © 2020 WitPlex. All rights reserved.
//

import Foundation
import Charts

class PieChartValueFormatter: NSObject, IValueFormatter {
    
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
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return formatter.string(from: NSNumber(value: entry.y)) ?? ""
    }
    
}
