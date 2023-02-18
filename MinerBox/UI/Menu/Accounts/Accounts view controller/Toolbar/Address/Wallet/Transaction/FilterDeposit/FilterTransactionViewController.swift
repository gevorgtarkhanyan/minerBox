//
//  FilterDepositViewController.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 09.03.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit

protocol FilterTransactionViewControllerDelegate: AnyObject  {
    func setFilteredTransaction(filtredTranasaction: FiltredTransactionDetail?)
}

class FilterTransactionViewController: BaseViewController {
    
    //MARK: - Properties
    @IBOutlet fileprivate weak var dateFromView: DateSelectorView!
    @IBOutlet fileprivate weak var dateToView: DateSelectorView!
    
    @IBOutlet weak var conentView: BaseView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusCollectionView: BaseCollectionView!
    @IBOutlet weak var coinLabel: UILabel!
    @IBOutlet weak var currencyLabel: BaseLabel!
    @IBOutlet weak var coinNamelabel: BaseLabel!
    @IBOutlet weak var coinIconImage: BaseImageView!
    
    @IBOutlet weak var unselectCoinButton: UIButton!
    @IBOutlet weak var selectCoinView: BaseView!
    @IBOutlet weak var saveButton: BackgroundButton!
    @IBOutlet weak var addButton: BaseButton!
    @IBOutlet var clearButton: UIButton!
    
    public var statuses: [FilterStatus] = []
    private var filtredTransaction = FiltredTransactionDetail()
    private var filtredCoins: [CoinModel] = []
    private var indexPath:IndexPath = .zero
    weak var delegate: FilterTransactionViewControllerDelegate?

    // MARK: - Static
    static func initializeStoryboard() -> FilterTransactionViewController? {
        return UIStoryboard(name: "Menu", bundle: nil).instantiateViewController(withIdentifier: FilterTransactionViewController.name) as? FilterTransactionViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blackTransparented
        setupViews()
        configCollectionLayout()
        configDateFilters()
        addGestureRecognizers()
        setOldFilterOptionals(filtredTransaction: filtredTransaction)
    }
    
    fileprivate func setupViews(){
        self.conentView.roundCorners([.topLeft,.topRight], radius: 20)
        self.titleLabel.text = "Filter"
        self.titleLabel.textColor = .barSelectedItem
        self.coinLabel.text = "coin_sort_coin".localized()
        self.clearButton.setTitle("clear".localized(), for: .normal)
        self.saveButton.setTitle("save".localized(), for: .normal)
        self.saveButton.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        self.clearButton.addTarget(self, action: #selector(clearButtonAction), for: .touchUpInside)
        self.clearButton.setTitleColor(.barSelectedItem, for: .normal)
        if filtredTransaction.status == nil { self.filtredTransaction.status = "all".localized() }
        self.currencyLabel.text = "all".localized()
        self.unselectCoinButton.addTarget(self, action: #selector(unSelectCoin), for: .touchUpInside)
        self.unselectCoinButton.tintColor = darkMode ? .darkGray : .lightGray

    }
    
    func configCollectionLayout() {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.itemSize = CGSize(width: 107, height: 30)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        flowLayout.scrollDirection = .horizontal
        self.statusCollectionView.delegate = self
        self.statusCollectionView.dataSource = self
        self.statusCollectionView.collectionViewLayout = flowLayout
        self.statusCollectionView.backgroundColor = .clear
        self.statusCollectionView.reloadData()
    }
    
    fileprivate func configDateFilters() {
        dateToView.delegate = self
        dateToView.setPlaceholder("date_to")
        dateToView.setMaximumDate(date: Date())
        
        dateFromView.delegate = self
        dateFromView.setPlaceholder("date_from")
        dateFromView.setMaximumDate(date: Date())
    }
    
    fileprivate func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        let addCoin = UITapGestureRecognizer(target: self, action: #selector(goToAddWalletCoin))
        self.addButton.addTarget(self, action: #selector(goToAddWalletCoin), for: .touchUpInside)
        self.selectCoinView.addGestureRecognizer(addCoin)
        
    }
    
    public func setDate( _statuses: [String], filtredCoins: [CoinModel], filtredTransaction: FiltredTransactionDetail?){
        
        self.statuses = _statuses.map({FilterStatus(name: $0)})
        self.statuses.insert(FilterStatus(name: "all".localized()), at: 0)
        self.statuses.first!.isSelected = true
        self.filtredCoins = filtredCoins
        
        if let filtredTransaction = filtredTransaction {
            self.filtredTransaction = filtredTransaction
        }
    }
    
    func setOldFilterOptionals(filtredTransaction: FiltredTransactionDetail) {
        
        if let startDate = filtredTransaction.startDate {
            dateToView.setMinimumDate(date: Date(milliseconds: startDate ))
            dateFromView.setDate(date: Date(milliseconds: startDate ))
        }
        
        if let endDate = filtredTransaction.endDate {
            dateFromView.setMaximumDate(date: Date(milliseconds: endDate ))
            dateToView.setDate(date: Date(milliseconds: endDate ))

        }
        
        if let _status = filtredTransaction.status {
            for status in statuses {
                status.isSelected = status.name == _status
            }
        }
        
        if let coin = filtredTransaction.coin {
            self.currencyLabel.text = coin.symbol
            self.coinNamelabel.text = "(\(coin.name))"
            self.coinIconImage.sd_setImage(with: URL(string: Constants.HttpUrlWithoutApi + "images/coins/" + coin.icon), placeholderImage: UIImage(named: "empty_coin"))
            self.unselectCoinButton.isHidden = false
        }
    }
    
    @objc func tapGestureAction() {
        dismiss(animated: true, completion: nil)
    }
 
    @objc func goToAddWalletCoin() {
        guard let controller = ChooseCoinViewController.initializeStoryboard() else { return }
        guard !filtredCoins.isEmpty else { return }
        controller.delegate = self
        controller.setDate(coins: filtredCoins)
        present(controller, animated: true)
        
    }
    @objc func saveButtonAction() {
        
        if self.filtredTransaction.coin == nil && self.filtredTransaction.status == "all".localized() && self.filtredTransaction.startDate == nil && self.filtredTransaction.endDate == nil {
            self.delegate?.setFilteredTransaction(filtredTranasaction: nil)
        } else {
            self.delegate?.setFilteredTransaction(filtredTranasaction: self.filtredTransaction)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func clearButtonAction() {
        dateFromView.clearText()
        dateToView.clearText()
        dateClear(sender: dateToView)
        dateClear(sender: dateFromView)
        configDateFilters()
        for (index,status) in statuses.enumerated() {
            status.isSelected = index == indexPath.row 
        }
        self.filtredTransaction.status = statuses[indexPath.row ].name
        self.statusCollectionView.reloadData()
        unSelectCoin()
    }
    
    @objc func unSelectCoin() {
        self.currencyLabel.text = "all".localized()
        self.coinNamelabel.text = ""
        self.coinIconImage.sd_setImage(with: URL(string: "-"), placeholderImage: UIImage(named: "empty_coin"))
        self.filtredTransaction.coin = nil
        self.unselectCoinButton.isHidden = true
    }
    
}

//MARK: - UICollectionViewDelegate -

extension FilterTransactionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        statuses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterStatus", for: indexPath) as? FilterStatusCollectionViewCell {
            cell.setDate(statuses[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for (index,status) in statuses.enumerated() {
            status.isSelected = index == indexPath.row
        }
        self.filtredTransaction.status = statuses[indexPath.row].name
        self.statusCollectionView.reloadData()
    }
}


// MARK: - TapGesture delegate
extension FilterTransactionViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return gestureRecognizer.view == touch.view
    }
}

// MARK: - Date selector delegate
extension FilterTransactionViewController: DateSelectorViewDelegate {
    func dateSelected(sender: DateSelectorView, date: Date) {
        
        switch sender {
        case dateFromView:
            dateToView.setMinimumDate(date: date)
            self.filtredTransaction.startDate = date.timeIntervalSince1970
        case dateToView:
            dateFromView.setMaximumDate(date: date)
            self.filtredTransaction.endDate = date.timeIntervalSince1970
        default:
            break
        }
    }
    
    func dateClear(sender: DateSelectorView) {
        switch sender {
        case dateFromView:
            dateToView.setMinimumDate(date: nil)
            self.filtredTransaction.startDate = nil
        case dateToView:
            let date = Date()
            dateFromView.setMaximumDate(date: date)
            self.filtredTransaction.endDate = nil
        default:
            break
        }
    }
}

// MARK: - AddPoolTableViewCellDelegate -

extension FilterTransactionViewController: ChooseCoinViewControllerDelegate {
    
    func selectedCoin(with selectedCoin: CoinModel) {
        self.currencyLabel.text = selectedCoin.symbol
        self.coinNamelabel.text = "(\(selectedCoin.name))"
        self.coinIconImage.sd_setImage(with: URL(string: Constants.HttpUrlWithoutApi + "images/coins/" + selectedCoin.icon), placeholderImage: UIImage(named: "empty_coin"))
        self.filtredTransaction.coin = selectedCoin
        self.unselectCoinButton.isHidden = false
    }
}

//Helper
class FilterStatus {
    var name: String
    var isSelected: Bool = false
    
    init(name: String) {
        self.name = name
    }
}

class FiltredTransactionDetail {
    var status: String?
    var coin: CoinModel?
    var startDate: Double?
    var endDate: Double?
    
    init() {}
}
