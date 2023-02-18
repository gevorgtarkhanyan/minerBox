//
//  Bool extension.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/1/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

extension Bool {
    public func getString() -> String {
        return self ? "true" : "false"
    }
}
