//
//  TotalHashrate.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 22.11.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

class TotalHashrateView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var tableView: BaseTableView!
    
    private var totalAccountValues = [TotalAccountValue]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("TotalHashrateView", owner: self, options: nil)
        addSubview(contentView)
        backgroundColor = .clear
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        initialSetup()
    }
    
    private func initialSetup() {
        initTableView()
    }
    
    private func initTableView() {
        tableView.register(UINib(nibName: TotalHashrateTableViewCell.name, bundle: nil), forCellReuseIdentifier: TotalHashrateTableViewCell.name)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
    }
    
    public func setData(_ data: [TotalAccountValue]) {
        totalAccountValues = data
        tableView.reloadData()
    }
    
}

extension TotalHashrateView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalAccountValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TotalHashrateTableViewCell.name) as? TotalHashrateTableViewCell else { return UITableViewCell() }
        
        cell.setData(totalAccountValues[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TotalHashrateTableViewCell.height
    }
    
}
