//
//  DateSelectorView.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/3/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import Localize_Swift

@objc protocol DateSelectorViewDelegate: AnyObject {
    func dateSelected(sender: DateSelectorView, date: Date)
    @objc optional func dateClear(sender: DateSelectorView)
    @objc optional func doneButtonTapped()
}

class DateSelectorView: BaseView {

    // MARK: - Views
    fileprivate var textField: TintTextField!
    fileprivate var toolbar: UIToolbar!

    fileprivate var doneButton: UIBarButtonItem!
    fileprivate var cancelButton: UIBarButtonItem!
    fileprivate var textFieldRightConstraint: NSLayoutConstraint!

    // MARK: - Properties
    weak var delegate: DateSelectorViewDelegate?

    fileprivate(set) var localizablePlaceholder = ""
    fileprivate(set) var datePicker = BaseDatePicker()

    fileprivate var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Localize.currentLanguage())
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter
    }
}

// MARK: - Startup default setup
extension DateSelectorView {
    override func startupSetup() {
        super.startupSetup()
        setupUI()
        changeColors()
        defaultSetup()
    }

    override func changeColors() {
        backgroundColor = .textFieldBackground
        textField?.textColor = darkMode ? .white : .textBlack
        doneButton?.tintColor = darkMode ? .white : .textBlack
        cancelButton?.tintColor = darkMode ? .white : .textBlack
        toolbar?.barTintColor = darkMode ? .barDark : .tableSectionLight

        changePlaceholderColor()
    }

    fileprivate func changePlaceholderColor() {
        let attribute: [NSAttributedString.Key: Any] = [.foregroundColor: darkMode ? UIColor.white : UIColor.textBlack]
        textField?.attributedPlaceholder = NSAttributedString(string: localizablePlaceholder.localized(), attributes: attribute)
    }

    override func languageChanged() {
        changePlaceholderColor()
    }
}

// MARK: - Setup UI
extension DateSelectorView {
    fileprivate func setupUI() {
        cornerRadius(radius: frame.height / 2)
        addTextField()
        addToolbar()
    }
    
    fileprivate func defaultSetup() {
        textField.delegate = self
        datePicker.date = Date()
        setMaximumDate(date: Date())
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    fileprivate func addTextField() {
        textField = TintTextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)
        
        if #available(iOS 14.0, *) {} else {
            textField.inputView = datePicker
        }
        textField.clearButtonMode = .always
        textField.tintColor = .clear
        textField.borderStyle = .none
        textField.textAlignment = .center
        textField.backgroundColor = .clear

        textField.minimumFontSize = 10
        textField.adjustsFontSizeToFitWidth = true
        textField.font = Constants.semiboldFont.withSize(15)

        textField.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textField.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        textField.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        textFieldRightConstraint = textField.rightAnchor.constraint(equalTo: rightAnchor)
        textFieldRightConstraint.isActive = true
    }

    fileprivate func addToolbar() {
        toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.isTranslucent = false
        textField.inputAccessoryView = toolbar

        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        doneButton = UIBarButtonItem(title: "done".localized(), style: .done, target: self, action: #selector(doneButtonTapped))
        cancelButton = UIBarButtonItem(title: "cancel".localized(), style: .done, target: self, action: #selector(cancelButtonAction(_:)))

        toolbar.setItems([cancelButton, space, doneButton], animated: false)
    }
    
    fileprivate func addRightIcon(iconName: String) {
        let image = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .barSelectedItem
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.55).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        
        layoutIfNeeded()
        textFieldRightConstraint.constant = -(imageView.frame.width + 10)
    }
    
    fileprivate func showDatePicker() {
        let vc = DatePickerViewController.loadFromNib()
        vc.setPicker(datePicker)
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        UIApplication.getTopViewController()?.present(vc, animated: true, completion: nil)
    }
}

// MARK: - TextField Delegate
extension DateSelectorView: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = nil
        delegate?.dateClear?(sender: self)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if #available(iOS 14.0, *) {
            endEditing(true)
            showDatePicker()
        }
    }
}

// MARK: - Actions
extension DateSelectorView: DatePickerViewControllerDelegate {
    @objc func doneButtonTapped() {
        endEditing(true)
        textField.text = dateFormatter.string(from: datePicker.date)
        delegate?.dateSelected(sender: self, date: datePicker.date)
        delegate?.doneButtonTapped?()
    }

    @objc fileprivate func cancelButtonAction(_ sender: UIButton) {
        endEditing(true)
    }
    
    @objc func tapped() {
        textField.becomeFirstResponder()
    }
}

// MARK: - Set Get data
extension DateSelectorView {
    public func setPlaceholder(_ placeholder: String) {
        localizablePlaceholder = placeholder
        changePlaceholderColor()
    }

    public func setDate(date: Date) {
        textField.text = dateFormatter.string(from: date)
        delegate?.dateSelected(sender: self, date: date)
        datePicker.setDateSafely(date, animated: true)
    }
    
    public func setDate(timeInterval: Double?) {
        guard let timeInterval = timeInterval else { return }
        
        let date = Date(timeIntervalSince1970: timeInterval)
        setDate(date: date)
    }

    public func setMinimumDate(date: Date?) {
        datePicker.minimumDate = date
    }

    public func setMaximumDate(date: Date?) {
        datePicker.setMaximumDateSafely(date: date)
    }
    
    public func setText(text: String?) {
        if let text = text,
            let date = dateFormatter.date(from: text) {
            setDate(date: date)
        }
    }
    
    public func getText() -> String? {
        return textField.text
    }
    
    public func getDate() -> Date {
        return datePicker.date
    }

    public func clearText() {
        textField.text = ""
    }
    
    public func setStyle(_ style: DateSelectorStyle) {
        switch style {
        case .coinChart:
            coinChartStyle()
        }
    }
    
}

//MARK: - Styles
extension DateSelectorView {
    enum DateSelectorStyle {
        case coinChart
    }

    fileprivate func coinChartStyle() {
        textField.clearButtonMode = .never
        datePicker.datePickerMode = .date
        setPlaceholder("date")
        setMaximumDate(date: Date.yesterday)
        addRightIcon(iconName: "calendar")
    }
}

