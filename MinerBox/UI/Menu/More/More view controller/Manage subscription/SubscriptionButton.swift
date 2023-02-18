//
//  SubscriptionButton.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/19/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class SubscriptionButton: BackgroundButton {

    // MARK: - Properties
    fileprivate(set) var planType: SubscriptionButtonPlanTypeEnum = .standard
    fileprivate(set) var durationType: SubscriptionButtonDurationTypeEnum = .none
    fileprivate(set) var subscriptionState: SubscriptionButtonSubscriptionStateEnum = .none

    fileprivate var price = ""
    fileprivate var trialActive = false

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 10
    }

    override func languageChanged() {
        changeTitle()
    }
}

// MARK: - Startup
extension SubscriptionButton {
    override func startupSetup() {
        super.startupSetup()
        changeFontSize(to: 17)
    }

    override func changeColors() {
        switch subscriptionState {
        case .none:
            backgroundColor = .clear
        case .current:
            backgroundColor = .activeSubscription
        case .next:
            backgroundColor = .nextSubscription
        case .billingRetry:
            backgroundColor = .nextSubscription
        }
    }
}

// MARK: - Actions
extension SubscriptionButton {
    fileprivate func changeTitle() {
        if planType == .restore {
            setTitle("restore_subscription".localized(), for: .normal)
        } else {
            if durationType == .monthly, trialActive {
                setTitle("try_7_days".localized().replacingOccurrences(of: "xxx", with: price), for: .normal)
                return
            }
            setTitle(price + " / " + durationType.rawValue.localized(), for: .normal)
        }
    }
}

// MARK: - Public methods
extension SubscriptionButton {
    public func setType(planType: SubscriptionButtonPlanTypeEnum, durationType: SubscriptionButtonDurationTypeEnum) {
        self.planType = planType
        self.durationType = durationType
        changeColors()

        changeTitle()
    }

    public func setPrice(_ price: String) {
        self.price = price
        changeTitle()
    }

    public func setTrialActive(_ trialActive: Bool) {
        self.trialActive = trialActive
        changeTitle()
    }

    public func setSubscriptionState(_ subscriptionState: SubscriptionButtonSubscriptionStateEnum) {
        self.subscriptionState = subscriptionState
        changeColors()
    }
}

// MARK: - Helpers
enum SubscriptionButtonPlanTypeEnum {
    case standard
    case premium
    case restore
}

enum SubscriptionButtonDurationTypeEnum: String {
    case monthly = "monthly"
    case yearly = "yearly"
    case none
}

enum SubscriptionButtonSubscriptionStateEnum: String {
    case current
    case next
    case none
    case billingRetry
}
