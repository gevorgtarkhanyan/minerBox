//
//  MultiAccountWidget.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 08.10.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//
//
import WidgetKit
import SwiftUI
import Intents
import RealmSwift
import Localize_Swift



struct MultiAccountProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> MultiAccountWidgetEntry {
        
        var _darkMode = true
        
        if let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") {
            if let darkMode = userDefaults.value(forKey: "darkMode") as? Bool {
                _darkMode = darkMode
            }
        }
        
        return    MultiAccountWidgetEntry(date: Date(), configuration: MultiAccountConfigurationIntent(),isLogin: true, darkMode: _darkMode,accounts: [SingleAccountForMulti(poolIcon: "images/pools/Binance.png", poolId: "example", poolAccountName: "example", poolType: "example",subType: "example",workersCount: 999999, currentHashrate: "example", balance: Balance(value: "example", type: "example"), numberAccount: 1),SingleAccountForMulti(poolIcon: "images/pools/Binance.png", poolId: "example", poolAccountName: "example", poolType: "example",subType: "example", workersCount: 999999, currentHashrate: "example", balance: Balance(value: "example", type: "example"), numberAccount: 2),SingleAccountForMulti(poolIcon: "images/pools/Binance.png", poolId: "example", poolAccountName: "example", poolType: "example",subType: "example", workersCount: 999999, currentHashrate: "example", balance: Balance(value: "example", type: "example"), numberAccount: 3),SingleAccountForMulti(poolIcon: "images/pools/Binance.png", poolId: "example", poolAccountName: "example", poolType: "example",subType: "example", workersCount: 999999, currentHashrate: "example", balance: Balance(value: "example", type: "example"), numberAccount: 4)],isSubscribted: true, widgetSize: context.displaySize)
    }
    
    func getSnapshot(
        for configuration: MultiAccountConfigurationIntent,
        in context: Context,
        completion: @escaping (MultiAccountWidgetEntry) -> ()) {
        
        var _darkMode = true
        
        if let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") {
            if let darkMode = userDefaults.value(forKey: "darkMode") as? Bool {
                _darkMode = darkMode
            }
        }
        
        let entry = MultiAccountWidgetEntry(date: Date(), configuration: MultiAccountConfigurationIntent(), darkMode: _darkMode,accounts: [SingleAccountForMulti(poolIcon: "images/pools/Binance.png", poolId: "1", poolAccountName: "BNB account", poolType: "Binance",subType: "Ethash", workersCount: 1, currentHashrate: "85,899 MH/s", balance: Balance(value: "0.165 ETH", type: "Total"), numberAccount: 1),SingleAccountForMulti(poolIcon: "images/pools/2Miners.png", poolId: "2", poolAccountName: "Ethereum2M", poolType: "2Miners",subType: "Ethereum", workersCount: 10, currentHashrate: "1.673 GH/s", balance: Balance(value: "2,107 ETH", type: "Unpaid") , numberAccount: 2),SingleAccountForMulti(poolIcon: "images/pools/Bitfly.png", poolId: "3", poolAccountName: "Ethermine", poolType: "Bitfly",subType: "ETH", workersCount: 10, currentHashrate: "2,501 GH/s", balance: Balance(value: "0,148 ETH", type: "Unpaid"), numberAccount: 3),SingleAccountForMulti(poolIcon: "images/pools/CrazyPool.png", poolId: "4", poolAccountName: "Crazy ETC", poolType: "CrezyPool",subType: "ETC", workersCount: 113, currentHashrate: "266,016 GH/s", balance: Balance(value: "1 771,365 ETC", type: "Paid"), numberAccount: 4)],isSubscribted: true, widgetSize: context.displaySize)
        
        completion(entry)
        
    }
    
    func getTimeline(for configuration: MultiAccountConfigurationIntent,
                     in context: Context,
                     completion: @escaping (Timeline<MultiAccountWidgetEntry>) -> ()) {
        
        var entries: [MultiAccountWidgetEntry] = []
        
        let accountIds = filtredAccountIds(configuration: configuration)
        
        self.getPoolsFullBalance(configuration: configuration, completion: { entry in
            entries.removeAll()
            entries.append(entry)
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }, isExampleView: false, widgetSize: context.displaySize, accountIds: accountIds)
        
    }
    
    func filtredAccountIds(configuration: MultiAccountConfigurationIntent) -> [String] {
        
        var accountIds = [String]()
        
        if let accountId = configuration.firstAccount?.identifier {
            accountIds.append(accountId)
        }
        if let accountId = configuration.secondAccount?.identifier {
            accountIds.append(accountId)
        }
        if let accountId = configuration.thirdAccount?.identifier {
            accountIds.append(accountId)
        }
        if let accountId = configuration.fourthAccount?.identifier {
            accountIds.append(accountId)
        }
        return accountIds
    }
    
    func getPoolsFullBalance (
        
        configuration: MultiAccountConfigurationIntent,
        completion: @escaping (MultiAccountWidgetEntry) -> Void,
        isExampleView:Bool,
        widgetSize: CGSize,
        accountIds: [String]) {
        
        var accountIds = accountIds
        
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
            var entry = MultiAccountWidgetEntry(date: Date(), configuration: MultiAccountConfigurationIntent(), isLogin: false, isSubscribted: false, widgetSize: widgetSize)
            entry.darkMode = _darkMode
            
            completion(entry)
            return
        }
        
        // Check Subscribe
        if !user!.isSubscribted && !isExampleView {
            
            var entry = MultiAccountWidgetEntry(date: Date(), configuration: MultiAccountConfigurationIntent(), isLogin: true, isSubscribted: false, widgetSize: widgetSize)
            
            entry.darkMode = _darkMode
            
            completion(entry)
            return
        }
        // Check Accounts Count
        
        if  let accounFromDB = RealmWrapper.sharedInstance.getAllObjectsOfModel(PoolAccountModel.self) as? [PoolAccountModel] {
            
            if (accounFromDB.isEmpty && !isExampleView) || (accountIds.isEmpty && !isExampleView) {
                
                if let firstAccount = accounFromDB.first  {
                    accountIds.append(firstAccount.id)
                } else {
                    
                    var entry = MultiAccountWidgetEntry(date: Date(), configuration: MultiAccountConfigurationIntent(), isLogin: true, isSubscribted: true, noAccount: true, widgetSize: widgetSize)
                    
                    entry.darkMode = _darkMode
                    
                    completion(entry)
                    return
                }
            }
        }
        checkTimerForAccountWidgets(accountIds: accountIds) { selectedAccountId, isAccountsGettingTime in
            
            let kitAccountsFromDB = RealmWrapper.sharedInstance.getAllObjectsOfModel(KitAccountModel.self) as? [KitAccountModel]
            
            var (selectedAccountId,isAccountsGettingTime) = (selectedAccountId,isAccountsGettingTime)
            
            if  !isAccountsGettingTime {  isAccountsGettingTime = kitAccountsFromDB == nil
                
                if kitAccountsFromDB != nil {isAccountsGettingTime = kitAccountsFromDB!.isEmpty }
            }
            
            if isAccountsGettingTime {
                let param = ["type" : "0","ids": selectedAccountId?.description ?? accountIds.description ] as [String : Any]
                
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
                    
                    let kitAccountsForEntry = kitAccounts.filter { selectedAccountId?.contains($0.poolId) ?? accountIds.contains($0.poolId)}
                    
                    guard kitAccountsForEntry.isEmpty else {
                        completion(sortingAccounts(accounts: kitAccountsForEntry, selectedAccountId: selectedAccountId, accountIds: accountIds, configuration: configuration, widgetSize: widgetSize, _darkMode: _darkMode))
                        return
                    }
                    var entry = MultiAccountWidgetEntry(date: Date(), configuration: MultiAccountConfigurationIntent(), isLogin: true, widgetSize: widgetSize, noSelectedAccount: true)
                    
                    entry.darkMode = _darkMode
                    
                    completion(entry)
                    
                }) { (error) in
                    debugPrint(error)
                }
            } else {
                
                completion(sortingAccounts(accounts: kitAccountsFromDB, selectedAccountId: selectedAccountId, accountIds: accountIds, configuration: configuration, widgetSize: widgetSize, _darkMode: _darkMode))
            }
        }
    }
    
    func checkTimerForAccountWidgets(accountIds: [String], successTuples: @escaping([String]?,Bool) -> Void) {
        
        var selectedAccountId = UserDefaults.sharedForWidget.value(forKey: "selected_accountId_for_kitWidget") as? [String]
        var isNewAccountId = false
        
        guard  selectedAccountId != nil  else {
            successTuples (nil,true)
            return
        }
        //Check Old Values
        for accountId in accountIds {
            if !selectedAccountId!.contains(accountId)  {
                isNewAccountId = true
                selectedAccountId!.append(accountId)
            }
        }
        guard !isNewAccountId else {
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
    
    func sortingAccounts(accounts :[KitAccountModel]?,
                         selectedAccountId: [String]?,
                         accountIds: [String],
                         configuration: MultiAccountConfigurationIntent,
                         widgetSize: CGSize,
                         _darkMode: Bool) -> MultiAccountWidgetEntry {
        
        
        var _kitAccountsForEntry = [KitAccountModel]()
        let kitAccountsForEntry = accounts?.filter { selectedAccountId?.contains($0.poolId) ?? accountIds.contains(($0.poolId)) }
        
        for accountId in accountIds {
            for kitAccount in kitAccountsForEntry! {
                if kitAccount.poolId ==  accountId {
                    _kitAccountsForEntry.append(kitAccount)
                }
            }
        }
        var accountsForEntry = [SingleAccountForMulti]()
        
        for (index,accountDetail) in _kitAccountsForEntry.enumerated() {
            var balanceString:Balance?
            
            switch accountDetail.poolId {
            case configuration.firstAccount?.identifier:
                balanceString = checkBalanceForMulti(balance: configuration.firstBalance, balaneFromServer: accountDetail)
            case configuration.secondAccount?.identifier:
                balanceString = checkBalanceForMulti(balance: configuration.secondBalance, balaneFromServer: accountDetail)
            case configuration.thirdAccount?.identifier:
                balanceString = checkBalanceForMulti(balance: configuration.thirdBalance, balaneFromServer: accountDetail)
            case configuration.fourthAccount?.identifier:
                balanceString = checkBalanceForMulti(balance: configuration.fourthBalance, balaneFromServer: accountDetail)
            default:
                balanceString = checkBalanceForMulti(balance: nil, balaneFromServer: accountDetail)
            }
            
            accountsForEntry.append(SingleAccountForMulti(poolIcon: accountDetail.poolIcon, poolId: accountDetail.poolId, poolAccountName: accountDetail.poolAccountLabel, poolType: accountDetail.poolTypeName,subType: accountDetail.poolSubItemName, workersCount: accountDetail.workersCount, currentHashrate: accountDetail.currentHashrate.textFromHashrate(hsUnit:accountDetail.hsUnit), balance: balanceString, numberAccount: index + 1))
        }
        let entry  = MultiAccountWidgetEntry(date: Date(), configuration: MultiAccountConfigurationIntent(),darkMode: _darkMode, accounts:accountsForEntry,isSubscribted: true, widgetSize: widgetSize)
        return entry
    }
    
    func checkBalanceForMulti(balance: Ballance?, balaneFromServer: KitAccountModel ) -> Balance? {
        
        Localize.setCurrentLanguage(UserDefaults(suiteName: "group.com.witplex.MinerBox")?.string(forKey: "appLanguage") ?? "en")
        
        guard  balance?.balanceType != nil else {
            return addDefaultBalane(balane: balaneFromServer)
        }
        
        for coin in balaneFromServer.coins {
            
            switch balance?.balanceType {
            case WidgetBalance.paid.rawValue where balance?.coinId == coin.coinId :
                guard coin.paid !=  -1  else { return nil}
                return   Balance(value: coin.paid.getString()  + " " +  coin.currency , type: WidgetBalance.paid.rawValue.localized())
            case WidgetBalance.unpaid.rawValue where balance?.coinId == coin.coinId :
                guard coin.unpaid !=  -1 else { return nil}
                return  Balance(value: coin.unpaid.getString()  + " " +  coin.currency , type: WidgetBalance.unpaid.rawValue.localized())
            case WidgetBalance.unconfirmed.rawValue where balance?.coinId == coin.coinId :
                guard coin.unconfirmed !=  -1 else { return nil}
                return Balance(value: coin.unconfirmed.getString()  + " " +  coin.currency , type: WidgetBalance.unconfirmed.rawValue.localized())
            case WidgetBalance.confirmed.rawValue where balance?.coinId == coin.coinId :
                guard coin.confirmed !=  -1 else { return nil}
                return   Balance(value: coin.confirmed.getString()  + " " +  coin.currency , type: WidgetBalance.confirmed.rawValue.localized())
            case WidgetBalance.orphaned.rawValue where balance?.coinId == coin.coinId :
                guard coin.orphaned !=  -1  else{ return nil}
                return   Balance(value: coin.orphaned.getString()  + " " +  coin.currency , type: WidgetBalance.orphaned.rawValue.localized())
            case WidgetBalance.credit.rawValue where balance?.coinId == coin.coinId :
                guard coin.credit !=  -1  else{ return nil}
                return  Balance(value: coin.credit.getString()  + " " +  coin.currency , type: WidgetBalance.credit.rawValue.localized())
            case WidgetBalance.totalBalance.rawValue where balance?.coinId == coin.coinId :
                guard coin.totalBalance !=  -1  else{ return nil}
                return  Balance(value: coin.totalBalance.getString()  + " " +  coin.currency , type: WidgetBalance.totalBalance.rawValue.localized())
            case "none":
                return nil
            default:
                continue
            }
        }
        return nil
    }
}

struct MultiAccountWidget: Widget {
    let kind: String = "Multi Account"
    
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind,
                            intent: MultiAccountConfigurationIntent.self,
                            provider: MultiAccountProvider()) { entry in
            MultiAccountWidgetView(entry: entry)
        }
        .configurationDisplayName("multi_Account_Widget")
        .description("multi_account_description")
        .supportedFamilies([.systemLarge])
    }
}

