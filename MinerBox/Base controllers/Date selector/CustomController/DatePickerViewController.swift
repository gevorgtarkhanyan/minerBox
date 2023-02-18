//
//  DatePickerViewController.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 29.11.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit
import SwiftUI

@objc protocol DatePickerViewControllerDelegate: AnyObject {
    @objc func doneButtonTapped()
}

class DatePickerViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var parentView: UIView!
    @IBOutlet fileprivate weak var dateContentView: UIView!
    @IBOutlet fileprivate weak var toolBar: UIToolbar!
    @IBOutlet fileprivate weak var parentViewAspectRatio: NSLayoutConstraint!
    
    fileprivate var datePicker: BaseDatePicker!
    public weak var delegate: DatePickerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sturtupSetup()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setDateFrame()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setDateFrame()
    }
}

extension DatePickerViewController {
    fileprivate func sturtupSetup() {
        setup()
        addDatePicker()
        addtoolBar()
    }
    
    private func setup() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.48)
        view.bounds = UIScreen.main.bounds
        parentView.backgroundColor = darkMode ? .darkGrayColor : .lightGrayColor
        parentView.cornerRadius(radius: 10)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismis))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    private func addDatePicker() {
        self.dateContentView.addSubview(self.datePicker)
        if datePicker.datePickerMode == .date {
            parentView.changeConstraintMultiplier(&parentViewAspectRatio, 315/370)
        }
    }
    
    fileprivate func setDateFrame() {
        DispatchQueue.main.async {
            self.datePicker.frame = self.dateContentView.bounds
            self.dateContentView.layoutIfNeeded()
        }
    }
    
    //MARK: - toolBar
    private func addtoolBar() {
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "done".localized(), style: .done, target: self, action: #selector(doneButtonTapped))
        let cancelButton = UIBarButtonItem(title: "cancel".localized(), style: .done, target: self, action: #selector(cancelButtonAction))
        
        toolBar.backgroundColor = .clear
        toolBar.barTintColor = .clear
        toolBar.tintColor = .barSelectedItem
        toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolBar.setItems([cancelButton, space, doneButton], animated: false)
    }
    
    @objc private func doneButtonTapped() {
        delegate?.doneButtonTapped()
        dismis()
    }
    
    @objc private func cancelButtonAction() {
        dismis()
    }
    
    @objc private func dismis() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension DatePickerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == gestureRecognizer.view
    }
}

//MARK: - Public
extension DatePickerViewController {
    public func setPicker(_ picker: BaseDatePicker) {
        self.datePicker = picker
    }
}
