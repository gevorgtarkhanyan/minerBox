//
//  Data extension.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 8/2/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

extension Data {
    func getSize() -> String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useAll]
        bcf.countStyle = .file
        return bcf.string(fromByteCount: Int64(self.count))
    }
}

extension Date {
    var millisecondsSince1970: Double {
        Double((self.timeIntervalSince1970).rounded())
    }
    
    init(milliseconds: Double) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds))
    }
}
