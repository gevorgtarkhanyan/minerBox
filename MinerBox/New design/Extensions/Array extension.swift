//
//  Array extension.swift
//  MinerBox
//
//  Created by Vazgen Hovakinyan on 17.05.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation


extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

extension Array where Element: NSCopying {
    func copy() -> [Element] {
        return self.map { $0.copy() as! Element }
    }
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
