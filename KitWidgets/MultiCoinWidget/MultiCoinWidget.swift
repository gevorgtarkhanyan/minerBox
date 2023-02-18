//
//  MultiCoinWidget.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 28.09.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents
import RealmSwift

struct MultiCoinProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> MultiCoinWidgetEntry {
        
        var _darkMode = true
        
        if let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") {
            if let darkMode = userDefaults.value(forKey: "darkMode") as? Bool {
                _darkMode = darkMode
            }
        }
        
        return  MultiCoinWidgetEntry(date: Date(), configuration: MultiCoinConfigurationIntent(),isLogin: true, darkMode: _darkMode, coins: [SingleCoinForMulti(icon: "bitcoin.png", id: "bitcoin", marketPriceUSD: "12.5489", change1h: 1.24545, change24h: 125.5454, change7d: 12.587878, numberCoin: 1),SingleCoinForMulti(icon: "bitcoin.png", id: "bitcoin", marketPriceUSD: "12.5489", change1h: 1.24545, change24h: 125.5454, change7d: 12.587878, numberCoin: 2),SingleCoinForMulti(icon: "bitcoin.png", id: "bitcoin", marketPriceUSD: "12.5489", change1h: 1.24545, change24h: 125.5454, change7d: 12.587878, numberCoin: 3),SingleCoinForMulti(icon: "bitcoin.png", id: "bitcoin", marketPriceUSD: "12.5489", change1h: 1.24545, change24h: 125.5454, change7d: 12.587878, numberCoin: 4),SingleCoinForMulti(icon: "bitcoin.png", id: "bitcoin", marketPriceUSD: "12.5489", change1h: 1.24545, change24h: 125.5454, change7d: 12.587878, numberCoin: 5)], widgetSize: context.displaySize)
    }
    
    func getSnapshot (
        for configuration: MultiCoinConfigurationIntent,
        in context: Context,
        completion: @escaping (MultiCoinWidgetEntry) -> ()) {
        
        self.getWidgetCoin(configuration: configuration, completion: { entry in
            completion(entry)
        }, widgetSize: context.displaySize, isExampleView: true)
    }
    
    func getTimeline(for configuration: MultiCoinConfigurationIntent,
                     in context: Context,
                     completion: @escaping (Timeline<MultiCoinWidgetEntry>) -> ()) {
        
        var entries: [MultiCoinWidgetEntry] = []
        
        self.getWidgetCoin(configuration: configuration, completion: { entry in
            entries.removeAll()
            entries.append(entry)
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }, widgetSize: context.displaySize, isExampleView: false)
    }
    
    func getWidgetCoin(
        configuration: MultiCoinConfigurationIntent,
        completion: @escaping (MultiCoinWidgetEntry) -> Void,
        widgetSize:CGSize,
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
            
            var entry = MultiCoinWidgetEntry(date: Date(), configuration: configuration, isLogin: true, coins: [SingleCoinForMulti(icon: "bitcoin.png", id: "bitcoin", marketPriceUSD: "50,548,595", name: "Bitcoin", change1h: 1.24545, change24h: 7.54, change7d: 12.58, numberCoin: 1),SingleCoinForMulti(icon: "ethereum.png", id: "ethereum", marketPriceUSD: "4,280,465", name: "Ethereum", change1h: 0.24545, change24h: 2.54, change7d: 4.578, numberCoin: 2),SingleCoinForMulti(icon: "ergo.png", id: "ergo", marketPriceUSD: "8.91", name: "Ergo", change1h: 1.24, change24h: 3.14, change7d: -3.58, numberCoin: 3),SingleCoinForMulti(icon: "monero.png", id: "monero", marketPriceUSD: "240.967", name: "Ethereum", change1h: 0.35, change24h: -11.54, change7d: -12.58, numberCoin: 4),SingleCoinForMulti(icon: "ravencoin.png", id: "ravencoin", marketPriceUSD: "0,1155", name: "Ravencoin", change1h: 0.45, change24h: 11.54, change7d: -15.74, numberCoin: 5)], widgetSize: widgetSize)
            
            entry.darkMode = _darkMode
            
            completion(entry)
            
            return
        }
        
        // Check User
        if user == nil {
            var entry = MultiCoinWidgetEntry(date: Date(), configuration: configuration, isLogin: false, widgetSize: widgetSize)
            
            entry.darkMode = _darkMode
            
            completion(entry)
            return
        }
            let coinIds = getSelectedCoinIds(configuration: configuration) ?? ["bitcoin","ethereum","ergo","monero","ravencoin"]
            // Check Favorite coins
            if isNotExistInFavoriteCoins(coinIds: coinIds) && getSelectedCoinIds(configuration: configuration) != nil {
                var entry = MultiCoinWidgetEntry(date: Date(),configuration: configuration, isLogin: true, coins: [], widgetSize: widgetSize, noSelectedCoins: true)
                entry.darkMode = _darkMode
                
                completion(entry)
                return
            }

        checkTimerForCoinWidgets(coinIds: coinIds) { selectedCoinId, isGetCoinTime in
            let kitCoinSFromDB = RealmWrapper.sharedInstance.getAllObjectsOfModel(KitCoinModel.self) as? [KitCoinModel]
            
            var (selectedCoinId,isGetCoinTime) = (selectedCoinId,isGetCoinTime)
            if  !isGetCoinTime {  isGetCoinTime = kitCoinSFromDB == nil
                
                if kitCoinSFromDB != nil {isGetCoinTime = kitCoinSFromDB!.isEmpty }
            }
            
            let endpoint =  "v2/widget/\(user!.id)/info"
            let param = ["type": "1", "ids": selectedCoinId?.description ??  ["bitcoin","ethereum","ergo","monero","ravencoin"].description] as [String : Any]
            let selectedCoin = getSelectedCoinIds(configuration: configuration) ??  ["bitcoin","ethereum","ergo","monero","ravencoin"]
            var coins = [SingleCoinForMulti]()
            
            if isGetCoinTime {
                NetworkManager.shared.request(method: .post, endpoint: endpoint,params: param) { json in
                    
                    guard let status = json.value(forKey: "status") as? Int,
                          status == 0,
                          let data = json["data"] as? NSDictionary else {return}
                    
                    if let rates = data["rates"] as? NSDictionary {
                        UserDefaults.standard.setValue(rates, forKey: "\(user?.id ?? "" )/rates")
                    }
                    var cointObject = [KitCoinModel]()  // KitCoinModel(json: data)
                    RealmWrapper.sharedInstance.deleteObjectsFromRealmDB(KitCoinModel.self)
                    
                    
                    if let _result = data.value(forKey: "results") as? [NSDictionary] {
                        _result.forEach { cointObject.append((KitCoinModel(json: $0)))}
                    }
                    let rates = UserDefaults.standard.value(forKey: "\(DatabaseManager.shared.currentUser?.id ?? "" )/rates") as? [String:Double]
                    
                    let currencyMultiplier: Double = rates?[Locale.appCurrency] ?? 1.0
                    
                    _ =  cointObject.map { $0.currencyMultiplier = currencyMultiplier; RealmWrapper.sharedInstance.addObjectInRealmDB($0) }
                    
                    let coinForEntry = sortingCoins(coinsForSorting: cointObject.filter { selectedCoin.contains($0.coinId) }, selectedCoins: getSelectedCoinIds(configuration: configuration) ?? ["bitcoin","ethereum","ergo","monero","ravencoin",])
                        
                    for (index,_coin) in coinForEntry.enumerated() {
                        let price = "\(Locale.appCurrencySymbol) " + (_coin.marketPriceUSD * currencyMultiplier).getString()
                        coins.append(SingleCoinForMulti(icon: _coin.icon, id: _coin.coinId, marketPriceUSD: price, name: _coin.name, symbol: _coin.symbol, change1h: _coin.change1h, change24h: _coin.change24h, change7d: _coin.change7d, numberCoin: index + 1))
                    }
                    
                    var entry = MultiCoinWidgetEntry(date: Date(),configuration: configuration, isLogin: true, coins: coins, widgetSize: widgetSize)
                    entry.darkMode = _darkMode
                    
                    completion(entry)
                    
                } failure: { err in
                    debugPrint(err)
                }
            } else {
                
                let coinIds = getSelectedCoinIds(configuration: configuration) ?? ["bitcoin","ethereum","ergo","monero","ravencoin"]
                // Check Favorite coins
                if isNotExistInFavoriteCoins(coinIds: coinIds) && getSelectedCoinIds(configuration: configuration) != nil {
                    var entry = MultiCoinWidgetEntry(date: Date(),configuration: configuration, isLogin: true, coins: [], widgetSize: widgetSize, noSelectedCoins: true)
                    entry.darkMode = _darkMode
                    
                    completion(entry)
                    return
                }
                
                let coinForEntry =  sortingCoins(coinsForSorting: kitCoinSFromDB!.filter { selectedCoin.contains($0.coinId) }, selectedCoins: coinIds)
                
                
                for (index,_coin) in coinForEntry.enumerated() {
                    let price = "\(Locale.appCurrencySymbol) " + (_coin.marketPriceUSD * _coin.currencyMultiplier).getString()
                    coins.append(SingleCoinForMulti(icon: _coin.icon, id: _coin.coinId, marketPriceUSD: price, name: _coin.name, symbol: _coin.symbol, change1h: _coin.change1h, change24h: _coin.change24h, change7d: _coin.change7d, numberCoin: index + 1))
                }
                
                var entry = MultiCoinWidgetEntry(date: Date(),configuration: configuration, isLogin: true, coins: coins, widgetSize: widgetSize)
                entry.darkMode = _darkMode
                
                completion(entry)
            }
        }
    }
    
    func sortingCoins( coinsForSorting: [KitCoinModel], selectedCoins: [String]) -> [KitCoinModel] {
        
        var _selectedCoinsEntry = [KitCoinModel]()

        for coinId in selectedCoins {
            for coin in coinsForSorting {
                if coin.coinId ==  coinId {
                    _selectedCoinsEntry.append(coin)
                }
            }
        }
        return _selectedCoinsEntry
    }
    
    func checkTimerForCoinWidgets(coinIds: [String], successTuples: @escaping([String]?,Bool) -> Void) {
        
        var selectedCoinId = UserDefaults.sharedForWidget.value(forKey: "selected_coinId_for_kitWidget") as? [String]
        var isNewCoinId = false
        
        guard  selectedCoinId != nil  else {
            successTuples (nil,true)
            return
        }
        //Check Old Values
        for coinID in coinIds {
            if !selectedCoinId!.contains(coinID)  {
                isNewCoinId = true
                selectedCoinId!.append(coinID)
            }
        }
        guard !isNewCoinId else {
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
    
    func getSelectedCoinIds(configuration: MultiCoinConfigurationIntent) -> [String]? {
        
        var coinIds: [String] = []
        guard configuration.coins != nil else {
            return nil
        }
        for coin  in configuration.coins! {
            coinIds.append(coin.identifier!)
        }
        
        return coinIds
    }
    
    func isNotExistInFavoriteCoins(coinIds: [String]) -> Bool {
        guard let favoriteCoinsFromDB = RealmWrapper.sharedInstance.getAllObjectsOfModel(FavoriteCoinModel.self) as? [FavoriteCoinModel] else { return true}
        for coinId in coinIds {
            if !favoriteCoinsFromDB.contains(where: {$0.coinId == coinId}) {
                return true
            }
        }
        return false
    }
}

struct MultiCoinWidget: Widget {
    let kind: String = "Multi Coin"
    
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind,
                            intent: MultiCoinConfigurationIntent.self,
                            provider: MultiCoinProvider()) { entry in
            MultiCoinView(entry: entry)
        }
        .configurationDisplayName("multi_Coin_Widget")
        .description("multi_coin_description")
        .supportedFamilies([.systemLarge])
        
    }
}


