//
//  CoinComparisionViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/16/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

protocol CoinComparisionViewControllerDelegate: AnyObject {
    func comparisionCoinSelected(_ coin: CoinModel?)
}

class CoinComparisionViewController: BaseViewController {
    
    // MARK: - Views
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var favoritesButton: BackgroundButton!
    
    // MARK: - Properties
    weak var delegate: CoinComparisionViewControllerDelegate?
    
    fileprivate var favoriteCoins: [CoinModel] = []
    fileprivate var selectedCoin: CoinModel?
    fileprivate var selectButton:UIBarButtonItem?
    fileprivate var indexForSelect:IndexPath? = .zero
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    
    override func languageChanged() {
        title = "choose_coin".localized()
        favoritesButton.setLocalizedTitle("coin_price_favorites")
    }
    override func configNoDataButton() {
        super.configNoDataButton()
            noDataButton!.setTransferButton(text: "You need to add something in favorites", subText: "", view: self.view)
            noDataButton!.addTarget(self, action: #selector(addFavorites), for: .touchUpInside)
    }
}

// MARK: - Startup
extension CoinComparisionViewController {
    fileprivate func startupSetup() {
        configTable()
        configButton()
        selectCoinRow()
    }
    
    fileprivate func configTable() {
        tableView.separatorColor = .separator
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    fileprivate func configButton() {
        favoritesButton.addTarget(self, action: #selector(addFavorites), for: .touchUpInside)
        favoritesButton.backgroundColor = .clear
        favoritesButton.setTitleColor(.barSelectedItem, for: .normal)
        favoritesButton.changeFontSize(to: 18)
        selectButton = UIBarButtonItem(title: "select".localized(), style: .done, target: self, action: #selector(chooseButtonAction))
        navigationItem.setRightBarButton(selectButton, animated: true)
        selectButton?.isEnabled = false
    }
    
    fileprivate func selectCoinRow() {
        if favoriteCoins.count == 0 {
            self.noDataButton?.isHidden = false
            return
        }
        self.noDataButton?.isHidden = true
        guard let coin = selectedCoin, let index = favoriteCoins.firstIndex(of: coin) else { return }
        
        let indexPath = IndexPath(row: index, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        tableView(tableView, didSelectRowAt: indexPath)
    }
    
    @objc private func addFavorites() {
        guard let controller = AddCoinAlertViewController.initializeStoryboard() else { return }
        
        controller.delegate = self
        controller.setFavoriteState(true, favoriteCoins: favoriteCoins)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc private func chooseButtonAction() {
        selectCoin(for: indexForSelect)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - TableView methods
extension CoinComparisionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteCoins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CheckmarkTableViewCell.name) as! CheckmarkTableViewCell
        let coin = favoriteCoins[indexPath.row]
        
        cell.setData(coin: coin, indexPath: indexPath, last: indexPath.row == favoriteCoins.count - 1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let cell = tableView.cellForRow(at: indexPath), cell.isSelected {
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.tableView(tableView, didDeselectRowAt: indexPath)
            return nil
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexForSelect = tableView.indexPathForSelectedRow
        selectButton?.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        indexForSelect = tableView.indexPathForSelectedRow
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    fileprivate func selectCoin(for indexPath: IndexPath?) {
        if let indexPath = indexPath {
            delegate?.comparisionCoinSelected(favoriteCoins[indexPath.row])
        } else {
            delegate?.comparisionCoinSelected(nil)
        }
    }
}

// MARK: - Set data
extension CoinComparisionViewController {
    public func setFavoriteCoins(coins: [CoinModel]) {
        self.favoriteCoins = coins
    }
    
    public func setSelecteCoin(_ coin: CoinModel?) {
        selectedCoin = coin
    }
}

// MARK: - Add Favorite
extension CoinComparisionViewController: AddCoinAlertViewControllerDelegate {
    func addFavorite(with favoriteCoin: CoinModel) {
        let param = ["favoriteCoin": favoriteCoin]
        NotificationCenter.default.post(name: .addFavorite, object: nil, userInfo: param)
        self.favoriteCoins.append(favoriteCoin)
        self.tableView.reloadData()
        self.selectCoinRow()
    }
}
