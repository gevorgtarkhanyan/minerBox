//
//  CustomAlertModel.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/17/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import Foundation
import UIKit

class CustomAlertModel {
    var imageName: String?
    var actionTitle: String = ""
    var isCanseledStyle: Bool = false
    var filter: String?
    
    
    init(imageName: String? = nil, actionTitle: String, isCanseledStyle: Bool = false, filter: String? = nil) {
        self.imageName = imageName
        self.actionTitle = actionTitle
        self.isCanseledStyle = isCanseledStyle
        self.filter = filter
    }
    
}
