//
//  LanguageViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/18/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import Localize_Swift
import WidgetKit

protocol DataDelegate: AnyObject {
    func reloadData()
}

class LanguageViewController: BaseViewController {
    
    // MARK: - Views
    
    @IBOutlet var searchBar: BaseSearchBar!
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    @IBOutlet var heightConstraintSearchBar: NSLayoutConstraint!
    
    weak var dataDelegate: DataDelegate?
    
    // MARK: - Properties
    private var languages = ["en", "hy", "fr", "ru", "zh-Hans", "ko", "de","es","pt-PT"]
    private var temperatureUnits = ["°C", "°F"]
    private var currentPage: MoreSettingsEnum = .languages
    private var items = [String]()
    private var currencys = [Currency]()
    private var filteredCurrencys = [Currency]()
    private var searchText = ""
    private var saveButton:UIBarButtonItem?
    private var selectWithoutReques = false
    private var indexPath:IndexPath = .zero
    // MARK: - Static
    static func initializeStoryboard() -> LanguageViewController? {
        return UIStoryboard(name: "More", bundle: nil).instantiateViewController(withIdentifier: LanguageViewController.name) as? LanguageViewController
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
    }
    
    override func languageChanged() {
        navigationItem.title = currentPage.rawValue.localized()
    }
}

// MARK: - Startup
extension LanguageViewController {
    fileprivate func startupSetup() {
        switch currentPage {
        case .languages:
            setupLanguages()
        case .temperature:
            setupTemperature()
        case .currency:
            getCurrencyList { currencies in
                self.currencys = currencies
                DispatchQueue.main.async {
//                    self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                    self.tableView.reloadData()
                    self.setupCurrency()
                }
            }
        default:
            return
        }
        saveButton = UIBarButtonItem(title: "save".localized(), style: .done, target: self, action: #selector(saveButtonAction))
        navigationItem.setRightBarButton(saveButton, animated: true)
        saveButton?.isEnabled = false
        searchBar.addBarButtomSeparator()
        searchBar.showsCancelButton = false
    }
    
    fileprivate func setupLanguages() {
        let currentLanguage = Localize.currentLanguage()
        let index = languages.firstIndex(of: currentLanguage)
        items = languages.map { getNationalNameForLanguage($0) }
        selectCurrentItem(index ?? 0)
    }
    
    fileprivate func setupTemperature() {
        let temperatureName = UserDefaults.shared.object(forKey: "temperatureUnit") as? String
        let name = temperatureName ?? Double.phoneTemperatureUnit
        let index = temperatureUnits.firstIndex(of: name) ?? 0
        items = ["Celsius (°C)", "Fahrenheit (°F)"]
        selectCurrentItem(index)
    }
    
    fileprivate func setupCurrency() {
        var index = 0
        filteredCurrencys.enumerated().forEach { (i, value) in
            if Locale.appCurrency == value.name {
                index = i
                return
            }
        }
        selectCurrentItem(index)
        selectWithoutReques = false
    }
    
    fileprivate func selectCurrentItem(_ index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
    }
    
    @objc func saveButtonAction() {
        guard !selectWithoutReques else { return }
        
        switch currentPage {
        case .languages:
            selectLanguage(indexPath)
        case .temperature:
            selectTemperature(indexPath)
        case .currency:
            selectCurrency(indexPath)
        default:
            return
        }
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Actions
extension LanguageViewController {
    fileprivate func getNationalNameForLanguage(_ language: String) -> String {
        switch language {
        case "en":
            return "English\n\nEnglish"
        case "hy":
            return "Armenian\n\nՀայերեն"
        case "fr":
            return "French\n\nFrançais"
        case "zh-Hans":
            return "Chinese\n\n中文"
        case "ko":
            return "Korean\n\n한국어"
        case "ru":
            return "Russian\n\nРусский"
        case "de":
            return "German\n\nDeutsch"
        case "es":
            return "Spanish\n\nEspañola"
        case "pt-PT":
            return "Portuguese\n\nPortuguês"
        default:
            break
        }
        return language
    }
    
    fileprivate func getCurrencyList(success: @escaping ([Currency]) -> Void) {
        Loading.shared.startLoading(ignoringActions: true, for: view, barButtons: [navigationItem.backBarButtonItem])
        UserRequestsService.shared.getCurrencyList { currency in
            success(currency)
            self.filteredCurrencys = currency
            Loading.shared.endLoading(for: self.view, barButtons: [self.navigationItem.backBarButtonItem])
        } failer: { err in
            self.showAlertView("", message: err, completion: nil)
            debugPrint(err)
            Loading.shared.endLoading(for: self.view, barButtons: [self.navigationItem.backBarButtonItem])
        }
        
    }
    
    fileprivate func selectLanguage(_ indexPath: IndexPath) {
        let newLanguage = languages[indexPath.row]
        Localize.setCurrentLanguage(newLanguage)
        UserDefaults(suiteName: "group.com.witplex.MinerBox")?.set(newLanguage, forKey: "appLanguage")
        if #available(iOS 14.0, *) {
            #if arch(arm64) || arch(i386) || arch(x86_64)
            WidgetCenter.shared.reloadAllTimelines()
            #endif
        }
    }
    
    fileprivate func selectTemperature(_ indexPath: IndexPath) {
        let temperatureUnit = temperatureUnits[indexPath.row]
        UserDefaults.shared.setValue(temperatureUnit, forKeyPath: "temperatureUnit")
        dataDelegate?.reloadData()
    }
    
    fileprivate func selectCurrency(_ indexPath: IndexPath) {
        let currency = filteredCurrencys[indexPath.row]
        
        if user != nil {
            sendCurrency(currency.name)
        } else {
            Locale.appCurrency = currency.name
            if #available(iOS 14.0, *) {
                #if arch(arm64) || arch(i386) || arch(x86_64)
                WidgetCenter.shared.reloadAllTimelines()
                #endif
            }
            dataDelegate?.reloadData()
        }
    }
    
    private func sendCurrency(_ currency: String) {
        Loading.shared.startLoading(ignoringActions: true, for: view, barButtons: [navigationItem.backBarButtonItem])
        UserRequestsService.shared.sendCurrency(currency) { [weak self] currency in
            guard let self = self else { return }
            DispatchQueue.main.async {
                Locale.appCurrency = currency
                if #available(iOS 14.0, *) {
                    #if arch(arm64) || arch(i386) || arch(x86_64)
                    WidgetCenter.shared.reloadAllTimelines()
                    #endif
                }
                self.dataDelegate?.reloadData()
                Loading.shared.endLoading(for: self.view, barButtons: [self.navigationItem.backBarButtonItem])
            }
        } failer: { error in
            self.showAlertView(nil, message: error, completion: nil)
            self.selectWithoutReques = true
            self.setupCurrency()
            Loading.shared.endLoading(for: self.view, barButtons: [self.navigationItem.backBarButtonItem])
        }
    }
}

// MARK: - TableView methods
extension LanguageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentPage == MoreSettingsEnum.currency ? filteredCurrencys.count : items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CheckmarkTableViewCell.name) as! CheckmarkTableViewCell
        if currentPage == MoreSettingsEnum.currency {
            heightConstraintSearchBar.constant = 56
            cell.setData(currency:filteredCurrencys[indexPath.row] , indexPath: indexPath, last: false)
        } else {
            heightConstraintSearchBar.constant = 0
            cell.setData(name: items[indexPath.row], indexPath: indexPath, last: false, roundCorners: false)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.indexPath = indexPath
        saveButton?.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return currentPage == .languages ? 75 : 44
    }
}

// MARK: - Search delegate
extension LanguageViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        filteredCurrencys = currencys.filter({ $0.name.lowercased().contains(searchText.lowercased())})
        if searchText.isEmpty {
            filteredCurrencys = currencys
        }
        self.tableView.reloadData()
        tableView.scroll(to: .top, animated: true)
    }
    
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.text = ""
            filteredCurrencys = currencys
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            hideKeyboard()
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            hideKeyboard()
        }
    }


// MARK: - Set data
extension LanguageViewController {
    public func setData(_ currentPage: MoreSettingsEnum) {
        self.currentPage = currentPage
    }
}
