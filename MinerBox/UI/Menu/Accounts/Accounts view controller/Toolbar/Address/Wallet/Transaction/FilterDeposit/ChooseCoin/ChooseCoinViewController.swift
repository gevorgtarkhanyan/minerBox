//
//  ChooseCoinViewController.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 11.03.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit

@objc protocol ChooseCoinViewControllerDelegate: AnyObject {
    func selectedCoin(with selectedCoin: CoinModel)
}

class ChooseCoinViewController: BaseViewController {
    //MARK: - Properties

    @IBOutlet weak var chooseCoinLabel: BaseLabel!

    @IBOutlet weak var closeButton: BaseButton!
    
    @IBOutlet weak var coinTableView: BaseTableView!
    fileprivate var coins: [CoinModel] = []
    
    weak var delegate: ChooseCoinViewControllerDelegate?
    
    // MARK: - Static
    static func initializeStoryboard() -> ChooseCoinViewController? {
        return UIStoryboard(name: "Menu", bundle: nil).instantiateViewController(withIdentifier: ChooseCoinViewController.name) as? ChooseCoinViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chooseCoinLabel.setLocalizableText("choose_coin")
        self.closeButton.setLocalizedTitle("")
        closeButton.addTarget(self, action: #selector(tapGestureAction), for: .touchUpInside)
    }
    
    public func setDate(coins: [CoinModel]) {
        self.coins = coins
    }
    
    @objc fileprivate func tapGestureAction() {
        dismiss(animated: true) {
            NotificationCenter.default.removeObserver(self)
            self.view = nil
        }
    }
}

//MARK: - TableViewDelegate  -
extension ChooseCoinViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coins.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: CheckmarkTableViewCell.name) as! CheckmarkTableViewCell
        
        cell.setData(coin: coins[indexPath.row], indexPath: indexPath, last: indexPath.row == coins.count - 1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.selectedCoin(with: coins[indexPath.row])
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
}
