//
//  Bundle extension.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/18/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

extension Bundle {
    var releaseVersionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    var buildVersionNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
}
