//
//  CoinDetailsViewController.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/31/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class CoinDetailsViewController: BaseViewController {
    
    @IBOutlet weak var coinDetailsTableView: BaseTableView!
    
    public var coinDetailsData: CoinTableViewDataModel?
    public var coinData: [CoinDetailsDataModel] = []
    public var currentCoin: CoinModel?
    public var coinID: String?
    public var indexPath: IndexPath?
    public var defaultsData: MiningDefaultsModel?
    public var revenue: CoinDetailsDataModel?
    public var profit: CoinDetailsDataModel?
    public var coinModel: MiningCoinsModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupTableView()
    }
    
    override func languageChanged() {
        title = "coin_details".localized()
    }
    
    func setupTableView() {
        coinDetailsTableView.register(UINib(nibName: "CoinDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "coinDetailsCell")
        coinDetailsTableView.layer.cornerRadius = CGFloat(10)
        
        let footerView = CustomFooterView(frame: .zero)
        coinDetailsTableView.tableFooterView = footerView
        coinDetailsTableView.tableFooterView?.frame.size.height = CustomFooterView.height
    }
    
    func setupData() {
        if let model = coinModel {
            let detailsData = CoinDetailsDataSource.shared.coinDetailsData(model)
            coinData += detailsData
            if let revenue = revenue, let profit = profit {
                coinData.append(revenue)
                coinData.append(profit)
            }
        }
    }
}

extension CoinDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "coinDetailsCell", for: indexPath) as? CoinDetailsTableViewCell {
            cell.setupCell(coinData, for: indexPath)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = CoinDetailsHeaderView(frame: .zero)
        if let data = coinDetailsData {
            headerView.setupHeader(data)
        }
            if coinID != nil {
                headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headerTapped)))
            } else {
                headerView.ToRightImageView.isHidden = true
                headerView.isMultipleTouchEnabled = false
            }
        return headerView
    }
    
    @objc func headerTapped() {
        let sb = UIStoryboard(name: "CoinPrice", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "CoinChartViewController") as! CoinChartViewController
        if coinID != nil {
            vc.setCoinId(coinID ?? "")
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CoinDetailsHeaderView.height
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CoinDetailsTableViewCell.height
    }
}
