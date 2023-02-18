//
//  AccountModel.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/29/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import MobileCoreServices

class AccountModel {
    
    var observe: (([PoolAccountModel]) -> Void)?
    
    private(set) var accounts: [PoolAccountModel] = [] {
        willSet {
            observe?(newValue)
        }
    }
    /// The traditional method for rearranging rows in a table view.
    func moveItem(at sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex else { return }

        let account = accounts[sourceIndex]
        accounts.remove(at: sourceIndex)
        accounts.insert(account, at: destinationIndex)
    }

    /// The method for adding a new item to the table view's data model.
    func addItem(_ account: PoolAccountModel, at index: Int) {
        accounts.insert(account, at: index)
    }
}

// MARK: Set data
extension AccountModel {
    func setAccounts(_ accounts: [PoolAccountModel]) {
        self.accounts = accounts
    }

    func remove(at index: Int) {
        self.accounts.remove(at: index)
    }
}

// MARK: - Dragging
@available(iOS 11.0, *)
extension AccountModel {
    /**
     A helper function that serves as an interface to the data model,
     called by the implementation of the `tableView(_ canHandle:)` method.
     */
    func canHandle(_ session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }

    /**
     A helper function that serves as an interface to the data mode, called
     by the `tableView(_:itemsForBeginning:at:)` method.
     */
//    func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
//        let account = accounts[indexPath.row]
//
//        let data = account.id.data(using: .utf8)
//        let itemProvider = NSItemProvider()
//
//        itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePlainText as String, visibility: .all) { completion in
//            completion(data, nil)
//            return nil
//        }
//
//        return [
//            UIDragItem(itemProvider: itemProvider)
//        ]
//    }
}

//MARK: - Helper
class TotalAccountValue {
    let name: String
    let hashrate: Double?
    let worker: Int?
    let hsUnit: String?
    
    init(name: String, hashrate: Double?, worker: Int?, hsUnit: String?) {
        self.name = name
        self.hashrate = hashrate
        self.worker = worker
        self.hsUnit = hsUnit
    }
}

