//
//  SingleCoinWidget.swift
//  SingleCoinWidget
//
//  Created by Vazgen Hovakimyan on 27.08.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents
import RealmSwift

struct SingleCoinProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SingleCoinWidgetEntry {
        var _darkMode = true
        
        if let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") {
            if let darkMode = userDefaults.value(forKey: "darkMode") as? Bool {
                _darkMode = darkMode
            }
        }
        
        return  SingleCoinWidgetEntry(date: Date(), icon: "", id: "", marketPriceUSD: "0", name: "", change1h: 0, change24h: 0, change7d: 0, darkMode: _darkMode, configuration: SingleCoinConfigurationIntent(),isLogin: true, widgetSize: context.displaySize)
    }
    
    func getSnapshot(
        for configuration: SingleCoinConfigurationIntent,
        in context: Context,
        completion: @escaping (SingleCoinWidgetEntry) -> ()) {
            
            self.getWidgetCoin(configuration: configuration, completion: { entry in
                completion(entry)
            }, widgetSize: context.displaySize, isExampleView: true)
        }
    
    func getTimeline(for configuration: SingleCoinConfigurationIntent,
                     in context: Context,
                     completion: @escaping (Timeline<SingleCoinWidgetEntry>) -> ()) {
        
        var entries: [SingleCoinWidgetEntry] = []
        
        self.getWidgetCoin(configuration: configuration, completion: { entry in
            entries.removeAll()
            entries.append(entry)
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }, widgetSize: context.displaySize, isExampleView: false)
    }
    
    func getWidgetCoin(
        configuration: SingleCoinConfigurationIntent,
        completion: @escaping (SingleCoinWidgetEntry) -> Void,
        widgetSize: CGSize,
        isExampleView:Bool) {
            DatabaseManager.shared.migrateRealm()
            
            let user = DatabaseManager.shared.currentUser
            
            var _darkMode = true
            
            if let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") {
                if let darkMode = userDefaults.value(forKey: "darkMode") as? Bool {
                    _darkMode = darkMode
                }
            }
            
            // Check ExampleView for Not Login Users
            if isExampleView && user == nil {
                var entry = SingleCoinWidgetEntry(date: Date(), icon: "bitcoin.png", id: "", marketPriceUSD: "60,526,958", name: "Bitcoin", change1h: 0.95, change24h: 7.8, change7d: 10.4,configuration: configuration, isLogin: true, widgetSize: widgetSize)
                
                entry.darkMode = _darkMode
                
                completion(entry)
                return
            }
            
            // Check User
            if user == nil {
                var entry = SingleCoinWidgetEntry(date: Date(), icon: "", id: "", marketPriceUSD: "0", name: "", change1h: 0, change24h: 0, change7d: 0,configuration: configuration, isLogin: false, widgetSize: widgetSize)
                
                entry.darkMode = _darkMode
                
                completion(entry)
                return
            }
            
            let coinId = configuration.Coin?.identifier ?? "bitcoin"
            
            // Check Favorite coins
            if !isContainFavoriteCoin(coinId: coinId)  && coinId != "bitcoin" {
                var entry = SingleCoinWidgetEntry.init(date: Date(), icon: "", id: "", marketPriceUSD: "", name: "", change1h: 0.0, change24h: 0.0, change7d: 0.0, configuration: configuration, isLogin: true, widgetSize: widgetSize, noSelectedCoin: true)
                entry.darkMode = _darkMode
                
                completion(entry)
                return
            }
            
            checkTimerForCoinWidgets(coinID: coinId) { selectedCoinId, isGetCoinTime in
                
                let kitCoinSFromDB = RealmWrapper.sharedInstance.getAllObjectsOfModel(KitCoinModel.self) as? [KitCoinModel]
                
                var (selectedCoinId,isGetCoinTime) = (selectedCoinId,isGetCoinTime)
                
                if  !isGetCoinTime {  isGetCoinTime = kitCoinSFromDB == nil
                    
                    if kitCoinSFromDB != nil {isGetCoinTime = kitCoinSFromDB!.isEmpty }
                }
                if isGetCoinTime {
                    
                    let endpoint = "v2/widget/\(user!.id)/info"
                    
                    let param = ["type": "1", "ids": selectedCoinId?.description ?? "bitcoin"] as [String : Any]
                    
                    NetworkManager.shared.request(method: .post, endpoint: endpoint,params: param) { json in
                        
                        var coin = KitCoinModel()
                        guard let status = json.value(forKey: "status") as? Int,
                              status == 0,
                              let data = json["data"] as? NSDictionary else {return}
                        
                        if let rates = data["rates"] as? NSDictionary {
                            UserDefaults.standard.setValue(rates, forKey: "\(user?.id ?? "" )/rates")
                        }
                        let rates = UserDefaults.standard.value(forKey: "\(DatabaseManager.shared.currentUser?.id ?? "" )/rates") as? [String:Double]
                        let currencyMultiplier: Double = rates?[Locale.appCurrency] ?? 1.0
                        
                        var cointObject = [KitCoinModel]()
                        RealmWrapper.sharedInstance.deleteObjectsFromRealmDB(KitCoinModel.self)
                        
                        if let _result = data.value(forKey: "results") as? [NSDictionary] {
                            _result.forEach { cointObject.append((KitCoinModel(json: $0)))}
                        }
                        _ =  cointObject.map { $0.currencyMultiplier = currencyMultiplier; RealmWrapper.sharedInstance.addObjectInRealmDB($0) }
                        
                        let coinId = configuration.Coin?.identifier ?? "bitcoin"
                        
                        coin =  cointObject.filter({$0.coinId == coinId }).first!
                        
                        let price = "\(Locale.appCurrencySymbol) " + (coin.marketPriceUSD * currencyMultiplier).getString()
                        
                        var entry = SingleCoinWidgetEntry(date: Date(), icon: coin.icon, id: coin.coinId, marketPriceUSD: price, name: coin.name, change1h: coin.change1h, change24h: coin.change24h, change7d: coin.change7d, configuration: configuration, isLogin: true, widgetSize: widgetSize)
                        entry.darkMode = _darkMode
                        
                        completion(entry)
                        
                    } failure: { err in
                        debugPrint(err)
                    }
                } else {
                    
                    let coinId = configuration.Coin?.identifier ?? "bitcoin"
                    
                    // Check Favorite coins
                    if !isContainFavoriteCoin(coinId: coinId)  && coinId != "bitcoin" {
                        var entry = SingleCoinWidgetEntry.init(date: Date(), icon: "", id: "", marketPriceUSD: "", name: "", change1h: 0.0, change24h: 0.0, change7d: 0.0, configuration: configuration, isLogin: true, widgetSize: widgetSize, noSelectedCoin: true)
                        entry.darkMode = _darkMode
                        
                        completion(entry)
                        return
                    }
                    
                    if  let coin =  kitCoinSFromDB!.filter({$0.coinId == coinId }).first {
                        let price = "\(Locale.appCurrencySymbol) " + (coin.marketPriceUSD * coin.currencyMultiplier).getString()
                        
                        var entry = SingleCoinWidgetEntry(date: Date(), icon: coin.icon, id: coin.coinId, marketPriceUSD: price, name: coin.name, change1h: coin.change1h, change24h: coin.change24h, change7d: coin.change7d, configuration: configuration, isLogin: true, widgetSize: widgetSize)
                        entry.darkMode = _darkMode
                        
                        completion(entry)
                    }
                }
            }
        }
    
    func checkTimerForCoinWidgets(coinID: String, successTuples: @escaping([String]?,Bool) -> Void) {
        
        var selectedCoinId = UserDefaults.sharedForWidget.value(forKey: "selected_coinId_for_kitWidget") as? [String]
        
        guard  selectedCoinId != nil  else {
            successTuples (nil,true)
            return
        }
        //Check Old Values
        guard selectedCoinId!.contains(coinID) else {
            selectedCoinId!.append(coinID)
            successTuples (selectedCoinId,true)
            return
        }
        //Check Time
        let isTimeToGetCoins = TimerManager.shared.isLoadingTime(item: .coinWidget)
        guard !isTimeToGetCoins else {
            successTuples (selectedCoinId,true)
            return
        }
        successTuples (selectedCoinId,false)
    }
    
    func isContainFavoriteCoin(coinId: String) -> Bool {
        if let favoriteCoinsFromDB = RealmWrapper.sharedInstance.getAllObjectsOfModel(FavoriteCoinModel.self) as? [FavoriteCoinModel], favoriteCoinsFromDB.contains(where: {$0.coinId == coinId}) {
            return true
        }
        return false
    }
}

struct SingleCoinWidget: Widget {
    let kind: String = "Single Coin"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SingleCoinConfigurationIntent.self, provider: SingleCoinProvider()) { entry in
            SingleCoinView(entry: entry)
        }
        .configurationDisplayName("single_Coin_Widget")
        .description("single_coin_description")
        .supportedFamilies([.systemSmall])
    }
}

