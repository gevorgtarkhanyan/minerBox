//
//  SettingsAlertDataSource.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 11/6/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import Foundation

class SettingsAlertDataSource {
    static func createDifficultyAlertModel(data: MiningSettingsModels) -> [CustomAlertModel] {
        var dataModel: [CustomAlertModel] = []
        let difficulties = data.difficulties
        
        for i in difficulties {
            let title = i.value.lowercased().localized()
            dataModel.append(CustomAlertModel(imageName: "", actionTitle: title))
        }
        
        return dataModel
    }
    
    static var algorithmAlertModel: [CustomAlertModel] {
        var dataModel: [CustomAlertModel] = []
        dataModel.append(CustomAlertModel(imageName: "", actionTitle: "algorithms".localized()))
        dataModel.append(CustomAlertModel(imageName: "", actionTitle: "models".localized()))
        return dataModel
    }
}
