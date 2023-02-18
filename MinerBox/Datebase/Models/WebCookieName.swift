//
//  WebCookieName.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 11/21/18.
//  Copyright © 2018 WitPlex. All rights reserved.
//

import UIKit
import RealmSwift

class WebCookieName: Object {
    @objc dynamic var profileName: String = ""
    
    convenience init(profileName: String) {
        self.init()
        self.profileName = profileName
    }
}
