//
//  NaviagationBar.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 11/1/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationBar {
    static func clearBackground() {
        self.appearance().setBackgroundImage(UIImage(), for: .default)
        self.appearance().setBackgroundImage(UIImage(), for: .compact)
    }
}
