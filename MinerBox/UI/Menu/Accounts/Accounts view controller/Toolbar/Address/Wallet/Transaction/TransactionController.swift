//
//  TransactionPageController.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 01.03.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit

class TransactionController: BaseViewController {
    
    //MARK: - Properties
    @IBOutlet weak var statusesView: UIView!
    @IBOutlet weak var statusesCollectionView: BaseCollectionView!
    @IBOutlet weak var transactionTableView: BaseTableView!
    @IBOutlet weak var balanceTotalLabel: BaseLabel!
    @IBOutlet weak var convertorButton: ConverterButton!
    @IBOutlet weak var totalViewHeight: NSLayoutConstraint!
    private var filterButton: UIBarButtonItem!

    public var historyTypes: [String] = []
    public var walletId: String = ""
    
    fileprivate var viewModel: TransactionViewModel?
    
    // MARK: - Static
    static func initializeStoryboard() -> TransactionController? {
        return UIStoryboard(name: "Menu", bundle: nil).instantiateViewController(withIdentifier: TransactionController.name) as? TransactionController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViewModel()
        self.setupNavigation()
        self.configCollectionLayout()
    }
    
    override func languageChanged() {
        title  = "history".localized()
    }
    //MARK: - Setup
    private func setupViewModel() {
        self.viewModel = TransactionViewModel(walletId: walletId, historyType: historyTypes)
        self.viewModel?.delegate = self
        self.viewModel?.getTransactions()
    }
    
    func setupNavigation() {
        navigationController?.navigationBar.shadowImage = UIImage()
        
        filterButton = UIBarButtonItem.customButton(self, action: #selector(openFilterPopUp), imageName: "filter_icon", tag: 1, renderingMode: .alwaysOriginal)
        let buttons: [UIBarButtonItem] = [filterButton!]
        navigationItem.setRightBarButtonItems(buttons, animated: false)
    }
    
    func configCollectionLayout() {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.itemSize = CGSize(width: 114, height: 32)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        flowLayout.scrollDirection = .horizontal
        self.statusesCollectionView.collectionViewLayout = flowLayout
        self.statusesCollectionView.backgroundColor = .clear
    }
    
    func configViews() {
        
        if self.viewModel!.selectedDateTransactions.isEmpty {
          showNoDataLabel()
        } else {
          hideNoDataLabel()
        }
        
        self.transactionTableView.register(UINib(nibName: TransactionTableViewCell.name, bundle: nil), forCellReuseIdentifier: TransactionTableViewCell.name)
        self.transactionTableView.separatorColor = darkMode ? .viewDarkBackground : .viewLightBackground
        
//        if #available(iOS 15.0, *) {
//            transactionTableView.sectionHeaderTopPadding = 0
//        }
        
        filterButton = UIBarButtonItem.customButton(self, action: #selector(openFilterPopUp), imageName: self.viewModel!.selectedFiltredDetail == nil ? "filter_icon" : "filter_select_icon", tag: 1, renderingMode: .alwaysOriginal)
        let buttons: [UIBarButtonItem] = [filterButton!]
        navigationItem.setRightBarButtonItems(buttons, animated: false)
        
        guard self.viewModel?.selectedtotalBalance != nil else {
            self.totalViewHeight.constant = 0
            return
        }
        self.totalViewHeight.constant = 34
        self.balanceTotalLabel.text = "balance".localized() + ": "
        + self.viewModel!.selectedtotalBalance!.value!.getFormatedString() + " " +  self.viewModel!.selectedtotalBalance!.currency
        self.convertorButton.setData(self.viewModel!.selectedtotalBalance!.coinId, amount: self.viewModel!.selectedtotalBalance!.value)

    }
    
    @objc func openFilterPopUp(){
        guard let popVC = FilterTransactionViewController.initializeStoryboard() else { return }
        popVC.delegate = self
        popVC.setDate(_statuses: self.viewModel?.selectedStatus ?? [],filtredCoins: self.viewModel?.selectedFiltredCoins ?? [], filtredTransaction: self.viewModel?.selectedFiltredDetail)
        present(popVC, animated: true)
    }
}
 


//MARK: - TableViewDelegate  -
extension TransactionController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel?.selectedDateTransactions.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TransactionTableHeaderView.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = TransactionTableHeaderView(frame: .zero)
        let item = viewModel?.selectedDateTransactions[section]
        
        header.setData(startDate: item!.startDate!.getDateFromUnixTime(withoutTime: true), endDate: item!.endDate!.getDateFromUnixTime(withoutTime: true))
        
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.selectedDateTransactions[section].transactions.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.name) as? TransactionTableViewCell {
            
            cell.setDate(transaction:  (viewModel?.selectedDateTransactions[indexPath.section].transactions[indexPath.row])!)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TransactionTableViewCell.height
    }
    
}

//MARK: - UICollectionViewDelegate -

extension TransactionController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        historyTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "statusTrans", for: indexPath) as? StatusCollectionViewCell {
            cell.setDate(history: self.viewModel!.historyType[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.hideNoDataLabel()
        self.viewModel?.changeSelect(index: indexPath.row)
    }
}


//MARK: - Pagination
extension TransactionController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard let indexPathsForVisibleRows = self.transactionTableView.indexPathsForVisibleRows, !indexPathsForVisibleRows.isEmpty else { return }
            self.viewModel!.indexPathForVisibleRow = indexPathsForVisibleRows.first
        }
        
        let position = scrollView.contentOffset.y
        
        if position > transactionTableView.contentSize.height - scrollView.frame.size.height * 0.85 {
            if !viewModel!.isPaginating {
                viewModel?.isPaginating = true
                transactionTableView.tableFooterView = createIndicatorFooter()
                viewModel?.getTransactions(isPaginateCall: true)
            }
        }
    }
    
    private func createIndicatorFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        Loading.shared.startLoadingForView(with: footerView)
        return footerView
    }
}

//MARK: - FilterTransactionViewControllerDelegate -
extension TransactionController: FilterTransactionViewControllerDelegate {
    
    func setFilteredTransaction(filtredTranasaction: FiltredTransactionDetail?) {
        self.viewModel?.removeTransactions()
        self.viewModel?.getTransactions(isFilteredState: true, filtredDetail: filtredTranasaction)
    }
    
}

//MARK: - TransactionViewModelDelegate
extension TransactionController: TransactionViewModelDelegate {
    
    func startLoading() {
        Loading.shared.startLoading()
    }
    
    func endLoading() {
        Loading.shared.endLoading()
    }
 
    func reloadData() {
        transactionTableView.tableFooterView = nil
        transactionTableView.reloadData()
        statusesCollectionView.reloadData()
        configViews()
    }
    
    func requestFailed(with error: String) {
        transactionTableView.tableFooterView = nil
        showAlertView("", message: error, completion: nil)
    }
}
