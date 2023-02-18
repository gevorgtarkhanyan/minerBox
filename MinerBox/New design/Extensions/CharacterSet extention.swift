//
//  CharacterSet extention.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 17.09.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation

extension CharacterSet {

    static let urlQueryParameterAllowed = CharacterSet.urlQueryAllowed.subtracting(CharacterSet(charactersIn: "&?/~!$*(.,)+':"))

    static let urlQueryDenied           = CharacterSet.urlQueryAllowed.inverted()
    static let urlQueryKeyValueDenied   = CharacterSet.urlQueryParameterAllowed.inverted()
    static let urlPathDenied            = CharacterSet.urlPathAllowed.inverted()
    static let urlFragmentDenied        = CharacterSet.urlFragmentAllowed.inverted()
    static let urlHostDenied            = CharacterSet.urlHostAllowed.inverted()

    static let urlDenied                = CharacterSet.urlQueryDenied
        .union(.urlQueryKeyValueDenied)
        .union(.urlPathDenied)
        .union(.urlFragmentDenied)
        .union(.urlHostDenied)


    func inverted() -> CharacterSet {
        var copy = self
        copy.invert()
        return copy
    }
}
