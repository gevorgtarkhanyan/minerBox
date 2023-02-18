//
//  ChatInfo.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 23.04.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation

struct Chat {
    let id: Int
    let imsgId: Int
    let hash: String
    
    init(with data: NSDictionary) {
        self.id = data.value(forKey: "id") as? Int ?? 0
        self.imsgId = data.value(forKey: "lmsg_id") as? Int ?? 0
        self.hash = data.value(forKey: "hash") as? String ?? ""
    }
    
    func toAny() -> NSDictionary {
        return [
            "id": id,
            "lmsg_id": imsgId,
            "hash": hash
        ]
    }
    
    var sessionStorageValue: String {
        var str = "\(toAny())"
        str = str.replacingOccurrences(of: "[", with: "{", options: .widthInsensitive, range: nil)
        str = str.replacingOccurrences(of: "]", with: "}", options: .widthInsensitive, range: nil)
        let value = """
            {"hash":"\(hash)","id":\(id),"lmsg_id":0}
        """
        return value
    }
}
