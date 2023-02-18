//
//  ModelAlgorithmDataModel.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 11/1/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class ModelAlgorithmDataModel {
    var name: String
    var speed: String?
    var power: String
    
    init(name: String, speed: Double? = nil, unit: String? = nil, power: Double) {
        self.name = name
        self.power = String(power)
        if speed != nil  && unit != nil {
            self.speed = String(speed!) + unit!
        }
    }
}
