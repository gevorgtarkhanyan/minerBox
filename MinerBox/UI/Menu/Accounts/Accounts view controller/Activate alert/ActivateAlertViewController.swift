//
//  ActivateAlertViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 1/30/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

protocol ActivateAlertViewControllerDelegate: NSObjectProtocol {
    func activated()
}

class ActivateAlertViewController: BaseViewController {

    // MARK: - Views
    @IBOutlet fileprivate weak var cancelButton: AlertControllerButton!
    @IBOutlet fileprivate weak var activateButton: AlertControllerButton!
    @IBOutlet fileprivate weak var warningText: UILabel!
    @IBOutlet fileprivate weak var activateLabel: UILabel!
    
    public var activeAccountCount = [PoolAccountModel]()

    // MARK: - Properties
    var delegate: ActivateAlertViewControllerDelegate?

    // MARK: - Static
    static func initializeStoryboard() -> ActivateAlertViewController {
        let bundle = Bundle(identifier: ActivateAlertViewController.name)
        return ActivateAlertViewController(nibName: ActivateAlertViewController.name, bundle: bundle)
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }

    override func languageChanged() {
        cancelButton.setTitle("cancel".localized(), for: .normal)

        activateButton.changeFont(to: Constants.semiboldFont)
        activateButton.setTitle("activate".localized(), for: .normal)

        activateLabel.text = "activate".localized()
        
            if !(user?.isSubscribted ?? false) {
                if activeAccountCount.count < 1 {
                    var text = "xxx_account_can_be_activated".localized()
                    text = text.replacingOccurrences(of: "XXX", with: "\( user?.maxAccountCount ?? 1)")
                    warningText.text = text
                } else {
                    warningText.text = "one_account_can_be_activated".localized()
                    activateButton.isHidden = true
                }
            } else if ((user?.isStandardUser) != nil) {
                if activeAccountCount.count < user?.maxAccountCount ?? 3 {
                    var text = "xxx_account_can_be_activated".localized()
                    text = text.replacingOccurrences(of: "XXX", with: "\(user?.maxAccountCount ?? 3)")
                    warningText.text = text
                } else {
                    warningText.text = "one_account_can_be_activated".localized()
                    activateButton.isHidden = true
                }
            } else {
                if activeAccountCount.count < user?.maxAccountCount ?? 10 {
                    var text = "xxx_account_can_be_activated".localized()
                    text = text.replacingOccurrences(of: "XXX", with: "\(user?.maxAccountCount ?? 10)")
                    warningText.text = text
                } else {
                    warningText.text = "one_account_can_be_activated".localized()
                    activateButton.isHidden = true
                }
            }
    }

    // MARK: - Actions
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func activateButtonAction(_ sender: UIButton) {
        delegate?.activated()
        self.dismiss(animated: true, completion: nil)
    }
}
