//
//  TodayViewController.swift
//  FVCoinWidget
//
//  Created by Vazgen Hovakinyan on 23.02.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit
import Foundation
import NotificationCenter
import RealmSwift
import Localize_Swift
import Alamofire


@available(iOS 10.0, *)
class FVCoinWidgetViewController: UIViewController, NCWidgetProviding {
    
    // MARK: - Views
    @IBOutlet fileprivate var FVwidgetTableView: UITableView!
    @IBOutlet fileprivate var FVCloadingIndicator: UIActivityIndicatorView!
    @IBOutlet fileprivate var FVCerrorButton: UIButton!
    
    // MARK: - Properties
    
    fileprivate var favoriteCoins = [FVCoinModel]()
    fileprivate var user: UserModel? {
        return DatabaseManager.shared.currentUser
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startupSetup()
        
        extensionContext?.widgetLargestAvailableDisplayMode = .compact
       
        FVCerrorButton.addTarget(self, action: #selector(FVCerrorButtonAction(_:)), for: .touchUpInside)
        
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        // Perform any setup necessary in order to update the view.
        
        Localize.setCurrentLanguage(UserDefaults(suiteName: "group.com.witplex.MinerBox")?.string(forKey: "appLanguage") ?? "en")
        self.checkUser()
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
       
        let height = self.favoriteCoins.count < 6 ? CGFloat(self.favoriteCoins.count) * FVCoinTableViewCell.height : 5  * FVCoinTableViewCell.height
        preferredContentSize = CGSize(width: maxSize.width, height: min(height, maxSize.height))
    }
    
}



// MARK: - Startup

@available(iOS 10.0, *)
extension FVCoinWidgetViewController {
    fileprivate func startupSetup() {
        self.FVwidgetTableView.delegate = self
        self.FVwidgetTableView.dataSource = self
        self.setupRealm()
        self.configTable()
    }
    
    fileprivate func configTable() {
        FVwidgetTableView.estimatedRowHeight = 150
        FVwidgetTableView.rowHeight = UITableView.automaticDimension
    }
}
// MARK: - Actions
@available(iOS 10.0, *)
extension FVCoinWidgetViewController {
    fileprivate func checkUser() {
        FVCerrorButton.setTitle("", for: .normal)
        hideTableView()
        guard self.user != nil else {
            FVCerrorButton.setTitle(Localized("login_login"), for: .normal)
            return
        }
        
        self.getInfo()
        
    }
    
    fileprivate func getInfo() {
        guard WidgetCointManager.shared.getCoinsIds().count != 0 else {
            FVCerrorButton.setTitle(Localized("please_check_acounts") , for: .normal)
            return
        }
        self.getFavoritesCoins()
    }
    
    fileprivate func getFavoritesCoins() {
        guard let user = DatabaseManager.shared.currentUser else { return }
        FVCloadingIndicator.startAnimating()
        let userId = user.id
        let endpoint = "v2/widget/\(userId)/info"
        
        let userEnabledCoinIds = WidgetCointManager.shared.getCoinsIds()
        
        let param = ["type": "1", "ids": userEnabledCoinIds.description ] as [String : Any]
        
        NetworkManager.shared.request(method: .post, endpoint: endpoint, params: param, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0, let jsonData = json["data"] as? NSDictionary,let result = jsonData["results"] as? [NSDictionary]  else {return}
            
            if let rates = jsonData["rates"] as? NSDictionary {
                UserDefaults.standard.setValue(rates, forKey: "\(self.user?.id ?? "" )/rates")
            }
            var receivedCoins = [FVCoinModel]()

            for dictionary in result {
                let cointObject = FVCoinModel(json: dictionary)
                receivedCoins.append(cointObject)
            }
            self.favoriteCoins = receivedCoins
            
            DispatchQueue.main.async {
                self.FVCloadingIndicator.stopAnimating()
                self.FVwidgetTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                self.updateWidgetHeight()
                self.showTableView()
            }
        }) { (error) in
            self.FVCloadingIndicator.stopAnimating()
            DispatchQueue.main.async {
                self.FVCerrorButton.setTitle(error, for: .normal)
                self.hideTableView()
            }
        }
    }
    
    fileprivate func updateWidgetHeight() {
          
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
 
        let cellHeight: CGFloat = 80
        let height = self.favoriteCoins.count < 6 ? CGFloat(self.favoriteCoins.count) * cellHeight : 5  * cellHeight
        preferredContentSize = CGSize(width: FVwidgetTableView.frame.width, height: height)
    }
    
    @objc fileprivate func FVCerrorButtonAction(_ sender: UIButton) {
        guard let title = sender.titleLabel?.text else { return }
        switch title {
        case Localized("login_login"):
            extensionContext?.open(URL(string:"minerbox://localhost/login")!,
                                   completionHandler: nil)
        case Localized("please_check_acounts"):
            extensionContext?.open(URL(string: "minerbox://localhost/coinwidget")!, completionHandler: nil)
        case Localized("need_subscription"):
            extensionContext?.open(URL(string: "minerbox://localhost/subscription")!, completionHandler: nil)
        default:
            self.checkUser()
        }
    }
}

// MARK: - TableView methods
@available(iOS 10.0, *)
extension FVCoinWidgetViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return FVCoinTableViewCell.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return favoriteCoins.count < 6 ? favoriteCoins.count : 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = FVwidgetTableView.dequeueReusableCell(withIdentifier: "FVCoinTableViewCell") as! FVCoinTableViewCell
        let item = favoriteCoins[indexPath.row]
        cell.setData(item: item, indexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coin = favoriteCoins[indexPath.row]
        WidgetCointManager.shared.addSelectedCoin(coin.coinId)
        extensionContext?.open(URL(string: "minerbox://localhost/coinprice")!, completionHandler: nil)
        
    }
    
}

// MARK: - Realm
@available(iOS 10.0, *)
extension FVCoinWidgetViewController {
    fileprivate func setupRealm() {
        DatabaseManager.shared.migrateRealm()
    }
}

// MARK: - Animations
@available(iOS 10.0, *)
extension FVCoinWidgetViewController {
    fileprivate func showTableView() {
        guard FVwidgetTableView.isHidden && FVCerrorButton.isHidden == false else { return }
        
        FVwidgetTableView.alpha = 0
        FVwidgetTableView.isHidden = false
        
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.FVwidgetTableView.alpha = 1
            self.FVCerrorButton.alpha = 0
        }) { (_) in
            self.FVCerrorButton.isHidden = true
        }
    }
    
    fileprivate func hideTableView() {
        guard FVwidgetTableView.isHidden == false && FVCerrorButton.isHidden else { return }
        
        FVCerrorButton.alpha = 0
        FVCerrorButton.isHidden = false
        
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.FVCerrorButton.alpha = 1
            self.FVwidgetTableView.alpha = 0
        }) { (_) in
            self.FVwidgetTableView.isHidden = true
        }
    }
}


