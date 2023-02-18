//
//  AnalyticsViewController.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 2/7/20.
//  Copyright © 2020 WitPlex. All rights reserved.
//

import UIKit
import Charts
import Localize_Swift

import FirebaseCrashlytics

class AnalyticsViewController: BaseViewController {
    
    @IBOutlet weak var arrowContainerView: UIView!
    @IBOutlet weak var contentView: BaseView!
    @IBOutlet weak var segmentParentView: BarCustomView!
    @IBOutlet weak var segmentControlView: BaseSegmentControl!
    @IBOutlet weak var pieParentView: BarCustomView!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var barChartView: HorizontalBarChartView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var barChartViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pieChartHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var analyticsArrowButton: UIButton!
    @IBOutlet weak var arrowActionView: UIView!
    
    @IBOutlet weak var legendLabel: BaseLabel!
    @IBOutlet weak var legendColorView: UIView!
    @IBOutlet weak var legendImageView: UIImageView!
    @IBOutlet weak var legendStackView: UIStackView!
    
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    private var shortPoolNames: [String] = []
    private var poolNamesData: [String] = []
    private var poolPercentData: [Double] = []
    private var poolUrlData: [String?] = []
    
    private var coinNamesData: [String] = []
    private var shortCoinNames: [String] = []
    private var coinPercentData: [Double] = []
    
    private var analyticsPoolData: [AnalyticsModel] = []
    private var analyticsCoinData: [AnalyticsModel] = []
    
    private var barChartPoolData: [BarChartDataModel] = []
    private var barChartCoinData: [BarChartDataModel] = []
    
    private var currentIndex = 0
    private var refreshControll: UIRefreshControl?
    private var lastLabel = ""
    
    private var currentPoolCoinsNames: [String] = []
    
    private var currentPoolLegendName: String = ""
    private var currentCoinLegendName: String = ""
    
    private var lastPoolSubItems: [String: Double]?
    private var lastCoinSubItems: [String: Double]?
    
    private var isSelectedPool = true
    
    private var initialPoolIndex: Int?
    private var initialCoinIndex: Int?
    private var isOpenedFirst = true
    
    private var shareItem: UIBarButtonItem?
    private var isArrowAnimationFinished = false
    private var arrowGesture: UITapGestureRecognizer?
    
    // MARK: - Static
    static func initializeStoryboard() -> AnalyticsViewController? {
        return UIStoryboard(name: "More", bundle: nil).instantiateViewController(withIdentifier: AnalyticsViewController.name) as? AnalyticsViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGesture()
//        controllPieChartHeight()
        initialSetup()
        setupRefreshControll()
        setupNavigation()
        setupSegmentControl()
        setup(pieChartView: pieChartView)
        setup(barChartView: barChartView)
        donwloadAnalyticsData()
    }
    
    private func addGesture() {
        let coinChartGestre = UITapGestureRecognizer(target: self, action: #selector(legendSelect))
        arrowGesture = UITapGestureRecognizer(target: self, action: #selector(scrollPageDown))
        arrowActionView.addGestureRecognizer(arrowGesture!)
        legendStackView.addGestureRecognizer(coinChartGestre)
        analyticsArrowButton.isHidden = true
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        startAnimation()
//    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        controllPieChartHeight()
    }
    
    //MARK: - Animation
    @objc private func scrollPageDown() {
        scrollView.setContentOffset(CGPoint(x: 0, y: 100), animated: true)
    }
    
    fileprivate func checkArrowDownAnimation() {
        view.layoutIfNeeded()
        print(scrollView.contentSize.height)
        print(view.bounds.height)
        
        if scrollView.contentSize.height > view.bounds.height {
            startAnimation()
        } else {
            removeArrowAnimations()
        }
    }
    
    private func startAnimation() {
        let positionAnim = constructPositionAnimation()
        let scaleAnim = constructScaleAnimation()
        let opacityAnim = constructOpacityAnimation()
        
        analyticsArrowButton.layer.add(positionAnim, forKey: nil)
        analyticsArrowButton.layer.add(scaleAnim, forKey: nil)
        analyticsArrowButton.layer.add(opacityAnim, forKey: nil)
        analyticsArrowButton.isHidden = false
        arrowContainerView.isHidden = false
        isArrowAnimationFinished = false
    }
    
   private func constructPositionAnimation() -> CABasicAnimation {
    let size = analyticsArrowButton.frame.width
    let startingValue = CGPoint(x: size + size / 3, y: size)
        let endingValue = CGPoint(x: size + size / 3, y: size + 20)
        
        let positionAnimation = CABasicAnimation(keyPath: "position")
        positionAnimation.fromValue = startingValue
        positionAnimation.toValue = endingValue
        positionAnimation.duration = 2
        positionAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        positionAnimation.repeatCount = Float.infinity
        positionAnimation.fillMode = .forwards
        
        return positionAnimation
    }
    
    private func constructOpacityAnimation() -> CABasicAnimation {
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0
        opacityAnimation.toValue = 0.6
        opacityAnimation.duration = 2
        opacityAnimation.repeatCount = Float.infinity
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        opacityAnimation.fillMode = .forwards
        
        return opacityAnimation
    }
    
    private func constructScaleAnimation() -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1
        scaleAnimation.toValue = 0.6
        scaleAnimation.duration = 2
        scaleAnimation.repeatCount = Float.infinity
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        scaleAnimation.fillMode = .forwards
        
        return scaleAnimation
    }
    
    private func removeArrowAnimations() {
        analyticsArrowButton.layer.removeAllAnimations()
        analyticsArrowButton.isHidden = true
        arrowContainerView.isHidden = true
        isArrowAnimationFinished = true
    }
    
    //MARK: - Setup
    private func controllPieChartHeight() {
        if view.isLandscape {//UIDevice.current.orientation.isLandscape {
            pieChartHeightConstraint.constant = (view.frame.size.height + tabBarHeight + topBarHeight) * 0.9
        } else {
            pieChartHeightConstraint.constant = view.frame.size.width * 0.9
        }
    }
    
    private func setupRefreshControll() {
        refreshControll = UIRefreshControl()
        refreshControll?.addTarget(self, action: #selector(updateAllData), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            scrollView.refreshControl = refreshControll
        } else {
            if let refreshControll = refreshControll {
                scrollView.addSubview(refreshControll)
            }
        }
    }
    
    private func initialSetup() {
        navigationController?.navigationBar.shadowImage = UIImage()
        contentView.backgroundColor = .clear
        barChartView.backgroundColor = .tableCellBackground
        barChartView.cornerRadius(radius: 10)
        
        axisFormatDelegate = self
        barChartView.isHidden = true
        initialLegendSetup()
    }
    
    private func setupNavigation() {
        title = "more_analytics".localized()
        shareItem = UIBarButtonItem(image: UIImage(named: "share"), style: .done, target: self, action: #selector(sharePage))
        
        //Enable after fixing photo access permission problem, when share and save to photos
        navigationItem.setRightBarButton(shareItem, animated: false)
    }
    
    @objc private func sharePage() {
        let drawViews: [UIView] = [segmentParentView, contentView]
        ShareManager.share(self,
                           drawViews: drawViews,
                           spaces: [0, 0],
                           removedView: arrowContainerView,
                           fileName: "Analitics")
    }
    
    private func setupSegmentControl() {
        segmentControlView.delegate = self
        
        let pool = "notifications_pool_alerts".localized()
        let coin = "notifications_coin_alerts".localized()
        segmentControlView.setSegments([pool, coin])
        segmentControlView.selectSegment(index: 0)
    }
    
    // MARK: -- Pi chart setup
    private func setup(pieChartView chartView: PieChartView) {
        chartView.delegate = self
        chartView.usePercentValuesEnabled = true
        chartView.holeRadiusPercent = 0.1
        chartView.holeColor = darkMode ? .black : .white
        chartView.transparentCircleRadiusPercent = 1
        chartView.transparentCircleColor = darkMode ? UIColor.black.withAlphaComponent(0.5) : UIColor.white.withAlphaComponent(0.5)
        
        chartView.legend.enabled = false
        chartView.legend.textColor = darkMode ? .white : .black
        chartView.legend.horizontalAlignment = .center
        chartView.legend.formSize = 10
        chartView.legend.font = .systemFont(ofSize: 12, weight: .light)
     
        chartView.rotationWithTwoFingers = true
        chartView.entryLabelColor = darkMode ? .white : .black
        chartView.entryLabelFont = .systemFont(ofSize: 12, weight: .light)
        
        chartView.noDataText = ""
    }
    
    private func setPiChartData(with names: [String], values: [Double]) {
        var entries: [ChartDataEntry] = []
        
        for i in 0 ..< names.count {
            let entry = PieChartDataEntry(value: values[i], label: names[i])
            
            entries.append(entry)
        }
        
        let set = PieChartDataSet(entries: entries)
        
        //set.colors = darkMode ? AnalyticsColor.darkAnaliticsColor : AnalyticsColor.lightAnaliticsColor
        set.colors = AnalyticsColor.darkAnaliticsColor
        set.sliceSpace = 1

        set.valueLineColor = darkMode ? .white : .black
        set.xValuePosition = .outsideSlice
        set.selectionShift = 10
        set.valueLinePart1Length = 1
        set.valueLinePart2Length = 0.8

        let data = PieChartData(dataSet: set)
        data.setValueFormatter(PieChartValueFormatter())
        data.setValueFont(.systemFont(ofSize: 11, weight: .light))
        data.setValueTextColor(darkMode ? NSUIColor.white : NSUIColor.black)
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            pieChartView.setExtraOffsets(left: 60.0, top: 0.0, right: 60.0, bottom: 0.0)
        } else {
            pieChartView.setExtraOffsets(left: 25.0, top: 0.0, right: 25.0, bottom: 0.0)
        }
        
        pieChartView.data = data
        pieChartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
    }
    
    // MARK: -- Bar chart setup
    private func setup(barChartView chartView: HorizontalBarChartView) {
        chartView.delegate = self
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = false
        chartView.legend.enabled = false
        chartView.rightAxis.enabled = false
        chartView.notifyDataSetChanged()
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.labelCount = 15
        xAxis.labelTextColor = darkMode ? .white : .black
//        xAxis.labelRotationAngle = -30
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.valueFormatter = YAxisValueFormatter()
        leftAxis.labelPosition = .outsideChart
//        leftAxis.spaceTop = 100
        leftAxis.spaceMax = 0.8
        leftAxis.spaceMin = 0.8
        leftAxis.spaceTop = 20
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = 100
        leftAxis.labelTextColor = darkMode ? .white : .black
        
        let l = chartView.legend
        l.textColor = darkMode ? .white : .black
        l.horizontalAlignment = .center
        l.verticalAlignment = .top
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .circle
        l.formSize = 9
        l.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        l.xEntrySpace = 4
        
        chartView.extraTopOffset = 10
        chartView.extraRightOffset = 25
//        chartView.setExtraOffsets(left: 25, top: 10, right: 25, bottom: 0)
    }
    
    private func setupBarChartData(_ data: [String: Double]) {
        currentPoolCoinsNames = []
        barChartView.isHidden = false
//        barChartView.xAxis.axisMaximum = Double(data.count)
        barChartView.xAxis.labelCount = data.count
        print(barChartView.xAxis.axisMaximum)
        barChartViewHeightConstraint.constant = 25 + CGFloat(data.count * 25)
        
        var start = Double(data.count)
        var entries: [BarChartDataEntry] = []
        
        let sortedData = data.sorted { $0.1 < $1.1 }
        for (name, percent) in sortedData {
            currentPoolCoinsNames.append(name)
            let entry = BarChartDataEntry(x: Double(sortedData.count) - start, y: percent, data: name)
            entries.append(entry)
            start = start - 1
        }
        
        let set =  BarChartDataSet(entries: entries)
        set.colors = AnalyticsColor.darkAnaliticsColor
        set.drawValuesEnabled = false
        
        let data = BarChartData(dataSet: set)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
        data.barWidth = 0.9
        
        barChartView.data = data
        let xAxisValue = barChartView.xAxis
        xAxisValue.valueFormatter = axisFormatDelegate
        barChartView.animate(yAxisDuration: 1.4, easingOption: .easeOutBack)
        
        currentLegendSetup()
        DispatchQueue.main.async {
            self.checkArrowDownAnimation()
        }
    }
    
    //MARK: - Legend
    private func initialLegendSetup() {
        let imageName = isSelectedPool ? "website_outh" : "details_section_header_arrow"
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        legendImageView.image = image
        legendImageView.tintColor = isSelectedPool ? .barSelectedItem : darkMode ? .white : .textBlack
    }
    
    private func currentLegendSetup() {
        let currentLegendIndex = (isSelectedPool ? initialPoolIndex : initialCoinIndex) ?? 0
        let legendColorIndex = currentLegendIndex % AnalyticsColor.darkAnaliticsColor.count
        let currentLegendName = isSelectedPool ? poolNamesData[currentLegendIndex] : coinNamesData[currentLegendIndex]
        let isOthers = isSelectedPool ? initialPoolIndex == analyticsPoolData.count - 1 : initialCoinIndex == analyticsCoinData.count - 1
        let iconIsShow = isSelectedPool ? (isOthers ? false :  poolUrlData[currentLegendIndex] != nil) : !isOthers
        
        legendLabel.text = currentLegendName
        legendColorView.backgroundColor = AnalyticsColor.darkAnaliticsColor[legendColorIndex]
        legendStackView.isHidden = false
        legendImageView.isHidden = !iconIsShow
        initialLegendSetup()
    }
    
    @objc private func legendSelect() {
        let isOthers = isSelectedPool ? initialPoolIndex == analyticsPoolData.count - 1 : initialCoinIndex == analyticsCoinData.count - 1
        guard !isOthers else { return }
        
        if isSelectedPool {
            guard let index = initialPoolIndex, let webUrl = poolUrlData[index] else { return }
            openURL(urlString: webUrl)
        } else {
            let coinId = analyticsCoinData[initialCoinIndex ?? 0].id
            openCoinChart(with: coinId)
        }
    }
    
    private func openCoinChart(with coinId: String) {
        guard let chartVC = CoinChartViewController.initializeStoryboard() else { return }
        
        chartVC.setCoinId(coinId)
        self.navigationController?.pushViewController(chartVC, animated: true)
    }
    
    // MARK: -- Downloading data
    @objc private func updateAllData() {
        if let refreshControll = refreshControll {
            donwloadAnalyticsData(with: refreshControll)
        }
    }
    
    private func donwloadAnalyticsData(with refreshControll: UIRefreshControl? = nil) {
        if refreshControll == nil {
            Loading.shared.startLoading(ignoringActions: true, views: [self.view, self.segmentControlView])
        }
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        AnalyticsRequestService.shared.getAnalyticsData(type: AnalyticsNames.pool.rawValue, success: { (analyticsPoolData) in
            self.analyticsPoolData = analyticsPoolData
            dispatchGroup.leave()
        }) { (error) in
            dispatchGroup.leave()
            debugPrint("Analytics_Pool_data download error")
        }
        
        dispatchGroup.enter()
        AnalyticsRequestService.shared.getAnalyticsData(type: AnalyticsNames.coin.rawValue, success: { (analyticsCoinData) in
            self.analyticsCoinData = analyticsCoinData
            dispatchGroup.leave()
        }) { (error) in
            dispatchGroup.leave()
            debugPrint("Analytics_Coin_data download error")
        }
        
        dispatchGroup.notify(queue: .main) {
            self.setupChartsInitialData()
            if refreshControll != nil {
                refreshControll?.endRefreshing()
            } else {
                Loading.shared.endLoading( views: [self.view, self.segmentControlView])
            }
//            if !self.isArrowAnimationFinished {
//               self.analyticsArrowButton.isHidden = false
//            }
        }
    }
    
    
    private func setupChartsInitialData() {
        guard let pools = DatabaseManager.shared.allPoolTypes else { return }
        
        resetChartInitialData()
        if analyticsPoolData.count != 0 {
            for data in analyticsPoolData {
                if data.id == "1000" {
                    shortPoolNames.append(Localized(AnalyticsNames.others.rawValue))
                    poolNamesData.append(Localized(AnalyticsNames.others.rawValue))
                    poolPercentData.append(data.percent)
                }
                
                for pool in pools {
                    if String(pool.poolId) == data.id {
                        let barChartData = getPoolSubItemsNames(subItems: data.subItems, for: pool)
                        poolNamesData.append(pool.poolName)
                        
                        if !pool.shortName.isEmpty {
                            shortPoolNames.append(pool.shortName)
                            if barChartData.count != 0 {
                                barChartPoolData.append(BarChartDataModel(name: pool.shortName, date: barChartData))
                            }
                        } else {
                            shortPoolNames.append(pool.poolName)
                            if barChartData.count != 0 {
                                barChartPoolData.append(BarChartDataModel(name: pool.poolName, date: barChartData))
                            }
                        }
                        poolPercentData.append(data.percent)
                        poolUrlData.append(pool.webUrl)
                        
                        break
                    }
                }
            }
        }
        
        if analyticsCoinData.count != 0 {
            for data in analyticsCoinData {
                if data.id == "1000" {
                    coinNamesData.append(Localized(AnalyticsNames.others.rawValue))
                    shortCoinNames.append(Localized(AnalyticsNames.others.rawValue))
                    coinPercentData.append(data.percent)
                    
                    continue
                }
                let barChartData = getCoinSubItemsNames(subItems: data.subItems, for: pools)
                coinNamesData.append(data.name)
                shortCoinNames.append(data.symbol)
                coinPercentData.append(data.percent)
                if barChartData.count != 0 {
                    barChartCoinData.append(BarChartDataModel(name: data.symbol, date: barChartData))
                }
            }
        }
        
        switch currentIndex {
        case 0:
            setupInitialChartData()
            setPiChartData(with: shortPoolNames, values: poolPercentData)
            debugPrint("SHORT pool names is ---- \(shortPoolNames)")
            if let index = initialPoolIndex {
                pieChartView.highlightValue(Highlight(x: Double(index), y: 0, dataSetIndex: 0))
            }
            if let subItems = lastPoolSubItems {
                setupBarChartData(subItems)
            }
        case 1:
            setupInitialChartData()
            setPiChartData(with: shortCoinNames, values: coinPercentData)
            
            if let index = initialCoinIndex {
                pieChartView.highlightValue(Highlight(x: Double(index), y: 0, dataSetIndex: 0))
            }
            if let subItems = lastCoinSubItems {
                setupBarChartData(subItems)
            }
        default:
            break
        }
    }
    
    private func setupInitialChartData() {
        for coinData in barChartCoinData {
            if let subItems = coinData.data {
                lastCoinSubItems = subItems
                break
            }
        }
        
        for poolData in barChartPoolData {
            if let subItems = poolData.data {
                lastPoolSubItems = subItems
                break
            }
        }
        initialPoolIndex = getInitialPoolIndex()
        initialCoinIndex = getInitialCoinIndex()
    }
    
    private func getInitialPoolIndex() -> Int? {
        var poolIndex: Int?
        var poolName = ""
        
        for poolData in barChartPoolData {
            if poolData.data != nil {
                poolName = poolData.name
                break
            }
        }
        
        for name in shortPoolNames {
            if poolIndex == nil {
                poolIndex = 0
            } else {
                poolIndex! += 1
            }
            
            if name == poolName {
                break
            }
        }
        
        if let index = poolIndex {
            currentPoolLegendName = poolNamesData[index]
        }
        
        return poolIndex
    }
    
    private func getInitialCoinIndex() -> Int? {
        var coinIndex: Int?
        var coinSymbol = ""
  
        for coinData in barChartCoinData {
            if coinData.data != nil {
                coinSymbol = coinData.name
                break
            }
        }
        
        for coin in shortCoinNames {
            if coinIndex == nil {
                coinIndex = 0
            } else {
                coinIndex! += 1
            }
            if coin == coinSymbol {
                break
            }
        }
        
        if let index = coinIndex {
            currentCoinLegendName = coinNamesData[index]
        }
        
        return coinIndex
    }
    
    private func getPoolSubItemsNames(subItems: [String : Double], for pool: PoolTypeModel) -> [String: Double] {
        var changeAbleSubItems: [String: Double] = [:]
        
        for (id, value) in subItems {
            if let intID = Int(id) {
                for subPool in pool.subItems {
                    if subPool.id == intID {
                        let coinName = subPool.shortName.isEmpty ? subPool.name : subPool.shortName
                        changeAbleSubItems[coinName] = value
                    }
                }
            }
        }
        return changeAbleSubItems
    }
    
    private func getCoinSubItemsNames(subItems: [String: Double], for pools: [PoolTypeModel]) -> [String: Double] {
        guard pools.count != 0 else {return [:]}
        var changeAbleSubItems: [String: Double] = [:]
        
        for (id, value) in subItems {
            if let intID = Int(id) {
                for pool in pools {
                    if pool.poolId == intID {
                        let poolName = pool.shortName.isEmpty ? pool.poolName : pool.shortName
                        changeAbleSubItems[poolName] = value
                    }
                }
            }
        }
        return changeAbleSubItems
    }
    
    private func resetChartInitialData() {
        shortPoolNames = []
        poolNamesData = []
        poolPercentData = []
        coinNamesData = []
        shortCoinNames = []
        coinPercentData = []
        poolUrlData = []
    }
    
    fileprivate func hideBarChartView() {
        barChartView.isHidden = true
        barChartViewHeightConstraint.constant = 0
        removeArrowAnimations()
    }
}

extension AnalyticsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        removeArrowAnimations()
    }
}

// MARK: -- Value formatter delegate method
extension AnalyticsViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let count = currentPoolCoinsNames.count
        guard let axis = axis, count > 0 else { return "" }

        let factor = axis.axisMaximum / Double(count)
        let index = Int((value / factor).rounded())
        guard index >= 0 && index < count else { return "" }

        return currentPoolCoinsNames[index]
    }
}

// MARK: -- Segment Controller delegate method
extension AnalyticsViewController: BaseSegmentControlDelegate {
    func segmentSelected(index: Int) {
        switch index {
        case 0:
            if currentIndex != index {
                pieChartView.highlightValue(nil)
                isSelectedPool = true
                setPiChartData(with: shortPoolNames, values: poolPercentData)
                if let index = initialPoolIndex {
                    pieChartView.highlightValue(Highlight(x: Double(index), y: 0, dataSetIndex: 0))
                    currentPoolLegendName = poolNamesData[index]
                }
                if let subItems = lastPoolSubItems {
                    setupBarChartData(subItems)
                }
            }
        case 1:
            if currentIndex != index {
                pieChartView.highlightValue(nil)
                isSelectedPool = false
                setPiChartData(with: shortCoinNames, values: coinPercentData)
                if let index = initialCoinIndex {
                    pieChartView.highlightValue(Highlight(x: Double(index), y: 0, dataSetIndex: 0))
                    currentCoinLegendName = coinNamesData[index]
                }
                if let subItems = lastCoinSubItems {
                    setupBarChartData(subItems)
                }
            }
        default:
            break
        }
        currentIndex = index
    }
}

// MARK: -- CharViewDelegate methods
extension AnalyticsViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard chartView == pieChartView,
              let pieEntry = entry as? PieChartDataEntry,
              let dataSet = chartView.data?.dataSets[ highlight.dataSetIndex] else { return }
        
        let index: Int = dataSet.entryIndex( entry: entry)
        
        if isSelectedPool {
            initialPoolIndex = index
            chartValueSelectedForPool(with: pieEntry)
        } else {
            initialCoinIndex = index
            chartValueSelectedForCoin(with: pieEntry)
        }
        DispatchQueue.main.async {
            self.currentLegendSetup()
        }
    }
    
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        guard chartView == pieChartView else {return}
        
        lastLabel = ""
        barChartView.isHidden = true
        legendStackView.isHidden = true
    }
    
    //MARK: - Chart Value Selected
    private func chartValueSelectedForPool(with pieEntry: PieChartDataEntry) {
        currentPoolLegendName = ""
        guard let poolLabel = pieEntry.label else { return }
        let currentIndex = shortPoolNames.firstIndex { $0 == poolLabel } ?? 0
        
        if poolLabel != lastLabel {
            var isSubitemsExist = false
            for poolData in barChartPoolData {
                if poolData.name == poolLabel {
                    if let subItems = poolData.data {
                        isSubitemsExist = true
                        currentPoolLegendName = poolNamesData[currentIndex]
                        lastPoolSubItems = subItems
//                        initialPoolIndex = currentIndex
                        debugPrint("Initial Pool Index---- \(initialPoolIndex!)")
                        setupBarChartData(subItems)
                        break
                    } else {
                        if !isSubscribed {
                            goToSubscriptionPage()
                            break
                        }
                    }
                } else {
                    if !isSubscribed {
                        goToSubscriptionPage()
                        break
                    }
                }
            }
            
            if !isSubitemsExist {
                hideBarChartView()
            }
            lastLabel = poolLabel
        } else if poolLabel == Localized(AnalyticsNames.others.rawValue) {
            if !isSubscribed {
                goToSubscriptionPage()
            }
            isSubscribed
            barChartView.isHidden = true
        }
        barChartView.zoomToCenter(scaleX: 0, scaleY: 0)
    }
    
    private func chartValueSelectedForCoin(with pieEntry: PieChartDataEntry) {
        isOpenedFirst = false
        currentCoinLegendName = ""
        guard let poolLabel = pieEntry.label else { return }
        
        let currentIndex = shortCoinNames.firstIndex { $0 == poolLabel } ?? 0
        
        if poolLabel != lastLabel {
            var isSubitemsExist = false
            var isCoinNameExist = false
            for coinData in barChartCoinData {
                if coinData.name == poolLabel {
                    if let subItems = coinData.data, subItems.count != 0 {
                        isSubitemsExist = true
                        isCoinNameExist = true
                        currentCoinLegendName = coinNamesData[currentIndex]
//                        initialCoinIndex = currentIndex
                        lastCoinSubItems = subItems
                        setupBarChartData(subItems)
                        break
                    }
                }
            }
            
            if isCoinNameExist == false {
                if !isSubscribed {
                    goToSubscriptionPage()
                }
            }
            if !isSubitemsExist {
                hideBarChartView()
            }
            lastLabel = poolLabel
        } else if poolLabel == Localized(AnalyticsNames.others.rawValue) {
            if !isSubscribed {
                goToSubscriptionPage()
            }
            barChartView.isHidden = true
        }
    }
    
}

// HELPERS:
enum AnalyticsNames: String {
    case coin = "1"
    case pool = "0"
    case others = "others"
}

struct AnalyticsColor {
    static let lightAnaliticsColor: [UIColor] = [UIColor(red: 153 / 255, green: 230 / 255, blue: 246 / 255, alpha: 1),
                                                 UIColor(red: 153 / 255, green: 170 / 255, blue: 222 / 255, alpha: 1),
                                                 UIColor(red: 153 / 255, green: 77 / 255, blue: 208 / 255, alpha: 1),
                                                 UIColor(red: 153 / 255, green: 128 / 255, blue: 203 / 255, alpha: 1),
                                                 UIColor(red: 153 / 255, green: 220 / 255, blue: 231 / 255, alpha: 1),
                                                 UIColor(red: 153 / 255, green: 128 / 255, blue: 222 / 255, alpha: 1),
                                                 UIColor(red: 153 / 255, green: 129 / 255, blue: 199 / 255, alpha: 1),
                                                 UIColor(red: 153 / 255, green: 118 / 255, blue: 205 / 255, alpha: 1),
                                                 UIColor(red: 153 / 255, green: 210 / 255, blue: 237 / 255, alpha: 1),
                                                 UIColor(red: 153 / 255, green: 100 / 255, blue: 194 / 255, alpha: 1)]
    
    static let darkAnaliticsColor: [UIColor] = [UIColor(red: 230 / 255, green: 246 / 255, blue: 157 / 255, alpha: 1),
                                                UIColor(red: 170 / 255, green: 222 / 255, blue: 167 / 255, alpha: 1),
                                                UIColor(red: 77 / 255, green: 208 / 255, blue: 225 / 255, alpha: 1),
                                                UIColor(red: 128 / 255, green: 203 / 255, blue: 196 / 255, alpha: 1),
                                                UIColor(red: 220 / 255, green: 231 / 255, blue: 117 / 255, alpha: 1),
                                                UIColor(red: 128 / 255, green: 222 / 255, blue: 234 / 255, alpha: 1),
                                                UIColor(red: 129 / 255, green: 199 / 255, blue: 132 / 255, alpha: 1),
                                                UIColor(red: 118 / 255, green: 205 / 255, blue: 221 / 255, alpha: 1),
                                                UIColor(red: 210 / 255, green: 237 / 255, blue: 243 / 255, alpha: 1),
                                                UIColor(red: 100 / 255, green: 194 / 255, blue: 166 / 255, alpha: 1)]
}
