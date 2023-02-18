//
//  IntentHandler.swift
//  KindWidgetsIntent
//
//  Created by Vazgen Hovakimyan on 30.08.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Intents
import Localize_Swift
import WidgetKit


// As an example, this class is set up to handle Message intents.
// You will want to replace this or add other intents as appropriate.
// The intents you wish to handle must be declared in the extension's Info.plist.

// You can test your example integration by saying things to Siri like:
// "Send a message using <myApp>"
// "<myApp> John saying hello"
// "Search for messages in <myApp>"

class IntentHandler: INExtension, SingleCoinConfigurationIntentHandling, SingleAccountConfigurationIntentHandling,MultiCoinConfigurationIntentHandling , MultiAccountConfigurationIntentHandling, AccountBalanceConfigurationIntentHandling {
    
    
    //MARK: - AccounBanalance -
    func provideBalancesOptionsCollection(for intent: AccountBalanceConfigurationIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<Ballance>?, Error?) -> Void) {
        self.checkAccount(accountid: intent.account?.identifier, searchTerm:searchTerm, with: { collection, err in
            completion(collection,err)
        })
    }
    
    func provideAccountOptionsCollection(for intent: AccountBalanceConfigurationIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<Account>?, Error?) -> Void) {
        
        getAccountsFromRealmDB(searchTerm: searchTerm) { completions, err in
            completion(completions,err)
        }
    }
    
    //MARK: - SingleAccount  -
    func provideAccountOptionsCollection(for intent: SingleAccountConfigurationIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<Account>?, Error?) -> Void) {
        
        getAccountsFromRealmDB(searchTerm: searchTerm) { completions, err in
            completion(completions,err)
        }
    }
    
    func provideBalanceOptionsCollection(for intent: SingleAccountConfigurationIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<Ballance>?, Error?) -> Void) {
        
        self.checkAccount(accountid: intent.Account?.identifier, searchTerm:searchTerm, with: { collection, err in
            completion(collection,err)
        })
    }
    
    func addListBallance(balance: KitAccountModel) -> [Ballance]  {
        
        var _ballances:[Ballance] = []
        
        for coin in balance.coins {
            
            if coin.paid != -1.0 {
                let balance = Ballance(identifier: coin.currency, display: WidgetBalance.paid.rawValue.localized() + " " + coin.currency)
                balance.balanceType = WidgetBalance.paid.rawValue
                balance.coinId = coin.coinId
                _ballances.append(balance)
            }
            if coin.unpaid != -1.0 {
                let balance = Ballance(identifier: coin.currency, display: WidgetBalance.unpaid.rawValue.localized() + " " + coin.currency)
                balance.balanceType = WidgetBalance.unpaid.rawValue
                balance.coinId = coin.coinId
                _ballances.append(balance)
            }
            if coin.unconfirmed != -1.0 {
                let balance = Ballance(identifier: coin.currency, display: WidgetBalance.unconfirmed.rawValue.localized() + " " + coin.currency)
                balance.balanceType = WidgetBalance.unconfirmed.rawValue
                balance.coinId = coin.coinId
                _ballances.append(balance)
            }
            if coin.confirmed != -1.0 {
                let balance = Ballance(identifier: coin.currency, display: WidgetBalance.confirmed.rawValue.localized() + " " + coin.currency)
                balance.balanceType = WidgetBalance.confirmed.rawValue
                balance.coinId = coin.coinId
                _ballances.append(balance)
            }
            if coin.orphaned != -1.0 {
                let balance = Ballance(identifier: coin.currency, display: WidgetBalance.orphaned.rawValue.localized() + " " + coin.currency)
                balance.balanceType = WidgetBalance.orphaned.rawValue
                balance.coinId = coin.coinId
                _ballances.append(balance)
            }
            if coin.credit != -1.0 {
                let balance = Ballance(identifier: coin.currency, display: WidgetBalance.credit.rawValue.localized() + " " + coin.currency)
                balance.balanceType = WidgetBalance.credit.rawValue
                balance.coinId = coin.coinId
                _ballances.append(balance)
            }
            if coin.totalBalance != -1.0 {
                let balance = Ballance(identifier: coin.currency, display: WidgetBalance.totalBalance.rawValue.localized() + " " + coin.currency)
                balance.balanceType = WidgetBalance.totalBalance.rawValue
                balance.coinId = coin.coinId
                _ballances.append(balance)
            }
        }
        let balance = Ballance(identifier: "none", display: "none".localized())
        balance.balanceType = "none"
        _ballances.append(balance)
        
        return _ballances
    }
    
    func getPoolsBalance( success: @escaping([KitAccountModel]) -> Void, failer: @escaping(String) -> Void,accountIds: [String]) {
        
        guard let user = DatabaseManager.shared.currentUser else {
            debugPrint("Not loged in. Developer issue")
            return
        }
        
        let endpoint = "v2/widget/\(user.id)/info"
        
        let param = ["type" : "0","ids": accountIds.description] as [String : Any]
        
        NetworkManager.shared.request(method: .post, endpoint: endpoint, params: param, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0, let data = json["data"] as? NSDictionary else {
                let message = json["description"] as? String ?? "unknown_error"
                debugPrint(message)
                return
            }
            
            var kitAccounts = [KitAccountModel]()
            
            if let results = data.value(forKey: "results") as? [NSDictionary] {
                results.forEach { kitAccounts.append((KitAccountModel(json: $0)))}
            }
            success(kitAccounts)
            
        }) { (error) in
            debugPrint(error)
        }
    }
    
    //MARK: -MultiAccount-
    func provideFirstAccountOptionsCollection(for intent: MultiAccountConfigurationIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<Account>?, Error?) -> Void) {
        
        getAccountsFromRealmDB(searchTerm: searchTerm) { completions, err in
            completion(completions,err)
        }
    }
    
    func provideFirstBalanceOptionsCollection(for intent: MultiAccountConfigurationIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<Ballance>?, Error?) -> Void) {
        
        self.checkAccount(accountid: intent.firstAccount?.identifier, searchTerm:searchTerm, with: { collection, err in
            completion(collection,err)
        })
    }
    
    func provideSecondAccountOptionsCollection(for intent: MultiAccountConfigurationIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<Account>?, Error?) -> Void) {
        
        getAccountsFromRealmDB(searchTerm: searchTerm) { completions, err in
            completion(completions,err)
        }
    }
    
    func provideSecondBalanceOptionsCollection(for intent: MultiAccountConfigurationIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<Ballance>?, Error?) -> Void) {
        
        self.checkAccount(accountid: intent.secondAccount?.identifier, searchTerm:searchTerm, with: { collection, err in
            completion(collection,err)
        })
    }
    
    func provideThirdAccountOptionsCollection(for intent: MultiAccountConfigurationIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<Account>?, Error?) -> Void) {
        
        getAccountsFromRealmDB(searchTerm: searchTerm) { completions, err in
            completion(completions,err)
        }
    }
    
    func provideThirdBalanceOptionsCollection(for intent: MultiAccountConfigurationIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<Ballance>?, Error?) -> Void) {
        
        self.checkAccount(accountid: intent.thirdAccount?.identifier, searchTerm:searchTerm, with: { collection, err in
            completion(collection,err)
        })
    }
    
    func provideFourthAccountOptionsCollection(for intent: MultiAccountConfigurationIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<Account>?, Error?) -> Void) {
        
        getAccountsFromRealmDB(searchTerm: searchTerm) { completions, err in
            completion(completions,err)
        }
    }
    
    func provideFourthBalanceOptionsCollection(for intent: MultiAccountConfigurationIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<Ballance>?, Error?) -> Void) {
        
        self.checkAccount(accountid: intent.fourthAccount?.identifier, searchTerm:searchTerm, with: { collection, err in
            completion(collection,err)
        })
    }
    
    func checkAccount(accountid: String?,searchTerm: String?,with completion: @escaping (INObjectCollection<Ballance>?, Error?) -> Void)  {
        
        if let accountId = accountid {
            
            
            // Balances From UserDefault
            if let selectedAccountWithBalances = UserDefaults.shared.value(forKey: "selected_Account_With_Balances") as? [String : Data], selectedAccountWithBalances.keys.first == accountid  {
                
                let decoded  = selectedAccountWithBalances.values.first
                let decodedINObjectCollectionTeams = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded!) as! [Ballance]
                
                self.createBalanceINObjectCollection(_ballances: decodedINObjectCollectionTeams, searchTerm: searchTerm) { collection, err in
                    completion(collection,err)
                }
                return
            }
            
            getPoolsBalance(success: { ballances in
                
                guard ballances.first != nil else {
                    completion(nil, nil)
                    return
                }
                let _ballances = self.addListBallance(balance: ballances.first!)
                
                do {
                    let encodedBalanceData = try NSKeyedArchiver.archivedData(withRootObject: _ballances, requiringSecureCoding: false)
                    UserDefaults.shared.setValue([accountid: encodedBalanceData], forKey: "selected_Account_With_Balances")
                }
                catch {
                    print(error.localizedDescription)
                }
                
                self.createBalanceINObjectCollection(_ballances: _ballances, searchTerm: searchTerm) { collection, err in
                    completion(collection,err)
                }
                
            }, failer: { err in
                debugPrint(err)
            }, accountIds: [accountId])
        } else {
            completion(nil, nil)
        }
    }
    
    func getAccountsFromRealmDB(searchTerm: String?, with completion: @escaping (INObjectCollection<Account>?, Error?) -> Void) {
        
        setSelectedAccountWidgets {  // Get old Selected Accounts
            var accounts:[Account] = []
            
            if  let accounFromDB = RealmWrapper.sharedInstance.getAllObjectsOfModel(PoolAccountModel.self) as? [PoolAccountModel] {
                accounts = accounFromDB.map({Account(identifier: $0.id, display: $0.poolAccountLabel)})
            }
            
            guard  searchTerm == nil else {
                let searchingAccounts = accounts.filter({$0.displayString.lowercased().contains(searchTerm!.lowercased())})
                let collection = INObjectCollection(items: searchingAccounts)
                completion(collection, nil)
                return
            }
            
            let collection = INObjectCollection(items: accounts)
            completion(collection, nil)
        }
    }
    
    func setSelectedAccountWidgets(success: @escaping() -> Void)  {
        
        var selectedAccountId: [String] = []
        
        WidgetCenter.shared.getCurrentConfigurations { result in
            switch result {
            case let .success(widgets):
                for widg in widgets {
                    switch widg.configuration {
                    case let intent as SingleAccountConfigurationIntent:
                        if let accountId = intent.Account?.identifier {
                            selectedAccountId.append(accountId)
                        }
                    case let intent as AccountBalanceConfigurationIntent:
                        if let accountId = intent.account?.identifier {
                            selectedAccountId.append(accountId)
                        }
                    case let intent as MultiAccountConfigurationIntent:
                        if let accountId = intent.firstAccount?.identifier {
                            selectedAccountId.append(accountId)
                        }
                        if let accountId = intent.secondAccount?.identifier {
                            selectedAccountId.append(accountId)
                        }
                        if let accountId = intent.thirdAccount?.identifier {
                            selectedAccountId.append(accountId)
                        }
                        if let accountId = intent.fourthAccount?.identifier {
                            selectedAccountId.append(accountId)
                        }
                    default:
                        print("No Intent")
                    }
                }
                selectedAccountId.removeDuplicates()
                UserDefaults.sharedForWidget.setValue(selectedAccountId, forKey: "selected_accountId_for_kitWidget")
                success()
            case let .failure(error): print(error)
            }
        }
    }
    
    func createBalanceINObjectCollection( _ballances: [Ballance] ,searchTerm: String?,with completion: @escaping (INObjectCollection<Ballance>?, Error?) -> Void)  {
        
        guard  searchTerm == nil else {
            let searchingBalance = _ballances.filter({$0.displayString.lowercased().contains(searchTerm!.lowercased())})
            let collection = INObjectCollection(items: searchingBalance)
            return completion(collection, nil)
            
        }
        
        let collection = INObjectCollection(items: _ballances)
        completion (collection, nil)
        
    }
    
    //MARK: - SingleCoin  -
    func provideCoinOptionsCollection(for intent: SingleCoinConfigurationIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<Coin>?, Error?) -> Void) {
        
        filtredCoinIdAndCoinName { coins in
            
            guard  searchTerm == nil else {
                let searchingCoins = coins.filter({$0.displayString.lowercased().contains(searchTerm!.lowercased()) || $0.symbol!.lowercased().contains(searchTerm!.lowercased())})
                
                let collection = INObjectCollection(items: searchingCoins)
                completion(collection, nil)
                return
            }
            let collection = INObjectCollection(items: coins)
            completion(collection, nil)
        }
    }
    
    func filtredCoinIdAndCoinName(success: @escaping([Coin]) -> Void)  {
        var coins:[Coin] = []
        
        setSelectedCoinWidget { // Get old Selected Coins
            guard let favoriteCoinsromDB = RealmWrapper.sharedInstance.getAllObjectsOfModel(FavoriteCoinModel.self) as? [FavoriteCoinModel], !favoriteCoinsromDB.isEmpty else {
                CoinRequestService.shared.getFavoritesCoins { fvCoins in
                    coins.removeAll()
                    for coin in fvCoins {
                        let _coin = Coin(identifier: coin.coinId, display: coin.name)
                        _coin.symbol = coin.symbol
                        coins.append(_coin)
                    }
                    success(coins)
                } failer: { error in
                    success(coins)
                    print(error)
                }
                return
            }
            coins = favoriteCoinsromDB.isEmpty ? [Coin(identifier: "bitcoin", display: "Bitcoin")] : favoriteCoinsromDB.map({
                let _coin = Coin(identifier: $0.coinId, display: $0.name)
                _coin.symbol = $0.symbol
                return _coin
            })
            success(coins)
        }
    }
    
    func setSelectedCoinWidget(success: @escaping() -> Void)  {
        
        var selectedCoinId: [String] = []
        
        WidgetCenter.shared.getCurrentConfigurations { result in
            switch result {
            case let .success(widgets):
                for widg in widgets {
                    switch widg.configuration {
                    case let intent as SingleCoinConfigurationIntent:
                        if let coinId = intent.Coin?.identifier {
                            selectedCoinId.append(coinId)
                        }
                    case let intent as MultiCoinConfigurationIntent:
                        if let coins = intent.coins {
                            _ =  coins.map({ selectedCoinId.append($0.identifier!)})
                        }
                    default:
                        print("No Intent")
                    }
                }
                selectedCoinId.removeDuplicates()
                UserDefaults.sharedForWidget.setValue(selectedCoinId, forKey: "selected_coinId_for_kitWidget")
                success()
            case let .failure(error): print(error)
            }
        }
    }
    
    //MARK: - MultiCoin  -
    func provideCoinsOptionsCollection(for intent: MultiCoinConfigurationIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<Coin>?, Error?) -> Void) {
        Localize.setCurrentLanguage(UserDefaults(suiteName: "group.com.witplex.MinerBox")?.string(forKey: "appLanguage") ?? "en")
        filtredCoinIdAndCoinName { coins in
            
            guard  searchTerm == nil else {
                let searchingCoins = coins.filter({$0.displayString.lowercased().contains(searchTerm!.lowercased()) || $0.symbol!.lowercased().contains(searchTerm!.lowercased())})
                
                
                let collection = INObjectCollection(items: searchingCoins)
                completion(collection, nil)
                return
                
            }
            
            let collection = INObjectCollection(items: coins)
            completion(collection, nil)
        }
    }
    
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        // Check realm migration
        DatabaseManager.shared.migrateRealm()
        Localize.setCurrentLanguage(UserDefaults(suiteName: "group.com.witplex.MinerBox")?.string(forKey: "appLanguage") ?? "en")
        
        
        return self
    }
    
    // MARK: - INSendMessageIntentHandling
    // Implement resolution methods to provide additional information about your intent (optional).
    func resolveRecipients(for intent: INSendMessageIntent, with completion: @escaping ([INSendMessageRecipientResolutionResult]) -> Void) {
        if let recipients = intent.recipients {
            
            // If no recipients were provided we'll need to prompt for a value.
            if recipients.count == 0 {
                completion([INSendMessageRecipientResolutionResult.needsValue()])
                return
            }
            
            var resolutionResults = [INSendMessageRecipientResolutionResult]()
            for recipient in recipients {
                let matchingContacts = [recipient] // Implement your contact matching logic here to create an array of matching contacts
                switch matchingContacts.count {
                case 2  ... Int.max:
                    // We need Siri's help to ask user to pick one from the matches.
                    resolutionResults += [INSendMessageRecipientResolutionResult.disambiguation(with: matchingContacts)]
                    
                case 1:
                    // We have exactly one matching contact
                    resolutionResults += [INSendMessageRecipientResolutionResult.success(with: recipient)]
                    
                case 0:
                    // We have no contacts matching the description provided
                    resolutionResults += [INSendMessageRecipientResolutionResult.unsupported()]
                    
                default:
                    break
                    
                }
            }
            completion(resolutionResults)
        }
    }
    
    func resolveContent(for intent: INSendMessageIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let text = intent.content, !text.isEmpty {
            completion(INStringResolutionResult.success(with: text))
        } else {
            completion(INStringResolutionResult.needsValue())
        }
    }
    
    //    // Once resolution is completed, perform validation on the intent and provide confirmation (optional).
    //
    //    func confirm(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
    //        // Verify user is authenticated and your app is ready to send a message.
    //
    //        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
    //        let response = INSendMessageIntentResponse(code: .ready, userActivity: userActivity)
    //        completion(response)
    //    }
    
    //    // Handle the completed intent (required).
    //
    //    func handle(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
    //        // Implement your application logic to send a message here.
    //
    //        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
    //        let response = INSendMessageIntentResponse(code: .success, userActivity: userActivity)
    //        completion(response)
    //    }
    //
    //    // Implement handlers for each intent you wish to handle.  As an example for messages, you may wish to also handle searchForMessages and setMessageAttributes.
    //
    //    // MARK: - INSearchForMessagesIntentHandling
    //
    //    func handle(intent: INSearchForMessagesIntent, completion: @escaping (INSearchForMessagesIntentResponse) -> Void) {
    //        // Implement your application logic to find a message that matches the information in the intent.
    //
    //        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSearchForMessagesIntent.self))
    //        let response = INSearchForMessagesIntentResponse(code: .success, userActivity: userActivity)
    //        // Initialize with found message's attributes
    //        response.messages = [INMessage(
    //            identifier: "identifier",
    //            content: "I am so excited about SiriKit!",
    //            dateSent: Date(),
    //            sender: INPerson(personHandle: INPersonHandle(value: "sarah@example.com", type: .emailAddress), nameComponents: nil, displayName: "Sarah", image: nil,  contactIdentifier: nil, customIdentifier: nil),
    //            recipients: [INPerson(personHandle: INPersonHandle(value: "+1-415-555-5555", type: .phoneNumber), nameComponents: nil, displayName: "John", image: nil,  contactIdentifier: nil, customIdentifier: nil)]
    //        )]
    //        completion(response)
    //    }
    //
    //    // MARK: - INSetMessageAttributeIntentHandling
    //
    //    func handle(intent: INSetMessageAttributeIntent, completion: @escaping (INSetMessageAttributeIntentResponse) -> Void) {
    //        // Implement your application logic to set the message attribute here.
    //
    //        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSetMessageAttributeIntent.self))
    //        let response = INSetMessageAttributeIntentResponse(code: .success, userActivity: userActivity)
    //        completion(response)
    //    }
}

