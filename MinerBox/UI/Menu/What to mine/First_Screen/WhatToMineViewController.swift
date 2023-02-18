//
//  WhatToMineViewController.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/31/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

protocol WhatToMineViewControllerDelegate: AnyObject {
    func getCurrentDefaultsData(_ data: MiningDefaultsModel, for type: AlgorithmType?,_ isSettging:Bool)
    func nothingChanged()
    func getLocalSelectedValue( models: [SelectedModel]?,algosGPU: [SelectedAlgos]?,algosASIC: [SelectedAlgos]?)
}

class WhatToMineViewController: BaseViewController {
    
    @IBOutlet weak var coinsTableView: BaseTableView!
    @IBOutlet weak var modelAlgorithmTableView: BaseTableView!
    @IBOutlet weak var modelAlgorithmTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var arrowButton: BackgroundButton!
    @IBOutlet weak var arrowButtonParentView: UIView!
    @IBOutlet var borderBottomViews: [UIView]!
    @IBOutlet weak var mainDataHeaderView: UIView!
    @IBOutlet weak var mainDataHeaderViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lastUpdatedKeyLabel: BaseLabel!
    @IBOutlet weak var lastUpdatedValueLabel: BaseLabel!
    
    @IBOutlet weak var difficultyKeyLabel: BaseLabel!
    @IBOutlet weak var difficultyValueLabel: BaseLabel!
    
    @IBOutlet weak var electricityCostLabbel: BaseLabel!
    @IBOutlet weak var electricityCostVauleLabbel: BaseLabel!
    
    @IBOutlet weak var typeLabbel: BaseLabel!
    @IBOutlet weak var typeValueLabbel: BaseLabel!
    
    @IBOutlet weak var searchBar: BaseSearchBar!
    private var searchButton: UIBarButtonItem!
    @IBOutlet weak var searchButtonHeightConstraits: NSLayoutConstraint!
    private var searchText = ""
    
    @IBOutlet weak var coinDataHeaderView: UIView!
    @IBOutlet weak var revenueButton: UIButton!
    @IBOutlet weak var profitButton: UIButton!
    @IBOutlet weak var profitArrowButton: UIButton!
    @IBOutlet var revenueArrowButton: UIButton!
    @IBOutlet weak var coinLabel: BaseLabel!
    @IBOutlet weak var algorithmLabel: BaseLabel!
    @IBOutlet weak var dayLabel: BaseLabel!
    @IBOutlet weak var usdLabel: BaseLabel!
    @IBOutlet var USDProfit: BaseLabel!
    @IBOutlet var dayProfit: BaseLabel!
    
    @IBOutlet weak var mainDataViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainDataSubViewsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var adsViewForWhatToMine = AdsView()
    private var adsManager = AdsManager.shared
    private var isAdsCome = false
    
    private let animDuration: TimeInterval = 0.3
    private var maxTransformScale: CGFloat = 1.2
    private var cachedConstraint: CGFloat?
    private var mainDataHeaderHeight: CGFloat?
    private var electricityCost: Double?
    private var settingsItem: UIBarButtonItem!
    private var calculateItem: UIBarButtonItem!
    private var isExpanded = false
    private var profitArrowTapped = false
    private var isTappedRevenue = true
    private var isSelectedModel = false
    private var currentDifficulty: String?
    private var mainAlgorithmData: ModelAlgorithmDataModel?
    private var filteredCoinData: [CoinTableViewDataModel] = [] {
        didSet {
            if filteredCoinData.count == 0 {
                showNoDataLabel()
            } else {
                hideNoDataLabel()
            }
        }
    }
    private var filteredAlgorithmData: [ModelAlgorithmDataModel] = []
    private var refreshControl: UIRefreshControl?
    private var isSelectedAlgorithm = false
    var coinData: [CoinTableViewDataModel] = []
    var algosData: [CalculatedAlgos] = []
    var modelsData: [CalculatedModels] = []
    var settingsDefaultsData: MiningDefaultsModel?
    var defaultAlgorithmType: AlgorithmType?
    var footerViewForCoins: CustomFooterView?
    var shapeLayer: CAShapeLayer?
    
    private var selectedModels: [SelectedModel] = []
    private var selectedlgosGPU: [SelectedAlgos] = []
    private var selectedAlgosASIC: [SelectedAlgos] = []
//    private let viewForMask = BaseView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        getSettingsData()
        setupNavigation()
        setupTableView()
        addArrowLayer(with: arrowButtonParentView.frame.size.height)
        addRefreshControl()
        addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupData()
        createTextTranslations()
        setupColoringForDarkLightMode()
        checkUserForAds()
        let size: CGSize = UIScreen.main.bounds.size
        if size.width / size.height > 1 {
            scrollView.isScrollEnabled = true
            mainDataSubViewsHeightConstraint?.constant = 15
            mainDataViewHeightConstraint?.constant = 90
        } else {
                self.scrollView.scrollToTop()
                self.scrollView.isScrollEnabled = false
            mainDataSubViewsHeightConstraint?.constant = 25
            mainDataViewHeightConstraint?.constant = 130
            }
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coinsTableView?.setEditing(false, animated: false)
        modelAlgorithmTableView?.setEditing(false, animated: false)
        coinsTableView?.reloadData()
        modelAlgorithmTableView?.reloadData()
        let size: CGSize = UIScreen.main.bounds.size
        if size.width / size.height > 1 {
            scrollView?.isScrollEnabled = true
            mainDataSubViewsHeightConstraint?.constant = 15
            mainDataViewHeightConstraint?.constant = 90
        } else {
                self.scrollView?.scrollToTop()
                self.scrollView?.isScrollEnabled = false
            mainDataViewHeightConstraint?.constant = 130
            mainDataSubViewsHeightConstraint?.constant = 25
            }
    }
//    override func hideKeyboard() {
//        super.hideKeyboard()
//        self.viewForMask.removeFromSuperview()
//    }
    
    // MARK: - Static
    static func initializeStoryboard() -> WhatToMineViewController? {
        return UIStoryboard(name: "Menu", bundle: nil).instantiateViewController(withIdentifier: WhatToMineViewController.name) as? WhatToMineViewController
    }
    
    //MARK: -- Observers code part
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(hideAds), name: .hideAdsForSubscribeUsers, object: nil)
    }
    
    private func setupTableView() {
        let footerViewForAlgos = CustomFooterView(frame: .zero)
        
        modelAlgorithmTableView.register(UINib(nibName: "ModelAlgorithmTableViewCell", bundle: nil), forCellReuseIdentifier: "selectedDataCell")
        modelAlgorithmTableView.tableFooterView = footerViewForAlgos
        modelAlgorithmTableView.tableFooterView?.frame.size.height = CustomFooterView.height
        modelAlgorithmTableView.roundCorners([.bottomLeft, .bottomRight], radius: 10)
        modelAlgorithmTableView.backgroundColor = darkMode ? .viewDarkBackground : .viewLightBackground
        footerViewForCoins = CustomFooterView(frame: .zero)
        coinsTableView.register(UINib(nibName: "CoinTableViewCell", bundle: nil), forCellReuseIdentifier: "coinCell")
        coinsTableView.tableFooterView = footerViewForCoins
        coinsTableView.tableFooterView?.frame.size.height = CustomFooterView.height
        coinsTableView.roundCorners([.bottomLeft, .bottomRight], radius: 10)
        coinsTableView.register(AdsTableViewCell.self, forCellReuseIdentifier: AdsTableViewCell.name)
        
        
        if let footerView = footerViewForCoins {
            if settingsDefaultsData == nil {
                footerView.isHidden = true
            } else {
                footerView.isHidden = false
            }
        }
    }
    
    private func setupNavigation() {
        settingsItem = UIBarButtonItem(image: UIImage(named: "coin_graph_settings")?.withRenderingMode(.alwaysTemplate), style: .done, target: self, action: #selector(settingsTapped))
        searchButton = UIBarButtonItem.customButton(self, action: #selector(searchButtonAction(_:)), imageName: "bar_search")
        calculateItem =  UIBarButtonItem(image: UIImage(named: "navi_reload"),style: .done, target: self, action:  #selector(calculateTapped))
        if DatabaseManager.shared.currentUser != nil {
            navigationItem.setRightBarButtonItems([settingsItem,searchButton,calculateItem], animated: true)
        } else {
            navigationItem.setRightBarButtonItems([settingsItem,searchButton], animated: false)
        }
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func initialSetup() {
        for view in borderBottomViews {
            view.backgroundColor = .separator
        }
        mainDataHeaderView.roundCorners([.topLeft, .topRight], radius: 10)
        coinDataHeaderView.roundCorners([.topLeft, .topRight], radius: 10)
        coinDataHeaderView.backgroundColor = darkMode ? .viewDarkBackground : .sectionHeaderLight
        revenueButton.transform = CGAffineTransform(scaleX: maxTransformScale, y: maxTransformScale)
        revenueButton.setTitleColor(.cellTrailingFirst, for: .normal)
        cachedConstraint = mainDataHeaderViewTopConstraint.constant
        coinDataHeaderView.isHidden = true
        mainDataHeaderView.isHidden = true

        arrowButtonParentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(algorithmArrowButtonTapped)))
    }
    
    private func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshCoins), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            coinsTableView.refreshControl = refreshControl
        } else {
            coinsTableView.backgroundView = refreshControl
        }
    }
    
    @objc private func refreshCoins() {
        Loading.shared.startLoading(ignoringActions: true, for: view)
        WhatToMineRequestService.shared.getMiningDefaultsData(success: { (model) in
            self.settingsDefaultsData = model
            self.setupData()
            if let footerView = self.footerViewForCoins {
                footerView.isHidden = false
            }
            self.refreshControl?.endRefreshing()
            Loading.shared.endLoading(for: self.view)
        }) { (error) in
            Loading.shared.endLoading(for: self.view)
            self.refreshControl?.endRefreshing()
            self.showAlertView("", message: error.localized(), completion: nil)
            debugPrint(error)
        }
    }
    
    @objc public func refreshPage(_ sender: Any?) {
        refreshCoins()
        setupTableView()
    }
    
    private func setupColoringForDarkLightMode() {
        revenueButton.backgroundColor = .clear
        profitButton.backgroundColor = .clear
        arrowButton.backgroundColor = .clear
        profitArrowButton.backgroundColor = .clear
        revenueArrowButton.backgroundColor = .clear
        
        if darkMode {
            revenueButton.setTitleColor(.white, for: .normal)
            profitButton.setTitleColor(.white, for: .normal)
            profitArrowButton.setImage(UIImage(named: "arrow_down"), for: .normal)
            revenueArrowButton.setImage(UIImage(named: "arrow_down"), for: .normal)
            arrowButton.setImage(UIImage(named: "arrow_down"), for: .normal)
        } else {
            revenueButton.setTitleColor(.black, for: .normal)
            profitButton.setTitleColor(.black, for: .normal)
            profitArrowButton.setImage(UIImage(named: "arrow_down")?.withRenderingMode(.alwaysTemplate), for: .normal)
            revenueArrowButton.setImage(UIImage(named: "arrow_down")?.withRenderingMode(.alwaysTemplate), for: .normal)
            arrowButton.setImage(UIImage(named: "arrow_down")?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        if profitButton.transform ==  CGAffineTransform(scaleX: maxTransformScale, y: maxTransformScale) {
            profitButton.setTitleColor(.cellTrailingFirst, for: .normal)
        } else if revenueButton.transform == CGAffineTransform(scaleX: maxTransformScale, y: maxTransformScale) {
            revenueButton.setTitleColor(.cellTrailingFirst, for: .normal)
        }
    }
    
    private func getSettingsData() {
        Loading.shared.startLoading(ignoringActions: true, for: view)
        WhatToMineRequestService.shared.getMiningDefaultsData(success: { (model) in
            self.settingsDefaultsData = model
            self.setupData()
            if let footerView = self.footerViewForCoins {
                footerView.isHidden = false
                self.modelAlgorithmTableView.isHidden = false
            }
            Loading.shared.endLoading(for: self.view)
        }) { (error) in
            Loading.shared.endLoading(for: self.view)
            self.showAlertView("", message: error.localized(), completion: nil)
            debugPrint(error)
        }
    }
    
    private func addArrowLayer(with height: CGFloat) {
        let arrowPath = UIBezierPath()
        arrowPath.move(to: CGPoint(x: 0, y: height))
        arrowPath.addCurve(to: CGPoint(x: height, y: height), controlPoint1: CGPoint(x: height / 5, y: height / 3), controlPoint2: CGPoint(x: 4 * (height / 5), y: height / 3))
        arrowPath.close()
        let arrowLayer = CAShapeLayer()
        arrowLayer.fillColor = UIColor.tableCellBackground.cgColor
        arrowLayer.path = arrowPath.cgPath
        arrowButtonParentView.layer.addSublayer(arrowLayer)
    }
    
    private func setupData() {
        if let data = settingsDefaultsData {//must be modified
            coinData = CoinTableViewDataSource.shared.coinTableDefaultDataForUser(data)
            filteredCoinData = coinData
            getCurrentDefaultsData(data, for: defaultAlgorithmType)
            coinDataHeaderView.isHidden = false
            mainDataHeaderView.isHidden = false
            modelAlgorithmTableView.reloadData()
            cheeckSearchCoins()
            sortSendingCoinData()
        }
    }
    
    private func createTextTranslations() {
        difficultyKeyLabel.text = "difficulty".localized()
        lastUpdatedKeyLabel.text = "last_updated".localized()
        electricityCostLabbel.text = "electricityCost".localized()
        typeLabbel.text = "type".localized()
        algorithmLabel.text = "algorithm".localized()
        dayLabel.text = "day".localized()
        dayProfit.text = "day".localized()
        usdLabel.text = "\(Locale.appCurrency)/"
        USDProfit.text = "\(Locale.appCurrency)/"
        coinLabel.text = "coin_sort_coin".localized()
        revenueButton.setTitle("revenue".localized(), for: .normal)
        profitButton.setTitle("profit".localized(), for: .normal)
        if let data = settingsDefaultsData {
            if let date = data.updatedDate {
                lastUpdatedValueLabel.text = Double(date.timeIntervalSince1970).getDateFromUnixTime()
            }
            if let miningData = data.miningCalculation {
                difficultyValueLabel.text = miningData.difficulty?.lowercased().localized()
                electricityCostVauleLabbel.text = "\(miningData.cost?.getString() ?? "") \(Locale.appCurrency)/kWh"
                
            }
            coinsTableView.reloadData()
        }
    }
    
    override func languageChanged() {
        title = "what_to_mine".localized()
    }
    
    @objc func calculateTapped() {
        if DatabaseManager.shared.currentUser != nil {
            Loading.shared.startLoading(ignoringActions: true, for: view)
            let userId = user!.id
            
            var cost: Double {
                if let num = electricityCostVauleLabbel.text?.toDouble() {//Double(electrisityValueTextField.text!) {
                    return num
                }
                return 0
            }
            
            var isByModel: Bool {
                if isSelectedAlgorithm || defaultAlgorithmType == .ASIC {
                    return false
                }
                return true
            }
            
            
            if isByModel {
                if selectedModels.count != 0 {
                    
                        WhatToMineRequestService.shared.calculateSettingsData(success: { (currentDefaultsData) in
                            self.getCurrentDefaultsData(currentDefaultsData, for: .GPU, true)
                            Loading.shared.endLoading(for: self.view)
                        }, calculatedData: MiningCalculationModel(userId: userId, isByModel: true, algos: selectedlgosGPU, models: selectedModels, cost: cost, difficulty: difficultyValueLabel?.text ?? "24h"))
                    
                } else {
                    nothingChanged()
                    Loading.shared.endLoading(for: self.view)
                }
            } else {
                if defaultAlgorithmType == .GPU {
                    if selectedlgosGPU.count != 0 {
                        
                            WhatToMineRequestService.shared.calculateSettingsData(success: { (currentDefaultsData) in
                                self.getCurrentDefaultsData(currentDefaultsData, for: .GPU, true)
                                Loading.shared.endLoading(for: self.view)
                            }, calculatedData: MiningCalculationModel(userId: userId, isByModel: false, algos: selectedAlgosASIC, models: selectedModels, cost: cost, difficulty: difficultyValueLabel?.text ?? "24h"))
                        
                    } else {
                        nothingChanged()
                        Loading.shared.endLoading(for: self.view)
                    }
                } else {
                    if selectedAlgosASIC.count != 0 {
                        
                            WhatToMineRequestService.shared.calculateSettingsData(success: { (currentDefaultsData) in
                                self.getCurrentDefaultsData(currentDefaultsData, for: .ASIC, true)
                                Loading.shared.endLoading(for: self.view)
                            }, calculatedData: MiningCalculationModel(userId: userId, isByModel: false, algos: selectedAlgosASIC, models: selectedModels, cost: cost, difficulty: difficultyValueLabel?.text ?? "24h"))
                        
                    } else {
                        nothingChanged()
                        Loading.shared.endLoading(for: self.view)
                    }
                }
            }
        } else {
            navigationItem.setRightBarButtonItems([settingsItem,searchButton], animated: false)
        }
    }

    @objc func settingsTapped() {
        if isExpanded {
            hideAlgorithmData()
        }
        let sb = UIStoryboard(name: "Menu", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "WhatToMineSettingsViewController") as! WhatToMineSettingsViewController
        vc.delegate = self
        if let data = settingsDefaultsData {
            vc.changedSettingsModel = data
        }
        if let type = defaultAlgorithmType {
            vc.defaultAlgorithmType = type
        }
        vc.isSelectedAlgorithm = self.isSelectedAlgorithm
        vc.setLocalSelectedValues(models: self.selectedModels, algosGPU: self.selectedlgosGPU, algosASIC: self.selectedAlgosASIC)
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func algorithmArrowButtonTapped() {
        if !isExpanded {
            showAlgorithmData()
        } else {
            hideAlgorithmData()
        }
    }
    
    @IBAction func profitArrowButtonTapped() {
        hideKeyboard()
        animateArrow(forward: !profitArrowTapped, for: profitArrowButton)
        sortCoinData()
    }
    
    @IBAction func revenueArrowButtonTapped(_ sender: Any) {
        hideKeyboard()
        animateArrow(forward: !profitArrowTapped, for: revenueArrowButton)
        sortCoinData()
    }
    
    private func sortCoinData() {
        if profitArrowTapped {
            if isTappedRevenue {
                filteredCoinData = filteredCoinData.sorted(by: { (item1, item2) -> Bool in
                    return item1.revenue > item2.revenue
                })
            } else {
                filteredCoinData = filteredCoinData.sorted(by: { (item1, item2) -> Bool in
                    return item1.profit > item2.profit
                })
            }
            
            profitArrowTapped = false
        } else {
            if isTappedRevenue {
                filteredCoinData = filteredCoinData.sorted(by: { (item1, item2) -> Bool in
                    return item1.revenue < item2.revenue
                })
            } else {
                filteredCoinData = filteredCoinData.sorted(by: { (item1, item2) -> Bool in
                    return item1.profit < item2.profit
                })
            }
            
            profitArrowTapped = true
        }
        coinsTableView.reloadData()
    }
    private func sortSendingCoinData() {
        
        if profitArrowTapped == true {
            animateArrow(forward: false, for: profitArrowButton)
            animateArrow(forward: false, for: revenueArrowButton)
            profitArrowTapped = false
        }
        if isTappedRevenue {
            filteredCoinData = filteredCoinData.sorted(by: { (item1, item2) -> Bool in
                return item1.revenue > item2.revenue
            })
        } else {
            filteredCoinData = filteredCoinData.sorted(by: { (item1, item2) -> Bool in
                return item1.profit > item2.profit
            })
        }
        coinsTableView.reloadData()
    }
    
    @IBAction func revenueButtonTapped() {
        if !isTappedRevenue {
            animate(revenueButton, stop: profitButton)
            isTappedRevenue = true
            sortSendingCoinData()
        }
        revenueArrowButton.isHidden = false
        profitArrowButton.isHidden = true
    }
    
    
    @IBAction func profitButtonTapped() {
        if isTappedRevenue {
            animate(profitButton, stop: revenueButton)
            isTappedRevenue = false
            sortSendingCoinData()
        }
        revenueArrowButton.isHidden = true
        profitArrowButton.isHidden = false
    }
    
    private func animate(_ button: UIButton, stop animButton: UIButton) {
        UIView.animate(withDuration: 0.2) {
            animButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            if self.darkMode {
                animButton.setTitleColor(.white, for: .normal)
            } else {
                animButton.setTitleColor(.black, for: .normal)
            }
        }
        UIView.animate(withDuration: 0.2) {
            button.transform = CGAffineTransform(scaleX: self.maxTransformScale, y: self.maxTransformScale)
            button.setTitleColor(.cellTrailingFirst, for: .normal)
        }
    }
    
    private func animateArrow(forward: Bool, for button: UIButton) {
        let rotationAnim = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnim.fromValue = forward ? 0.0 : CGFloat.pi
        rotationAnim.toValue = forward ? CGFloat.pi : 0.0
        rotationAnim.fillMode = .forwards
        rotationAnim.isRemovedOnCompletion = false
        rotationAnim.timingFunction = CAMediaTimingFunction(name: .easeIn)
        rotationAnim.duration = animDuration
        button.layer.add(rotationAnim, forKey: nil)
    }
    //MARK: -- Show or hide data
    
    private func showAlgorithmData() {
        var currentHeight: CGFloat {
            if isSelectedModel {
                return CGFloat(modelsData.count) * ModelAlgorithmTableViewCell.height
            } else {
                return CGFloat(algosData.count) * ModelAlgorithmTableViewCell.height
            }
        }
        
        modelAlgorithmTableViewHeightConstraint.constant = currentHeight
        
        animateArrow(forward: true, for: arrowButton)
        
        UIView.animate(withDuration: animDuration, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            self.isExpanded = true
        }
    }
    
    private func hideAlgorithmData() {
        self.modelAlgorithmTableViewHeightConstraint.constant = ModelAlgorithmTableViewCell.height
        animateArrow(forward: false, for: arrowButton)
        UIView.animate(withDuration: animDuration, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            self.isExpanded = false
            self.view.layoutIfNeeded()
        }
    }
    
    private func isArrowButtonHidden(_ bool: Bool) {
        arrowButtonParentView.isHidden = bool
    }
    //MARK: - Search Bar Methods -
    
    @objc private func searchButtonAction(_ sender: UIBarButtonItem) {
        showSearchBar()
    }
    private func showSearchBar() {
        if searchBar.isHidden {
            searchBar.isHidden = false
            if DatabaseManager.shared.currentUser != nil {
                navigationItem.setRightBarButtonItems([settingsItem,calculateItem], animated: true)
            } else {
                navigationItem.setRightBarButtonItems([settingsItem], animated: false)
            }
            
            
            UIView.animate(withDuration: Constants.animationDuration) {
                self.searchButtonHeightConstraits.constant = 60
                self.searchBar.becomeFirstResponder()
                self.view.layoutIfNeeded()
            }
        }
    }
    private func hideSearchBar() {
        if !searchBar.isHidden {
            searchBar.text = ""
            self.searchText = ""
            view.endEditing(true)
            if DatabaseManager.shared.currentUser != nil {
                self.navigationItem.setRightBarButtonItems([settingsItem,searchButton,calculateItem], animated: false)
            } else {
                navigationItem.setRightBarButtonItems([settingsItem,searchButton], animated: false)
            }
            
            UIView.animate(withDuration: Constants.animationDuration, animations: {
                self.searchButtonHeightConstraits.constant = 0
                self.view.layoutIfNeeded()
            }) { (_) in
                self.searchBar.isHidden = true
                self.filteredCoinData = self.coinData
                self.coinsTableView.reloadData()
            }
        }
    }
    
    //MARK: --Keyboard frame changes
    override func keyboardWillShow(_ sender: Notification) {
        super.keyboardWillShow(sender)
        if let keyboardHeight = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            mainDataHeaderHeight = mainDataHeaderView.frame.height
            if let height = mainDataHeaderHeight {
                if height + keyboardHeight > view.frame.height - 100 {
                    mainDataHeaderViewTopConstraint.constant = -height
                }
            }
            self.coinsTableView.contentInset.bottom = keyboardHeight - self.tabBarHeight
            view.layoutIfNeeded()
        }
    }
    
    override func keyboardWillHide(_ sender: Notification) {
        super.keyboardWillHide(sender)
        if let constraint = self.cachedConstraint {
            self.mainDataHeaderViewTopConstraint.constant = constraint
        } else {
            self.mainDataHeaderViewTopConstraint.constant = 5
        }
        coinsTableView.contentInset.bottom = 8
        view.layoutIfNeeded()
    }
    
}
//MARK: - WhatToMineViewControllerDelegate -

extension WhatToMineViewController: WhatToMineViewControllerDelegate {
    func getLocalSelectedValue(models: [SelectedModel]?, algosGPU: [SelectedAlgos]?, algosASIC: [SelectedAlgos]?) {
        
        if let models = models {
            self.selectedModels = models
        }
        if let algosGPU = algosGPU {
            self.selectedlgosGPU = algosGPU
        }
        if let algosASIC = algosASIC {
            self.selectedAlgosASIC = algosASIC
        }
    }
    
    func getCurrentDefaultsData(_ data: MiningDefaultsModel, for type: AlgorithmType?,_ isSettging: Bool = false) {
        selectedModels = []
        selectedlgosGPU = []
        selectedAlgosASIC = []
        settingsDefaultsData = data
        defaultAlgorithmType = type
        if isSettging { self.hideSearchBar()}
        
        if let date = data.updatedDate {
            lastUpdatedValueLabel.text = Double(date.timeIntervalSince1970).getDateFromUnixTime()
        }
        
        
        if let miningData = data.miningCalculation {
            difficultyValueLabel.text = miningData.difficulty?.lowercased().localized()
            currentDifficulty = miningData.difficulty
            electricityCost = miningData.cost
            electricityCostVauleLabbel.text = "\(miningData.cost?.getString() ?? "") \(Locale.appCurrency)/kWh"
            
            isSelectedModel = (miningData.isByModel != nil) ? miningData.isByModel! : true
            
            if miningData.isByModel == true {
                if let models = data.miningCalculation?.models {
                    typeValueLabbel.text = "\(defaultAlgorithmType?.rawValue ?? "GPU") / \("models".localized())"
                    modelsData = models
                    for model in models {
        
                             let sendedModel = SelectedModel(modelId: model.modelId, count: model.count)
                            sendedModel.modelName = model.name
                            selectedModels.append(sendedModel)
                        
                    }
                    isArrowButtonHidden(models.count <= 1)
                    
                    modelAlgorithmTableView.reloadData()
                }
                self.isSelectedAlgorithm = false
            } else {
                if let algos = data.miningCalculation?.algos {
                    typeValueLabbel.text = "\(defaultAlgorithmType?.rawValue ?? "GPU") / \("algorithms".localized())"
                    algosData = algos
                    
                    for algo in algos {
                            let sendedAlgo = SelectedAlgos(algoId: algo.algoId, hs: algo.hs, w: algo.w)
                            sendedAlgo.algosName = algo.name
                        selectedAlgosASIC.append(sendedAlgo)
                    }
                        for algo in algos {
                                let sendedAlgo = SelectedAlgos(algoId: algo.algoId, hs: algo.hs, w: algo.w)
                                sendedAlgo.algosName = algo.name
                                selectedlgosGPU.append(sendedAlgo)
                    }
                    
                    isArrowButtonHidden(algos.count <= 1)
                    
                    modelAlgorithmTableView.reloadData()
                }
                self.isSelectedAlgorithm = true
            }
        }
        
        coinData = CoinTableViewDataSource.shared.coinTableDefaultDataForUser(data)
        filteredCoinData = coinData
        filterData()
        coinsTableView.reloadData()
        Loading.shared.endLoading(for: view)
    }
    
    func filterData() {
        if profitArrowTapped {
            if isTappedRevenue {
                filteredCoinData = filteredCoinData.sorted(by: { (item1, item2) -> Bool in
                    return item1.revenue < item2.revenue
                })
            } else {
                filteredCoinData = filteredCoinData.sorted(by: { (item1, item2) -> Bool in
                    return item1.profit < item2.profit
                })
            }
            
        } else {
            if isTappedRevenue {
                filteredCoinData = filteredCoinData.sorted(by: { (item1, item2) -> Bool in
                    return item1.revenue > item2.revenue
                })
            } else {
                filteredCoinData = filteredCoinData.sorted(by: { (item1, item2) -> Bool in
                    return item1.profit > item2.profit
                })
            }
        }
    }
    
    func nothingChanged() {
        algosData = []
        modelsData = []
        view.layoutIfNeeded()
    }
}
//MARK: - Search bar delegate methods implementation -

extension WhatToMineViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        self.cheeckSearchCoins()
    }
    
    func cheeckSearchCoins() {
        
        filteredCoinData = coinData.filter({($0.coinName.lowercased() + $0.algorithmName.lowercased() + $0.coinSymbol.lowercased()).contains(self.searchText.lowercased())})
        if self.searchText.isEmpty {
            filteredCoinData = coinData
        }
        coinsTableView.reloadData()
        coinsTableView.scroll(to: .top, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}
//MARK: -- Table view delegate methods implementation

extension WhatToMineViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == modelAlgorithmTableView {
            return isSelectedModel ? modelsData.count : algosData.count
        } else if tableView == coinsTableView {
            if isAdsCome && !filteredCoinData.isEmpty { return filteredCoinData.count + 1 }
            return filteredCoinData.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == modelAlgorithmTableView {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "selectedDataCell", for: indexPath) as? ModelAlgorithmTableViewCell {
                if isSelectedModel {
                    cell.setupCell(with: modelsData, for: indexPath)
                } else {
                    cell.setupCell(with: algosData, for: indexPath)
                }
                
                return cell
            }
        } else if tableView == coinsTableView {
            
            if   filteredCoinData.count < 3  && isAdsCome && indexPath.row == filteredCoinData.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: AdsTableViewCell.name) as! AdsTableViewCell
                adsViewForWhatToMine.translatesAutoresizingMaskIntoConstraints = false
                cell.setData(view: adsViewForWhatToMine)
                return cell
                
            }
            
            if isAdsCome && indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: AdsTableViewCell.name) as! AdsTableViewCell
                adsViewForWhatToMine.translatesAutoresizingMaskIntoConstraints = false
                cell.setData(view: adsViewForWhatToMine)
                return cell
                
            }
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "coinCell", for: indexPath) as? CoinTableViewCell {
                
                let currentCoin = isAdsCome && indexPath.row > 3 ? filteredCoinData[indexPath.row - 1] : filteredCoinData[indexPath.row]
                
                cell.setupCell(currentCoin, isTappedRevenue)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isAdsCome && indexPath.row == 3 {return}
        if  !filteredCoinData.isEmpty && filteredCoinData.count < 3  && isAdsCome && indexPath.row == filteredCoinData.count { return }
        if tableView == coinsTableView {
            let sb = UIStoryboard(name: "Menu", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "CoinDetailsViewController") as! CoinDetailsViewController
            let currentCoin = isAdsCome && indexPath.row > 3 ? filteredCoinData[indexPath.row - 1] : filteredCoinData[indexPath.row]
            
            vc.coinDetailsData = currentCoin
            let rates = UserDefaults.standard.value(forKey: "\(DatabaseManager.shared.currentUser?.id ?? "" )/rates") as? [String:Double]
            let currencyMultiplier: Double = rates?[Locale.appCurrency] ?? 1.0

            if settingsDefaultsData != nil {
                for coin in settingsDefaultsData!.miningCoins {
                    if coin.coinName == currentCoin.coinName {
                        vc.coinModel = coin
                        break
                    }
                }
                
                
                vc.coinData.append(CoinDetailsDataModel(key: "Algorithm", value: currentCoin.algorithmName))
                vc.revenue = CoinDetailsDataModel(key: "Revenue" , value: (currentCoin.revenue * currencyMultiplier).getString())
                vc.profit = CoinDetailsDataModel(key: "Profit", value: (currentCoin.profit * currencyMultiplier).getString())
                
                if currentCoin.coinName != "NICEHASH" {
                    vc.coinID = currentCoin.coinId
                }
                vc.defaultsData = settingsDefaultsData!
                vc.indexPath = indexPath
            }
            navigationController?.pushViewController(vc, animated: true)
            hideKeyboard()
        }
    }
    // MARK: -- TableView cell height
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == modelAlgorithmTableView {
            return ModelAlgorithmTableViewCell.height
        }
        if isAdsCome && indexPath.row == 3  { return AdsTableViewCell.height }
        if isAdsCome && indexPath.row  == filteredCoinData.count && filteredCoinData.count < 3 { return AdsTableViewCell.height }
        
        return CoinTableViewCell.height
    }
}
 

// MARK: - Ads Methods
extension WhatToMineViewController {
 
   @objc func hideAds() {
        self.isAdsCome = false
        self.coinsTableView.reloadData()
    }
    
    func checkUserForAds() {
        self.adsManager.checkUserForAds(zoneName: .whatToMine,isAdsTableView: true) { adsView in
            self.adsViewForWhatToMine = adsView
            self.isAdsCome = true
          //  DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.coinsTableView.reloadData()
        //    }
        }
    }
}

