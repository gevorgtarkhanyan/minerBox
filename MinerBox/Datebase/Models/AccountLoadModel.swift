//
//  AccountLoedModel.swift
//  MinerBox
//
//  Created by Vazgen Hovakinyan on 06.04.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//
import UIKit

class AccountLoadModel {
    
    @objc dynamic var isLoaded: Bool
    @objc dynamic var loadEnd: Bool
    
    init(isLoaded: Bool, loadEnd: Bool) {
        self.isLoaded = isLoaded
        self.loadEnd = loadEnd
    }

}
