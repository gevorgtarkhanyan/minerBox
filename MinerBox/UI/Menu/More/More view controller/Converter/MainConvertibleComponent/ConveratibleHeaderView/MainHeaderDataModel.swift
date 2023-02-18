//
//  MainHeaderDataModel.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/21/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class MainHeaderDataModel {
    var headerName: String = ""
    var headerSymbol: String = ""
    var headerImageName: String = ""
    
    init(headerName: String, headerSymbol: String, headerImageName: String) {
          self.headerName = headerName
          self.headerSymbol = headerSymbol
          self.headerImageName = headerImageName
    }
}
