//
//  ViewControllerExtension.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 1/25/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

// MARK: - AlertView
extension UIViewController {
    
    var topBarHeight: CGFloat {
        var top = self.navigationController?.navigationBar.frame.height ?? 0.0
        if #available(iOS 13.0, *) {
            top += UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            top += UIApplication.shared.statusBarFrame.height
        }
        return top
    }
    
    var tabBarHeight: CGFloat {
        return tabBarController?.tabBar.frame.size.height ?? 0.0
    }

    // MARK: - Base Alert view
    func showAlertView(_ title: String?, message: String?, completion: ((_ finish: Bool) -> Void)?) -> Void {
        DispatchQueue.main.async {
            self.showAlertViewInMain(title, message: message, completion: completion)
        }
    }
    
    func showActionShit(_ vc: UIViewController, type: ActionSheetTypeEnum, items: [String], point: CGPoint? = nil) {
        let controller = tabBarController ?? vc
        let newVC = ActionSheetViewController()
        newVC.delegate = vc as? ActionSheetViewControllerDelegate
        newVC.setData(controller: controller, type: type, names: items, point: point)

        newVC.modalPresentationStyle = .overCurrentContext
        controller.present(newVC, animated: false, completion: nil)
    }
    
    func showActionShit(_ vc: UIViewController, items: [String], point: CGPoint? = nil, completion: @escaping (Int) -> ()) {
        let controller = tabBarController ?? vc
        let newVC = ActionSheetViewController()
        newVC.setData(controller: controller, names: items, point: point, completion: completion)

        newVC.modalPresentationStyle = .overCurrentContext
        controller.present(newVC, animated: false, completion: nil)
    }

    fileprivate func showAlertViewInMain(_ title: String?, message: String?, completion: ((_ finish: Bool) -> Void)?) {
        let alertController = getAlertController(title: title, message: message)

        let okAction = UIAlertAction(title: "ok".localized(), style: .cancel, handler: { _ in
            completion?(true)
        })
        okAction.setValue(UIColor.barSelectedItem, forKey: "titleTextColor")
        alertController.addAction(okAction)

        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Toast Alert
    func showToastAlert(_ title: String?, message: String?) {
        DispatchQueue.main.async {
            self.showToastAlertInMain(title, message: message, finished: { })
        }
    }

    func showToastAlert(_ title: String?, message: String?, finished: @escaping() -> ()) {
        DispatchQueue.main.async {
            self.showToastAlertInMain(title, message: message, finished: finished)
        }
    }

    fileprivate func showToastAlertInMain(_ title: String?, message: String?, finished: @escaping() -> ()) {
        let alertController = getAlertController(title: title, message: message)
        self.present(alertController, animated: true, completion: nil)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            alertController.dismiss(animated: true, completion: nil)
            finished()
        }
    }

    // MARK: - Alert view controller
    func showAlertViewController(_ title: String?, message: String?, otherButtonTitles: [String]?, cancelButtonTitle: String? = nil, actionHandler: ((_ action: String) -> Void)?) {

        DispatchQueue.main.async {
            self.showAlertViewControllerInMain(title, message: message, otherButtonTitles: otherButtonTitles, cancelButtonTitle: cancelButtonTitle, actionHandler: actionHandler)
        }
    }

    fileprivate func showAlertViewControllerInMain(_ title: String?, message: String?, otherButtonTitles: [String]?, cancelButtonTitle: String?, actionHandler: ((_ action: String) -> Void)?) {

        let alertController = getAlertController(title: title, message: message)

        // Cancel button
        let cancel = UIAlertAction(title: cancelButtonTitle?.localized() ?? "cancel".localized(), style: .cancel, handler: { alert in
            actionHandler?(cancelButtonTitle ?? "cancel")
            alertController.dismiss(animated: true, completion: nil)
        })
        cancel.setValue(UIColor.barSelectedItem, forKey: "titleTextColor")

        alertController.addAction(cancel)

        // Other buttons
        if let otherTitles = otherButtonTitles {
            for otherButtonTitle in otherTitles {
                let action = UIAlertAction(title: otherButtonTitle.localized(), style: .default, handler: { alert in
                    actionHandler?(otherButtonTitle)
                    alertController.dismiss(animated: true, completion: nil)
                })
                action.setValue(UIColor.barSelectedItem, forKey: "titleTextColor")
                alertController.addAction(action)
            }
        }

        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Xib
    static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T.init(nibName: String(describing: T.self), bundle: nil)
        }
        
        return instantiateFromNib()
    }

    // MARK: - Helper
    fileprivate func getAlertController(title: String?, message: String?) -> UIAlertController {
        let textColor = darkMode ? .white : UIColor.black.withAlphaComponent(0.85)

        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        if let subview = alertController.view.subviews.first?.subviews.first?.subviews.first {
            subview.backgroundColor = darkMode ? .viewDarkBackground : .viewLightBackground
        }

        // Title
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: Constants.semiboldFont.withSize(17), .foregroundColor: textColor]
        let attributedTitle = NSAttributedString(string: title?.localized() ?? "", attributes: titleAttributes)

        // Message
        let messageAttributes: [NSAttributedString.Key: Any] = [.font: Constants.regularFont.withSize(17), .foregroundColor: textColor]
        let attributedMessage = NSAttributedString(string: message?.localized() ?? "", attributes: messageAttributes)

        alertController.setValue(attributedTitle, forKey: "attributedTitle")
        alertController.setValue(attributedMessage, forKey: "attributedMessage")
        
        
        return alertController
    }
}
