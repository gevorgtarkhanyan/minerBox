//
//  NewsModel.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 30.11.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

class NewsModel: NSObject {
    
    var _id: String = ""
    var newsId: String = ""
    var source: String = ""
    var title: String = ""
    var content: String = ""
    var creator: String = ""
    var link: String = ""
    var price: Double = 0
    var watched: Double = 0
    var liked: Double = 0
    var disliked: Double = 0
    var image: String = ""
    var date: Double = 0
    var categories: [String] = []
    var isBookmarked = false
    var userAction: Double = 0

    
    init(json: NSDictionary?) {
        let json = json ?? NSDictionary()
        
        self._id = json.value(forKey: "_id") as? String ?? ""
        self.newsId = json.value(forKey: "newsId") as? String ?? ""
        self.source = json.value(forKey: "source") as? String ?? ""
        self.title = json.value(forKey: "title") as? String ?? ""
        self.content = json.value(forKey: "content") as? String ?? ""
        self.creator = json.value(forKey: "creator") as? String ?? ""
        self.link = json.value(forKey: "link") as? String ?? ""
        self.watched = json.value(forKey: "watched") as? Double ?? 0
        self.liked = json.value(forKey: "liked") as? Double ?? 0
        self.disliked = json.value(forKey: "disliked") as? Double ?? 0
        if let imagepath = json.value(forKey: "image") as? String  {
            self.image =  Constants.HttpNewsUrl + ("images/")  + imagepath
        }
        self.date = json.value(forKey: "pubDate") as? Double ?? 0
        self.categories = json.value(forKey: "categories") as? [String] ?? []
        self.isBookmarked = json.value(forKey: "isBookmarked") as? Bool ?? false
        self.userAction = json.value(forKey: "userAction") as? Double ?? 0

    }
}



