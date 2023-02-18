//
//  TransactionViewModel.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 01.03.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import Foundation

protocol TransactionViewModelDelegate: AnyObject {
    func reloadData()
    func requestFailed(with error: String)
    func startLoading()
    func endLoading()
}

class TransactionViewModel {
    
    var walletId: String?
    var historyType: [HistoryType]
    var selectedHistory: HistoryType?
    var selectedIndex: Int?
    
    var statuses: [String:[String]] = [:]
    var totalBalance: [String:TotalBalance?] = [:]
    var filterCoins: [String:[CoinModel]] = [:]
    var transactions: [String: [TransactionModel]] = [:]
    var filtredDetail: [String: FiltredTransactionDetail] = [:]
    var selectedDateTransactions: [DateTransaction] = []
    
    var selectedStatus: [String] {
        return statuses[self.selectedHistory!.name] ?? []
    }
    
    var selectedtotalBalance: TotalBalance? {
        return totalBalance[self.selectedHistory!.name] ?? nil
    }
    
    var selectedFiltredCoins: [CoinModel] {
        return filterCoins[self.selectedHistory!.name] ?? []
    }
    
    var selectedFiltredDetail: FiltredTransactionDetail? {
        return filtredDetail[self.selectedHistory!.name]
    }
    
    private var skip: Int {
        transactions[selectedHistory!.name]?.count ?? 0
    }
    
    var isPaginating = false
    var indexPathForVisibleRow: IndexPath?
    
    weak var delegate: TransactionViewModelDelegate?
    
    init(walletId: String?, historyType: [String]) {
        self.walletId = walletId
        self.historyType = historyType.map({ HistoryType(name: $0) })
        if self.historyType.first != nil {
            self.historyType.first!.isSelected = true
            selectedHistory = self.historyType.first!
        }
    }
    
    public func changeSelect(index: Int) {
        
        self.selectedHistory = self.historyType[index]
        for (_index, history) in self.historyType.enumerated() {
            history.isSelected = _index == index
        }
        self.getTransactions()
    }
    public func removeTransactions() {
        self.transactions[self.selectedHistory!.name]!.removeAll()
    }
    
    public func getTransactions(isPaginateCall: Bool = false, isFilteredState: Bool = false, filtredDetail: FiltredTransactionDetail? = nil) {
        
        self.totalBalance[self.selectedHistory!.name] = nil
        
        if isFilteredState  {
        self.filtredDetail[selectedHistory!.name] = filtredDetail
        }
        
        if self.transactions[self.selectedHistory!.name] != nil && !isPaginating && !isFilteredState {  // if transactions already exsit
            self.calculateDateSections(transactions:  self.transactions[self.selectedHistory!.name]!)
            self.isPaginating = false
            self.delegate?.reloadData()
            self.delegate?.endLoading()
            return
        }
        
        if !isPaginateCall {
            delegate?.startLoading()
        }
        
        WalletManager.shared.getTransactions(
            skip: isPaginateCall ? skip : 0,
            walletId: walletId!,
            txType: selectedHistory!.name,
            currency:  self.filtredDetail[selectedHistory!.name]?.coin?.symbol,
            status:  self.filtredDetail[selectedHistory!.name]?.status,
            startDate: self.filtredDetail[selectedHistory!.name]?.startDate,
            endDate:  self.filtredDetail[selectedHistory!.name]?.endDate)
        {[weak self] jsonData in
            
            guard let self = self else { return }
            
            if let transactionData = jsonData["transactions"] as? [NSDictionary] {
                
                if isPaginateCall &&  self.transactions[self.selectedHistory!.name] != nil {
                    self.transactions[self.selectedHistory!.name]! += transactionData.map { TransactionModel(json: $0) }
                    self.calculateDateSections(transactions:  self.transactions[self.selectedHistory!.name]! )
                } else {
                    self.transactions[self.selectedHistory!.name] = transactionData.map { TransactionModel(json: $0) }
                    self.calculateDateSections(transactions:  self.transactions[self.selectedHistory!.name]! )
                }
            }
            self.statuses[self.selectedHistory!.name] = jsonData.value(forKey: "statuses") as? [String] ?? []
            
            if let totalJson = jsonData.value(forKey: "totalBalance") as? NSDictionary {
                self.totalBalance[self.selectedHistory!.name]  = TotalBalance(json: totalJson)
            }
            if let coinsJson = jsonData.value(forKey: "filterCoins") as? [NSDictionary] {
                self.filterCoins[self.selectedHistory!.name] =  coinsJson.map { CoinModel(json: $0) }
            }
            
            let count = jsonData["count"] as? Int ?? 0
            
            self.isPaginating = self.transactions[self.selectedHistory!.name]!.count == count
            self.delegate?.reloadData()
            self.delegate?.endLoading()
            
        } failer: { error in
            debugPrint(error)
            self.isPaginating = false
            self.delegate?.requestFailed(with: error)
            self.delegate?.endLoading()
        }
    }
    
    
    private func calculateDateSections(transactions: [TransactionModel]) {
        
        self.selectedDateTransactions.removeAll()
        
        for transaction in transactions {
            guard let lastDateTransaction = selectedDateTransactions.last else {
                let DateTransactionObj = createDateTransaction(transaction: transaction)
                DateTransactionObj.transactions.append(transaction)
                self.selectedDateTransactions.append(DateTransactionObj)
                continue
            }
            
            if lastDateTransaction.rangeTime! ~= transaction.date {
                lastDateTransaction.transactions.append(transaction)
                continue
            }
            
            let DateTransactionObj = createDateTransaction(transaction: transaction)
            DateTransactionObj.transactions.append(transaction)
            self.selectedDateTransactions.append(DateTransactionObj)
            
        }
    }
    
    private func createDateTransaction(transaction: TransactionModel) -> DateTransaction {
        
        var createdDate: (startDate:Double, endDate: Double)?
        
        let day = transaction.date.getDayInDate()
        switch Weeks(day) {
        case .first:
            createdDate = createDate(tranasctionDate: transaction.date, startDay: 1)
        case .second:
            createdDate = createDate(tranasctionDate: transaction.date, startDay: 11)
        case .third:
            createdDate = createDate(tranasctionDate: transaction.date, startDay: 21)
        }
        
        return DateTransaction(startDate: createdDate!.startDate, endDate: createdDate!.endDate)
    }
    
    private func createDate(tranasctionDate: Double, startDay: Int ) -> (startDate:Double, endDate: Double) {
        
        let userCalendar = Calendar.current
        var startDate = DateComponents()
        startDate.year = tranasctionDate.getYearInDate()
        startDate.month = tranasctionDate.getMonthInDate()
        startDate.day = startDay
        startDate.timeZone = TimeZone(abbreviation: "ARM")
        let startDateAndTime = userCalendar.date(from: startDate)
        
        var endDateAndTime = Date()
        
        if startDay == 21 {
            endDateAndTime = startDateAndTime!.endOfMonth
        } else {
            var endtDate = DateComponents()
            endtDate.year = tranasctionDate.getYearInDate()
            endtDate.month = tranasctionDate.getMonthInDate()
            endtDate.day = startDay + 9
            endtDate.timeZone = TimeZone(abbreviation: "ARM")
            endDateAndTime = userCalendar.date(from: endtDate)!
        }
        return  (startDate: startDateAndTime!.millisecondsSince1970, endDate: endDateAndTime.millisecondsSince1970)
    }
}


//HELPER
class HistoryType {
    var name: String = ""
    var isSelected = false
    
    init(name: String) {
        self.name = name
    }
}

class DateTransaction {
    var startDate: Double?
    var endDate: Double?
    var rangeTime: ClosedRange<Double>?
    var transactions: [TransactionModel] = []
    
    init(startDate: Double, endDate: Double) {
        self.startDate = startDate
        self.endDate = endDate
        self.rangeTime = startDate...endDate
    }
}


enum Weeks {
    case first
    case second
    case third
    
    var range: CountableClosedRange<Int> {
        switch self {
        case .first:   return 0...10
        case .second:  return 11...20
        case .third:   return 21...31
        }
    }
    
    init(_ day: Int) {
        switch (day) {
        case Weeks.first.range:   self = .first
        case Weeks.second.range:  self = .second
        case Weeks.third.range:   self = .third
        default: fatalError()
        }
    }
}


