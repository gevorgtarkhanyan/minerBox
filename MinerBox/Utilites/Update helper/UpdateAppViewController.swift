//
//  UpdateAppViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 3/27/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class UpdateAppViewController: BaseViewController {

    static let laterButtonTag = 1
    static let updateButtonTag = 2

    @IBOutlet fileprivate weak var newUpdateTextLabel: UILabel!
    @IBOutlet fileprivate weak var updateButton: AlertControllerButton!
    @IBOutlet fileprivate weak var laterButton: AlertControllerButton!

    var completionHandler: ((Int) -> ())?

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapRecognizer()

        updateButton.changeFont(to: Constants.semiboldFont)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }

    fileprivate func addTapRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapToHide(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }

    @objc fileprivate func tapToHide(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }

    override func languageChanged() {
        updateButton.layer.borderColor = UIColor.clear.cgColor
        laterButton.layer.borderColor = UIColor.clear.cgColor
        
        newUpdateTextLabel.text = "update_info".localized()
        updateButton.setTitle("update".localized(), for: .normal)
        laterButton.setTitle("later".localized(), for: .normal)
    }

    // MARK: - Actions
    @IBAction func inputButtonsClick(_ sender: UIButton) {
        completionHandler?(sender.tag)
    }
}

extension UpdateAppViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return gestureRecognizer.view == touch.view
    }
}
