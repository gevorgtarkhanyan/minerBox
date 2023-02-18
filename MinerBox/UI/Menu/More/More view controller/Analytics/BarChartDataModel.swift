//
//  BarChartDataModel.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 2/14/20.
//  Copyright © 2020 WitPlex. All rights reserved.
//

import Foundation

class BarChartDataModel {
    var name: String
    var data: [String: Double]?
    
    init(name: String, date: [String: Double]? = nil) {
        self.name = name
        self.data = date
    }
}
