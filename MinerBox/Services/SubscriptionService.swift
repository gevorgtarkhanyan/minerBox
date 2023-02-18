//
//  SubscriptionService.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 12/10/18.
//  Copyright © 2018 WitPlex. All rights reserved.
//

import UIKit
import Alamofire
import StoreKit
import FirebaseCrashlytics

class SubscriptionService: NSObject {
    
    static let shared = SubscriptionService()
    
    var currentUser: UserModel? {
        return DatabaseManager.shared.currentUser
    }
    
    let receiptURL = Bundle.main.appStoreReceiptURL
    var completionHandler: ((Bool, [Subscription]?) -> Void)?
    
    private var subscriptionAdd: String? {
        guard let user = currentUser else { return nil }
        return "subscription/\(user.id)/add"
    }
    
    private var subscriptionGet: String? {
        guard let user = currentUser else { return nil }
        return "subscription/\(user.id)/get"
    }
    
    private var subcriptionGetWithoutUserId : String? {
        return "subscription/get"
    }
}

// MARK: - Requests
extension SubscriptionService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products.map { Subscription(product: $0) }
        completionHandler?(true, products)
        completionHandler = nil
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        completionHandler?(false, nil)
        completionHandler = nil
    }
    
    func requestProductsWithCompletionHandler(completionHandler: @escaping (Bool, [Subscription]?) -> Void) {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier?.lowercased() else {
            completionHandler(false, nil)
            return
        }
        
        self.completionHandler = completionHandler
        let productIDPrefix = bundleIdentifier + "."
        let premiumMonthly = productIDPrefix + "premiummonthly"
        let premiumYearly = productIDPrefix + "premiumyearly"
        let standardMonthly = productIDPrefix + "standardmonthly"
        let standardYearly = productIDPrefix + "standardyearly"
        let productIDs = Set([premiumMonthly, premiumYearly, standardMonthly, standardYearly])
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }
    
    func addSubsriptionToServer(subscriptionId: String, retore: Int = 0, success: @escaping() -> Void, failer: @escaping(String) -> Void ) {
        guard let receiptURL = receiptURL else {
            failer("cant_get_app_store_url")
            return
        }
        guard let receipt = try? Data(contentsOf: receiptURL) else {
            failer("subscription_info_empty")
            return
        }
        guard let endpoint = subscriptionAdd else {
            failer("user_not_loged_in")
            return
        }
        
        // Get appstore data
        let base64encodedReceipt = receipt.base64EncodedString()
        var decodedData = String(base64encodedReceipt.filter { " \n\t\r".contains($0) == false })
        decodedData = decodedData.replacingOccurrences(of: "+", with: "%2B")
        
        let params = ["subscriptionId": subscriptionId , "purchaseToken": decodedData, "restore": retore.description ]
        
        // If request failed, try to resend info many times
        NetworkManager.shared.request(method: .post, secure: true, endpoint: endpoint, params: params, encoding: AppstoreEncoding(), success: { (json) in
            if let status = json.value(forKey: "status") as? Int, status != 500 {
                
                UserDefaults.standard.set(false, forKey: "subscriptionSendFiled")
                UserDefaults.standard.removeObject(forKey: "arentSendedSubscriptionId")
                if status == 0 {
                    success()
                } else  {
                    let message = json["description"] as? String ?? "unknown_error"
                    failer(message)
                }
            } else {
                UserDefaults.standard.set(true, forKey: "subscriptionSendFiled")
                UserDefaults.standard.set(subscriptionId, forKey: "arentSendedSubscriptionId")
                DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                    self.addSubsriptionToServer(subscriptionId: subscriptionId, retore: retore ,success: success, failer: failer)
                })
            }
        }) { (error) in
            failer(error)
            UserDefaults.standard.set(true, forKey: "subscriptionSendFiled")
            UserDefaults.standard.set(subscriptionId, forKey: "arentSendedSubscriptionId")
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                self.addSubsriptionToServer(subscriptionId: subscriptionId, retore: retore ,success: success, failer: failer)
            })
        }
    }
    
    func getSubscriptionFromServer(success: @escaping([SubscriptionModel]) -> Void, failer: @escaping(String) -> Void) {
        guard let endPoint = subscriptionGet, let user = currentUser else {
            failer("user_not_loged_in".localized())
            return
        }
        
        NetworkManager.shared.request(method: .get, endpoint: endPoint, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0, let data = json["data"] as? NSDictionary else {
                let message = (json["description"] as? String ?? "unknown_error").localized()
                failer(message)
                return
            }
            let isSubscribted =  UserDefaults.standard.bool(forKey: "isSubscribted\(self.currentUser?.id ?? "")") ? true: false
            let subscription = SubscriptionModel(json: data)
            if let purchaseRecipt = data["purchaseRecipt"] as? NSDictionary, let pending_renewal_info = purchaseRecipt.value(forKey: "pending_renewal_info") as? NSDictionary, let storeType = purchaseRecipt.value(forKey: "kind") as? String {
                subscription.purchaseRecipt = PurchaseRecipt(json: pending_renewal_info)
                subscription.storeType = storeType == "AppleStore" ? 0 : 1
            }
            Crashlytics.crashlytics().setCustomValue(user.subsciptionInfo?.subscriptionType as Any, forKey: "subscriptionType")
            
            
            user.realm?.beginWrite()
            Crashlytics.crashlytics().setCustomValue(user.subsciptionInfo?.subscriptionType as Any, forKey: "subscriptionType1")
            
            Crashlytics.crashlytics().setCustomValue(user.subsciptionInfo?.subscriptionType as Any, forKey: "subscriptionType2")
            do {
                user.subsciptionInfo = subscription
                try user.realm?.commitWrite()
            } catch {
                Crashlytics.crashlytics().setCustomValue(error.localizedDescription.localized() as Any, forKey: "commitWriteError")
                failer(error.localizedDescription.localized())
            }
            
            AdsRequestService.shared.getZoneList {
                debugPrint("Ads List is update")
            } failer: { err in
                Crashlytics.crashlytics().setCustomValue(user.subsciptionInfo?.subscriptionType as Any, forKey: "subscriptionType3")
                debugPrint(err)
            }
            
            Crashlytics.crashlytics().setCustomValue(user.subsciptionInfo?.subscriptionState as Any, forKey: "subscriptionState")
            
            
            if isSubscribted != user.isSubscribted && UserDefaults.standard.value(forKey: "isSubscribted\(self.currentUser?.id ?? "")") != nil {
                if user.isSubscribted {
                    UserDefaults.standard.setValue(true, forKey: "isSubscribted\(self.currentUser?.id ?? "")")
                    NotificationManager.shared.sendNotificationsToServer()
                } else {
                    UserDefaults.standard.setValue(false, forKey: "isSubscribted\(self.currentUser?.id ?? "")")
                    UserDefaults.standard.removeObject(forKey: "removeAds\(DatabaseManager.shared.currentUser?.id ?? "")")
                    NotificationManager.shared.getAllNotificationsFromServer()
                }
            }
            if user.isSubscribted {
                UserDefaults.standard.setValue(true, forKey: "isSubscribted\(self.currentUser?.id ?? "")")
            } else {
                UserDefaults.standard.setValue(false, forKey: "isSubscribted\(self.currentUser?.id ?? "")")
            }
            success([subscription])
            
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
    
    func getSubscriptionFromServerWithoutUserID(success: @escaping([SubscriptionModel]) -> Void, failer: @escaping(String) -> Void) {
        guard let endPoint = subcriptionGetWithoutUserId else { return }
        
        NetworkManager.shared.request(method: .get, endpoint: endPoint, success: { (json) in
            guard let status = json.value(forKey: "status") as? Int, status == 0, let data = json["data"] as? NSDictionary else {
                let message = (json["description"] as? String ?? "unknown_error").localized()
                failer(message)
                return
            }
            let subscription = SubscriptionModel(json: data)
            success([subscription])
            
        }) { (error) in
            failer(error)
            debugPrint(error)
        }
    }
}


// MARK: - Helpers
struct Subscription {
    let id: Int
    let product: SKProduct
    let formattedPrice: String
    let price:Double
    
    init(product: SKProduct) {
        self.product = product
        
        if formatter.locale != self.product.priceLocale {
            formatter.locale = self.product.priceLocale
        }
        
        formattedPrice = formatter.string(from: product.price) ?? "\(product.price)"
        price = Double(truncating: product.price)
        
        if product.productIdentifier.lowercased().contains("standardmonthly") {
            self.id = 1
        } else if product.productIdentifier.contains("standardyearly") {
            self.id = 2
        } else if product.productIdentifier.contains("premiummonthly") {
            self.id = 3
        } else if product.productIdentifier.contains("premiumyearly") {
            self.id = 4
        } else {
            self.id = 0
        }
    }
    
    fileprivate var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.formatterBehavior = .behavior10_4
        
        return formatter
    }()
}
