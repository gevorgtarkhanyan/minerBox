//
//  CommunityModel.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 26.07.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation
import RealmSwift

class CommunityModel: Object {
    @objc dynamic var _id: String = UUID().uuidString
    @objc dynamic var telegramURL: String = ""
    @objc dynamic var facebookURL: String = ""
    @objc dynamic var twitterURL: String = ""
    @objc dynamic var redditURL: String = ""
    @objc dynamic var facebookID: String = ""
    @objc dynamic var feedbackEmail: String = ""
    @objc dynamic var minerboxUrl: String = ""
    @objc dynamic var helpUrl: String = ""
    
    override class func primaryKey() -> String? {
        return "_id"
    }
    
    override init() {
        super.init()
    }
    
    init(dict: NSDictionary) {
        self.telegramURL = dict.value(forKey: "telegramUrl") as? String ?? ""
        self.facebookURL = dict.value(forKey: "facebookUrl") as? String ?? ""
        self.facebookID = dict.value(forKey: "facebookId") as? String ?? ""
        self.twitterURL = dict.value(forKey: "twitterUrl") as? String ?? ""
        self.redditURL = dict.value(forKey: "redditUrl") as? String ?? ""
        self.feedbackEmail = dict.value(forKey: "feedbackEmail") as? String ?? ""
        self.minerboxUrl = dict.value(forKey: "minerboxUrl") as? String ?? ""
        self.helpUrl = dict.value(forKey: "helpUrl") as? String ?? ""
    }
    
    //    override init() {
    //        self.telegramURL = "https://t.me/joinchat/HMRTnxA3Wcj0GrtaKwYzZQ"
    //        self.facebookURL = "http://facebook.com/MinerBoxApp"
    //        self.facebookID = "291224344999953"
    //        self.twitterURL = "https://twitter.com/box_miner"
    //        self.redditURL = "https://www.reddit.com/u/minerbox_app"
    //        self.feedbackEmail = "minerbox@witplex.com"
    //    }
}
