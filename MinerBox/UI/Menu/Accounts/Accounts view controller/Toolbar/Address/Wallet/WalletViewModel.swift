//
//  WalletViewModel.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 22.02.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import Foundation

protocol WalletViewModelDelegate: AnyObject {
    func reloadData()
    func requestFailed(with error: String)
    func startLoading(toLoweAlpha: Bool)
    func endLoading(toRaiseAlpha: Bool)
    func showActionShit()
}

class WalletViewModel {
    
    var exchange: ExchangeModel?
    var selectedWallet: WalletModel?
    var walletId: String?
    var show0 = true
    let rates = UserDefaults.standard.value(forKey: "\(DatabaseManager.shared.currentUser?.id ?? "" )/rates") as? [String:Double]
    var searchTimer = Timer()
    var searchText: String = ""
    
    private var refresWalletTimer: Timer?
    private var refreshTime = 0

    weak var delegate: WalletViewModelDelegate?
    
    init(walletId: String?) {
        self.walletId = walletId
        self.addObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("WalletViewModel Deinit")
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(getExchange), name: .updateWalletData, object: nil)
    }
    
    //MARK: - Requestes
    @objc public func getExchange() {
        guard walletId != nil else { return }
        self.delegate?.startLoading(toLoweAlpha: false)
        WalletManager.shared.getExchangies(walletId: walletId!) { [weak self] exchange in
            guard let self = self else { return }

            self.exchange = exchange
            self.startWalletTimer()
            self.exchange?.showWalletTotalValue = UserDefaults.shared.bool(forKey: "show_wallet_total")
            self.setupSelectedWallet()
            Cacher.shared.walletTransactionState = exchange.transactionsLoaded ? .show : .loading
            NotificationCenter.default.post(name: .changeTransactionState, object: nil)
            self.delegate?.endLoading(toRaiseAlpha: false)
        } failer: { error in
            debugPrint(error)
            self.delegate?.requestFailed(with: error)
            self.delegate?.endLoading(toRaiseAlpha: false)
        }
    }
    
    public func updateExchange() {
        if #unavailable(iOS 13.0){
        self.delegate?.startLoading(toLoweAlpha: false)
        }
        guard walletId != nil else { return }
        Cacher.shared.walletUpateState = .loading
        NotificationCenter.default.post(name: .updateReloadState, object: nil)
        WalletManager.shared.updateExchangies(walletId: walletId!) {  [weak self] exchange in
            guard let self = self else { return }

            Cacher.shared.walletUpateState = .show
            NotificationCenter.default.post(name: .updateReloadState, object: nil)

            guard self.delegate != nil else {
                NotificationCenter.default.post(name: .updateWalletData, object: nil)
                return
            }
            self.exchange = exchange
            self.startWalletTimer()
            self.exchange?.showWalletTotalValue = UserDefaults.shared.bool(forKey: "show_wallet_total")
            self.setupSelectedWallet()
            Cacher.shared.walletTransactionState = exchange.transactionsLoaded ? .show : .loading
            NotificationCenter.default.post(name: .changeTransactionState, object: nil)
            self.delegate?.endLoading(toRaiseAlpha: false)
        } failer: { error in
            debugPrint(error)
            self.delegate?.requestFailed(with: error)
        }
    }
    
    public func getWalletCoin() {
        guard walletId != nil && selectedWallet?.selectedBalance != nil else { return }
        self.delegate?.startLoading(toLoweAlpha: true)
        
        for walletCoin in self.exchange!.walletCoins {
            if walletCoin.coinId == selectedWallet?.selectedBalance?.coinId {
                self.selectedWallet?.selectedWalletCoin = walletCoin
                guard walletCoin.addresses.isEmpty else {
                    self.delegate?.showActionShit()
                    return
                }
                return
            }
        }
        
        WalletManager.shared.getWalletCoin(walletId: walletId!, coinId: (selectedWallet?.selectedBalance)!.coinId, currency: (selectedWallet?.selectedBalance)!.currency, exchange: exchange!.exchange) { [weak self] walletCoin in
            guard let self = self else { return }

            self.exchange?.walletCoins.append(walletCoin)
            self.selectedWallet?.selectedWalletCoin = walletCoin
            guard walletCoin.addresses.isEmpty else {
                self.delegate?.showActionShit()
                return
            }
        } failer: { error in
            debugPrint(error)
            self.delegate?.requestFailed(with: error)
            self.delegate?.endLoading(toRaiseAlpha: true)
        }
    }
    
    public func changeSelect(index: Int) {
        self.selectedWallet = self.exchange?.wallets[index]
        for (_index, wallet) in self.exchange!.wallets.enumerated() {
            wallet.isSelected = _index == index
        }
        self.delegate?.reloadData()
    }
    
    public func changeSelectedBalance(index: Int) {
        self.selectedWallet?.selectedBalance =  self.selectedWallet?.showingBalances[index]
        self.getWalletCoin()
    }
    
    func setupSelectedWallet() {
        guard exchange != nil else { return }
        if let wallet = exchange!.wallets.first {
            self.selectedWallet = wallet
            self.selectedWallet?.isSelected = true
        }
        self.delegate?.reloadData()
        self.delegate?.endLoading(toRaiseAlpha: false)
    }
    
    func toggleShowWalletValue() {
        self.exchange?.showWalletTotalValue.toggle()
        UserDefaults.shared.setValue(self.exchange?.showWalletTotalValue, forKey: "show_wallet_total")
        self.delegate?.reloadData()
    }
    
    func startWalletTimer() {
        guard refresWalletTimer == nil else { return }
        self.refresWalletTimer = Timer.scheduledTimer(timeInterval: Constants.singleCallTimeInterval, target: self, selector: #selector(self.checkTransactionLoad), userInfo: nil, repeats: true)
    }
    
    func stopWalletTimer() {
        refresWalletTimer?.invalidate()
        refresWalletTimer = nil
    }
    
    @objc private func checkTransactionLoad() {

        self.refreshTime += 5
        if refreshTime == Constants.poolRequestTimeInterval {
            self.refreshTime = 0
            self.stopWalletTimer()
            Cacher.shared.walletTransactionState = .noShow
            NotificationCenter.default.post(name: .changeTransactionState, object: nil)

            return
        }
        
        guard exchange != nil else { return }

        guard exchange!.transactionsLoaded else {
            

            guard walletId != nil else { return }
            WalletManager.shared.getExchangies(short: true, walletId: walletId!) { [weak self] exchange in
                guard let self = self else { return }

                self.exchange?.transactionsLoaded = exchange.transactionsLoaded
            } failer: { error in
                debugPrint(error)
            }
            return
        }
        
        self.refreshTime = 0
        Cacher.shared.walletTransactionState = .show
        NotificationCenter.default.post(name: .changeTransactionState, object: nil)
        self.stopWalletTimer()
    }
    
    public func sortBalanceWithout0( _ ballances: [WalletBalanceModel]? = nil)  {
        
        self.selectedWallet?.showingBalances = self.show0 ? self.selectedWallet?.balances ?? [] :  self.selectedWallet?.balances.filter({$0.availableBalance != 0}) ?? []
        
        // IsSearching
        guard ballances == nil else {
            self.selectedWallet?.showingBalances = self.show0 ? ballances! : ballances!.filter({$0.availableBalance != 0})
            self.delegate?.reloadData()
            return
        }
        
        guard self.searchText == "" else {
        sortBalanceWithSearchText(self.selectedWallet?.showingBalances)
            return
        }
        self.delegate?.reloadData()

    }
    
    public func sortBalanceWithSearchText( _ ballances: [WalletBalanceModel]? = nil)  {
        guard self.searchText != "" else {
            self.selectedWallet?.showingBalances = ballances ?? (self.selectedWallet?.balances ?? [])
            guard self.show0 else {
                self.sortBalanceWithout0(self.selectedWallet?.showingBalances)
              return
            }
            self.delegate?.reloadData()
            return
        }
        // IsSortingZero
        guard ballances == nil else {
            self.selectedWallet?.showingBalances =  ballances!.filter({ $0.coinId.uppercased().contains(self.searchText.uppercased()) || $0.currency.uppercased().contains(self.searchText.uppercased())})
            self.delegate?.reloadData()
            return
        }
        
        self.selectedWallet?.showingBalances =  self.selectedWallet?.balances.filter({ $0.coinId.uppercased().contains(self.searchText.uppercased()) || $0.currency.uppercased().contains(self.searchText.uppercased())  }) ?? []
        
        guard self.show0 else {
            self.sortBalanceWithout0(self.selectedWallet?.showingBalances)
          return
        }
        self.delegate?.reloadData()
    }
}
