//
//  SecurityBiometryType.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/19/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import LocalAuthentication

class SecurityBiometryType: NSObject {

    // MARK: - Static
    static let shared = SecurityBiometryType()
}


// MARK: - Methods
extension SecurityBiometryType {
    func getBiometryType() -> DeviceBiometryTypes {
        if #available(iOS 11.0, *) {
            let context = LAContext()
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                if context.biometryType == .faceID {
//                UserDefaults.standard.set("faceID", forKey: "biomtricType")
                    return .faceID
                } else if context.biometryType == .touchID {
//                UserDefaults.standard.set("touchID", forKey: "biomtricType")
                    return .touchID
                }
            }
        }

        return .none
    }
}

// MARK: - Helpers
enum DeviceBiometryTypes: String {
    case faceID = "FaceID"
    case touchID = "TouchID"
    case none
}

