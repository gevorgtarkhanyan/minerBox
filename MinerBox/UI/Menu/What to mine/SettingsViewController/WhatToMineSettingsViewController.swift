//
//  WhatToMineSettingsViewController.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 11/4/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

enum AlgorithmType: String {
    case GPU
    case ASIC
}

class WhatToMineSettingsViewController: BaseViewController {
    
    @IBOutlet weak var settingsTableView: BaseTableView!
    @IBOutlet weak var difficultyValueLabel: BaseLabel!
    @IBOutlet weak var difficultyNameLabel: BaseLabel!
    @IBOutlet var difficultyValueView: UIView!
    @IBOutlet var electricityValueView: UIView!
    
    @IBOutlet weak var toolsView: BaseView!
    
    @IBOutlet weak var toolsViewTopConstraits: NSLayoutConstraint!
    @IBOutlet weak var electricityCostLabel: BaseLabel!
    @IBOutlet weak var electrisityValueTextField: BaseTextField!
    @IBOutlet weak var electricityParentView: UIView!
    
    @IBOutlet weak var difficultyArrowButton: UIButton!
    @IBOutlet weak var settingsSegmentControllerView: BaseSegmentControl!
    @IBOutlet weak var algoritmSegmentsView: BaseSegmentControl!
    @IBOutlet var algoritmSegmentMainView: UIView!
    @IBOutlet weak var usdLabel: BaseLabel!
    
    @IBOutlet weak var algoritmSegmentHeighConstraits: NSLayoutConstraint!
    @IBOutlet var searchButton: BaseButton!
    @IBOutlet var searchBar: BaseSearchBar!
    @IBOutlet var scrollView: UIScrollView!
    
    weak var delegate: WhatToMineViewControllerDelegate?
    
    private var algorithmAlertModel: [CustomAlertModel] = SettingsAlertDataSource.algorithmAlertModel
    private var difficultyAlertModel: [CustomAlertModel] = []
    private var algorithmDataGPU: [MiningAlgorithmsModel] = []
    private var algorithmDataASIC: [MiningAlgorithmsModel] = []
    private var modelData: [MiningMachineModels] = []
    private var filteredAlgorithmDataGPU: [MiningAlgorithmsModel] = []
    private var filteredAlgorithmDataASIC: [MiningAlgorithmsModel] = []
    private var filteredModelData: [MiningMachineModels] = []
    private var selectedModels: [SelectedModel] = []
    private var selectedAlgosGPU: [SelectedAlgos] = []
    private var selectedAlgosASIC: [SelectedAlgos] = []
    public var  firstCallModels = true
    public var  firstCallAlgosGPU = true
    public var  firstCallAlgosASIC = true
    private var firstOpenView = true
    private var searchText = ""
    
    @IBOutlet weak var clearView: BaseView!
    @IBOutlet weak var clearButton: UIButton!
    private var noSelectedItem = false
    private var settingsData: MiningSettingsModels?
    private var footerView: CustomFooterView?
    private var headerView: CustomHeaderWhatMineView?
    private var electrisityCost: Double?
    private var currentElectricityCost: Double = 0
    private var isOpenedKeyboard = false
    private var isSelectedGPU = true
    private var currentDifficulty = "current".localized()
    private var notLocalizedDifficulty = "24h"
    public var defaultAlgorithmType = AlgorithmType.GPU
    public var isSelectedAlgorithm = false
    public var changedSettingsModel: MiningDefaultsModel?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDiffAndElectricityValues()
        getMainData()
        setupNavigation()
        setupTableView()
        initialSetup()
        addGestureToView()
        let size: CGSize = UIScreen.main.bounds.size
            if size.width / size.height > 1 {
                scrollView.isScrollEnabled = true
            } else {
                scrollView.scrollToTop()
                scrollView.isScrollEnabled = false
            }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createTextTranslations()
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        settingsTableView?.setEditing(false, animated: false)
        settingsTableView?.reloadData()
        let size: CGSize = UIScreen.main.bounds.size
        if size.width / size.height > 1 {
            scrollView?.isScrollEnabled = true
        } else {
            scrollView?.scrollToTop()
            scrollView?.isScrollEnabled = false
        }
    }
    
    override func languageChanged() {
        title = "Settings".localized()
    }
    
    @IBAction func changeElectriCityText(_ sender: UITextField) {
        sender.getFormatedText()
    }
    
    func getDiffAndElectricityValues() {
        if let data = changedSettingsModel {
            if let miningData = data.miningCalculation {
                difficultyValueLabel.text = miningData.difficulty?.lowercased().localized()
                notLocalizedDifficulty = miningData.difficulty ?? "24h"
                if let num = miningData.cost {
                    if let costInt = Int(exactly: num) {
                        electrisityValueTextField.text = costInt.getFormatedString()
                    } else {
                        electrisityValueTextField.text = num.getFormatedString()
                    }
                }
            }
        }
    }
    
    func getMainData() {
        Loading.shared.startLoading(ignoringActions: true, for: view)
        WhatToMineRequestService.shared.getMiningSettingsData(success: { (settingsModel) in
            self.settingsData = settingsModel
            self.difficultyAlertModel =  SettingsAlertDataSource.createDifficultyAlertModel(data: settingsModel)
            //       self.downloadSettingsData()
        }) {(error) in
            Loading.shared.endLoading(for: self.view)
            self.showAlertView("", message: error.localized(), completion: nil)
            debugPrint(error)
        }
    }
    func initialSetup() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        clearView.backgroundColor = darkMode ? .viewDarkBackground: .sectionHeaderLight
        toolsView.layer.cornerRadius = 10
        electricityCostLabel.changeFontSize(to: 15)
        electricityCostLabel.text = "electricityCost".localized()
        difficultyArrowButton.setImage(UIImage(named: "arrow_down")?.withRenderingMode(.alwaysTemplate), for: .normal)
        difficultyArrowButton.tintColor = darkMode ? .white : .barSelectedItem
        electricityValueView.backgroundColor = darkMode ? .textFieldBackgorund : .white
        difficultyValueView.backgroundColor = darkMode ? .textFieldBackgorund : .white
        electrisityValueTextField.textColor = darkMode ? .whiteTextColor : .textBlack
        electrisityValueTextField.backgroundColor = .clear
        electrisityValueTextField.borderStyle = .none
        electrisityValueTextField.changeFontSize(to: 14)
        clearView.roundCorners([.topLeft,.topRight],radius: 10)
        clearButton.setTitle("clear".localized(), for: .normal)
        clearButton.setTitleColor(.barSelectedItem, for: .normal)
        clearButton.addTarget(self, action: #selector(resetAllSelectedRow), for: .touchUpInside)
        usdLabel.text = "\(Locale.appCurrency)/kWh"
        settingsTableView.roundCorners([.topLeft,.topRight],radius: 0)
        searchBar.delegate = self
        searchBar.barTintColor = darkMode ? .viewDarkBackground : .sectionHeaderLight
        searchBar.backgroundColor = .clear
        searchBar.cornerRadius = 10
        algoritmSegmentMainView.backgroundColor = darkMode ? .blackBackground : .white
        setupSegmentConfigs()
    }
    
    func setupSegmentConfigs() {
        settingsSegmentControllerView.delegate = self
        settingsSegmentControllerView.setSegments(["GPU", "ASIC"])
        
        
        if defaultAlgorithmType == .GPU {
            settingsSegmentControllerView.selectSegment(index: 0)
            if isSelectedAlgorithm {
                selectAlgorithm()
            } else {
                selectModel()
            }
        } else {
            settingsSegmentControllerView.selectSegment(index: 1)
        }
        
        algoritmSegmentsView.delegate = self
        algoritmSegmentsView.setSegments(["models".localized(),"algorithms".localized()], true)
        if !isSelectedAlgorithm {
            algoritmSegmentsView.selectSegment(index: 2)
        } else {
            algoritmSegmentsView.selectSegment(index: 3)
        }
    }
    
    func setLocalSelectedValues(models: [SelectedModel]?,algosGPU: [SelectedAlgos]?,algosASIC: [SelectedAlgos]?) {
        self.selectedModels = models!
        self.selectedAlgosGPU = algosGPU!
        self.selectedAlgosASIC = algosASIC!
    }
    
    func createTextTranslations() {
        difficultyNameLabel.text = "difficulty".localized()
    }
    
    func setupTableView() {
        settingsTableView.register(UINib(nibName: "SettingsModelTableViewCell", bundle: nil), forCellReuseIdentifier: "modelCell")
        settingsTableView.register(UINib(nibName: "SettingsAlgorithmTableViewCell", bundle: nil), forCellReuseIdentifier: "algorithmCell")
        
        footerView = CustomFooterView(frame: .zero)
        settingsTableView.tableFooterView = footerView
        settingsTableView.tableFooterView?.frame.size.height = CustomFooterView.height
        settingsTableView.layer.cornerRadius = 10
        
        if let view = footerView {
            if settingsData == nil {
                view.isHidden = true
            } else {
                view.isHidden = false
            }
        }
        if let view = headerView {
            if settingsData == nil {
                view.isHidden = true
            } else {
                view.isHidden = false
            }
        }
    }
    
    func sortSelectedData() {
        for selected in selectedModels {
            for filtered in filteredModelData {
                if selected.modelName == filtered.name {
                    filteredModelData = filteredModelData.filter() {$0 != filtered}
                    filteredModelData.insert(filtered, at: 0)
                }
            }
        }
        
        for selected in selectedAlgosGPU {
            for filtered in filteredAlgorithmDataGPU {
                if selected.algosName == filtered.name {
                    filteredAlgorithmDataGPU = filteredAlgorithmDataGPU.filter() {$0 != filtered}
                    filteredAlgorithmDataGPU.insert(filtered, at: 0)
                }
            }
        }

        for selected in selectedAlgosASIC {
            for filtered in filteredAlgorithmDataASIC {
                if selected.algosName == filtered.name {
                    filteredAlgorithmDataASIC = filteredAlgorithmDataASIC.filter() {$0 != filtered}
                    filteredAlgorithmDataASIC.insert(filtered, at: 0)
                }
            }
        }

    }
    
    func setupNavigation() {
        let save = UIBarButtonItem(title: "save".localized(), style: .done, target: self, action: #selector(saveChanges))
        navigationItem.setRightBarButton(save, animated: false)
        navigationController?.navigationBar.shadowImage = UIImage()
        searchButton.addTarget(self, action: #selector(searchButtonAction(_:)), for: .touchUpInside)
    }
    
    @objc func resetAllSelectedRow() {
        self.selectedModels = []
        self.selectedAlgosGPU = []
        self.selectedAlgosASIC = []
        
        for algo in algorithmDataASIC {
            algo.selected = false
        }
        
        for algo in algorithmDataGPU {
            algo.selected = false
        }
        for model in modelData {
            model.selected = false
        }
        noSelectedItem = true
        settingsTableView.reloadData()
    }
    
    @objc func saveChanges() {
        if DatabaseManager.shared.currentUser != nil {
            calculateParameters()
        } else {
            goToLogIn()
        }
    }
    
    @objc private func searchButtonAction(_ sender: UIBarButtonItem) {
        showSearchBar()
    }
    
    private func showSearchBar() {
        if searchBar.isHidden {
            self.searchButton.isHidden = true
            searchBar.showsCancelButton = false
            
            UIView.animate(withDuration: Constants.animationDuration) {
                self.searchBar.isHidden = false
                self.searchBar.showsCancelButton = true
                self.searchBar.becomeFirstResponder()
            }
        }
    }
    
    private func hideSearchBar() {
        if !searchBar.isHidden {
            searchBar.text = ""
            self.searchText = ""
            view.endEditing(true)
            
            UIView.animate(withDuration: Constants.animationDuration, animations: {
                self.searchBar.isHidden = true
                self.searchBar.showsCancelButton = false
            }) { (_) in
            self.searchButton.isHidden = false
                self.searchBar.showsCancelButton = true
            self.filteredModelData = self.modelData
            self.filteredAlgorithmDataGPU = self.algorithmDataGPU
            self.filteredAlgorithmDataASIC = self.algorithmDataASIC
            self.settingsTableView.reloadData()
            }
        }
    }
    
    func calculateParameters() {
        if let user = DatabaseManager.shared.currentUser {
            Loading.shared.startLoading(ignoringActions: true, for: view)
            let userId = user.id
            
            var cost: Double {
                if let num = electrisityValueTextField.text?.toDouble() {//Double(electrisityValueTextField.text!) {
                    return num
                }
                return 0
            }
            currentElectricityCost = cost
            
            var isByModel: Bool {
                if isSelectedAlgorithm || defaultAlgorithmType == .ASIC {
                    return false
                }
                return true
            }
            self.filtredSelectedValue()
            
            if defaultAlgorithmType == .GPU {
                if isSelectedAlgorithm {
                    if self.selectedAlgosGPU.count == 0 {
                        self.noSelectedItem = true
                    } else {
                        self.noSelectedItem = false
                    }
                } else {
                    if self.selectedModels.count == 0 {
                        self.noSelectedItem = true
                    } else {
                        self.noSelectedItem = false
                    }
                }
            } else if defaultAlgorithmType == .ASIC {
                if self.selectedAlgosASIC.count == 0 {
                    self.noSelectedItem = true
                } else {
                    self.noSelectedItem = false
                }
            }
            guard !noSelectedItem else {
                Loading.shared.endLoading(for: self.view)
                showAlertView(nil, message:"no_item_selected".localized(), completion: nil)
                return
            }
            if isByModel {
                if selectedModels.count != 0 {
                    WhatToMineRequestService.shared.calculateSettingsData(success: { (currentDefaultsData) in
                        self.delegate?.getCurrentDefaultsData(currentDefaultsData, for: .GPU, true)
                        Loading.shared.endLoading(for: self.view)
                        self.navigationController?.popViewController(animated: true)
                    }, calculatedData: MiningCalculationModel(userId: userId, isByModel: true, algos: selectedAlgosGPU, models: selectedModels, cost: cost, difficulty: notLocalizedDifficulty))
                } else {
                    delegate?.nothingChanged()
                    Loading.shared.endLoading(for: self.view)
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                if defaultAlgorithmType == .GPU {
                    if selectedAlgosGPU.count != 0 {
                        WhatToMineRequestService.shared.calculateSettingsData(success: { (currentDefaultsData) in
                            self.delegate?.getCurrentDefaultsData(currentDefaultsData, for: .GPU, true)
                            Loading.shared.endLoading(for: self.view)
                            self.navigationController?.popViewController(animated: true)
                        }, calculatedData: MiningCalculationModel(userId: userId, isByModel: false, algos: selectedAlgosGPU, models: selectedModels, cost: cost, difficulty: notLocalizedDifficulty))
                    } else {
                        delegate?.nothingChanged()
                        Loading.shared.endLoading(for: self.view)
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    if selectedAlgosASIC.count != 0 {
                        WhatToMineRequestService.shared.calculateSettingsData(success: { (currentDefaultsData) in
                            self.delegate?.getCurrentDefaultsData(currentDefaultsData, for: .ASIC, true)
                            Loading.shared.endLoading(for: self.view)
                            self.navigationController?.popViewController(animated: true)
                        }, calculatedData: MiningCalculationModel(userId: userId, isByModel: false, algos: selectedAlgosASIC, models: selectedModels, cost: cost, difficulty: notLocalizedDifficulty))
                    } else {
                        delegate?.nothingChanged()
                        Loading.shared.endLoading(for: self.view)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    func filtredSelectedValue() {
        selectedModels = []
        selectedAlgosGPU = []
        selectedAlgosASIC = []
        
        for model in filteredModelData {
            if model.selected && model.disabled == false {
                let sendedModel = SelectedModel(modelId: model.modelId, count: model.count)
                sendedModel.modelName = model.name
                selectedModels.append(sendedModel)
            }
        }
        for algo in filteredAlgorithmDataGPU {
            if algo.selected && algo.disabled == false {
                let sendedAlgo = SelectedAlgos(algoId: algo.algoId, hs: algo.hs, w: algo.w)
                sendedAlgo.algosName = algo.name
                selectedAlgosGPU.append(sendedAlgo)
            }
        }
        for algo in filteredAlgorithmDataASIC {
            if algo.selected && algo.disabled == false {
                let sendedAlgo = SelectedAlgos(algoId: algo.algoId, hs: algo.hs, w: algo.w)
                sendedAlgo.algosName = algo.name
                selectedAlgosASIC.append(sendedAlgo)
            }
        }
        self.delegate?.getLocalSelectedValue(models: selectedModels, algosGPU: selectedAlgosGPU, algosASIC: selectedAlgosASIC)
    }
    
    //MARK: -- Download settings data
    func downloadSettingsData() {
        
        Loading.shared.startLoading(ignoringActions: true, for: view)
        
        if defaultAlgorithmType == .GPU {
            if isSelectedAlgorithm {
                guard firstCallAlgosGPU else {
                    Loading.shared.endLoading(for: self.view)
                    return
                }
                firstCallAlgosGPU = false
                WhatToMineRequestService.shared.getMiningAlgorithmsData(type: AlgorithmType.GPU.rawValue, difficulty: notLocalizedDifficulty, success: { (algorithms) in
                    self.algorithmDataGPU = algorithms
                    self.filteredAlgorithmDataGPU = self.algorithmDataGPU
                    self.sortSelectedData()
                    self.setupAlgorithmGPUValues()
                    self.settingsTableView.reloadData()
                    Loading.shared.endLoading(for: self.view)
                }) {(error) in
                    Loading.shared.endLoading(for: self.view)
                    self.showAlertView("", message: error.localized(), completion: nil)
                }
            } else  {
                guard firstCallModels else {
                    Loading.shared.endLoading(for: self.view)
                    return
                }
                firstCallModels = false
                
                WhatToMineRequestService.shared.getMiningMachineModelsData(difficulty: notLocalizedDifficulty, success: { (models) in
                    self.modelData = models
                    self.filteredModelData = self.modelData
                    self.setupModelValues()
                    self.sortSelectedData()
                    self.settingsTableView.reloadData()
                    Loading.shared.endLoading(for: self.view)
                }) {(error) in
                    Loading.shared.endLoading(for: self.view)
                    self.showAlertView("", message: error.localized(), completion: nil)
                }
            }
        } else if defaultAlgorithmType == .ASIC  {
            guard firstCallAlgosASIC else {
                Loading.shared.endLoading(for: self.view)
                return
            }
            firstCallAlgosASIC = false
            
            WhatToMineRequestService.shared.getMiningAlgorithmsData(type: AlgorithmType.ASIC.rawValue, difficulty: notLocalizedDifficulty, success: { (algorithms) in
                self.algorithmDataASIC = algorithms
                self.filteredAlgorithmDataASIC = self.algorithmDataASIC
                self.sortSelectedData()
                self.setupAlgorithmASICValues()
                self.settingsTableView.reloadData()
                Loading.shared.endLoading(for: self.view)
            }) {(error) in
                Loading.shared.endLoading(for: self.view)
                self.showAlertView("", message: error.localized(), completion: nil)
            }
        }
        if let view = self.footerView {
            view.isHidden = false
        }
        if let view = self.headerView {
            view.isHidden = false
        }
    }
    
    //MARK: -- Setup algorithm and models values
    func setupAlgorithmGPUValues() {
        for sendedAlgo in selectedAlgosGPU {
            for algo in filteredAlgorithmDataGPU {
                if sendedAlgo.algoId == algo.algoId {
                    algo.selected = true
                    algo.hs = sendedAlgo.hs
                    algo.w = sendedAlgo.w
                }
            }
        }
        algorithmDataGPU.sort(by: {$0.selected && !$1.selected})
    }
    
    func setupAlgorithmASICValues() {
        for sendedAlgo in selectedAlgosASIC {
            for algo in filteredAlgorithmDataASIC {
                if sendedAlgo.algoId == algo.algoId {
                    algo.selected = true
                    algo.hs = sendedAlgo.hs
                    algo.w = sendedAlgo.w
                }
            }
        }
        algorithmDataASIC.sort(by: {$0.selected && !$1.selected})
    }
    
    func setupModelValues() {
        var stepCount = selectedModels.count
        for model in filteredModelData {
            for sendedModel in selectedModels {
                if model.modelId == sendedModel.modelId {
                    model.selected = true
                    model.count = sendedModel.count
                    stepCount -= 1
                    break
                } else {
                    model.selected = false
                    model.count = 0
                }
            }
            if stepCount == 0 {
                break
            }
        }
        filteredModelData.sort(by: {$0.selected && !$1.selected})
    }
    
    //MARK: -- Gesture added labels
    func addGestureToView() {
        let difficultyTap = UITapGestureRecognizer(target: self, action: #selector(changeDifficulty))
        difficultyValueView.addGestureRecognizer(difficultyTap)
        difficultyValueView.isUserInteractionEnabled = true
        
    }
    
    @IBAction func changeDifficulty() {
        if isOpenedKeyboard {
            hideKeyboard()
        }
        setupAlert(difficultyAlertModel)
    }
    
    @IBAction func electricityEditingChaned(_ sender: UITextField) {
        sender.getFormatedText()
    }
    
    func setupAlert(_ alertModel: [CustomAlertModel]) {
        let sb = UIStoryboard(name: "Menu", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "CustomAlertViewController") as! CustomAlertViewController
        
        vc.alertModels = alertModel
        vc.delegate = self
        
        let controller = tabBarController ?? self
        controller.present(vc, animated: true, completion: nil)
    }
    
    // MARK: -- Show/hide  Algorithm/model
    func showalgoritmSegmentsView() {
        if isOpenedKeyboard {
            hideKeyboard()
        }
        if !isSelectedGPU {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.algoritmSegmentsView.alpha = 1
                self.algoritmSegmentHeighConstraits.constant = 30
                self.toolsViewTopConstraits.constant = 40
                self.view.layoutIfNeeded()
            }
            isSelectedGPU = true
        }
    }
    
    func hidealgoritmSegmentsView() {
        if isOpenedKeyboard {
            hideKeyboard()
        }
        if isSelectedGPU {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.toolsViewTopConstraits.constant = 5
                self.algoritmSegmentsView.alpha = 0
                self.algoritmSegmentHeighConstraits.constant = 0
                self.view.layoutIfNeeded()
            }
            isSelectedGPU = false
        }
    }
    
    // MARK: -- Select Algorithm or model functions
    func selectAlgorithm() {
        if !isSelectedAlgorithm {
            setupAlgorithmGPUValues()
            isSelectedAlgorithm = true
            settingsTableView.reloadData()
        }
    }
    
    func selectModel() {
        if isSelectedAlgorithm {
            setupModelValues()
            isSelectedAlgorithm = false
            settingsTableView.reloadData()
        }
    }
    
    //MARK: --Keyboard frame changes
    override func keyboardWillShow(_ sender: Notification) {
        super.keyboardWillShow(sender)
        isOpenedKeyboard = true
        if let keyboardHeight = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            
            settingsTableView.contentInset.bottom = keyboardHeight - self.tabBarHeight
            view.layoutIfNeeded()
        }
    }
    
    override func keyboardWillHide(_ sender: Notification) {
        super.keyboardWillHide(sender)
        isOpenedKeyboard = false
        settingsTableView.contentInset.bottom = 8
        view.layoutIfNeeded()
    }
}

extension WhatToMineSettingsViewController: BaseSegmentControlDelegate {
    func segmentSelected(index: Int) {
        switch index {
        case 0:
            if isOpenedKeyboard {
                hideKeyboard()
            }
            defaultAlgorithmType = .GPU
            if !firstOpenView {
                self.downloadSettingsData()
            }
            firstOpenView = false
            settingsTableView.reloadData()
            showalgoritmSegmentsView()
        case 1:
            if isOpenedKeyboard {
                hideKeyboard()
            }
            defaultAlgorithmType = .ASIC
            if !firstOpenView {
                self.downloadSettingsData()
            }
            firstOpenView = false
            setupAlgorithmASICValues()
            settingsTableView.reloadData()
            hidealgoritmSegmentsView()
        case 2:
            if isOpenedKeyboard {
                hideKeyboard()
            }
            selectModel()
            
            downloadSettingsData()
            
        case 3:
            if isOpenedKeyboard {
                hideKeyboard()
            }
            selectAlgorithm()
            downloadSettingsData()
        default:
            break
        }
    }
}
//MARK: - Search bar delegate methods implementation -

extension WhatToMineSettingsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        self.cheeckSearchCoins()
    }
    
    func cheeckSearchCoins() {
        if defaultAlgorithmType == .ASIC {
            filteredAlgorithmDataASIC = algorithmDataASIC.filter({($0.name.lowercased()).contains(self.searchText.lowercased())})
            if self.searchText.isEmpty {
                filteredAlgorithmDataASIC = algorithmDataASIC
            }
        } else {
            if isSelectedAlgorithm {
                filteredAlgorithmDataGPU = algorithmDataGPU.filter({($0.name.lowercased()).contains(self.searchText.lowercased())})
                if self.searchText.isEmpty {
                    filteredAlgorithmDataGPU = algorithmDataGPU
                }
            } else {
                filteredModelData = modelData.filter({($0.name.lowercased()).contains(self.searchText.lowercased())})
                if self.searchText.isEmpty {
                    filteredModelData = modelData
                }
            }
        }
        settingsTableView.reloadData()
        settingsTableView.scroll(to: .top, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

extension WhatToMineSettingsViewController: SettingsAlgorithmTableViewCellDelegate, SettingsModelTableViewCellDelegate {
    
    
    func insertTextField(for indexPath: IndexPath, minCount: Int) {
        let currentData = filteredModelData[indexPath.row]
        
        if minCount == 0 {
            currentData.selected = false
        } else if !currentData.selected {
            currentData.selected = true
        }
    
    }
    
    
    // MARK: -- Model cell delegate methods
    func modelButtonTapped(for indexPath: IndexPath) {
        let currentData = filteredModelData[indexPath.row]
        if currentData.selected == true {
            currentData.selected = false
        } else {
            currentData.selected = true
        }
        settingsTableView.reloadData()
    }
    
    func minusButtonTapped(for indexPath: IndexPath, minCount: Int) {
        let currentData = filteredModelData[indexPath.row]
        if minCount == 0 {
            currentData.selected = false
            settingsTableView.reloadData()
        }
    }
    
    func plusButtonTapped(for indexPath: IndexPath) {
        let currentData = filteredModelData[indexPath.row]
        
        if !currentData.selected {
            currentData.selected = true
            settingsTableView.reloadData()
        }
    }
    
    func modelCountChange(for indexPath: IndexPath, to count: Int) {
        let currentData = filteredModelData[indexPath.row]
        currentData.count = Double(count)
    }
    
    // MARK: -- Algorithm cell delegate methods
    func algorithmButtonTapped(for indexPath: IndexPath) {
        let currentData = defaultAlgorithmType == .GPU ? filteredAlgorithmDataGPU[indexPath.row] : filteredAlgorithmDataASIC[indexPath.row]
        if currentData.selected == true {
            currentData.selected = false
        } else {
            currentData.selected = true
        }
        settingsTableView.reloadData()
    }
    
    func algosTextFieldChange(for text: String, indexPath: IndexPath, changedText: String) {
        let currentData = defaultAlgorithmType == .GPU ? filteredAlgorithmDataGPU[indexPath.row] : filteredAlgorithmDataASIC[indexPath.row]
        if let num = changedText.toDouble() {
            if text == "hs" {
                currentData.hs = num
            } else if text == "w" {
                currentData.w = num
            }
        }
    }
    
    // MARK: -- Model+Algorithm cells delegate method
    func goToLogIn() {
        if UserDefaults.standard.bool(forKey: "isSignUp") {
            guard let vc = LoginViewController.initializeStoryboard() else { return }
            navigationController?.pushViewController(vc, animated: true)
        } else {
            guard let vc = SignupViewController.initializeStoryboard() else { return }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: -- Custom Alert delegate method implementation
extension WhatToMineSettingsViewController: CustomAlertViewControllerDelegate {
    func sendFilterType(_ filteredType: String) {
        
        //Custom alert response for difficulty
        if let data = settingsData {
            for difficulty in data.difficulties {
                let currentDiff = difficulty.value.lowercased().localized()
                switch filteredType {
                case currentDiff:
                    difficultyValueLabel.text = currentDiff
                    if notLocalizedDifficulty != difficulty.value {
                        notLocalizedDifficulty = difficulty.value
                        self.firstCallModels = true
                        self.firstCallAlgosGPU = true
                        self.firstCallAlgosASIC = true
                        
                        downloadSettingsData()
                    }
                    view.layoutIfNeeded()
                default:
                    break
                }
            }
        }
        
        let controller = tabBarController ?? self
        controller.dismiss(animated: false, completion: nil)
    }
}

//MARK: - UITextFieldDelegate
extension WhatToMineSettingsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return electrisityValueTextField.allowOnlyNumbersForConverter(string: string)//allowOnlyNumbers(string: string)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if DatabaseManager.shared.currentUser == nil {
            textField.resignFirstResponder()
            goToLogIn()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "0." || textField.text == "0," {
            textField.text = "0"
        }
    }
}

//MARK: - UITableViewDataSource
extension WhatToMineSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if defaultAlgorithmType == .ASIC {
            return filteredAlgorithmDataASIC.count
        } else {
            if isSelectedAlgorithm {
                return filteredAlgorithmDataGPU.count
            } else {
                return filteredModelData.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if defaultAlgorithmType == .ASIC {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "algorithmCell", for: indexPath) as? SettingsAlgorithmTableViewCell {
                cell.delegate = self
                cell.setupCell(filteredAlgorithmDataASIC, for: indexPath)
                return cell
            }
        } else {
            if !isSelectedAlgorithm   {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "modelCell", for: indexPath) as? SettingsModelTableViewCell {
                    cell.delegate = self
                    cell.setupCell(filteredModelData, for: indexPath)
                    return cell
                }
                
            } else if isSelectedAlgorithm || defaultAlgorithmType == .ASIC {//must be modifviedc
                if let cell = tableView.dequeueReusableCell(withIdentifier: "algorithmCell", for: indexPath) as? SettingsAlgorithmTableViewCell {
                    cell.delegate = self
                    cell.setupCell(filteredAlgorithmDataGPU, for: indexPath)
                    return cell
                }
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isSelectedAlgorithm || defaultAlgorithmType == .ASIC {
            return SettingsAlgorithmTableViewCell.height
        }
        return SettingsModelTableViewCell.height
    }
}

extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
   }
}
