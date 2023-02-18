//
//  ToolbarViewController.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 07.04.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

class ToolbarViewController: BaseViewController {

    @IBOutlet fileprivate weak var tableView: UITableView!
    
    private let cellTypes = ToolbarTypeEnum.allCases
    private var toolBarItems = [String]()

    // MARK: - Static
    static func initializeStoryboard() -> ToolbarViewController? {
        return UIStoryboard(name: "More", bundle: nil).instantiateViewController(withIdentifier: ToolbarViewController.name) as? ToolbarViewController
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
    }

    override func languageChanged() {
        title = MoreSettingsEnum.toolBar.rawValue.localized()
    }
    
    private func startupSetup() {
        tableView.separatorColor = .separator
        getPageState()
    }
    
}

// MARK: - TableView methods
extension ToolbarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTypes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MoreTableViewCell.name) as! MoreTableViewCell
        let isOn = toolBarItems.contains(cellTypes[indexPath.row].rawValue)
        cell.showSwitch(for: indexPath, isOn: isOn)
        cell.setData(title: cellTypes[indexPath.row].rawValue, indexPath: indexPath)
        cell.delegate = self
        cell.iconImageView.backgroundColor = .barSelectedItem
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MoreTableViewCell.height
    }
    
}

// MARK: - TableView methods
extension ToolbarViewController: MoreTableViewCellDelegate {
    func switchTapped(indexPath: IndexPath, sender: BaseSwitch) {
        if sender.isOn {
            toolBarItems.append(cellTypes[indexPath.row].rawValue)
        } else {
            toolBarItems.removeAll { $0 == cellTypes[indexPath.row].rawValue }
        }
        savePageState()
    }
}

//MARK: -- Page State
extension ToolbarViewController {
    private func savePageState() {
        guard let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") else { return }
        
        if let userId = self.user?.id {
            userDefaults.set(toolBarItems, forKey: "\(userId)toolBarItems")
        } else {
            userDefaults.set(toolBarItems, forKey: "toolBarItems")
        }
        NotificationCenter.default.post(name: .reloadTabBarItems, object: nil)
    }
    
    private func getPageState() {
        guard let userDefaults = UserDefaults(suiteName: "group.com.witplex.MinerBox") else { return }
        
        let userId = user != nil ? user!.id : ""
        if let toolBarItems = userDefaults.array(forKey: "\(userId)toolBarItems") as? [String] {
            self.toolBarItems = toolBarItems
        } else {
            toolBarItems = cellTypes.map { $0.rawValue }
        }
    }
}

// MARK: - Helpers
enum ToolbarTypeEnum: String, CaseIterable {
    case analytics = "more_analytics"
    case converter = "more_converter"
    case income = "income"
    case news = "news"
    case wallet = "more_wallet"
}
