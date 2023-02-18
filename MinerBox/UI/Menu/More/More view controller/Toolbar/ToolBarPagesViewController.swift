//
//  ToolBarPagesViewController.swift
//  MinerBox
//
//  Created by Gevorg Tarkhanyan on 04.05.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit

class ToolBarPagesViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let cellTypes = ToolbarTypeEnum.allCases
    private var toolBarItems = [String]()
    
    // MARK: - Static
    static func initializeStoryboard() -> ToolBarPagesViewController? {
        return UIStoryboard(name: "More", bundle: nil).instantiateViewController(withIdentifier: ToolBarPagesViewController.name) as? ToolBarPagesViewController
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
        
        
    }
    override func languageChanged() {
        title = MoreSettingsEnum.toolBarPages.rawValue.localized()
    }
    
    private func startupSetup() {
        tableView.separatorColor = .separator
        
    }
}

// MARK: - TableView methods
extension ToolBarPagesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MoreTableViewCell.name) as! MoreTableViewCell
        let isOn = toolBarItems.contains(cellTypes[indexPath.row].rawValue)
        cell.showSwitch(for: indexPath, isOn: isOn)
        cell.setData(title: cellTypes[indexPath.row].rawValue, indexPath: indexPath)
        cell.iconImageView.backgroundColor = .barSelectedItem
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = cellTypes[indexPath.row]
        let sb = UIStoryboard(name: "More", bundle: nil)
        
        switch item {
        case .converter:
            if let vc = sb.instantiateViewController(withIdentifier: "ConverterViewController") as? ConverterViewController {
                navigationController?.pushViewController(vc, animated: true)
            }
        case .wallet:
            guard let newVC = AddressViewController.initializeStoryboard() else { return }
            navigationController?.pushViewController(newVC, animated: true)
        case .income:
            guard let newVC = BalanceViewController.initializeStoryboard() else { return }
            navigationController?.pushViewController(newVC, animated: true)
        case .news:
            guard let newVC = NewsPageController.initializeStoryboard() else { return }
            navigationController?.pushViewController(newVC, animated: true)
        case .analytics:
            if let vc = sb.instantiateViewController(withIdentifier: "AnalyticsViewController") as? AnalyticsViewController {
                navigationController?.pushViewController(vc, animated: true)
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MoreTableViewCell.height
    }
    
    // MARK: - Helpers
}
enum ToolbarPagesTypeEnum: String, CaseIterable {
    case analytics = "more_analytics"
    case converter = "more_converter"
    case income = "income"
    case news = "news"
    case wallet = "more_wallet"
    
}
