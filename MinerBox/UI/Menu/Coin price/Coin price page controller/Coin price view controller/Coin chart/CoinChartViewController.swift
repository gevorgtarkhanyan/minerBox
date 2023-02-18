//
//  CoinChartViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/15/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import Charts
import Localize_Swift
import SwiftUI
import AVFoundation

class CoinChartViewController: BaseViewController {
    
    // Only for ipad. in landscape mode priority 999, in portait` 750
    @IBOutlet weak var chartBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var linkTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var exploreatursHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var websiteButtonsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var dateContentView: UIStackView!
    @IBOutlet fileprivate weak var dateSelectorView: DateSelectorView!
    @IBOutlet fileprivate weak var datePriceLabel: BaseLabel!
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var linkTableView: BaseTableView!
    @IBOutlet fileprivate weak var timeSelectorView: GraphTimeSelector!
    @IBOutlet fileprivate weak var chartView: LineChartView!
    @IBOutlet fileprivate weak var graphBackgroundView: BaseView!
    @IBOutlet fileprivate weak var selectedDateLabel: BaseLabel!
    @IBOutlet fileprivate weak var selectedPriceLabel: BaseLabel!
    @IBOutlet fileprivate weak var favoriteButton: BaseButton!
    @IBOutlet fileprivate weak var alertButton: BaseButton!
    @IBOutlet fileprivate weak var convertorButton: BaseButton!
    
    @IBOutlet fileprivate weak var linkParentView: UIView!
    @IBOutlet fileprivate weak var websiteButton: UIButton!
    @IBOutlet fileprivate weak var twitterButton: UIButton!
    @IBOutlet fileprivate weak var redditButton: UIButton!
    @IBOutlet fileprivate weak var exploreatursLabel: BaseLabel!
    
    @IBOutlet weak var highValueLabel: BaseLabel!
    @IBOutlet weak var lowValueLabel: BaseLabel!
    @IBOutlet weak var highDateLabel: BaseLabel!
    @IBOutlet weak var lowDateLabel: BaseLabel!
    @IBOutlet weak var HighLowVIew: BaseView!
    @IBOutlet var GraphViewTopConstraint: NSLayoutConstraint!
    
    weak var delegate: CoinPriceViewControllerDelegate?
    private var coins = [CoinModel]()
    private var chartMinY = 0.0
    private var chartMaxY = 0.0
    private var max = 0.0
    private var min = 0.0
    private var settingsItem: UIBarButtonItem!
    private var shareItem: UIBarButtonItem!
    private var isFavorite: Bool?
    private var coinId = String()
    private var favoriteCoins: [CoinModel] = []
    public var selectedCoins: [CoinModel] = []
    private var landscape:Bool = false
    private var coinsDatas = [(order: Int, coin: CoinModel, data: [ChartDataEntry])]()
    private var chartSavedData = [CoinModel: [GraphTimeFilter: (order: Int, coin: CoinModel, data: [ChartDataEntry])]]()
    private var tableData: [(key: String, value: String)] = []
    
    private var currentTime = GraphTimeFilter.week
    let rates = UserDefaults.standard.value(forKey: "\(DatabaseManager.shared.currentUser?.id ?? "" )/rates") as? [String:Double]
    
    private var expLinks: [String] {
        return selectedCoins.first?.explorerLinks ?? []
    }
    
    private var verticalLineIsOn: Bool {
        return UserDefaults.standard.value(forKey: Constants.coinSettingsVertical) as? Bool ?? true
    }
    private var horizontalLineIsOn: Bool {
        return UserDefaults.standard.value(forKey: Constants.coinSettingsHorizontal) as? Bool ?? true
    }
    private var lineGraphIsOn: Bool {
        return UserDefaults.standard.bool(forKey: Constants.coinSettingsLineGraph)
    }
    
    static func initializeStoryboard() -> CoinChartViewController? {
        return UIStoryboard(name: "CoinPrice", bundle: nil).instantiateViewController(withIdentifier: CoinChartViewController.name) as? CoinChartViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(addFavorite(_:)), name: .addFavorite, object: nil)
        Loading.shared.startLoadingForView(with: graphBackgroundView)
        setupGraph(for: timeSelectorView.currentTime)
        timeSelected(time: timeSelectorView.currentTime)
        self.favoriteButton.setBackgroundImage(UIImage(named: "details_heart"), for: .normal)
        if coinsDatas.count == 0 {
            chartView.clear()
        }
    }
    
    @objc func addFavorite(_ notification: NSNotification) {
        if let coin = notification.userInfo?["favoriteCoin"] as? CoinModel {
            for favorite in selectedCoins {
                favorite.isFavorite = coin.isFavorite
            }
            loadingSetup()
        }
    }
    
    override func themeChanged() {
        super.themeChanged()
        chartView.noDataTextColor = darkMode ? .white : .black
    }
    
    override func languageChanged() {
        chartView.noDataText = "no_chart_data".localized()
        setCoinChartTitle(coin: selectedCoins.first)
    }
    
    // Detect device orientation changes for ipad
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        checkDeviceOrientation(landscape: UIApplication.shared.statusBarOrientation.isPortrait)
    }
}

// MARK: - Startup setup
extension CoinChartViewController {
    fileprivate func startupSetup() {
        configTable()
        //        setTableData()
        setupNavigation()
        setupDate()
        configGraphBackground()
        checkDeviceOrientation(landscape: UIApplication.shared.statusBarOrientation.isLandscape)
        checkCoin()
        configDetailsButtons()
    }
    
    fileprivate func loadingSetup() {
        setTableData()
        themeChanged()
        setupGraph(for: timeSelectorView.currentTime)
        timeSelected(time: timeSelectorView.currentTime)
        configFavoriteButton()
        if coinsDatas.count == 0 {
            chartView.clear()
        }
        
    }
    
    fileprivate func setupGraph(for time: GraphTimeFilter) {
        chartView.isHidden = true
        chartView.delegate = self
        
        //        if let first = selectedCoins.first {
        //            favoriteCoins.removeAll { $0 == first }
        //        }
        
        selectDefaultTime(time: time)
    }
    
    fileprivate func configGraphBackground() {
        graphBackgroundView.clipsToBounds = true
        graphBackgroundView.layer.cornerRadius = 10
        
    }
    
    fileprivate func configFavoriteButton() {
        for coin in selectedCoins {
            if coin.isFavorite {
                self.favoriteButton.setBackgroundImage(UIImage(named: "details_heart_fill"), for: .normal)
            } else {
                self.favoriteButton.setBackgroundImage(UIImage(named: "details_heart"), for: .normal)
            }
        }
    }
    
    fileprivate func configDetailsButtons () {
        
        convertorButton.addTarget(self, action: #selector(coinConverterAction), for: .touchUpInside)
        alertButton.addTarget(self, action: #selector(coinAlertAction), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(coinFavoriteAction), for: .touchUpInside)
        
    }
    @objc private func coinAlertAction() {
        guard let newVC = AddCoinAlertViewController.initializeStoryboard() else { return }
        for coins in selectedCoins {
            let selectedCoin = coins
            newVC.setCoinForAlert(selectedCoin)
        }
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    @objc private func coinConverterAction() {
        let sb = UIStoryboard(name: "More", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ConverterViewController") as! ConverterViewController
        for coins in selectedCoins {
            vc.headerCoinId = coins.coinId
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc private func coinFavoriteAction() {
        guard let user = self.user else {
            goToLoginPage()
            return
        }
        for coin in selectedCoins {
            if coin.isFavorite {
                Loading.shared.startLoading(ignoringActions: true, for: tableView)
                CoinRequestService.shared.deleteFromFavorites(userId: user.id, coinId: coin.coinId, success: { (String) in
                    self.showToastAlert("", message: String.localized())
                    WidgetCointManager.shared.removeCoin(coin.coinId)
                    coin.isFavorite = false
                    self.favoriteCoins.removeAll { $0.coinId == coin.coinId }
                    Loading.shared.endLoading(for: self.tableView)
                    self.favoriteButton.setBackgroundImage(UIImage(named: "details_heart"), for: .normal)
                    let param = ["deleteFavorite": coin]
                    NotificationCenter.default.post(name: .deleteFavorite, object: nil, userInfo: param)
                }, failer: { (error) in
                    Loading.shared.endLoading()
                    self.showAlertView("", message: error, completion: nil)
                })
            } else {
                Loading.shared.startLoading(ignoringActions: true, for: tableView)
                CoinRequestService.shared.addToFavorites(userId: user.id, coinId: coin.coinId, success: { (CoinModel,String) in
                    self.showToastAlert("", message: String.localized())
                    Loading.shared.endLoading()
                    coin.isFavorite = true
                    self.favoriteButton.setBackgroundImage(UIImage(named: "details_heart_fill"), for: .normal)
                    let param = ["favoriteCoin": coin]
                    NotificationCenter.default.post(name: .addFavorite, object: nil, userInfo: param)
                    self.favoriteCoins.append(coin)
                }) { (error) in
                    Loading.shared.endLoading(for: self.tableView)
                    self.showAlertView("", message: error, completion: nil)
                }
            }
        }
        
    }
    
    fileprivate func setupNavigation() {
        shareItem = UIBarButtonItem(image: UIImage(named: "share"), style: .done, target: self, action: #selector(share))
        settingsItem = UIBarButtonItem(image: UIImage(named: "coin_graph_settings")?.withRenderingMode(.alwaysTemplate), style: .done, target: self, action: #selector(settingsButtonAction(_:)))
        navigationItem.setRightBarButtonItems([settingsItem, shareItem], animated: true)
    }
    
    fileprivate func setupDate() {
        dateSelectorView.setStyle(.coinChart)
        dateSelectorView.delegate = self
        
        datePriceLabel.backgroundColor = .textFieldBackground
        datePriceLabel.cornerRadius(radiusType: .half)
    }
    
    fileprivate func selectDefaultTime(time: GraphTimeFilter) {
        chartView.clear()
        timeSelectorView.delegate = self
        timeSelectorView.selectTime(time)
    }
    
    fileprivate func setTableData() {
        guard let coin = selectedCoins.first else { return }
        
        let market_cap_usd = "market_cap_usd".localized().replacingOccurrences(of: "USD", with: Locale.appCurrency)
        let price_usd = "price_usd".localized().replacingOccurrences(of: "USD", with: Locale.appCurrency)
        
        tableData.append((key: "coin_sort_rank", value: "\(coin.rank)"))
        tableData.append((key: market_cap_usd, value:  "\(Locale.appCurrencySymbol) " + (coin.marketCapUsd * (rates?[Locale.appCurrency] ?? 1.0)).formatUsingAbbrevation()))
        tableData.append((key: price_usd, value: "\(Locale.appCurrencySymbol) " + (coin.marketPriceUSD * (rates?[Locale.appCurrency] ?? 1.0)).getString()))
        tableData.append((key: "price_btc", value: "฿ " + coin.marketPriceBTC.getString()))
        tableData.append((key: "last_updated", value: coin.lastUpdated.getDateFromUnixTime()))
        tableData.append((key: "change_1_hour", value: coin.change1h.getString()))
        tableData.append((key: "change_24_hour", value: coin.change24h.getString()))
        tableData.append((key: "change_7_day", value: coin.change7d.getString()))
        
        if let volumeUSD = coin.volumeUSD {
            let key = "volume".localized() + " " + "24h".localized()
            tableData.append((key: key, value:"\(Locale.appCurrencySymbol) " + volumeUSD.formatUsingAbbrevation()))
        }
        if let totalSupply = coin.totalSupply {
            tableData.append((key: "total_supply", value: totalSupply.getFormatedString()))
        }
        if let availableSupply = coin.availableSupply {
            tableData.append((key: "max_supply", value: availableSupply.getFormatedString()))
        }
        
        tableViewHeightConstraint.constant = CGFloat(tableData.count * 35)
        tableView.reloadData()
    }
    
    fileprivate func configTable() {
        tableView.separatorColor = .separator
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    fileprivate func checkCoin() {
        if selectedCoins.isEmpty {
            getCoin()
        } else {
            linkSetup()
            loadingSetup()
        }
    }
}

// MARK: - Link Setup
extension CoinChartViewController {
    private func linkSetup() {
        websiteButtonsSetup()
        linkParentView.backgroundColor = .tableCellBackground
        linkParentView.layer.cornerRadius = 10
        exploreatursLabel.setLocalizableText("explorers")
        
        exploreatursHeightConstraint.constant = expLinks.isEmpty ? 0 : 30
        linkTableViewHeightConstraint.constant = CGFloat(expLinks.count * 35)
        
        linkTableView.delegate = self
        linkTableView.dataSource = self
        linkTableView.separatorStyle = .none
        linkTableView.reloadData()
        view.layoutIfNeeded()
    }
    
    private func websiteButtonsSetup() {
        guard let coin = selectedCoins.first else { return }
        
        websiteButton.setImage(UIImage(named: "website"), for: .normal)
        twitterButton.setImage(UIImage(named: "community_twitter"), for: .normal)
        redditButton.setImage(UIImage(named: "community_reddit"), for: .normal)
        
        websiteButton.addTarget(self, action: #selector(buttunAction(sender:)), for: .touchUpInside)
        twitterButton.addTarget(self, action: #selector(buttunAction(sender:)), for: .touchUpInside)
        redditButton.addTarget(self, action: #selector(buttunAction(sender:)), for: .touchUpInside)
        
        websiteButton.isHidden = coin.websiteUrl == nil
        twitterButton.isHidden = coin.twitterUrl == nil
        redditButton.isHidden = coin.redditUrl == nil
        let buttonsIsHidden = websiteButton.isHidden && twitterButton.isHidden && redditButton.isHidden
        linkParentView.isHidden = buttonsIsHidden && expLinks.isEmpty
        
        websiteButtonsHeightConstraint.constant = buttonsIsHidden ? 0 : 30
    }
    
    @objc private func buttunAction(sender: BackgroundButton) {
        var urlStr = ""
        guard let coin = selectedCoins.first else { return }
        
        switch sender.tag {
        case 0:
            urlStr = coin.websiteUrl ?? ""
            openApp(appString: "nil", webString: urlStr)
        case 1:
            urlStr = coin.twitterUrl ?? ""
            let fileURL = URL(fileURLWithPath: urlStr)
            openApp(appString: "twitter:///user?screen_name=\(fileURL.lastPathComponent)", webString: urlStr)
        case 2:
            urlStr = coin.redditUrl ?? ""
            let fileURL = URL(fileURLWithPath: urlStr)
            openApp(appString: "reddit:///r/\(fileURL.lastPathComponent)", webString: urlStr)
        default:
            return
        }
    }
    
    private func openApp(appString: String, webString: String) {
        guard let appURL = URL(string: appString), let webURL = URL(string: webString) else { return }
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL)
            }
        } else {
            //redirect to browser because the user doesn't have application
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(webURL)
            }
        }
    }
}

// MARK: - TableView methods
extension CoinChartViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = tableView == linkTableView ? expLinks.count : tableData.count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == linkTableView {
            let cell = BaseTableViewCell()
            cell.textLabel?.text = expLinks[indexPath.row]
            cell.textLabel?.textColor = .barSelectedItem
            cell.backgroundColor = .clear
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailsTableViewCell.name) as! DetailsTableViewCell
        cell.setCoinGraphData(list: tableData, indexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == linkTableView {
            openURL(urlString: expLinks[indexPath.row])
        }
    }
}

// MARK: - Actions
extension CoinChartViewController {
    private func getFavoriteCoin() {
        Loading.shared.startLoading()
        CoinRequestService.shared.getFavoritesCoins { (favoriteCoins) in
            self.favoriteCoins = favoriteCoins
            self.tableView.reloadData()
            Loading.shared.endLoading()
        } failer: { (error) in
            Loading.shared.endLoading()
            self.showAlertView("", message: error.localized(), completion: nil)
        }
    }
    
    private func getDataFromServer(timeZone: GraphTimeFilter, received: @escaping(Bool) -> Void) {
//        Loading.shared.startLoading()
        var receivedData = [(order: Int, coin: CoinModel, data: [ChartDataEntry])]()
        for (index, coin) in selectedCoins.enumerated() {
            if let selectedCoin = chartSavedData[coin], let graphData = selectedCoin[timeZone] {
                let data = graphData.data
                receivedData.append((order: index, coin: coin, data: data))
                if receivedData.count == self.selectedCoins.count {
                    self.coinsDatas = receivedData.sorted { $0.order < $1.order }
                    received(true)
                }
            } else {
                chartView.noDataText = ""
                Loading.shared.startLoadingForView(with: graphBackgroundView)
                CoinRequestService.shared.getCoinGraph(coinId: coin.coinId, period: timeZone.rawValue, success: { (graphData) in
                    let data = graphData.map { (item) -> ChartDataEntry in
                        return ChartDataEntry(x: item.date, y: item.usd * (self.rates?[Locale.appCurrency] ?? 1.0))
                    }
                    guard data.count > 0 else {
                        Loading.shared.endLoading()
                        Loading.shared.endLoadingForView(with: self.graphBackgroundView)
                        self.chartView.clear()
                        received(false)
                        self.drawGraph()
                        return
                    }
                    
                    if let _ = self.chartSavedData[coin] {
                        self.chartSavedData[coin]![timeZone] = (order: index, coin: coin, data: data)
                    } else {
                        let value = [timeZone: (order: index, coin: coin, data: data)]
                        self.chartSavedData[coin] = value
                    }
                    
                    receivedData.append((order: index, coin: coin, data: data))
                    
                    if receivedData.count == self.selectedCoins.count {
                        self.coinsDatas = receivedData.sorted { $0.order < $1.order }
                        received(true)
                    }
                }) { (error) in
                    received(false)
                    Loading.shared.endLoading()
                    self.drawGraph()
                }
            }
        }
    }
    
    private func getCoin() {
        if !landscape {
            Loading.shared.startLoading()
        }
        CoinRequestService.shared.getCoin(coinID: coinId.urlEncoded()) { (coin) in
            self.selectedCoins.append(coin)
            Loading.shared.endLoading()
            for favorite in self.selectedCoins {
                favorite.isFavorite = self.isFavorite ?? false
                if self.isFavorite == nil {
//                    Loading.shared.startLoading()
                    CoinRequestService.shared.getFavoritesCoins { (favoriteCoins) in
                        self.favoriteCoins = favoriteCoins
                        for favoriteCoin in self.favoriteCoins {
                            if favorite.coinId == favoriteCoin.coinId {
                                favorite.isFavorite = true
                                self.configFavoriteButton()
                            }
                        }
                        self.tableView.reloadData()
                    } failer: { (error) in
                        Loading.shared.endLoading()
                        self.showAlertView("", message: error.localized(), completion: nil)
                    }
                    
                }
            }
            DispatchQueue.main.async {
                self.linkSetup()
                self.loadingSetup()
                
            }
        } failer: { (error) in
            Loading.shared.endLoading()
            Loading.shared.endLoadingForView(with: self.graphBackgroundView)
            self.drawGraph()
            self.showAlertView("", message: error.localized(), completion: nil)
        }
    }
    
    fileprivate func getMinMax (arr : [ChartDataEntry]) -> (ChartDataEntry,ChartDataEntry) {
        let n = arr.count
        var max = ChartDataEntry()
        var min = ChartDataEntry()
        var i = 0
        if n % 2 == 0 {
            
            if arr[0].y > arr[1].y {
                
                max = arr[0]
                min = arr[1]
                
            } else {
                
                min = arr[0]
                max = arr[1]
            }
            
            i = 2
            
        } else {
            
            min = arr[0]
            max = arr[0]
            i = 1
            
        }
        
        while (i < n - 1) {
            
            if arr[i].y > arr [i + 1].y {
                if arr[i].y > max.y {
                    max =  arr[i]
                }
                if arr[i + 1].y < min.y {
                    min =  arr[i + 1]
                }
            } else {
                if arr[i + 1].y > max.y {
                    max =  arr[i + 1]
                }
                if arr[i].y < min.y {
                    min =  arr[i]
                }
                
            }
            
            i += 2
        }
        return (max, min)
    }
    
    fileprivate func setDrawIcons(LineData : LineChartData)  {
        var highImage = UIImage()
        var lowImage = UIImage()
        if #available(iOS 10.0, *) {
            highImage = (UIImage(named: "charts_high_image")?.scaled(toWidth: 10))!
            lowImage = (UIImage(named: "charts_low_image")?.scaled(toWidth: 10))!
        }
        min = 0.0
        max = 0.0
        for i in 0..<LineData.dataSetCount {
            let yMin = LineData.getDataSetByIndex(i).yMin
            let yMax = LineData.getDataSetByIndex(i).yMax
            
            let entryCount = LineData.getDataSetByIndex(i).entryCount
            for j in 0..<entryCount {
                let y = LineData.getDataSetByIndex(i).entryForIndex(j)?.y
                let x = LineData.getDataSetByIndex(i).entryForIndex(j)?.x
                if yMin == yMax {
                    if max == 0.0 && min == 0.0 {
                        max = yMax
                        min = yMin
                    }
                } else {
                    if y == yMin {
                    if min == 0.0 {
                        LineData.getDataSetByIndex(i).entryForXValue(x!, closestToY: Double.nan)?.icon = lowImage
                    }
                    if yMin != 0 {
                        min = yMin
                    } else {
                        min = 1
                    }
                } else if y == yMax {
                    if max == 0.0 {
                        LineData.getDataSetByIndex(i).entryForXValue(x!, closestToY: Double.nan)?.icon = highImage
                   }
                    if yMax != 0 {
                        max = yMax
                    } else {
                        max = 1
                    }
                }
             }
          }
       }
    }
    // MARK: - Draw graph
    private func drawGraph() {
        chartView.isHidden = false
        
        var dataSets = [LineChartDataSet]()
        
        for (i, item) in coinsDatas.enumerated() {
            var chartDataSet = LineChartDataSet(entries: item.data, label: "\(item.coin.name) (\(item.coin.symbol))")
            chartDataSet.sort { $0.x < $1.x }
            dataSets.append(chartDataSet)
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: Localize.currentLanguage())
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
            let minMax = getMinMax(arr: item.data)
            highValueLabel.setLocalizableText(Locale.appCurrencySymbol + " " + "\(chartDataSet.yMax.getString())")
            lowValueLabel.setLocalizableText(Locale.appCurrencySymbol + " " + "\(chartDataSet.yMin.getString())")
            highDateLabel.setLocalizableText("\(minMax.0.x.getDateFromUnixTime())")
            lowDateLabel.setLocalizableText("\(minMax.1.x.getDateFromUnixTime())")
            
            let lineGraph = lineGraphIsOn
            chartDataSet.fillAlpha = 0.6
            chartDataSet.drawValuesEnabled = false
            chartDataSet.drawFilledEnabled = !lineGraph
            
            let colorArray = UIColor.graphLineGradientColors[i]
            chartDataSet.drawCirclesEnabled = false
            chartDataSet.circleRadius = 4.0
            chartDataSet.circleHoleRadius = 2.0
            chartDataSet.lineWidth = lineGraph ? 1 : 0
            chartDataSet.setColor(colorArray.first!)
            
            
            if selectedCoins.count > 1 || dataSets.count == 0 {
            GraphViewTopConstraint.constant = 10
            HighLowVIew.isHidden = true
            chartDataSet.drawIconsEnabled = false
            } else {
            GraphViewTopConstraint.constant = 50
            HighLowVIew.isHidden = false
            chartDataSet.drawIconsEnabled = true
            }
            
            let gradientColors = colorArray.map { $0.cgColor } as CFArray
            let colorLocations: [CGFloat] = [0, 1]
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) {
                chartDataSet.fill = Fill.fillWithLinearGradient(gradient, angle: 0)
            }
            
            // Selection cross configs
            chartDataSet.highlightColor = darkMode ? .white : .textBlack
            chartDataSet.highlightLineWidth = 0.5
        }
        chartView.maxVisibleCount = 10000
        chartView.chartDescription?.text = ""
        chartView.data = LineChartData(dataSets: dataSets)
        chartView.animate(xAxisDuration: 1.0)
        setDrawIcons(LineData: chartView.data as! LineChartData )
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.valueFormatter = currentTime == GraphTimeFilter.day ? DateChartFormatter() : DateChartFormatter(dateFormat: "dd/MM/yy")
        xAxis.axisLineColor = darkMode ? .white : .black
        xAxis.labelTextColor = darkMode ? .white : .black
        xAxis.enabled = horizontalLineIsOn
        
        if currentTime == .treeMonth {
            xAxis.setLabelCount(5, force: false)
        }
        
        chartView.legend.textColor = darkMode ? .white : .black
        chartView.leftAxis.axisLineColor = darkMode ? .white : .black
        chartView.rightAxis.drawLabelsEnabled = false
        
        let leftAxis = chartView.leftAxis
        leftAxis.valueFormatter = PriceChartFormatter()
        leftAxis.axisLineColor = darkMode ? .white : .black
        leftAxis.labelTextColor = darkMode ? .white : .black
        leftAxis.labelPosition = .outsideChart
        leftAxis.enabled = verticalLineIsOn
        
        if let Ymin = chartView.data?.yMin  {
            if Ymin < 1 {
                chartView.leftAxis.axisMinimum = 0
                chartView.rightAxis.axisMinimum = 0
            }
        }
        
        if coinsDatas.count == 0 {
            chartView.clear()
        }
        
        Loading.shared.endLoading()
        Loading.shared.endLoadingForView(with: graphBackgroundView)
        languageChanged()
    }
    
    fileprivate func checkDeviceOrientation(landscape: Bool) {
        if landscape {
            self.landscape = landscape
        }
        guard UIDevice.current.userInterfaceIdiom == .pad else { return }
        
        if landscape {
            hideTableView()
        } else {
            showTableView()
        }
    }
    
    // MARK: - UI actions
    @objc fileprivate func settingsButtonAction(_ sender: UIBarButtonItem) {
        guard let navigation = ChartSettingsViewController.initializeNavigationStoryboard() else { return }
        if let controller = navigation.viewControllers.first as? ChartSettingsViewController {
            controller.delegate = self
            if selectedCoins.count > 1 {
                controller.setComparisionCoin(selectedCoins[1])
            }
            controller.setFavoriteCoins(favoriteCoins)
        }
        navigation.view.backgroundColor = .clear
        navigation.modalPresentationStyle = .overCurrentContext
        tabBarController?.present(navigation, animated: true, completion: nil)
    }
    
    @objc fileprivate func share(_ sender: UIBarButtonItem) {
        guard navigationItem.titleView != nil else { return }
        let views: [UIView] = [navigationItem.titleView!, HighLowVIew, graphBackgroundView, dateContentView, tableView, linkParentView,  ]
        ShareManager.share(self, drawViews: views, fileName: "CoinChart")
    }
}

// MARK: - Charts delegate
extension CoinChartViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Localize.currentLanguage())
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        let time = entry.x.getDateFromUnixTime()
        let price = entry.y
        selectedDateLabel.setLocalizableText("\(time)")
        selectedPriceLabel.setLocalizableText( Locale.appCurrencySymbol + " " + price.getString()  )
    }
}

// MARK: - Graph time selector delegate
extension CoinChartViewController: GraphTimeSelectorDelegate {
     func timeSelected(time: GraphTimeFilter) {
        guard selectedCoins.count != 0 else { return }
        getDataFromServer(timeZone: time) { (received) in
            if received {
                self.currentTime = time
                self.setupGraph(for: self.currentTime)
                self.drawGraph()
                self.resetValues()
            }
        }
    }
    
    func resetValues() {
        selectedPriceLabel.text = ""
        selectedDateLabel.text = ""
    }
}

// MARK: - Chart settings delegate
extension CoinChartViewController: ChartSettingsViewControllerDelegate {
    func settingsChanged(horizontalLine: Bool, verticalLine: Bool, lineGraph: Bool) {
        UserDefaults.standard.set(lineGraph, forKey: Constants.coinSettingsLineGraph)
        UserDefaults.standard.set(verticalLine, forKey: Constants.coinSettingsVertical)
        UserDefaults.standard.set(horizontalLine, forKey: Constants.coinSettingsHorizontal)
        drawGraph()
    }
    
    func compareCoin(coin: CoinModel?) {
        if selectedCoins.count > 1 {
            selectedCoins.removeLast()
        }
        if let secondCoin = coin {
            selectedCoins.append(secondCoin)
        }
        timeSelected(time: timeSelectorView.currentTime)
    }
}

// MARK: - Chart settings delegate
extension CoinChartViewController: DateSelectorViewDelegate {
    func dateSelected(sender: DateSelectorView, date: Date) {
        guard let coinId = selectedCoins.first?.coinId else { return }
        CoinRequestService.shared.getDatePrice(coinId, date: date.timeIntervalSince1970) { [weak self] datePrice in
            guard let self = self else { return }
            self.datePriceLabel.text = "\(Locale.appCurrencySymbol) " + datePrice.convertedPrice.getFormatedString()
        } failer: { error in
            self.datePriceLabel.text = nil
            self.showAlertView(nil, message: error, completion: nil)
        }
    }
    
}

// MARK: - Set data
extension CoinChartViewController {
    public func setCoin(coin: CoinModel) {
        isFavorite = coin.isFavorite
        
    }
    
    public func setCoinId(_ coinId: String) {
        self.coinId = coinId
    }
    
    public func setFavoriteCoins(_ coins: [CoinModel]) {
        favoriteCoins = coins
    }
}

// MARK: - Animations
extension CoinChartViewController {
    fileprivate func hideTableView() {
        guard tableView.isHidden == false else { return }
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.tableView.alpha = 0
            self.chartBottomConstraint.priority = UILayoutPriority(rawValue: 999)
            self.view.layoutIfNeeded()
        }) { (_) in
            self.tableView.isHidden = true
        }
    }
    
    fileprivate func showTableView() {
        guard tableView.isHidden else { return }
        tableView.isHidden = false
        UIView.animate(withDuration: Constants.animationDuration) {
            self.tableView.alpha = 1
            self.chartBottomConstraint.priority = .defaultHigh
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Helpers
@objc(PriceChartFormatter)
public class PriceChartFormatter: NSObject, IAxisValueFormatter {
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return  Locale.appCurrencySymbol + value.formatUsingAbbrevation()
    }
}
