//
//  MiningCalculationModel.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 11/12/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class MiningCalculationModel: NSObject, Codable {
    
    var userId: String
    var isByModel: Bool
    var models: [SelectedModel]?
    var algos: [SelectedAlgos]?
    var cost: Double
    var difficulty: String
    
    init(userId: String, isByModel: Bool, algos: [SelectedAlgos]?, models: [SelectedModel]?, cost: Double, difficulty: String) {
        self.userId = userId
        self.isByModel = isByModel
        self.algos = algos
        self.models = models
        self.cost = cost
        self.difficulty = difficulty
    }
    
    var asDictionary: [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary["userId"] = self.userId
        dictionary["isByModel"] = self.isByModel
        dictionary["cost"] = self.cost
        dictionary["difficulty"] = self.difficulty
        dictionary["models"] = self.models?.map { $0.asDictionary }
        dictionary["algos"] = self.algos?.map { $0.asDictionary }
        
        return dictionary
    }
    
    //MARK: -- Saving models
    static var getAllModels: [SelectedModel]? {
         if let objects = UserDefaults.standard.value(forKey: "models") as? Data {
            let decoder = JSONDecoder()
            if let objectsDecoded = try? decoder.decode(Array.self, from: objects) as [SelectedModel] {
               return objectsDecoded
            } else {
               return nil
            }
         } else {
            return nil
         }
      }
    
    static func saveModels(_ models: [SelectedModel]) {
         let encoder = JSONEncoder()
         if let encoded = try? encoder.encode(models){
            UserDefaults.standard.set(encoded, forKey: "models")
         }
    }
    
    static func deleteAllModels() {
        UserDefaults.standard.removeObject(forKey: "models")
    }
    
    
    //MARK: -- Saving algos GPU
    static var getAllAlgosGPU: [SelectedAlgos]? {
       if let objects = UserDefaults.standard.value(forKey: "algosGPU") as? Data {
          let decoder = JSONDecoder()
          if let objectsDecoded = try? decoder.decode(Array.self, from: objects) as [SelectedAlgos] {
             return objectsDecoded
          } else {
             return nil
          }
       } else {
          return nil
       }
    }
    
    static func saveAlgosGPU(_ algos: [SelectedAlgos]) {
         let encoder = JSONEncoder()
         if let encoded = try? encoder.encode(algos){
            UserDefaults.standard.set(encoded, forKey: "algosGPU")
         }
    }
    
    static func deleteAlgosGPU() {
        UserDefaults.standard.removeObject(forKey: "algosGPU")
    }
    
    //MARK: -- Saving algos ASIC
    static var getAllAlgosASIC: [SelectedAlgos]? {
       if let objects = UserDefaults.standard.value(forKey: "algosASIC") as? Data {
          let decoder = JSONDecoder()
          if let objectsDecoded = try? decoder.decode(Array.self, from: objects) as [SelectedAlgos] {
             return objectsDecoded
          } else {
             return nil
          }
       } else {
          return nil
       }
    }
    
    static func saveAlgosASIC(_ algos: [SelectedAlgos]) {
         let encoder = JSONEncoder()
         if let encoded = try? encoder.encode(algos){
            UserDefaults.standard.set(encoded, forKey: "algosASIC")
         }
    }
    
    static func deleteAlgosASIC() {
        UserDefaults.standard.removeObject(forKey: "algosASIC")
    }
    
    //MARK: -- Save difficulty and electricityCost
    
    static func saveDifficultyAndElectricityCost(cost: Double, difficulty: String) {
        UserDefaults.standard.setValue(difficulty, forKey: "electricityCost")
        UserDefaults.standard.setValue(difficulty, forKey: "difficulty")
    }
    
    static func getSavedCostAndDifficultyValues() -> (Double?, String?) {
        let cost = UserDefaults.standard.value(forKey: "electricityCost") as? String ?? "0"
        let difficulty = UserDefaults.standard.value(forKey: "difficulty") as? String ?? "24h"
        
        if let num = Double(cost) {
            return (num, difficulty)
        } else {
            return (nil, difficulty)
        }
    }
    
}

class SelectedModel: NSObject, Codable {
    var modelId: Double
    var count: Double
    var modelName: String = ""
    
    init(modelId: Double, count: Double) {
        self.modelId = modelId
        self.count = count
    }
    
    var asDictionary: [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary["modelId"] = self.modelId
        dictionary["count"] = self.count
        
        return dictionary
    }
}

class SelectedAlgos: NSObject, Codable {
    var algoId: Double
    var hs: Double
    var w: Double
    var algosName: String = ""
    
    init(algoId: Double, hs: Double, w: Double) {
        self.algoId = algoId
        self.hs = hs
        self.w = w
    }
    
    var asDictionary: [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary["algoId"] = self.algoId
        dictionary["hs"] = self.hs
        dictionary["w"] = self.w
        
        return dictionary
    }
}
