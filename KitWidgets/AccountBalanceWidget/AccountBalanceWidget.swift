//
//  AccountBalanceWidget.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 22.10.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents
import RealmSwift
import Localize_Swift


struct AccountBalanceProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SingleAccountEntry {
        
        var _darkMode = true
        
        if let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") {
            if let darkMode = userDefaults.value(forKey: "darkMode") as? Bool {
                _darkMode = darkMode
            }
        }
        
        return  SingleAccountEntry(date: Date(), poolIcon: "/images/pools/2Miners.png", poolId: "1", poolAccountName: "Ethereum2M", poolTypeAndSubType: "2miner  ETH", workersCount: 14, currentHashrate: "2/23 GH/s", darkMode: _darkMode, balance: Balance(value: "1.42 ETH", type: "Unpaid"),configurationForBalance: AccountBalanceConfigurationIntent(), isLogin: true, isSubscribted: true, widgetSize: context.displaySize,balances:[Balance(value: "1.42 ETH", type: "Unpaid"),Balance(value: "1.42 ETH", type: "Unpaid"),Balance(value: "1.42 ETH", type: "Unpaid"),Balance(value: "1.42 ETH", type: "Unpaid"),Balance(value: "1.42 ETH", type: "Unpaid"),Balance(value: "1.42 ETH", type: "Unpaid")])
    }
    
    func getSnapshot(
        for configuration: AccountBalanceConfigurationIntent,
        in context: Context,
        completion: @escaping (SingleAccountEntry) -> ()) {
        
        var _darkMode = true
        
        if let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") {
            if let darkMode = userDefaults.value(forKey: "darkMode") as? Bool {
                _darkMode = darkMode
            }
        }
        
        let entry = SingleAccountEntry(date: Date(), poolIcon: "/images/pools/Nanopool.png", poolId: "1", poolAccountName: "Nano Conflux", poolTypeAndSubType: "Nanopool CFX", workersCount: 3, currentHashrate: "17/5 MH/s", darkMode: _darkMode, configurationForBalance: AccountBalanceConfigurationIntent(), isLogin: true, isSubscribted: true, widgetSize: context.displaySize,balances:[Balance(value: "102.365 CFX", type: "Paid"),Balance(value: "14.43 CFX", type: "Confirmed"),Balance(value: "0 CFX", type: "Unconfirmed")])
        
        completion(entry)
        
    }
    
    func getTimeline(for configuration: AccountBalanceConfigurationIntent,
                     in context: Context,
                     completion: @escaping (Timeline<SingleAccountEntry>) -> ()) {
        
        var entries: [SingleAccountEntry] = []
        let accountId = configuration.account?.identifier
        
        self.getPoolsFullBalance(configuration: configuration, completion: { entry in
            entries.removeAll()
            entries.append(entry)
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }, isExampleView: false, widgetSize: context.displaySize, accountIds: [accountId])
        
    }
    
    func getPoolsFullBalance (
        
        configuration: AccountBalanceConfigurationIntent,
        completion: @escaping (SingleAccountEntry) -> Void,
        isExampleView:Bool,
        widgetSize: CGSize,
        accountIds: [String?]) {
        
        var accountId = accountIds[0]
        
        DatabaseManager.shared.migrateRealm()
        
        var _darkMode = true
        
        if let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") {
            if let darkMode = userDefaults.value(forKey: "darkMode") as? Bool {
                _darkMode = darkMode
            }
        }
        
        // Check User
        let user =  DatabaseManager.shared.currentUser
        let endpoint = user != nil ? "v2/widget/\(user!.id)/info" : ""

        if user == nil && !isExampleView {
            var entry = SingleAccountEntry(date: Date(), poolTypeAndSubType: "", workersCount: 0, currentHashrate: "", configurationForBalance: configuration, isLogin: false, isSubscribted: false, widgetSize: widgetSize)
            entry.darkMode = _darkMode
            
            completion(entry)
            return
        }
        
        // Check Subscribe
        if !user!.isSubscribted && !isExampleView {
            
            var entry = SingleAccountEntry(date: Date(), poolTypeAndSubType: "", workersCount: 0, currentHashrate: "", configurationForBalance: configuration, isLogin: true, isSubscribted: false, widgetSize: widgetSize)
            
            entry.darkMode = _darkMode
            
            completion(entry)
            return
        }
        // Check Accounts Count
        
        if  let accounFromDB = RealmWrapper.sharedInstance.getAllObjectsOfModel(PoolAccountModel.self) as? [PoolAccountModel] {
            
            if (accounFromDB.isEmpty && !isExampleView) || (accountId == nil && !isExampleView) {
                
                if let firstAccount = accounFromDB.first  {
                    accountId = firstAccount.id
                } else {
                    
                    var entry = SingleAccountEntry(date: Date(), poolTypeAndSubType: "", workersCount: 0, currentHashrate: "", configurationForBalance: configuration, isLogin: true, isSubscribted: true, noAccount: true, widgetSize: widgetSize)
                    
                    entry.darkMode = _darkMode
                    
                    completion(entry)
                    return
                }
            }
        }
        
        
        
        checkTimerForAccountWidgets(accountId: accountId!) {  selectedAccountId, isAccountsGettingTime in
            let kitAccountsFromDB = RealmWrapper.sharedInstance.getAllObjectsOfModel(KitAccountModel.self) as? [KitAccountModel]
            
            var (selectedAccountId,isAccountsGettingTime) = (selectedAccountId,isAccountsGettingTime)
            
            if  !isAccountsGettingTime {  isAccountsGettingTime = kitAccountsFromDB == nil
                
                if kitAccountsFromDB != nil {isAccountsGettingTime = kitAccountsFromDB!.isEmpty }
            }
            
            if isAccountsGettingTime {
                
                let param = ["type" : "0","ids": selectedAccountId?.description ?? [accountId!].description ] as [String : Any]
                
                
                NetworkManager.shared.request(method: .post, endpoint: endpoint, params: param, success: { (json) in
                    guard let status = json.value(forKey: "status") as? Int, status == 0, let data = json["data"] as? NSDictionary else {
                        let message = json["description"] as? String ?? "unknown_error"
                        debugPrint(message)
                        return
                    }
                    
                    var kitAccounts = [KitAccountModel]()
                    RealmWrapper.sharedInstance.deleteObjectsFromRealmDB(KitAccountModel.self)
                    
                    if let results = data.value(forKey: "results") as? [NSDictionary] {
                        results.forEach { kitAccounts.append((KitAccountModel(json: $0)))}
                    }
                    kitAccounts.forEach({RealmWrapper.sharedInstance.addObjectInRealmDB($0)})
                    
                    if let accountDetail = kitAccounts.filter({$0.poolId == accountId }).first {
                        let balances = checkBalances(configuration: configuration, balane: accountDetail)
                        
                        var entry  = SingleAccountEntry(date: Date(), poolIcon: accountDetail.poolIcon, poolId: accountDetail.poolId, poolAccountName: accountDetail.poolAccountLabel, poolTypeAndSubType: "\(accountDetail.poolTypeName) \(accountDetail.poolSubItemName)", workersCount: accountDetail.workersCount, currentHashrate: accountDetail.currentHashrate.textFromHashrate(hsUnit:accountDetail.hsUnit), darkMode: true, configurationForBalance: configuration, isLogin: true, isSubscribted: true, widgetSize: widgetSize,balances: balances)
                        entry.darkMode = _darkMode
                        
                        completion(entry)
                        return
                    }
                    
                    completion(SingleAccountEntry(date: Date(), poolIcon: "", poolId: "", poolAccountName: "", poolTypeAndSubType: "",currentHashrate: "", darkMode: true, balance: Balance(value: "", type: ""), configurationForBalance: AccountBalanceConfigurationIntent(), isLogin: true, isSubscribted: true, noSelectedAccount: true, widgetSize: widgetSize))
                    
                }) { (error) in
                    debugPrint(error)
                }
            } else {
                if let accountDetail = kitAccountsFromDB?.filter({$0.poolId == accountId }).first {
                    let balances = checkBalances(configuration: configuration, balane: accountDetail)
                    
                    var entry  = SingleAccountEntry(date: Date(), poolIcon: accountDetail.poolIcon, poolId: accountDetail.poolId, poolAccountName: accountDetail.poolAccountLabel, poolTypeAndSubType: "\(accountDetail.poolTypeName) \(accountDetail.poolSubItemName)", workersCount: accountDetail.workersCount, currentHashrate: accountDetail.currentHashrate.textFromHashrate(hsUnit:accountDetail.hsUnit), darkMode: true, configurationForBalance: configuration, isLogin: true, isSubscribted: true, widgetSize: widgetSize,balances: balances)
                    entry.darkMode = _darkMode
                    
                    completion(entry)
                    return
                }
            }
        }
    }
    
    func checkTimerForAccountWidgets(accountId: String, successTuples: @escaping([String]?,Bool) -> Void) {
        
        var selectedAccountId = UserDefaults.sharedForWidget.value(forKey: "selected_accountId_for_kitWidget") as? [String]
        
        guard  selectedAccountId != nil  else {
            successTuples (nil,true)
            return
        }
        //Check Old Values
        guard selectedAccountId!.contains(accountId) else {
            selectedAccountId!.append(accountId)
            successTuples (selectedAccountId,true)
            return
        }
        //Check Time
        let isTimeToGetAccounts = TimerManager.shared.isLoadingTime(item: .accountWidget)
        guard !isTimeToGetAccounts else {
            successTuples (selectedAccountId,true)
            return
        }
        successTuples (selectedAccountId,false)
    }
    
    func checkBalances(configuration: AccountBalanceConfigurationIntent, balane: KitAccountModel ) -> [Balance]? {
        
        Localize.setCurrentLanguage(UserDefaults(suiteName: "group.com.witplex.MinerBox")?.string(forKey: "appLanguage") ?? "en")
        
        var balances = [Balance]()
        
        guard  configuration.balances != nil else {
            if let balance =  addDefaultBalane(balane: balane)  {
                balances.append(balance)
            }
            return balances
        }
        
        for balance in configuration.balances! {
            for coin in balane.coins {
                
                switch balance.balanceType {
                case WidgetBalance.paid.rawValue where balance.coinId == coin.coinId :
                    if coin.paid ==  -1  { continue}
                    balances.append( Balance(value:( coin.paid.getString() + " " + coin.currency ), type: WidgetBalance.paid.rawValue.localized()))
                    continue
                case WidgetBalance.unpaid.rawValue where balance.coinId == coin.coinId :
                    if coin.unpaid ==  -1  { continue }
                    balances.append( Balance(value: coin.unpaid.getString() + " "  + coin.currency  , type: WidgetBalance.unpaid.rawValue.localized()))
                    continue
                case WidgetBalance.unconfirmed.rawValue where balance.coinId == coin.coinId :
                    if coin.unconfirmed ==  -1  { continue }
                    balances.append( Balance(value: (coin.unconfirmed.getString() + " " + coin.currency  ), type: WidgetBalance.unconfirmed.rawValue.localized()))
                    continue
                case WidgetBalance.confirmed.rawValue where balance.coinId == coin.coinId :
                    if coin.confirmed ==  -1  { continue }
                    balances.append( Balance(value: (coin.confirmed.getString() + " " + coin.currency  ), type: WidgetBalance.confirmed.rawValue.localized()))
                    continue
                case WidgetBalance.orphaned.rawValue where balance.coinId == coin.coinId :
                    if coin.orphaned ==  -1  { continue }
                    balances.append( Balance(value: (coin.orphaned.getString() + " "  + coin.currency ) , type: WidgetBalance.orphaned.rawValue.localized()))
                    continue
                case WidgetBalance.credit.rawValue where balance.coinId == coin.coinId :
                    if coin.credit ==  -1  { continue }
                    balances.append( Balance(value: (coin.credit.getString() + " " +  coin.currency ), type: WidgetBalance.credit.rawValue.localized()))
                    continue
                case WidgetBalance.credit.rawValue where balance.coinId == coin.coinId :
                    if coin.credit ==  -1  { continue }
                    balances.append( Balance(value: (coin.paid.getString() + " " +  coin.currency ) , type: WidgetBalance.paid.rawValue.localized()))
                    continue
                case WidgetBalance.totalBalance.rawValue where balance.coinId == coin.coinId :
                    if coin.totalBalance ==  -1  { continue }
                    balances.append( Balance(value: (coin.totalBalance.getString() + " " +  coin.currency) , type: WidgetBalance.totalBalance.rawValue.localized()))
                    continue
                default:
                    continue
                }
            }
        }
        return balances.isEmpty ? nil : balances
    }
}


struct AccountBalanceWidget: Widget {
    let kind: String = "Account Balance"
    
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind,
                            intent: AccountBalanceConfigurationIntent.self,
                            provider: AccountBalanceProvider()) { entry in
            AccountBalanceView(entry: entry)
        }
        .configurationDisplayName("account_Balance_Widget")
        .description("account_balance_description")
        .supportedFamilies([.systemMedium])
    }
}
