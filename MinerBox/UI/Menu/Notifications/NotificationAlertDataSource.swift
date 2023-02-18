//
//  NotificationAlertDataSource.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/17/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import Foundation
import UIKit

class NotificationAlertDataSource {
    
    static var alertDataModel: [CustomAlertModel] {
        var dataModel: [CustomAlertModel] = []
        
        dataModel.append(CustomAlertModel(imageName: "worker_alert", actionTitle: "workers".localized(), filter: "worker_alert"))
        dataModel.append(CustomAlertModel(imageName: "hashrate_alert", actionTitle: "hashrate".localized(), filter: "hashrate_alert"))
        dataModel.append(CustomAlertModel(imageName: "repHash_alert", actionTitle: "reportedHashrate".localized(), filter: "repHash_alert"))
        dataModel.append(CustomAlertModel(imageName: "payout_alert", actionTitle: "account_payouts".localized(), filter: "payout_alert"))
        dataModel.append(CustomAlertModel(actionTitle: "all".localized(), filter: "all"))
        dataModel.append(CustomAlertModel(actionTitle: "cancel".localized(), isCanseledStyle: true, filter: "all"))
        return dataModel
    }
    
}
