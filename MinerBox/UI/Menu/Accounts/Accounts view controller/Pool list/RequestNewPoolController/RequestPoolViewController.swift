//
//  RequestPoolViewController.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/16/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class RequestPoolViewController: BaseViewController {
    
    @IBOutlet weak var centerView: BaseView!
    @IBOutlet weak var nameTextField: BaseTextField!
    @IBOutlet weak var cancelButton: LoginButton!
    @IBOutlet weak var doneButton: LoginButton!
    @IBOutlet weak var centerViewBottomConstraint: NSLayoutConstraint!
    private var keyboardHeight: CGFloat!
    private var blurView: UIVisualEffectView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.modalPresentationStyle = .overCurrentContext
        isPageRotationEnabled = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setBlurViewSize(with: size)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.modalPresentationStyle = .overCurrentContext
        isPageRotationEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIComponents()
        addTapRecognizer()
    }
    
    private func setupUIComponents() {
        setupBlureEffect()
        view.backgroundColor = .clear
        centerView.layer.cornerRadius = 10
        centerView.clipsToBounds = true
        nameTextField.setPlaceholder("enter_new_pool_name")
        cancelButton.setLocalizedTitle("cancel")
        doneButton.setLocalizedTitle("done")
        doneButton.changeFontSize(to: 17)
        cancelButton.changeFontSize(to: 17)
        view.bringSubviewToFront(centerView)
    }
    
    func setupBlureEffect() {
        blurView = UIVisualEffectView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        view.addSubview(blurView)
        blurView.alpha = 0.7
        blurView.effect = UIBlurEffect(style: .dark)
    }
    
    func setBlurViewSize(with size: CGSize) {
        blurView.frame.size = size
    }
    
    @IBAction func cancelTapped() {
        view.endEditing(true)
        isPageRotationEnabled = true
        controllPageRotation()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneTapped() {
        if let poolName = nameTextField.text {
            if poolName.containSpecialCharactersWithSpace() == false {
                Loading.shared.startLoading(ignoringActions: true, for: self.view)
                let userId = DatabaseManager.shared.currentUser?.id ?? "1"
                UserRequestsService.shared.requestForNewPool(userId: userId, poolName: poolName, success: {
                    Loading.shared.endLoading(for: self.view)
                    self.showToastAlert("", message: "sent".localized() + "!", finished: {
                        self.view.endEditing(true)
                        self.dismiss(animated: true, completion: nil)
                    })
                }) { (error) in
                    Loading.shared.endLoading(for: self.view)
                    self.view.endEditing(true)
                    self.showToastAlert("", message: error.localized())
                }
            } else {
                self.showToastAlert("", message: "incorrect_symbol".localized())
            }
        }
    }
    
    //MARK: --Keyboard frame changes
    override func keyboardFrameChanged(_ sender: Notification) {
        if let keyboardHSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardHSize.height
            if centerViewBottomConstraint.constant < keyboardHeight {
                UIView.animate(withDuration: 0) {
                    self.centerViewBottomConstraint.constant = self.keyboardHeight + 8
                }
                view.layoutIfNeeded()
            }
        }
    }
}
extension RequestPoolViewController: UIGestureRecognizerDelegate {
    private func addTapRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapToHide(_:)))
        tap.delegate = self
        blurView.contentView.addGestureRecognizer(tap)
    }
    
    @objc private func tapToHide(_ sender: UITapGestureRecognizer) {
        cancelTapped()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return gestureRecognizer.view == touch.view
    }
}
