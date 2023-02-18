//
//  Loading.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 5/31/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class Loading: NSObject {

    // MARK: - Properties
    private var loadingView: UIView!
    private var activityIndicator: UIActivityIndicatorView?
    private var activityIndicatorForView: UIActivityIndicatorView?
    
    // MARK: - Static
    static let shared = Loading()
    
    // MARK: - Init
    fileprivate override init() {
        super.init()
    }

    var isAnimating: Bool {
        return getActivityIndicatorView()?.isAnimating ?? false
    }

    // MARK: - Methods
    private func getActivityIndicatorView() -> UIActivityIndicatorView? {
        if let indicatior = activityIndicator {
            UIApplication.shared.keyWindow?.bringSubviewToFront(indicatior)
            return indicatior
        }

        activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator?.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator?.color = .barSelectedItem
        activityIndicator?.backgroundColor = .clear
        activityIndicator?.hidesWhenStopped = true
        
        if let activity = self.activityIndicator {
            DispatchQueue.main.async {
                if let keyWindow = UIApplication.shared.keyWindow {
                    keyWindow.addSubview(activity)
                    activity.centerYAnchor.constraint(equalTo: keyWindow.centerYAnchor).isActive = true
                    activity.centerXAnchor.constraint(equalTo: keyWindow.centerXAnchor).isActive = true
                    activity.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
                }
            }
        }
        DispatchQueue.main.async {
            if let activity = self.activityIndicator {
                UIApplication.shared.keyWindow?.bringSubviewToFront(activity)
            }
        }
        return activityIndicator
    }
    
    func startLoadingForView(ignoringActions: Bool = false, with view: UIView, scalePoint: CGFloat? = nil) {
        if ignoringActions {
            view.isUserInteractionEnabled = false
        }
        activityIndicatorForView = UIActivityIndicatorView(style: .white)
        activityIndicatorForView?.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorForView?.color = .barSelectedItem
        activityIndicatorForView?.backgroundColor = .clear
        activityIndicatorForView?.hidesWhenStopped = true
        activityIndicatorForView?.frame = view.bounds
        activityIndicatorForView?.startAnimating()
        
        DispatchQueue.main.async {
            view.addSubview(self.activityIndicatorForView!)
            view.bringSubviewToFront(self.activityIndicatorForView!)
            self.activityIndicatorForView!.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            self.activityIndicatorForView!.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            self.activityIndicatorForView!.transform = CGAffineTransform(scaleX: scalePoint ?? 1.7, y: scalePoint ?? 1.7)
        }
    }
    
    func endLoadingForView(with view: UIView) {
        activityIndicatorForView?.stopAnimating()
        activityIndicatorForView?.removeFromSuperview()
        for view in view.subviews  where view is UIActivityIndicatorView {
            view.removeFromSuperview()
        }
        view.isUserInteractionEnabled = true
    }
    
    func startLoading(ignoringActions: Bool = false, for view: UIView = UIView(), views: [UIView] = [], barButtons: [UIBarButtonItem?] = []) {
        getActivityIndicatorView()?.startAnimating()
        
        if ignoringActions {
            view.isUserInteractionEnabled = false
            
            if views.count != 0 {
                for view in views {
                    view.isUserInteractionEnabled = false
                }
            }
            
            if barButtons.count != 0 {
                for button in barButtons {
                    button?.isEnabled = false
                }
            }
        }
    }

    func endLoading(for view: UIView = UIView(), views: [UIView] = [], barButtons: [UIBarButtonItem?] = []) {
        getActivityIndicatorView()?.stopAnimating()
        view.isUserInteractionEnabled = true
        if views.count != 0 {
            for view in views {
                view.isUserInteractionEnabled = true
            }
        }
        
        if barButtons.count != 0 {
            for button in barButtons {
                button?.isEnabled = true
            }
        }
    }
}


extension UIActivityIndicatorView {
    func changeStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.color = .barSelectedItem
        self.backgroundColor = .clear
        self.hidesWhenStopped = true
        self.startAnimating()
    }
}
