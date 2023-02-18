//
//  GraphViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/9/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import Charts
import Localize_Swift

class GraphViewController: BaseViewController {
    
    // MARK: - Views
    @IBOutlet fileprivate weak var dateFromView: DateSelectorView!
    @IBOutlet fileprivate weak var dateToView: DateSelectorView!
    
    @IBOutlet fileprivate weak var selectedDateLabel: BaseLabel!
    @IBOutlet fileprivate weak var selectedValueLabel: BaseLabel!
    
    @IBOutlet fileprivate weak var lineChartView: LineChartView!
    @IBOutlet fileprivate weak var barChartView: BarChartView!
    
    @IBOutlet fileprivate weak var chooseWorkersButton: BackgroundButton?
    
    @IBOutlet weak var MaxMinView: UIView!
    @IBOutlet weak var maxPriceLabel: BaseLabel!
    @IBOutlet weak var maxDateLabel: BaseLabel!
    @IBOutlet weak var minPriceLabel: BaseLabel!
    @IBOutlet weak var minDateLabel: BaseLabel!
    @IBOutlet weak var maxMinViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateViewConstraint: NSLayoutConstraint!
    // MARK: - Properties
    fileprivate var account: PoolAccountModel!
    
    fileprivate var graphType: GraphTypeEnum = .hashrate
    
    fileprivate var allWorkers = [GraphWorker]() {
        didSet {
            checkDataAvailabel(with: allWorkers)
        }
    }
    fileprivate var selectedWorkers = [GraphWorker]() {
        didSet {
            checkDataAvailabel(with: selectedWorkers)
        }
    }
    fileprivate var filteredWorkers = [GraphWorker]() {
        didSet {
            checkDataAvailabel(with: filteredWorkers)
        }
    }
    private var max = 0.0
    private var min = 0.0
    fileprivate var selectedMinimumTime = 0.0
    fileprivate var selectedMaximumTime = Date().timeIntervalSince1970
    
    fileprivate var email: String?
    fileprivate var lastSeen: String?
    let rates = UserDefaults.standard.value(forKey: "\(DatabaseManager.shared.currentUser?.id ?? "" )/rates") as? [String:Double]
    
    // Disable rotate
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disablePageRotate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let refreshButton = UIBarButtonItem(image: UIImage(named: "bar_refresh"), style: .done, target: self, action: #selector(refreshButtonAction(_:)))
        navigationItem.rightBarButtonItem = refreshButton
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        enablePageRotate()
        
        navigationItem.rightBarButtonItem = nil
    }
    
    override func languageChanged() {
        title = graphType.rawValue.localized()
        barChartView.noDataText = "no_chart_data".localized()
        lineChartView.noDataText = "no_chart_data".localized()
        
        let chooseTitle = graphType == .hashrate ? "select" : "choose_shares"
        chooseWorkersButton?.setTitle(chooseTitle.localized(), for: .normal)
    }
    
    override func themeChanged() {
        super.themeChanged()
        let textColor = darkMode ? .white : UIColor.black.withAlphaComponent(0.85)
        barChartView.noDataTextColor = textColor
        lineChartView.noDataTextColor = textColor
        
        barChartView.backgroundColor = darkMode ? .viewDarkBackground : .viewLightBackground
        lineChartView.backgroundColor = darkMode ? .viewDarkBackground : .viewLightBackground
        
        // Change graph colors
        [lineChartView, barChartView].forEach { (graph) in
            graph?.xAxis.labelTextColor = textColor
            graph?.leftAxis.labelTextColor = textColor
            graph?.legend.textColor = textColor
        }
        configChartView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let newVC = segue.destination as? ChooseGraphWorkersViewController else { return }
        newVC.delegate = self
        newVC.setWorkers(all: allWorkers)
        newVC.setType(graphType: graphType)
    }
}

// MARK: - Startup default setup
extension GraphViewController {
    fileprivate func startupSetup() {
        getGraphHistory()

        hidePageElements()
        configChartViews()
        configDateFilters()
        configChooseWorkersButton()
    }
    
    fileprivate func configChartViews() {
        switch graphType {
        case .hashrate:
            barChartView.isHidden = true
            lineChartView.clipsToBounds = true
            lineChartView.layer.cornerRadius = 10
        case .share:
            lineChartView.isHidden = true
            barChartView.clipsToBounds = true
            barChartView.layer.cornerRadius = 10
        }
    }
    
    fileprivate func configDateFilters() {
        dateToView.delegate = self
        dateToView.layer.cornerRadius = 15
        dateToView.setPlaceholder("date_to")
        dateToView.setMaximumDate(date: Date())
        
        dateFromView.delegate = self
        dateFromView.layer.cornerRadius = 15
        dateFromView.setPlaceholder("date_from")
        dateFromView.setMaximumDate(date: Date())
    }
    
    fileprivate func configChooseWorkersButton() {
        chooseWorkersButton?.clipsToBounds = true
        chooseWorkersButton?.layer.cornerRadius = 15
    }
    
}

// MARK: - Requests
extension GraphViewController {
    fileprivate func getGraphHistory() {
        guard let account = self.account else { return }
        Loading.shared.startLoading(ignoringActions: true, for: self.view)
        let type = graphType == .hashrate ? 0 : 1
        PoolRequestService.shared.getAccountHistory(poolId: account.id, poolType: account.poolType, type: type, success: { [weak self] history in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.configWorkers(history: history)
                Loading.shared.endLoading(for: self.view)
            }
        }, failer: { (error) in
            Loading.shared.endLoading(for: self.view)
            //            self.showToastAlert("", message: error.localized())
            self.checkDataAvailabel(with: [])
        })
    }
}

// MARK: - Actions
extension GraphViewController {
    fileprivate func configChartView() {
        guard filteredWorkers.count > 0 else {
            barChartView.isHidden = true
            lineChartView.isHidden = true
            return
        }
        switch self.graphType {
        case .hashrate:
            lineChartView.isHidden = false
            self.configLineChartView()
        case .share:
            barChartView.isHidden = false
            self.configBarChartView()
        }
    }
    
    fileprivate func configWorkers(history: [PoolGraphModel]) {
        guard history.count > 0 else { return }
        
        var newWorkers = [GraphWorker]()
        for item in history {
            guard item.data.count > 0 else { continue }
            
            switch graphType {
            case .hashrate:
                if item.data[0].curHs != -1 {
                    newWorkers.append(configWorkerHashrateData(model: item, type: .current))
                }
                if item.data[0].averageHs != -1 {
                    newWorkers.append(configWorkerHashrateData(model: item, type: .average))
                }
                if item.data[0].realHs != -1 {
                    newWorkers.append(configWorkerHashrateData(model: item, type: .real))
                }
                if item.data[0].repHs != -1 {
                    newWorkers.append(configWorkerHashrateData(model: item, type: .reported))
                }
            case .share:
                if item.data[0].validSh != -1 {
                    newWorkers.append(configWorkerShareData(model: item, type: .valid))
                }
                if item.data[0].invalidSh != -1 {
                    newWorkers.append(configWorkerShareData(model: item, type: .invalid))
                }
                if item.data[0].staleSh != -1 {
                    newWorkers.append(configWorkerShareData(model: item, type: .stale))
                }
                if item.data[0].expiredSh != -1 {
                    newWorkers.append(configWorkerShareData(model: item, type: .expired))
                }
            }
        }
        
        self.allWorkers = newWorkers
        getSelectedWorkers()
        
        if newWorkers.count < 2 {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.chooseWorkersButton?.removeFromSuperview()
                self.view.layoutIfNeeded()
                self.dateViewConstraint.constant = 20
            }
        }
    }
    
    fileprivate func configWorkerHashrateData(model: PoolGraphModel, type: WorkerHashrateValuesEnum) -> GraphWorker {
        let name = (model.name.localized()) + " - " + type.rawValue.localized().lowercased()
        
        let data = model.data.map { (item) -> WorkersGraphData in
            switch type {
            case .current:
                return WorkersGraphData(time: Double(item.time), value: item.curHs)
            case .real:
                return WorkersGraphData(time: Double(item.time), value: item.realHs)
            case .reported:
                return WorkersGraphData(time: Double(item.time), value: item.repHs)
            case .average:
                return WorkersGraphData(time: Double(item.time), value: item.averageHs)
            }
        }
        
        return GraphWorker(name: name, data: data)
    }
    
    fileprivate func configWorkerShareData(model: PoolGraphModel, type: WorkerShareValuesEnum) -> GraphWorker {
        let name = (model.name.localized()) + " - " + type.rawValue.localized().lowercased()
        
        let data = model.data.map { (item) -> WorkersGraphData in
            switch type {
            case .valid:
                return WorkersGraphData(time: Double(item.time), value: item.validSh)
            case .invalid:
                return WorkersGraphData(time: Double(item.time), value: item.invalidSh)
            case .stale:
                return WorkersGraphData(time: Double(item.time), value: item.staleSh)
            case .expired:
                return WorkersGraphData(time: Double(item.time), value: item.expiredSh)
            }
        }
        
        return GraphWorker(name: name, data: data)
    }
    
    private func getSelectedWorkers() {
        guard let account = Cacher.shared.account, !allWorkers.isEmpty else { return }
        let selectedIndexes = UserDefaults.shared.array(forKey: "\(account.keyPath + graphType.rawValue)ChooseGraphWorkersViewController") as? [Int] ?? [0]
        selectedWorkers.removeAll()
        for i in selectedIndexes {
            if allWorkers.indices.contains(i) {
                selectedWorkers.append(allWorkers[i])
            }
        }
        graphWorkersSelected(selectedWorkers)
    }
    
    private func hideMaxMinView() {
//        if selectedWorkers.count > 1 {
//            maxMinViewConstraint.constant = 13
//            MaxMinView.isHidden = true
//        } else {
//            maxMinViewConstraint.constant = 60
//            MaxMinView.isHidden = false
//        }
    }
    
    fileprivate func filterWorkers() {
        var workers = [GraphWorker]()
        for worker in selectedWorkers {
            let data = worker.data.filter { (item) -> Bool in
                return item.time >= selectedMinimumTime && item.time <= selectedMaximumTime
            }
            workers.append(GraphWorker(name: worker.name, data: data))
        }
        filteredWorkers = workers
        configChartView()
    }
    
    fileprivate func checkDataAvailabel(with workers: [GraphWorker]) {
        DispatchQueue.main.async {
            if workers.isEmpty {
                self.hidePageElements()
                self.showNoDataLabel()
            } else {
                self.showPageElements()
                self.hideNoDataLabel()
            }
        }
    }
    
    fileprivate func hidePageElements() {
        dateToView.isHidden = true
        dateFromView.isHidden = true
        chooseWorkersButton?.isHidden = true
    }
    
    fileprivate func showPageElements() {
        dateToView.isHidden = false
        dateFromView.isHidden = false
        chooseWorkersButton?.isHidden = false
    }
    
    // MARK: - UI actions
    @objc fileprivate func refreshButtonAction(_ sender: UIBarButtonItem) {
        getGraphHistory()
    }
    
    fileprivate func getMinMax (arr : [ChartDataEntry]) -> (ChartDataEntry,ChartDataEntry) {
        let n = arr.count
        var max = ChartDataEntry()
        var min = ChartDataEntry()
        var i = 0
        
        if n % 2 == 0 && n != 0 {
            
            if arr[0].y > arr[1].y {
                
                max = arr[0]
                min = arr[1]
                
            } else {
                
                min = arr[0]
                max = arr[1]
            }
            
            i = 2
            
        } else if n != 0 {
            
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
    
    fileprivate func setDrawIconsLineChart(LineData : LineChartData)  {
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
    
    fileprivate func setDrawIconsBarChart(BarData : BarChartData)  {
        var highImage = UIImage()
        var lowImage = UIImage()
        if #available(iOS 10.0, *) {
            highImage = (UIImage(named: "charts_high_image")?.scaled(toWidth: 10))!
            lowImage = (UIImage(named: "charts_low_image")?.scaled(toWidth: 10))!
        }
        var min = 0.0
        max = 0.0
        for i in 0..<BarData.dataSetCount {
            let yMin = BarData.getDataSetByIndex(i).yMin
            let yMax = BarData.getDataSetByIndex(i).yMax
            
            let entryCount = BarData.getDataSetByIndex(i).entryCount
            for j in 0..<entryCount {
                let y = BarData.getDataSetByIndex(i).entryForIndex(j)?.y
                let x = BarData.getDataSetByIndex(i).entryForIndex(j)?.x
                if yMin == yMax {
                    if max == 0.0 && min == 0.0 {
                        max = yMax
                        min = yMin
                    }
                } else {
                    if y == yMin {
                        if min == 0.0 {
                            BarData.getDataSetByIndex(i).entryForXValue(x!, closestToY: Double.nan)?.icon = lowImage
                        }
                        if yMin != 0 {
                            min = yMin
                        } else {
                            min = 0.1
                        }
                    } else if y == yMax {
                        if max == 0.0 {
                            BarData.getDataSetByIndex(i).entryForXValue(x!, closestToY: Double.nan)?.icon = highImage
                        }
                        if yMax != 0 {
                            max = yMax
                        } else {
                            max = 0.1
                        }
                    }
                }
            }
        }
    }
}


// MARK: - Create charts
extension GraphViewController {
    fileprivate func configLineChartView() {
        lineChartView.delegate = self
        
        var lineChartDataSets = [LineChartDataSet]()
        
        var maximum = 0.0
        
        let fillEnabled = filteredWorkers.count <= 2
        
        for (i, worker) in filteredWorkers.enumerated() {
            let dataEntriy = worker.data.map { (i) -> ChartDataEntry in
                return ChartDataEntry(x: i.time, y: i.value)
            }
            let values = worker.data.map { $0.value }
            let maximumValue = values.max() ?? 0
            if maximumValue > maximum {
                maximum = maximumValue
            }
            let chartDataSet = LineChartDataSet(entries: dataEntriy, label: worker.name)
            
            chartDataSet.valueColors = [darkMode ? .white : .black]
            
            chartDataSet.drawIconsEnabled = false
            chartDataSet.drawValuesEnabled = false
            chartDataSet.drawCirclesEnabled = false
            chartDataSet.drawFilledEnabled = fillEnabled
            
            let colorArray = UIColor.graphLineGradientColors[i]
            if dataEntriy.count != 0 {
            let minMax = getMinMax(arr: dataEntriy)
            maxDateLabel.setLocalizableText("\(minMax.0.x.getDateFromUnixTime())")
            minDateLabel.setLocalizableText("\(minMax.1.x.getDateFromUnixTime())")
            maxPriceLabel.setLocalizableText( chartDataSet.yMax.textFromHashrate(account: account))
            minPriceLabel.setLocalizableText( chartDataSet.yMin.textFromHashrate(account: account))
            }
            
            if selectedWorkers.count > 1 || dataEntriy.count == 0 {
            maxMinViewConstraint.constant = 13
            MaxMinView.isHidden = true
            chartDataSet.drawIconsEnabled = false
            } else {
            maxMinViewConstraint.constant = 60
            MaxMinView.isHidden = false
            chartDataSet.drawIconsEnabled = true
            }
            
            if fillEnabled {
                chartDataSet.fillAlpha = 0.6
                chartDataSet.lineWidth = 0
                chartDataSet.setColor(colorArray.first!)
                
                let gradientColors = colorArray.map { $0.cgColor } as CFArray
                let colorLocations: [CGFloat] = [0, 1]
                if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) {
                    chartDataSet.fill = Fill.fillWithLinearGradient(gradient, angle: 270)
                }
            } else {
                chartDataSet.lineWidth = 1.5
                chartDataSet.colors = [colorArray.first!.withAlphaComponent(0.5)]
            }
            
            chartDataSet.highlightColor = darkMode ? .white : .textBlack
            chartDataSet.highlightLineWidth = 0.5
            
            lineChartDataSets.append(chartDataSet)
        }
        lineChartView.data = LineChartData(dataSets: lineChartDataSets)
    
        setDrawIconsLineChart(LineData: lineChartView.data as! LineChartData )
        lineChartView.maxVisibleCount = 10000
        
        let xAxis = lineChartView.xAxis
        xAxis.centerAxisLabelsEnabled = false
        xAxis.setLabelCount(6, force: false)
        xAxis.labelPosition = .bottom
        xAxis.valueFormatter = DateChartFormatter()
        
        let leftAxis = lineChartView.leftAxis
        leftAxis.valueFormatter = HashrateChartFormatter()
        leftAxis.labelPosition = .outsideChart
        
        maximum = maximum == 0 ? 1 : maximum * 1.1
        if let Ymin = lineChartView.data?.yMin  {
            if Ymin < 1 {
                lineChartView.leftAxis.axisMinimum = 0
                lineChartView.rightAxis.axisMinimum = 0
                lineChartView.leftAxis.axisMaximum = maximum
                lineChartView.rightAxis.axisMaximum = maximum
            }
        }
        
        
        lineChartView.chartDescription?.text = ""
        lineChartView.rightAxis.drawLabelsEnabled = false
    }
    
    fileprivate func configBarChartView() {
        barChartView.delegate = self
        
        var maximum = 0.0
        var alpha: CGFloat = 1
        
        var barChartDataSets = [BarChartDataSet]()
        
        for (i, worker) in filteredWorkers.enumerated() {
            let dataEntriy = worker.data.map { (i) -> BarChartDataEntry in
                return BarChartDataEntry(x: i.time, y: i.value)
            }
            let values = worker.data.map { $0.value }
            let maximumValue = values.max() ?? 1
            if maximumValue > maximum {
                maximum = maximumValue
            }
            
            let set = BarChartDataSet(entries: dataEntriy, label: worker.name)
            set.valueColors = [darkMode ? .white : .black]
            let color = UIColor.graphLineColors[i].withAlphaComponent(alpha)
            set.colors = [color]
            set.drawValuesEnabled = false
            
            barChartDataSets.append(set)
            if i < 3 {
                alpha -= 0.3
            }
            
            if selectedWorkers.count > 1 || dataEntriy.count == 0 {
            maxMinViewConstraint.constant = 13
            MaxMinView.isHidden = true
            set.drawIconsEnabled = false
            } else {
            maxMinViewConstraint.constant = 60
            MaxMinView.isHidden = false
            set.drawIconsEnabled = true
            }
            if dataEntriy.count != 0 {
            let minMax = getMinMax(arr: dataEntriy)
            maxDateLabel.setLocalizableText("\(minMax.0.x.getDateFromUnixTime())")
            minDateLabel.setLocalizableText("\(minMax.1.x.getDateFromUnixTime())")
            maxPriceLabel.setLocalizableText( set.yMax.getString())
            minPriceLabel.setLocalizableText( set.yMin.getString())
            }
        }
        
        
        
        let data = BarChartData(dataSets: barChartDataSets)
        data.barWidth = 500
        self.barChartView.data = data
        
        setDrawIconsBarChart(BarData: barChartView.data as! BarChartData )
        barChartView.maxVisibleCount = 10000
        
        
        let xAxis = barChartView.xAxis
        xAxis.centerAxisLabelsEnabled = false
        xAxis.setLabelCount(6, force: false)
        xAxis.labelPosition = .bottom
        xAxis.valueFormatter = DateChartFormatter()
        
        maximum = maximum == 0 ? 1 : maximum * 1.1
        barChartView.leftAxis.axisMinimum = 0
        barChartView.rightAxis.axisMinimum = 0
        lineChartView.leftAxis.axisMaximum = maximum
        lineChartView.rightAxis.axisMaximum = maximum
        
        barChartView.chartDescription?.text = ""
        barChartView.rightAxis.drawLabelsEnabled = false
        barChartView.xAxis.valueFormatter = xAxis.valueFormatter
    }
}

// MARK: - Charts delegate
extension GraphViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let time = entry.x.getDateFromUnixTime()
        let rate = entry.y
        selectedDateLabel.setLocalizableText("\(time)")
        selectedValueLabel.setLocalizableText(graphType == .hashrate ? rate.textFromHashrate(account: account) : rate.getString())
    }
}

// MARK: - Date selector delegate
extension GraphViewController: DateSelectorViewDelegate {
    func dateSelected(sender: DateSelectorView, date: Date) {
        switch sender {
        case dateFromView:
            dateToView.setMinimumDate(date: date)
            selectedMinimumTime = date.timeIntervalSince1970
        case dateToView:
            dateFromView.setMaximumDate(date: date)
            selectedMaximumTime = date.timeIntervalSince1970
        default:
            break
        }
        filterWorkers()
    }
    func dateClear(sender: DateSelectorView) {
        switch sender {
        case dateFromView:
            dateToView.setMinimumDate(date: nil)
            selectedMinimumTime = 0.0
            DispatchQueue.main.async {
                self.getGraphHistory()
            }
        case dateToView:
            let date = Date()
            dateFromView.setMaximumDate(date: date)
            selectedMaximumTime = date.timeIntervalSince1970
            DispatchQueue.main.async {
                self.getGraphHistory()
            }
        default:
            break
        }
    }
}

// MARK: - Workers selection delegate
extension GraphViewController: ChooseGraphWorkersViewControllerDelegate {
    func graphWorkersSelected(_ selectedWorkers: [GraphWorker]) {
        self.selectedWorkers = selectedWorkers
        filterWorkers()
    }
}

// MARK: - Set data
extension GraphViewController {
    public func setAccount(_ account: PoolAccountModel) {
        self.account = account
    }
    
    public func setGraphType(_ graphType: GraphTypeEnum) {
        self.graphType = graphType
    }
    
    public func setAccountInfoData(mail: String?, lastSeen: String?) {
        self.email = mail
        self.lastSeen = lastSeen
    }
}

// MARK: - Helpers
enum GraphTypeEnum: String {
    case hashrate = "hashrate"
    case share = "shares"
}

class GraphWorker: NSObject {
    var name: String
    var data: [WorkersGraphData]
    
    init(name: String, data: [WorkersGraphData]) {
        self.name = name
        self.data = data
    }
}
struct WorkersGraphData {
    var time: Double
    var value: Double
}

enum WorkerHashrateValuesEnum: String {
    case current = "current"
    case average = "average"
    case reported = "reported"
    case real = "real"
}

enum WorkerShareValuesEnum: String {
    case valid = "valid"
    case invalid = "invalid"
    case stale = "stale"
    case expired = "expired"
}

@objc(DateChartFormatter)
public class DateChartFormatter: NSObject, IAxisValueFormatter {
    let dateFormat: String
    
    init(dateFormat: String = "HH:mm") {
        self.dateFormat = dateFormat
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Localize.currentLanguage())
        formatter.dateFormat = dateFormat
        return formatter.string(from: Date(timeIntervalSince1970: TimeInterval(value)))
    }
}

@objc(HashrateChartFormatter)
public class HashrateChartFormatter: NSObject, IAxisValueFormatter {
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return value.textFromHashrate(account: Cacher.shared.account)
    }
}

