//
//  AppRateRequest.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 2/6/20.
//  Copyright © 2020 WitPlex. All rights reserved.
//

import Foundation
import StoreKit
import UIKit

class AppRateRequest {
    static let shared = AppRateRequest()
    private init() {}
    
    public func requestReviewIfAppropriate() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            setupRateAppAlert()
        }
    }
    
    private func setupRateAppAlert() {
        let alertController = RateAppViewController(nibName: "RateAppViewController", bundle: nil)
        alertController.modalPresentationStyle = .overCurrentContext
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
}
