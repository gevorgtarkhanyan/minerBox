//
//  ChartSettingsViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/16/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

protocol ChartSettingsViewControllerDelegate: AnyObject {
    func settingsChanged(horizontalLine: Bool, verticalLine: Bool, lineGraph: Bool)
    func compareCoin(coin: CoinModel?)
}

class ChartSettingsViewController: BaseViewController {

    // MARK: - Views
    @IBOutlet fileprivate weak var bottomView: BarCustomView!

    @IBOutlet fileprivate weak var axisButton: BackgroundButton!
    @IBOutlet fileprivate weak var verticalLabel: BaseLabel!
    @IBOutlet fileprivate weak var verticalSwitch: BaseSwitch!
    @IBOutlet fileprivate weak var horizontalLabel: BaseLabel!
    @IBOutlet fileprivate weak var horizontalSwitch: BaseSwitch!

    @IBOutlet fileprivate weak var graphButton: BackgroundButton!
    @IBOutlet fileprivate weak var mountainButton: SettingsGraphButton!
    @IBOutlet fileprivate weak var lineButton: SettingsGraphButton!

    @IBOutlet fileprivate weak var analyzeButton: BackgroundButton!
    @IBOutlet fileprivate weak var comparisionButton: SettingsGraphButton!

    // MARK: - Properties
    weak var delegate: ChartSettingsViewControllerDelegate?

    fileprivate var favoriteCoins: [CoinModel] = []
    fileprivate var secondCoin: CoinModel?

    // MARK: - Static
    static func initializeStoryboard() -> ChartSettingsViewController? {
        return UIStoryboard(name: "CoinPrice", bundle: nil).instantiateViewController(withIdentifier: ChartSettingsViewController.name) as? ChartSettingsViewController
    }

    static func initializeNavigationStoryboard() -> BaseNavigationController? {
        return UIStoryboard(name: "CoinPrice", bundle: nil).instantiateViewController(withIdentifier: "ChartSettingsNavigationController") as? BaseNavigationController
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.compareCoin(coin: secondCoin)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let newVC = segue.destination as? CoinComparisionViewController else { return }
        newVC.delegate = self
        newVC.setSelecteCoin(secondCoin)
        newVC.setFavoriteCoins(coins: favoriteCoins)
    }
    @objc func addFavorite(_ notification: NSNotification) {
        if let coin = notification.userInfo?["favoriteCoin"] as? CoinModel {
            self.favoriteCoins.append(coin)
        }
    }
}

// MARK: - Startup
extension ChartSettingsViewController {
    fileprivate func startupSetup() {
        setupUI()

        configLabel()
        configButtons()

        addGestureRecognizers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackgroundOrForeground), name: .goToForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackgroundOrForeground), name: .goToBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addFavorite(_:)), name: .addFavorite, object: nil)
        
    }

    fileprivate func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }

    fileprivate func configButtons() {
        axisButton.setLocalizedTitle("coin_settings_axis")
        graphButton.setLocalizedTitle("coin_settings_graph")
        analyzeButton.setLocalizedTitle("coin_settings_analize")

        mountainButton.delegate = self
        mountainButton.setTitle("coin_settings_mountain")
        mountainButton.setImage(UIImage(named: "coin_graph_mountain"))

        lineButton.delegate = self
        lineButton.setTitle("coin_settings_line")
        lineButton.setImage(UIImage(named: "coin_graph_line"))

        comparisionButton.delegate = self
        comparisionButton.setTitle("coin_settings_comparision")
        comparisionButton.setImage(UIImage(named: "coin_graph_comparision"))

        let lineGraph = UserDefaults.standard.bool(forKey: Constants.coinSettingsLineGraph)
        lineButton.setSelected(lineGraph)
        mountainButton.setSelected(!lineGraph)
        
        let vIsOn = UserDefaults.standard.value(forKey: Constants.coinSettingsVertical) as? Bool ?? true
        verticalSwitch.addTarget(self, action: #selector(lineSwitchAction(_:)), for: .valueChanged)
        verticalSwitch.setOn(vIsOn, animated: true)

        let hIsOn = UserDefaults.standard.value(forKey: Constants.coinSettingsHorizontal) as? Bool ?? true
        horizontalSwitch.addTarget(self, action: #selector(lineSwitchAction(_:)), for: .valueChanged)
        horizontalSwitch.setOn(hIsOn, animated: true)
    }

    fileprivate func configLabel() {
        verticalLabel.setLocalizableText("coin_settings_vertical")
        horizontalLabel.setLocalizableText("coin_settings_horizontal")
    }
    @objc func appMovedToBackgroundOrForeground() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Setup UI
extension ChartSettingsViewController {
    fileprivate func setupUI() {
        bottomView.changeSeparatorToTop()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.35)
    }
}

// MARK: - Actions
extension ChartSettingsViewController {
    @objc fileprivate func tapAction(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

    @objc fileprivate func lineSwitchAction(_ sender: BaseSwitch) {
        delegate?.settingsChanged(horizontalLine: horizontalSwitch.isOn, verticalLine: verticalSwitch.isOn, lineGraph: lineButton.isSelected)
    }
}

// MARK: - Custom button delegate
extension ChartSettingsViewController: SettingsGraphButtonDelegate {
    func graphButtonSelected(_ sender: SettingsGraphButton) {
        switch sender {
        case comparisionButton:
            performSegue(withIdentifier: "compareSegue", sender: self)
        case mountainButton:
            lineButton.setSelected(false)
            mountainButton.setSelected(true)
            delegate?.settingsChanged(horizontalLine: horizontalSwitch.isOn, verticalLine: verticalSwitch.isOn, lineGraph: lineButton.isSelected)
        case lineButton:
            lineButton.setSelected(true)
            mountainButton.setSelected(false)
            delegate?.settingsChanged(horizontalLine: horizontalSwitch.isOn, verticalLine: verticalSwitch.isOn, lineGraph: lineButton.isSelected)
        default:
            break
        }
    }
}

// MARK: - Comparision delegate
extension ChartSettingsViewController: CoinComparisionViewControllerDelegate {
    func comparisionCoinSelected(_ coin: CoinModel?) {
        secondCoin = coin
    }
}

// MARK: - Tap gesture delegate
extension ChartSettingsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return gestureRecognizer.view == touch.view
    }
}

// MARK: - Set data
extension ChartSettingsViewController {
    public func setFavoriteCoins(_ coins: [CoinModel]) {
        self.favoriteCoins = coins
    }

    public func setComparisionCoin(_ coin: CoinModel?) {
        secondCoin = coin
    }
}
