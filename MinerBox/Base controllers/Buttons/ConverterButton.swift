//
//  ConverterButton.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 04.08.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

class ConverterButton: UIButton {
    
    // MARK: - Properties
    private weak var controller: UIViewController?
    
    private var amount: Double?
    private var coinId: String?
    private var coin: CoinModel?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        startupSetup()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        debugPrint("ConverterButton deinit")
    }
}

// MARK: - Default startup settings
extension ConverterButton {
    fileprivate func startupSetup() {
        setupUI()
        addAction()
        addObservers()
    }
    
    fileprivate func addAction() {
        addTarget(self, action: #selector(openConverterPage(_:)), for: .touchUpInside)
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged(_:)), name: Notification.Name(Constants.themeChanged), object: nil)
    }
    
    @objc func themeChanged(_ notification: Notification) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.changeColors()
            }
        }
    }
}

// MARK: - Setup UI
extension ConverterButton {
    fileprivate func setupUI() {
        let imageName = darkMode ? "details_converter_white" : "details_converter_black"
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        setImage(image, for: .normal)
        
        changeColors()
    }
    
    fileprivate func changeColors() {
        backgroundColor = .clear
        tintColor = darkMode ? .white : .black
        imageView?.tintColor = darkMode ? .white : .black
    }
}

// MARK: - Set data
extension ConverterButton {
    public func setData(_ coinId: String?, amount: Double?) {
        self.coinId = coinId
        self.amount = amount
    }
    
    public func setCoin(_ coin: CoinModel) {
        self.coin = coin
    }
    
    public func setController(_ controller: UIViewController) {
        self.controller = controller
    }
}

// MARK: - Actions
extension ConverterButton {
    @objc fileprivate func openConverterPage(_ sender: ConverterButton) {
        guard let converterVC = ConverterViewController.initializeStoryboard() else { return }
        
        if let amount = amount,
           let coinId = coinId {
            converterVC.multiplier = amount
            converterVC.headerCoinId = coinId
        }
        
        DispatchQueue.main.async {
            guard let presentedViewController = UIApplication.getTopViewController() else { return }
            
            if let navigationController = presentedViewController.navigationController {
                navigationController.pushViewController(converterVC, animated: true)
            } else {
                UIView.animate(withDuration: Constants.animationDuration / 10) {
                    presentedViewController.view.alpha = 0
                }
                presentedViewController.dismiss(animated: true) {
                    UIApplication.getTopViewController()?.navigationController?.pushViewController(converterVC, animated: true)
                }
            }
        }
    }
    
}
