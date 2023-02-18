//
//  ModelAlgorithmDataSource.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 11/1/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class ModelAlgorithmDataSource {
    
    static let shared = ModelAlgorithmDataSource()
    
    func modelAlgorithmDefaultDataForUser(_ defaultsData: MiningDefaultsModel) ->  [ModelAlgorithmDataModel] {
        var dataModel: [ModelAlgorithmDataModel] = []
            if let bool = defaultsData.miningCalculation?.isByModel {
                if bool {
                    if let sendedDataModel = defaultsData.miningCalculation?.models {
                        for model in sendedDataModel {
                            let currentCoin = ModelAlgorithmDataModel(name: model.name, power: model.count)
                            dataModel.append(currentCoin)
                        }
                        return dataModel
                    }
                } else {
                    if let sendedDataModel = defaultsData.miningCalculation?.algos {
                        for algos in sendedDataModel {
                            let currentCoin = ModelAlgorithmDataModel(name: algos.name, speed: algos.hs, unit: algos.unit , power: algos.w)
                            dataModel.append(currentCoin)
                        }
                        return dataModel
                    }
                }
            }
        return dataModel
    }
}
