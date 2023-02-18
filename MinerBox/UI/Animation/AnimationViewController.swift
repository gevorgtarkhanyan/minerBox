//
//  AnimationViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/1/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class AnimationViewController: BaseViewController {
    
    // MARK: - Views
    @IBOutlet fileprivate weak var backgroundView: AnimationView!
    
    @IBOutlet fileprivate weak var logoImageView: UIImageView!
    @IBOutlet fileprivate weak var retryButton: LoginButton!
    
    // MARK: - Properties
    fileprivate var dataGetSuccessfull = false
    fileprivate var stopAnimation = false
    fileprivate var error: String?
    
    // MARK: - Static
    static func initializeStoryboard() -> AnimationViewController? {
        return UIStoryboard(name: "Animation", bundle: nil).instantiateViewController(withIdentifier: AnimationViewController.name) as? AnimationViewController
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
        startRequests()
        TimerManager.shared.resetTime(item: .addressType)
    }
}

// MARK: - Startup default setup
extension AnimationViewController {
    fileprivate func startupSetup() {
        configRetryButton()
        configLogo()
    }
    
    fileprivate func configRetryButton() {
        retryButton.setLocalizedTitle("animation_retry")
        retryButton.changeFontSize(to: 15)
        retryButton.addTarget(self, action: #selector(retryButtonAction(_:)), for: .touchUpInside)
    }
    
    fileprivate func configLogo() {
        let iconName = Date().isChristmasDay ? "christmasLogo" : "logo"
        logoImageView.image = UIImage(named: iconName)
    }
}

// MARK: - Requests
extension AnimationViewController {
    fileprivate func startRequests() {
        animateLogo()
        let group = DispatchGroup()
        
        group.enter()
        getCommnity {
            group.leave()
        }
        
        group.enter()
        getPoolTypes {
            group.leave()
        }
        
        group.enter()
        getZoneList {
            group.leave()
        }
        
        if let _ = user {
            group.enter()
            getSubscription {
                group.leave()
            }
        }
        
        group.notify(queue: .main, work: DispatchWorkItem(block: {
            self.requestsEnded()
        }))
        
        if !UserDefaults.standard.bool(forKey: "isPresent") || DatabaseManager.shared.communityModel == nil {
            self.getWelcomeMessagePush()
        }
    }
    
    fileprivate func getWelcomeMessagePush() {
        UserDefaults.standard.setValue(true, forKey: "isPresent")
        WelcomeMessageManager.shared.getWelcomeMessageWithURL()
    }
    
    fileprivate func getSubscription(ended: @escaping() -> Void) {
        SubscriptionService.shared.getSubscriptionFromServer(success: {_ in 
            ended()
        }) { (error) in
            self.requestFailed(error: error, completion: ended)
        }
    }
    
    fileprivate func getPoolTypes(ended: @escaping() -> Void) {
        PoolRequestService.shared.getTypeList(success: {
            ended()
        }) { (error) in
            self.requestFailed(error: error, completion: ended)
        }
    }
    
    fileprivate func getZoneList(ended: @escaping() -> Void) {
        AdsRequestService.shared.getZoneList {
            ended()
        } failer: { (error) in
            self.requestFailed(error: error, completion: ended)
        }
    }
    
    fileprivate func getCommnity(ended: @escaping () -> Void) {
        
        let isOver24Hors = TimerManager.shared.isLoadingTime(item: .community)
        guard isOver24Hors || DatabaseManager.shared.communityModel == nil else { ended(); return }
        
        CommunityManager.shared.getList(success: { (community) in
            ended()
        }) { (error) in
            self.requestFailed(error: error, completion: ended)
        }
    }
    
    fileprivate func requestsEnded() {
        dataGetSuccessfull = true
        self.hideRetryButton()
    }
    
    fileprivate func requestFailed(error: String, completion: () -> Void) {
        self.error = error
        self.stopAnimation = true
        completion()
    }
    
    fileprivate func failedAction() {
        self.showRetryButton()
        guard let error = error else { return }
        self.showAlertView("", message: error, completion: nil)
    }
    
}

// MARK: - Actions
extension AnimationViewController {
    fileprivate func goToTabController() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let storyboard = UIStoryboard(name: "Menu", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MenuTabBarController")
        
        if #available(iOS 11.0, *) {
            controller.view.animateSnapshotView()
        }
        
        appDelegate.window?.rootViewController = controller
    }
    
    // MARK: UI Actions
    @objc fileprivate func retryButtonAction(_ sender: UIButton) {
        stopAnimation = false
        startRequests()
    }
}

// MARK: - Animations
extension AnimationViewController {
    fileprivate func showRetryButton() {
        guard retryButton.isHidden else { return }
        retryButton.isHidden = false
        UIView.animate(withDuration: Constants.animationDuration) {
            self.retryButton.alpha = 1
        }
    }
    
    fileprivate func hideRetryButton() {
        guard retryButton.isHidden == false else { return }
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.retryButton.alpha = 0
        }) { (_) in
            self.retryButton.isHidden = true
        }
    }
    
    fileprivate func animateLogo() {
        UIView.animate(withDuration: 1.5) {
            self.logoImageView.transform = CGAffineTransform(rotationAngle: .pi)
        }
        
        UIView.animate(withDuration: 1.5, animations: {
            self.logoImageView.transform = .identity
        }) { (_) in
            guard self.stopAnimation == false else { self.failedAction(); return }
            if self.dataGetSuccessfull {
                self.goToTabController()
            } else {
                self.animateLogo()
            }
        }
    }
}
