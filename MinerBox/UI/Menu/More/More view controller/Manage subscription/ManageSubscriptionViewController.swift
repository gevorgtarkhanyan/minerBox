//
//  ManageSubscriptionViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/19/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import StoreKit

class ManageSubscriptionViewController: BaseViewController {

    // MARK: - Views
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet fileprivate weak var promoUserView: UIView?
    @IBOutlet fileprivate weak var promoUserLabel: LocalizableLabel?
    @IBOutlet fileprivate weak var updateButton: UIButton?
    @IBOutlet var planBaseView: BaseView!
    @IBOutlet var accountsCountLabel: BaseLabel!
    @IBOutlet var hashrateLabel: BaseLabel!
    @IBOutlet var workerAlertsLabel: BaseLabel!
    @IBOutlet var payoutsView: BaseView!
    @IBOutlet var payoutAlersLabel: BaseLabel!
    @IBOutlet var widgetView: BaseView!
    @IBOutlet var widgetLabel: BaseLabel!
    @IBOutlet var removeAdsVIew: BaseView!
    @IBOutlet var removeAdsLabel: BaseLabel!
    @IBOutlet fileprivate weak var segmentControlSubscriptionType: BaseSegmentControl!
    @IBOutlet var montlyView: UIView!
    @IBOutlet var yearlyView: UIView!
    @IBOutlet var YearlyImageView: BaseImageView!
    @IBOutlet var montlyPriceLabel: UILabel!
    @IBOutlet var montlyLabel: UILabel!
    @IBOutlet var yearlyPriceLabel: UILabel!
    @IBOutlet var yearlyLabel: UILabel!
    @IBOutlet var yearlyToMonthsLabel: UILabel!
    @IBOutlet var saveDegressLabel: UILabel!
    @IBOutlet var countinueButton: BaseButton!
    @IBOutlet var continueView: UIView!
    @IBOutlet var countinueOrTryLabel: UILabel!
    @IBOutlet var moreButton: UIButton!
    @IBOutlet var monthlyCheckmarkIcon: UIImageView!
    @IBOutlet var yearlyCheckmarkIcon: UIImageView!
    @IBOutlet var monthlyLabelConstraint: NSLayoutConstraint!
    @IBOutlet var yearlyLabelConstraint: NSLayoutConstraint!
    @IBOutlet var yearlyMonthlyBaseView: UIView!
    @IBOutlet var accountsCountImage: BaseImageView!
    @IBOutlet var hashrateImage: BaseImageView!
    @IBOutlet var workerImage: BaseImageView!
    @IBOutlet var payoutsImage: UIImageView!
    @IBOutlet var widgetImage: BaseImageView!
    @IBOutlet var removeAdsImage: BaseImageView!
    @IBOutlet var segmentControlView: BarCustomView!
    
    // Other
    @IBOutlet fileprivate weak var restoreButton: UIButton!
    @IBOutlet fileprivate weak var subscriptionInfoLabel: BaseLabel!
    @IBOutlet fileprivate weak var privacyPolicyButton: UIButton!
    @IBOutlet fileprivate weak var termsOfUseButton: UIButton!
    
    // MARK: - Properties
    fileprivate var products: [Subscription]?
    fileprivate var subscriptionPlans = SubscriptionTypes.allCases
    fileprivate var selectedPlan: SubscriptionTypes = .premium
    fileprivate var selectedButtonIndex = -1
    fileprivate var restoreSended: Bool = false
    fileprivate var productPrice:Double = 0.0
    fileprivate var communtiyModel = DatabaseManager.shared.communityModel
    fileprivate var countTappedYearly = 0
    fileprivate var countTappedMontly = 0
    private var subscriptions: [SubscriptionModel]?
    private var standartMaxAccountCount = 0
    private var premiumMaxAccountCount = 0
    // MARK: - Static
    static func initializeStoryboard() -> ManageSubscriptionViewController? {
        return UIStoryboard(name: "More", bundle: nil).instantiateViewController(withIdentifier: ManageSubscriptionViewController.name) as? ManageSubscriptionViewController
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Loading.shared.endLoading(for: self.view)
    }
    
    override func languageChanged() {
        title = MoreSettingsEnum.manageSubscription.rawValue.localized()
        
        let title = "update".localized()
        let text = NSMutableAttributedString(string: title, attributes: [.foregroundColor: UIColor.white])
        //        text.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, title.count))
        updateButton?.setTitleColor(.white, for: .normal)
        updateButton?.setAttributedTitle(text, for: .normal)
        //        updateButton?.titleLabel?.numberOfLines = 2
        updateButton?.titleLabel?.textAlignment = .center
        //        updateButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        
        privacyPolicyButton.setTitle("privacy_policy".localized(), for: .normal)
        termsOfUseButton.setTitle("terms_of_use".localized(), for: .normal)
    }
}

// MARK: - Startup
extension ManageSubscriptionViewController {
    fileprivate func startupSetup() {
        getSubscriptions()
        configLabels()
        configViews()
        configButtons()
        SKPaymentQueue.default().add(self)
        NotificationCenter.default.addObserver(self, selector: #selector(successfulSubscription), name: Notification.Name(Constants.successfullSubscription), object: nil)
        configSegmentControl()
    }
    
    fileprivate func configLabels() {
        var MaxAccount = "add_up_to_xxx_accounts".localized()
        switch selectedPlan {
        case .premium:
            MaxAccount = MaxAccount.replacingOccurrences(of: "xxx", with: "\(premiumMaxAccountCount)")
        case .standart:
            MaxAccount = MaxAccount.replacingOccurrences(of: "xxx", with: "\(standartMaxAccountCount)")
        }
        accountsCountLabel.setLocalizableText(MaxAccount)
        hashrateLabel.setLocalizableText("add_hashrate_alerts")
        workerAlertsLabel.setLocalizableText("add_worker_alerts")
        payoutAlersLabel?.setLocalizableText("add_payout_alerts")
        widgetLabel?.setLocalizableText("add_widget")
        removeAdsLabel?.setLocalizableText("remove_ads_more")
        
        // Default
        subscriptionInfoLabel.setLocalizableText("subscription_info")
        
        if #available(iOS 10, *) { } else {
            widgetView?.removeFromSuperview()
        }
    }
    
    fileprivate func configSegmentControl() {
        segmentControlSubscriptionType.delegate = self
        let titles = subscriptionPlans.map { $0.rawValue }
        segmentControlSubscriptionType.setSegments(titles)
        guard user?.subscriptionId != nil else {
            if selectedPlan == .premium {
                selectedButtonIndex = 2
                setButtonsPrices()
            } else {
                selectedButtonIndex = 0
                setButtonsPrices()
            }
            montlyView.layer.borderWidth = 1.5
            montlyView.layer.borderColor = UIColor.barSelectedItem.cgColor
            return
        }
        segmentControlSubscriptionType.setSelectedIndex(with: 0)
        if let subcriptionPlan = user?.subscriptionId, user?.subsciptionInfo?.getSubscriptionState() == .active {
            if subcriptionPlan.lowercased().contains("standard") {
                segmentControlSubscriptionType.setSelectedIndex(with: 1)
                montlyView.layer.borderWidth = 1.5
                montlyView.layer.borderColor = UIColor.barSelectedItem.cgColor
                selectedButtonIndex = 2
                setButtonsPrices()
            } else {
                segmentControlSubscriptionType.setSelectedIndex(with: 0)
                montlyView.layer.borderWidth = 1.5
                montlyView.layer.borderColor = UIColor.barSelectedItem.cgColor
                selectedButtonIndex = 0
                setButtonsPrices()
            }
        }
    }
    
    fileprivate func configViews() {
        restoreButton.layer.borderColor = UIColor.barSelectedItem.cgColor
        restoreButton.layer.borderWidth = 1.5
        restoreButton.setTitle("restore_subscription".localized()
                               , for: .normal)
        restoreButton.setTitleColor(.barSelectedItem, for: .normal)
        restoreButton.roundCorners(radius: 10)
        yearlyMonthlyBaseView.backgroundColor = darkMode ?  .tableCellBackground : .viewLightBackground
        yearlyView.backgroundColor = darkMode ? .viewDarkBackground : .tableCellBackground
        montlyView.backgroundColor = darkMode ? .viewDarkBackground : .tableCellBackground
        promoUserView?.backgroundColor = .workerGreen
        updateButton?.backgroundColor = .nextSubscription
        yearlyCheckmarkIcon.image = UIImage(named: "cell_checkmark")?.withRenderingMode(.alwaysTemplate)
        monthlyCheckmarkIcon.image = UIImage(named: "cell_checkmark")?.withRenderingMode(.alwaysTemplate)
        yearlyCheckmarkIcon.tintColor = darkMode ? .whiteTextColor : .textBlack
        monthlyCheckmarkIcon.tintColor = darkMode ? .whiteTextColor : .textBlack
        montlyPriceLabel.textColor = darkMode ? .whiteTextColor : .textBlack
        montlyLabel.textColor = darkMode ? .whiteTextColor : .textBlack
        yearlyPriceLabel.textColor = darkMode ? .whiteTextColor : .textBlack
        yearlyLabel.textColor = darkMode ? .whiteTextColor : .textBlack
        yearlyToMonthsLabel.textColor = darkMode ? .whiteTextColor : .textBlack
        saveDegressLabel.textColor = darkMode ? .textBlack : .whiteTextColor
        accountsCountImage.image = UIImage(named: "subscription_up_to_10_accounts")?.withRenderingMode(.alwaysTemplate)
        hashrateImage.image = UIImage(named: "subscription_hashrate_alert")?.withRenderingMode(.alwaysTemplate)
        workerImage.image = UIImage(named: "subscription_woker_alert")?.withRenderingMode(.alwaysTemplate)
        payoutsImage.image = UIImage(named: "subscription_payout_alert")?.withRenderingMode(.alwaysTemplate)
        widgetImage.image = UIImage(named: "subscription_widget")?.withRenderingMode(.alwaysTemplate)
        removeAdsImage.image = UIImage(named: "remove_ads")?.withRenderingMode(.alwaysTemplate)
        //        accountsCountImage.tintColor = darkMode ? .white : .black
        //        if let user = self.user {
        //            promoUserLabel?.setLocalizableText(user.isPremiumUser ? "premium_promo_user" : "standard_promo_user")
        //        }
    }
    
    // montlyView tap action
    @objc func montlyViewAction(recognizer: UITapGestureRecognizer) {
        countTappedYearly = 0
        countTappedMontly += 1
        if selectedPlan == .premium {
            selectedButtonIndex = 2
        } else {
            selectedButtonIndex = 0
        }
        countinueOrTryLabel.text = "subscribe".localized()
        setButtonsPrices()
        montlyView.layer.borderWidth = 1.5
        montlyView.layer.borderColor = UIColor.barSelectedItem.cgColor
        yearlyView.layer.borderWidth = 0
        yearlyView.layer.borderColor = UIColor.clear.cgColor
        if countTappedMontly == 2 {
            subscriptionButtonAction(SubscriptionButton.init())
            countTappedMontly = 1
        }
    }
    
    // yearlyView tap action
    @objc func yearlyViewAction(recognizer: UITapGestureRecognizer) {
        countTappedMontly = 0
        countTappedYearly += 1
        if selectedPlan == .premium {
            selectedButtonIndex = 3
        } else {
            selectedButtonIndex = 1
        }
        countinueOrTryLabel.text = "subscribe".localized()
        setButtonsPrices()
        yearlyView.layer.borderWidth = 1.5
        yearlyView.layer.borderColor = UIColor.barSelectedItem.cgColor
        montlyView.layer.borderWidth = 0
        montlyView.layer.borderColor = UIColor.clear.cgColor
        if countTappedYearly == 2 {
            subscriptionButtonAction(SubscriptionButton.init())
            countTappedYearly = 1
        }
    }
    
    fileprivate func configButtons() {
        // Add tap recognizer
        let tapRecognizerMontly = UITapGestureRecognizer(target: self, action: #selector(montlyViewAction(recognizer:)))
        montlyView.addGestureRecognizer(tapRecognizerMontly)
        let tapRecognizerYearly = UITapGestureRecognizer(target: self, action: #selector(yearlyViewAction(recognizer:)))
        yearlyView.addGestureRecognizer(tapRecognizerYearly)
        countinueButton.addTarget(self, action: #selector(subscriptionButtonAction(_:)), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(restoreButtonAction(_:)), for: .touchUpInside)
        updateButton?.addTarget(self, action: #selector(updateButtonAction(_:)), for: .touchUpInside)
        termsOfUseButton.addTarget(self, action: #selector(termsButtonAction(_:)), for: .touchUpInside)
        privacyPolicyButton.addTarget(self, action: #selector(privacyButtonAction(_:)), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(openNewURL), for: .touchUpInside)
    }
}

// MARK: - Actions
extension ManageSubscriptionViewController {
    fileprivate func getSubscriptions() {
        Loading.shared.startLoading(ignoringActions: true, for: self.view)
        SubscriptionService.shared.requestProductsWithCompletionHandler { (success, receivedProducts) in
            if success, let newProducts = receivedProducts {
                self.products = newProducts.sorted(by: { (item1, item2) -> Bool in
                    return item1.id < item2.id
                })
                if self.isLogedIn {
                    DispatchQueue.main.async {
                        self.getSubscriptionInfoFromBackend()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.getSubscriptionInfoFromBackendWithoutUserID()
                    }
                }
            } else {
                Loading.shared.endLoading(for: self.view)
                self.showAlertView("", message: "unknown_error", completion: nil)
            }
        }
    }
    
    fileprivate func getSubscriptionInfoFromBackend() {
        SubscriptionService.shared.getSubscriptionFromServer(success: { subscription in
            self.setButtonsPrices()
            self.showViews()
            for maxAccounts in subscription {
                self.standartMaxAccountCount = maxAccounts.standartMaxAccountCount
                self.premiumMaxAccountCount =  maxAccounts.premiumMaxAccountCount
            }
            Loading.shared.endLoading(for: self.view)
            self.configLabels()
            self.restoreSended = false
        }, failer: { (error) in
            self.restoreSended = false
            Loading.shared.endLoading(for: self.view)
            self.showAlertView("", message: error, completion: nil)
        })
    }
    
    fileprivate func getSubscriptionInfoFromBackendWithoutUserID() {
        guard DatabaseManager.shared.currentUser == nil else {return}
        SubscriptionService.shared.getSubscriptionFromServerWithoutUserID(success: {subscription in
            self.setButtonsPrices()
            self.showViews()
            for maxAccounts in subscription {
                self.standartMaxAccountCount = maxAccounts.standartMaxAccountCount
                self.premiumMaxAccountCount =  maxAccounts.premiumMaxAccountCount
            }
            self.configLabels()
            Loading.shared.endLoading(for: self.view)
        }, failer: { (error) in
            Loading.shared.endLoading(for: self.view)
            self.showAlertView("", message: error, completion: nil)
        })
        
    }
    
    fileprivate func setButtonsPrices() {
        if products == nil { return }
        guard let products = self.products else { return }
        
        var trialExpired = false
        if let user = DatabaseManager.shared.currentUser, user.trialState {
            trialExpired = true
            
        }
        for (index, product) in products.enumerated() {
            
            if selectedPlan == .premium {
                if index == 2 {
                    montlyPriceLabel.text = product.formattedPrice
                    productPrice = product.price * 12
                } else if index == 3 {
                    yearlyPriceLabel.text = product.formattedPrice
                    var text = "12_months_as_mo".localized()
                    text = text.replacingOccurrences(of: "x", with: "\((product.price / 12).getString())")
                    yearlyToMonthsLabel.text = text
                    saveDegressLabel.text = "SAVE".localized() + " " + "\(Int(100 - ((product.price * 100) / productPrice)))" + "%"
                }
            } else {
                if index == 0 {
                    montlyPriceLabel.text = product.formattedPrice
                    productPrice = product.price * 12
                } else if index == 1 {
                    yearlyPriceLabel.text = product.formattedPrice
                    var text = "12_months_as_mo".localized()
                    text = text.replacingOccurrences(of: "x", with: "\((product.price / 12).getString())")
                    yearlyToMonthsLabel.text = text
                    saveDegressLabel.text = "SAVE".localized() + " " + "\(Int(100 - ((product.price * 100) / productPrice)))" + "%"
                }
            }
            
            if product.product.productIdentifier.lowercased().contains("monthly"), trialExpired == false {
                let trialText = "try_7_days".localized()
                if product.product.productIdentifier.lowercased().contains("standard") {
                    if selectedButtonIndex == 0 {
                        countinueOrTryLabel.text = trialText
                    }
                } else {
                    if selectedButtonIndex == 2 {
                        countinueOrTryLabel.text = trialText
                    }
                }
            }
            
            guard let user = DatabaseManager.shared.currentUser, let subscriptionState = user.subsciptionInfo?.getSubscriptionState() else { continue }
            
            if product.product.productIdentifier == user.subscriptionId {
                if subscriptionState == .active {
                    if selectedPlan == .premium  {
                        if index == 2 {
                            montlyView.backgroundColor = .accountEnabled
                            monthlyCheckmarkIcon.isHidden = false
                            monthlyLabelConstraint.constant = 10
                        } else if index == 3 {
                            yearlyView.backgroundColor = .accountEnabled
                            yearlyCheckmarkIcon.isHidden = false
                            yearlyLabelConstraint.constant = 2
                        }
                    } else {
                        if index == 0 {
                            montlyView.backgroundColor = .accountEnabled
                            monthlyCheckmarkIcon.isHidden = false
                            monthlyLabelConstraint.constant = 10
                        } else if index == 1 {
                            yearlyView.backgroundColor = .accountEnabled
                            yearlyCheckmarkIcon.isHidden = false
                            yearlyLabelConstraint.constant = 2
                        }
                    }
                } else if subscriptionState == .activeBut {
                    if let subInfo = user.subsciptionInfo {
                        if selectedPlan == .premium {
                            if index == 2 {
                                montlyView.backgroundColor = .nextSubscription
                                monthlyCheckmarkIcon.isHidden = false
                                monthlyLabelConstraint.constant = 10
                                if subInfo.purchaseRecipt?.auto_renew_status != 1 {
                                    if selectedButtonIndex == index {
                                        countinueOrTryLabel.text = "re_subscribe".localized()
                                    }
                                }
                            } else if index == 3 {
                                yearlyView.backgroundColor = .nextSubscription
                                yearlyCheckmarkIcon.isHidden = false
                                yearlyLabelConstraint.constant = 2
                                if subInfo.purchaseRecipt?.auto_renew_status != 1 {
                                    if selectedButtonIndex == index {
                                        countinueOrTryLabel.text = "re_subscribe".localized()
                                    }
                                }
                                
                            }
                        } else {
                            if index == 0 {
                                montlyView.backgroundColor = .nextSubscription
                                monthlyCheckmarkIcon.isHidden = false
                                monthlyLabelConstraint.constant = 10
                                if subInfo.purchaseRecipt?.auto_renew_status != 1 {
                                    if selectedButtonIndex == index {
                                        countinueOrTryLabel.text = "re_subscribe".localized()
                                    }
                                }
                                
                            } else if index == 1 {
                                yearlyView.backgroundColor = .nextSubscription
                                yearlyCheckmarkIcon.isHidden = false
                                yearlyLabelConstraint.constant = 2
                                if subInfo.purchaseRecipt?.auto_renew_status != 1 {
                                    if selectedButtonIndex == index {
                                        countinueOrTryLabel.text = "re_subscribe".localized()
                                    }
                                }
                                
                            }
                        }
                    }
                } else if subscriptionState == .billingRetry {
                    if selectedPlan == .premium {
                        if index == 2  {
                            montlyView.backgroundColor = .nextSubscription
                            monthlyCheckmarkIcon.isHidden = false
                            monthlyLabelConstraint.constant = 10
                        } else if index == 3 {
                            yearlyView.backgroundColor = .nextSubscription
                            yearlyCheckmarkIcon.isHidden = false
                            yearlyLabelConstraint.constant = 3
                        }
                    } else {
                        if index == 0 {
                            montlyView.backgroundColor = .nextSubscription
                            monthlyCheckmarkIcon.isHidden = false
                            monthlyLabelConstraint.constant = 10
                        } else if index == 1 {
                            yearlyView.backgroundColor = .nextSubscription
                            yearlyCheckmarkIcon.isHidden = false
                            yearlyLabelConstraint.constant = 3
                        }
                    }
                } else {
                    if selectedPlan == .premium {
                        if index == 2  {
                            montlyView.backgroundColor = darkMode ? .viewDarkBackground : .tableCellBackground
                            monthlyCheckmarkIcon.isHidden = true
                            monthlyLabelConstraint.constant = 18
                        } else if index == 3 {
                            yearlyView.backgroundColor = darkMode ? .viewDarkBackground : .tableCellBackground
                            yearlyCheckmarkIcon.isHidden = true
                            yearlyLabelConstraint.constant = 10
                        }
                    } else {
                        if index == 0 {
                            montlyView.backgroundColor = darkMode ? .viewDarkBackground : .tableCellBackground
                            monthlyCheckmarkIcon.isHidden = true
                            monthlyLabelConstraint.constant = 18
                        } else if index == 1 {
                            yearlyView.backgroundColor = darkMode ? .viewDarkBackground : .tableCellBackground
                            yearlyCheckmarkIcon.isHidden = true
                            yearlyLabelConstraint.constant = 10
                        }
                    }
                }
            } else {
                if selectedPlan == .premium {
                    if index == 2  {
                        montlyView.backgroundColor = darkMode ? .viewDarkBackground : .tableCellBackground
                        monthlyCheckmarkIcon.isHidden = true
                        monthlyLabelConstraint.constant = 18
                    } else if index == 3 {
                        yearlyView.backgroundColor = darkMode ? .viewDarkBackground : .tableCellBackground
                        yearlyCheckmarkIcon.isHidden = true
                        yearlyLabelConstraint.constant = 10
                        
                    }
                } else {
                    if index == 0 {
                        montlyView.backgroundColor = darkMode ? .viewDarkBackground : .tableCellBackground
                        monthlyCheckmarkIcon.isHidden = true
                        monthlyLabelConstraint.constant = 18
                    } else if index == 1 {
                        yearlyView.backgroundColor = darkMode ? .viewDarkBackground : .tableCellBackground
                        yearlyCheckmarkIcon.isHidden = true
                        yearlyLabelConstraint.constant = 10
                    }
                }
            }
            
            if subscriptionState == .active, user.subscriptionId != user.nextSubscriptionId, product.product.productIdentifier == user.nextSubscriptionId {
                if selectedPlan == .premium {
                    if index == 2 {
                        montlyView.backgroundColor = .nextSubscription
                        monthlyCheckmarkIcon.isHidden = false
                        monthlyLabelConstraint.constant = 10
                    } else if index == 3 {
                        yearlyView.backgroundColor = .nextSubscription
                        yearlyCheckmarkIcon.isHidden = false
                        yearlyLabelConstraint.constant = 2
                    }
                } else {
                    if index == 0 {
                        montlyView.backgroundColor = .nextSubscription
                        monthlyCheckmarkIcon.isHidden = false
                        monthlyLabelConstraint.constant = 10
                    } else if index == 1 {
                        yearlyView.backgroundColor = .nextSubscription
                        yearlyCheckmarkIcon.isHidden = false
                        yearlyLabelConstraint.constant = 2
                    }
                }
            }
        }
    }
    
    @objc fileprivate func successfulSubscription() {
        DispatchQueue.main.async {
            self.setButtonsPrices()
        }
        Loading.shared.endLoadingForView(with: self.view)
        
    }
    
    // MARK: - UI actions
    @objc fileprivate func subscriptionButtonAction(_ sender: SubscriptionButton) {
        guard isLogedIn else {
            goToLoginPage()
            return
        }
        
        guard let products = self.products, products.indices.contains(selectedButtonIndex ) else {
            self.showToastAlert("", message: "unknown_error".localized())
            return
        }
        let newProduct = products[selectedButtonIndex ]
        
        DispatchQueue.global().async {
            let payment = SKPayment(product: newProduct.product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    @objc func openNewURL() {
        openURL(urlString: "https://www.witplex.com/MinerBox/active/help/subscriptions_help/")
    }
    
    @objc fileprivate func restoreButtonAction(_ sender: SubscriptionButton) {
        guard isLogedIn else {
            goToLoginPage()
            return
        }
        Loading.shared.startLoading()
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    @objc fileprivate func updateButtonAction(_ sender: UIButton) {
        openURL(urlString: "itms-apps://apps.apple.com/account/subscriptions")
    }
    
    @objc fileprivate func privacyButtonAction(_ sender: UIButton) {
        openURL(urlString: "http://www.witplex.com/MinerBox/PrivacyPolicy/")
    }
    
    @objc fileprivate func termsButtonAction(_ sender: UIButton) {
        openURL(urlString: "http://www.witplex.com/MinerBox/TermOfUse/")
    }
}

// MARK: - Payment delegates
extension ManageSubscriptionViewController: SKPaymentTransactionObserver {
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if queue.transactions.count == 0 {
            Loading.shared.endLoading(for: self.view)
            return
        }
        
        queue.transactions.forEach { (transaction) in
            queue.finishTransaction(transaction)
        }
        
        if restoreSended == false {
            restoreSended = true
            handlePurchasedState(for: "Restored")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        Loading.shared.endLoadingForView(with: self.view)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        Loading.shared.endLoading(for: self.view)
        
        Loading.shared.startLoadingForView(ignoringActions: true,with: view)
        
        if transactions.count == 1, let transaction = transactions.last {
            switch transaction.transactionState {
            case .purchasing, .deferred:
                handlePurchasingState(for: transaction, in: queue)
            case .purchased :
                queue.finishTransaction(transaction)
                handlePurchasedState(for: transaction.payment.productIdentifier)
            case .restored :
                handlePurchasedState(for: transaction.payment.productIdentifier, restore: 1)
            case .failed:
                queue.finishTransaction(transaction)
                handleFailedState(for: transaction)
            default:
                queue.finishTransaction(transaction)
                Loading.shared.endLoading(for: self.view)
            }
        } else {
            queue.transactions.forEach { (transaction) in
                queue.finishTransaction(transaction)
            }
            if restoreSended == false {
                restoreSended = true
                handlePurchasedState(for: "Restored", restore: 1)
            }
        }
    }
    
    func handlePurchasingState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        Loading.shared.endLoading(for: self.view)
        
        Loading.shared.startLoadingForView(ignoringActions: true,with: view)
        
        debugPrint("User is attempting to purchase product id: \(transaction.payment.productIdentifier)")
    }
    
    func handlePurchasedState(for productIdentifier: String, restore: Int = 0) {
        SubscriptionService.shared.addSubsriptionToServer(subscriptionId: productIdentifier, retore: restore, success: {
            NotificationCenter.default.post(name: Notification.Name(Constants.successfullSubscription), object: nil)
            self.getSubscriptionInfoFromBackend()
        }) { (error) in
            self.getSubscriptionInfoFromBackend()
            debugPrint(error)
            self.showAlertView("", message: error.localized(), completion: nil)
        }
        debugPrint("User purchased/restored product id: \(productIdentifier)")
    }
    
    func handleFailedState(for transaction: SKPaymentTransaction) {
        Loading.shared.endLoadingForView(with: self.view)
        debugPrint("Purchase failed for product id: \(transaction.payment.productIdentifier)")
    }
}

// MARK: - SegmentControl delegate
extension ManageSubscriptionViewController: BaseSegmentControlDelegate {
    func segmentSelected(index: Int) {
        countTappedYearly = 0
        selectedPlan = subscriptionPlans[index]
        configLabels()
        yearlyView.layer.borderWidth = 0
        yearlyView.layer.borderColor = UIColor.clear.cgColor
        montlyView.layer.borderWidth = 0
        montlyView.layer.borderColor = UIColor.clear.cgColor
        countinueOrTryLabel.text = "subscribe".localized()
        if selectedPlan == .premium {
            selectedButtonIndex = 2
            
        } else {
            selectedButtonIndex = 0
        }
        montlyView.layer.borderWidth = 1.5
        montlyView.layer.borderColor = UIColor.barSelectedItem.cgColor
        countTappedMontly = 1
        setButtonsPrices()
    }
}

// MARK: - Animations
extension ManageSubscriptionViewController {
    fileprivate func showViews() {
        
        if let user = DatabaseManager.shared.currentUser, let subInfo = user.subsciptionInfo {
            
            // Hide or show green promo view
            switch subInfo.promoType {
            case 1:
                promoUserLabel?.setLocalizableText("standard_promo_user")
                updateButton?.removeFromSuperview()
                
            case 2:
                promoUserLabel?.setLocalizableText("premium_promo_user")
                updateButton?.removeFromSuperview()
            default:
                // Resubscripe
                if subInfo.getSubscriptionState() == .activeBut {
                    promoUserView?.layer.borderColor = UIColor.nextSubscription.cgColor
                    promoUserView?.layer.borderWidth = 1.5
                    promoUserView?.backgroundColor = .clear
                    if subInfo.purchaseRecipt?.auto_renew_status == 1 {
                        promoUserLabel?.setLocalizableText("payment_problem")
                    } else {
                        promoUserLabel?.setLocalizableText("subscription_cancelled")
                        
                        updateButton?.removeFromSuperview()
                    }
                } else if subInfo.getSubscriptionState() == .billingRetry {
                    promoUserLabel?.setLocalizableText("billing_retry")
                    promoUserView?.layer.borderColor = UIColor.nextSubscription.cgColor
                    promoUserView?.layer.borderWidth = 1.5
                    promoUserView?.backgroundColor = .clear
                } else {
                    promoUserView?.removeFromSuperview()
                }
            }
            
            // Disable subscription if user subscribed from Play store
            if subInfo.getStoreType() == .playStore, subInfo.getSubscriptionState() == .active {
                self.showAlertView("", message: "subscripted_from_play_store".localized(), completion: nil)
            }
        } else {
            promoUserView?.removeFromSuperview()
        }
        
        UIView.animate(withDuration: Constants.animationDuration) {
            self.scrollView.alpha = 1
            self.segmentControlView.alpha = 1
        }
    }
}

enum SubscriptionTypes: String,CaseIterable {
    case premium = "premium"
    case standart = "standart"
}
