//
//  AccountAlertSectionDataModel.swift
//  MinerBox
//
//  Created by Gevorg Tarkhanyan on 29.03.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit

class AccountAlertCellAsSectionDataModel {
     var isExpanded = false
     var models: [PoolAlertModel] = []
     var url: String
     var alertType: String
     var CurrentValue: String
     var CountLabel: String


    init(isExpanded: Bool, models: [PoolAlertModel], url: String, alertType: String, CurrentValue: String, CountLabel: String) {
        self.url = url
        self.alertType = alertType
        self.CurrentValue = CurrentValue
        self.CountLabel = CountLabel
        self.models = models
    }
}

