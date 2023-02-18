//
//  ComparisionViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/4/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import Localize_Swift

@objc protocol ActionSheetViewControllerDelegate: AnyObject {
    @objc optional func alertTypeSelected(index: Int)
    @objc optional func comparisionSelected(index: Int)
    @objc optional func hashrateTypesSelected(index: Int)
    @objc optional func coinSortTypeSelected(index: Int, type: ActionSheetTypeEnum)
    @objc optional func payoutTypeSelected(index: Int)
    @objc optional func payoutCurrencySelected(index: Int)
    @objc optional func estimationTypeSelected(index: Int)
    @objc optional func estimationNameSelected(index: Int)
    @objc optional func actionShitSelected(index: Int)
}

class ActionSheetViewController: UIViewController {

    // MARK: - Views
    fileprivate var middleView: UIView!
    fileprivate var middleViewTopConstraint: NSLayoutConstraint!

    fileprivate var stackView: UIStackView!

    fileprivate var tabBar: UIView!
    fileprivate var tabBarHeightConstraint: NSLayoutConstraint!
    
    fileprivate var sourceView: UIView?

    // MARK: - Properties
    weak var delegate: ActionSheetViewControllerDelegate?

    fileprivate var controller: UIViewController!
    fileprivate var sheetType: ActionSheetTypeEnum = .comparision

    fileprivate let alertTypes = AccountAlertType.allCases
    fileprivate let comparisionTypes = AlertComparisionType.allCases
    fileprivate let hashrateTypes = AddAccountHashrateTypes.allCases
    fileprivate var coinSortTypes = CoinSortEnum.getChangeCases()
    fileprivate var reportedHashrate:Bool = false
    fileprivate var names: [String] = []
    
    fileprivate var point: CGPoint?
    
    fileprivate var completion: ((Int) -> ())?

    // MARK: - Life cycle
    
//    init(sourceView: UIView?) {
//        self.sourceView = sourceView
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
        DispatchQueue.main.async {
            self.showActionShit()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        showMiddleView()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tabBarHeightConstraint?.constant = controller.tabBarController?.tabBar.frame.height ?? 0
    }
}

// MARK: - Startup default setup
extension ActionSheetViewController {
    fileprivate func startupSetup() {
        setupUI()
        addGestureRecognizers()
        addObservers()
    }

    fileprivate func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        view.addGestureRecognizer(tap)
    }

    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: Notification.Name(LCLLanguageChangeNotification), object: nil)
    }
}

// MARK: - Setup UI
extension ActionSheetViewController {
    fileprivate func setupUI() {
        addTabBar()
        addMiddleView()

        addStackView()
        addButtons()

        view.backgroundColor = .clear
    }

    fileprivate func addTabBar() {
        tabBar = UIView(frame: .zero)
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBar)

        tabBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tabBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        if #available(iOS 11.0, *) {
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }

        tabBarHeightConstraint = tabBar.heightAnchor.constraint(equalToConstant: controller.tabBarController?.tabBar.frame.height ?? 0)
        tabBarHeightConstraint.isActive = true
    }

    fileprivate func addMiddleView() {
        middleView = UIView(frame: .zero)
        middleView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(middleView)

        middleView.backgroundColor = .lightGray

//        middleView.heightAnchor.constraint(equalToConstant: 72).isActive = true
        middleView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        middleView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        middleViewTopConstraint = middleView.topAnchor.constraint(equalTo: view.bottomAnchor)
        middleViewTopConstraint.isActive = true

        let bottomAnch = middleView.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
        bottomAnch.priority = .defaultHigh
        bottomAnch.isActive = true
    }

    fileprivate func addStackView() {
        stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        middleView.addSubview(stackView)

        stackView.spacing = 1
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually

        stackView.leftAnchor.constraint(equalTo: middleView.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: middleView.rightAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: middleView.topAnchor, constant: 1).isActive = true
        stackView.bottomAnchor.constraint(equalTo: middleView.bottomAnchor, constant: -1).isActive = true
    }

    fileprivate func addButtons() {
        var alertNames = alertTypes.map { $0.rawValue }
        alertNames.removeLast()
        
//        let coinSortNames = coinSortTypes.map { $0.rawValue }
        let comparisionNames = comparisionTypes.map { $0.rawValue }
        let hashrateTypeNames = hashrateTypes.map { $0.rawValue }

        switch sheetType {
        case .comparision:
            names = comparisionNames
        case .alert:
            names = alertNames
        case .coinSort:
            coinSortTypes = CoinSortEnum.getCoinCases()
            names = coinSortTypes.map { $0.localized }
        case .coinPriceSort:
            coinSortTypes = CoinSortEnum.getPriceCases()
            names = coinSortTypes.map { $0.localized }
        case .coinChangeSort:
            coinSortTypes = CoinSortEnum.getChangeCases()
            names = coinSortTypes.map { $0.localized }
        case .addAlert:
            names = hashrateTypeNames
        default:
            print("default")
        }

        for (index, name) in names.enumerated() {
            let button = UIButton(frame: .zero)
            button.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(button)

            button.tag = index
            button.backgroundColor = darkMode ? .barDark : .tableSectionLight
            button.setTitleColor(darkMode ? .white : .textBlack, for: .normal)
            button.setTitle(name.localized(), for: .normal)
            button.titleLabel?.font = Constants.regularFont.withSize(23)
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            
            button.heightAnchor.constraint(equalToConstant: 36).isActive = true
        }
    }
}

// MARK: - Actions
extension ActionSheetViewController {
    @objc fileprivate func languageChanged() {
        for subview in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(subview)
        }
        addButtons()
    }

    @objc fileprivate func tapAction(_ sender: Any?) {
        hideMiddleView()
    }

    @objc fileprivate func buttonAction(_ sender: UIButton) {
        switch sheetType {
        case .alert:
            delegate?.alertTypeSelected?(index: sender.tag)
        case .comparision:
            delegate?.comparisionSelected?(index: sender.tag)
        case .coinSort, .coinPriceSort, .coinChangeSort:
            delegate?.coinSortTypeSelected?(index: sender.tag, type: sheetType)
        case .payoutsType:
            delegate?.payoutTypeSelected?(index: sender.tag)
        case .payoutsCurrency:
            delegate?.payoutCurrencySelected?(index: sender.tag)
        case .estimationsType:
            delegate?.estimationTypeSelected?(index: sender.tag)
        case .estimationsName:
            delegate?.estimationNameSelected?(index: sender.tag)
        case .simple:
            delegate?.actionShitSelected?(index: sender.tag)
        case .addAlert:
            delegate?.hashrateTypesSelected?(index: sender.tag)
        }
        completion?(sender.tag)
        tapAction(nil)
    }
    
    private func buttonActions(_ index: Int) {
        switch sheetType {
        case .alert:
            delegate?.alertTypeSelected?(index: index)
        case .comparision:
            delegate?.comparisionSelected?(index: index)
        case .coinSort, .coinPriceSort, .coinChangeSort:
            delegate?.coinSortTypeSelected?(index: index, type: sheetType)
        case .payoutsType:
            delegate?.payoutTypeSelected?(index: index)
        case .payoutsCurrency:
            delegate?.payoutCurrencySelected?(index: index)
        case .estimationsType:
            delegate?.estimationTypeSelected?(index: index)
        case .estimationsName:
            delegate?.estimationNameSelected?(index: index)
        case .simple:
            delegate?.actionShitSelected?(index: index)
        case .addAlert:
            delegate?.hashrateTypesSelected?(index: index)
        }
        completion?(index)
        tapAction(nil)
    }
}

// MARK: - Animations
extension ActionSheetViewController {
    fileprivate func showMiddleView() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.middleViewTopConstraint.isActive = false
            self.view.layoutIfNeeded()
        }
    }

    fileprivate func hideMiddleView() {
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.middleViewTopConstraint.isActive = true
            self.view.layoutIfNeeded()
        }) { (_) in
            self.dismiss(animated: false, completion: nil)
        }
    }
}

//MARK: - Nativ Action Shit
extension ActionSheetViewController {
    func showActionShit() {
        let actionShit = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionShit.view.tintColor = .barSelectedItem
        let closure = { (index: Int) in
            { (action: UIAlertAction!) -> Void in
                self.buttonActions(index)
            }
        }
        
        for (index, name) in names.enumerated() {
            let action = UIAlertAction(title: name.localized(), style: .default, handler: closure(index))
            actionShit.addAction(action)
        }
        
        if let cancelBackgroundViewType = NSClassFromString("_UIAlertControlleriOSActionSheetCancelBackgroundView") as? UIView.Type {
            cancelBackgroundViewType.appearance().subviewsBackgroundColor = darkMode ? .viewDarkBackground : .sectionHeaderLight
        }
        
        actionShit.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: { action in
            self.hideMiddleView()
        }))
        
        if let firstSubview = actionShit.view.subviews.first, let alertContentView = firstSubview.subviews.first {
            for view in alertContentView.subviews {
                view.backgroundColor = darkMode ? .viewDarkBackgroundWithAlpha : .viewLightBackgroundWithAlpha
            }
        }

        if let popoverController = actionShit.popoverPresentationController {
            let point = self.point ?? CGPoint(x: self.view.bounds.midX, y: self.view.bounds.height)
            
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(origin: point, size: .zero)
            popoverController.permittedArrowDirections = [.down, .up]
        }
        present(actionShit, animated: true, completion: nil)
    }
}

// MARK: - Set data
extension ActionSheetViewController {
    public func setData(controller: UIViewController, type: ActionSheetTypeEnum? = nil, names: [String] = [], point: CGPoint? = nil, completion: ((Int) -> ())? = nil) {
        self.controller = controller
        self.sheetType = type ?? .simple
        self.names = names.map { $0.localized() }
        self.point = point
        self.completion = completion
    }
    
    public func reportedHashrate(Bool: Bool) {
        reportedHashrate = Bool
    }
}

// MARK: - Helpers
enum AlertComparisionType: String, CaseIterable {
    case lessThan = "comparision_less_than"
    case greatherThan = "comparision_greather_than"
}

enum AccountAlertType: String, CaseIterable {
    case hashrate = "hashrate"
    case worker = "workers"
    case reportedHashrate = "reportedHashrate"
    
    func getRawValue() -> Int {
        switch self {
        case .hashrate:
            return  0
        case .worker:
            return 1
        case .reportedHashrate:
            return 3
        }
    }
}
enum AddAccountHashrateTypes: String, CaseIterable {
    case current = "current"
    case reported = "reported"
}
