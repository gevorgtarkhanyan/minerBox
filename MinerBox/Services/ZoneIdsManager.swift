//
//  ZoneIdsManager.swift
//  MinerBox
//
//  Created by Vazgen Hovakinyan on 25.05.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation
import UIKit

enum ZoneName: String, CaseIterable {
    case account = "PoolAccounts_1"
    case coinsPrcie = "CoinPrice_All_1"
    case whatToMine = "WhatToMine_1"
    case converter = "Converter_1"
    case newsMyFeed = "News_MyFeed_1"
    case newsTop = "News_Top_1"
    case newsAll = "News_All_1"
    case newsTweets = "News_Twitter_1"
    case newArticle = "News_Article_1"
    case wallet = "Wallets_1"

}

class ZoneIdsManager: NSObject {
    
    // MARK: - Static
    static let shared = ZoneIdsManager()
    
    fileprivate var userID: String? {
        return DatabaseManager.shared.currentUser?.id
    }
    
    //MARK: - FileManager Methods -
    
    public func addZoneToFile(_ zone: ActiveZoneModel) {
        guard let data = zone.getJsonData(),
              let directory = getAdsZoneDocumentDirectory() else { return }
        
        do {
            try data.write(to: directory.appendingPathComponent("\(zone.zoneName).json"))
        } catch {
            debugPrint("Can't write zoneId model json data to file: \(error.localizedDescription)")
        }
    }
        public func getAdsZoneDocumentDirectory() -> URL? {
            
            let fileManager = FileManager.default
            do {
                let docURL = Constants.fileManagerURL
                let adsZoneUrl = docURL.appendingPathComponent("AdsZones")
                if !fileManager.fileExists(atPath: adsZoneUrl.path) {
                    try fileManager.createDirectory(atPath: adsZoneUrl.path, withIntermediateDirectories: true, attributes: nil)
                }
                return adsZoneUrl
            } catch {
                debugPrint("Can't get docURL: \(error.localizedDescription)")
                return nil
            }
        }
    
    public func removeAdsZoneByFolder() {
        
        guard let urlAdsZone = self.getAdsZoneDocumentDirectory() else { return }
            
            do {
                try FileManager.default.removeItem(atPath: urlAdsZone.path)
            } catch {
                debugPrint("Can't delete saved adsZones: \(error.localizedDescription)")
            }
    }
    public func getAdsZoneFromDirectory() -> [ActiveZoneModel] {
        
        guard let urlAdsZone = self.getAdsZoneDocumentDirectory() else { return [] }
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: urlAdsZone, includingPropertiesForKeys: nil)
            var adsZones: [ActiveZoneModel] = []
            
            for url in urls {
                let jsonData = try Data(contentsOf: url)
                let adsZone = try JSONDecoder().decode(ActiveZoneModel.self, from: jsonData)
                adsZones.append(adsZone)
            }
            return adsZones
        } catch {
            debugPrint("Can't get adsZones from json: \(error.localizedDescription)")
        }
        
        return []
    }
            
}
