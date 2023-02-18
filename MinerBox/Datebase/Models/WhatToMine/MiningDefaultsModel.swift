//
//  MiningDefaultsModel.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 11/7/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class MiningDefaultsModel: NSObject, Codable {
    var miningCalculation: MiningDefaultsCalculatedByModel?
    var miningCoins: [MiningCoinsModel] = []
    var updatedDate: Date?
    
    func addCoins(_ coin: MiningCoinsModel) {
        miningCoins.append(coin)
    }
    
    convenience init(json: NSDictionary) {
        self.init()
        
        if let calculation = json.value(forKey: "calculatedBy") as? NSDictionary {
            self.miningCalculation = MiningDefaultsCalculatedByModel(json: calculation)
        }
        
        if let coins = json.value(forKey: "coins") as? [NSDictionary] {
            coins.forEach { self.addCoins(MiningCoinsModel(json: $0)) }
        }
        
        self.updatedDate = json.value(forKey: "updatedDate") as? Date ?? Date()
    }
    
}

class MiningDefaultsCalculatedByModel: NSObject, Codable {
    var difficulty: String?
    var isByModel: Bool?
    var models: [CalculatedModels] = []
    var algos: [CalculatedAlgos] = []
    var cost: Double?
    
    func addAlgos(_ currentAlgos: CalculatedAlgos) {
        algos.append(currentAlgos)
    }
    
    func addModels(_ currentModels: CalculatedModels) {
        models.append(currentModels)
    }
    
    convenience init(json: NSDictionary) {
        self.init()
        self.difficulty = json.value(forKey: "difficulty") as? String
        self.isByModel = json.value(forKey: "isByModel") as? Bool
        self.cost = json.value(forKey: "cost") as? Double 
        if let modelsData = json.value(forKey: "models") as? [NSDictionary] {
            modelsData.forEach { self.addModels(CalculatedModels(json: $0)) }
        }
        if let algosData = json.value(forKey: "algos") as? [NSDictionary] {
            algosData.forEach { self.addAlgos(CalculatedAlgos(json: $0)) }
        }
    }
}

class CalculatedModels: NSObject, Codable {
    var modelId: Double
    var count: Double
    var name: String
    
    init(json: NSDictionary?) {
        let json = json ?? NSDictionary()
        
        self.modelId = json.value(forKey: "modelId") as? Double ?? 0
        self.count = json.value(forKey: "count") as? Double ?? 0
        self.name = json.value(forKey: "name") as? String ?? ""
        super.init()
    }
}

class CalculatedAlgos: NSObject, Codable {
    var algoId: Double
    var hs: Double
    var w: Double
    var name: String
    var unit: String
    
    init(json: NSDictionary?) {
        let json = json ?? NSDictionary()
        
        self.algoId = json.value(forKey: "algoId") as? Double ?? 0
        self.hs = json.value(forKey: "hs") as? Double ?? 0
        self.w = json.value(forKey: "w") as? Double ?? 0
        self.name = json.value(forKey: "name") as? String ?? ""
        self.unit = json.value(forKey: "unit") as? String ?? ""
        super.init()
    }
}

class MiningCoinsModel: NSObject, Codable {
    var profit: Double = 0
    var revenue: Double = 0
    var symbol: String = ""
    var coinName: String = ""
    var coinIcon: String = ""
    var coinId: String = ""
    var algorithm: String = ""
    var details: [String: String] = [:]
    
    convenience init(json: NSDictionary?) {
        self.init()
        let json = json ?? NSDictionary()
        self.profit = json.value(forKey: "profit") as? Double ?? 0
        self.revenue = json.value(forKey: "revenue") as? Double ?? 0
        self.symbol = json.value(forKey: "symbol") as? String ?? ""
        self.coinName = json.value(forKey: "coinName") as? String ?? ""
        self.coinIcon = json.value(forKey: "coinIcon") as? String ?? ""
        self.coinId = json.value(forKey: "coinId") as? String ?? ""
        self.algorithm = json.value(forKey: "algorithm") as? String ?? ""
        self.details = json.value(forKey: "details") as? [String: String] ?? [:]
    }
}
