//
//  PoolGraphModel.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 1/14/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import RealmSwift

class PoolGraphModel: Object {
    @objc dynamic var name = "worker_name"
    var graphData = List<GraphData>()

    var data: [GraphData] {
        if graphData.count == 0 {
            return [GraphData]()
        }
        return graphData.sorted {
            return $0.time < $1.time
        }
    }

    func addData(_ value: GraphData) {
        self.graphData.append(value)
    }

    convenience init(json: NSDictionary) {
        self.init()
        if let name = json.value(forKey: "name") as? String {
            self.name = name == "" || name == "All" ? "coin_price_all" : name
        }

        guard let graphData = json["data"] as? [NSDictionary] else { return }
        for newData in graphData {
            self.addData(GraphData(json: newData))
        }
    }
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

class GraphData: Object {
    @objc dynamic var time = 0

    @objc dynamic var curHs = 0.0
    @objc dynamic var repHs = 0.0
    @objc dynamic var realHs = 0.0
    @objc dynamic var averageHs = 0.0

    @objc dynamic var validSh = 0.0
    @objc dynamic var invalidSh = 0.0
    @objc dynamic var staleSh = 0.0
    @objc dynamic var expiredSh = 0.0

    convenience init(json: NSDictionary) {
        self.init()
        self.time = json.value(forKey: "time") as? Int ?? 0
        ///must be remove old default keys
        self.curHs = json.value(forKey: "cHs") as? Double ?? json.value(forKey: "curHs") as? Double ?? -1.0
        self.repHs = json.value(forKey: "rpHs") as? Double ?? json.value(forKey: "repHs") as? Double ?? -1.0
        self.realHs = json.value(forKey: "rlHs") as? Double ?? json.value(forKey: "realHs") as? Double ?? -1.0
        self.averageHs = json.value(forKey: "aHs") as? Double ?? json.value(forKey: "averageHs") as? Double ?? -1.0
        self.validSh = json.value(forKey: "vSh") as? Double ?? json.value(forKey: "validSh") as? Double ?? -1.0
        self.invalidSh = json.value(forKey: "iSh") as? Double ?? json.value(forKey: "invalidSh") as? Double ?? -1.0
        self.staleSh = json.value(forKey: "sSh") as? Double ?? json.value(forKey: "staleSh") as? Double ?? -1.0
        self.expiredSh = json.value(forKey: "eSh") as? Double ?? json.value(forKey: "expiredSh") as? Double ?? -1.0
    }

    convenience init(time: Int?, curHs: Double? = nil, repHs: Double? = nil, realHs: Double? = nil, validSh: Double? = nil, invalidSh: Double? = nil, staleSh: Double? = nil, expiredSh: Double? = nil) {
        self.init()
        self.time = time ?? 0
        self.curHs = curHs ?? -1.0
        self.repHs = repHs ?? -1.0
        self.realHs = realHs ?? -1.0
        self.validSh = validSh ?? -1.0
        self.invalidSh = invalidSh ?? -1.0
        self.staleSh = staleSh ?? -1.0
        self.expiredSh = expiredSh ?? -1.0
    }
}
