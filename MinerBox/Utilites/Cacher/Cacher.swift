//
//  Cacher.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 18.08.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation

class Cacher {
    
    static let shared = Cacher()
    
    public var account: PoolAccountModel?
    
    public var accountSettings: PoolSettingsModel?
    
    public var walletTransactionState: LoadingState = .loading
    
    public var walletUpateState: LoadingState = .show

}

