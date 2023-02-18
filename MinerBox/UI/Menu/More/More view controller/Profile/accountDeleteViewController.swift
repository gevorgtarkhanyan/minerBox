//
//  accountDeleteViewController.swift
//  MinerBox
//
//  Created by Gevorg Tarkhanyan on 25.07.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit
import WidgetKit

class accountDeleteViewController: BaseViewController {

    @IBOutlet weak var accountDeleteButton: UIButton!
    @IBOutlet weak var contactSupportButton: UIButton!
    
    // MARK: - Static
    static func initializeStoryboard() -> accountDeleteViewController? {
        return UIStoryboard(name: "More", bundle: nil).instantiateViewController(withIdentifier: accountDeleteViewController.name) as? accountDeleteViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
    }
    
    override func languageChanged() {
        title = "delete_account".localized()
    }
    
    fileprivate func startupSetup () {
        accountDeleteButton.addTarget(self, action: #selector(deleteAccountAlert), for: .touchUpInside)
        contactSupportButton.addTarget(self, action: #selector(contactSupportButtonAction), for: .touchUpInside)
        accountDeleteButton.layer.borderColor = UIColor.red.cgColor
        accountDeleteButton.layer.borderWidth = darkMode ? 0 : 1
    }
    
    @objc private func contactSupportButtonAction() {
        ContactSupport.shared.contactSupport(with: self)
    }
    
    @objc private func deleteAccountAlert() {
        self.showAlertViewController(nil, message: "ask_for_delete", otherButtonTitles: ["ok"], cancelButtonTitle: "cancel") { (responce) in
            if responce == "ok" {
                self.deleteAccount()
            }
        }
    }
    
    @objc func deleteAccount() {
        Loading.shared.startLoading(ignoringActions: true, for: self.view)
        UserRequestsService.shared.userDelete(success: {
            if #available(iOS 14.0, *) {
                #if arch(arm64) || arch(i386) || arch(x86_64)
                WidgetCenter.shared.reloadAllTimelines()
                #endif
            }
            AdsRequestService.shared.getZoneList {
                debugPrint("Ads List is update")
            } failer: { err in
                debugPrint(err)
            }
            Loading.shared.endLoading(for: self.view)
            self.changeControllerToLogin()
            
        }){ (error) in
            Loading.shared.endLoading(for: self.view)
            self.showAlertView("", message: error, completion: nil)
        }
    }
    
    fileprivate func changeControllerToLogin() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let controller = LoginViewController.initializeNavigationStoryboard() else { return }
        UserDefaults.standard.set(false, forKey: "isSkip")
        appDelegate.setInitialController(controller)
    }
}
