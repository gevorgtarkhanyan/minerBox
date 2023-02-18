//
//  BaseTextField.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/27/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

protocol BaseTextFieldDelegate: class {
    func textFieldShouldReturn(_ textField: CustomTextField)
}

enum BaseTextFieldType {
    case email
    case password
}

class CustomTextField: UIView {

    // MARK: - Views
    fileprivate var textField: UITextField!
    fileprivate var placeholderLabel: BaseLabel!

    // MARK: - Properties
    weak var delegate: BaseTextFieldDelegate?

    public var text: String {
        return textField.text ?? ""
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        awakeFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        startupSetup()
    }
}

// MARK: - Startup default setup
extension CustomTextField {
    fileprivate func startupSetup() {
        setupUI()
        addObservers()
        addTapGesture()
    }

    fileprivate func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tap.delegate = self
        addGestureRecognizer(tap)
    }

    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeColors), name: Notification.Name(Constants.themeChanged), object: nil)
    }
}

// MARK: - Setup UI
extension CustomTextField {
    fileprivate func setupUI() {
        addTextField()

        addPlaceholder()
        changeColors()
    }

    fileprivate func addTextField() {
        textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)

        textField.delegate = self

        textField.heightAnchor.constraint(equalToConstant: 20).isActive = true
        textField.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        textField.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
        textField.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true

        // Bottom border
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        textField.addSubview(view)

        view.backgroundColor = .separator

        view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        view.leftAnchor.constraint(equalTo: textField.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: textField.rightAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: textField.bottomAnchor).isActive = true
    }

    fileprivate func addPlaceholder() {
        layoutIfNeeded()

        placeholderLabel = BaseLabel(frame: .zero)
        placeholderLabel.frame = textField.frame
        addSubview(placeholderLabel)

        placeholderLabel.changeFontSize(to: 17)
        placeholderLabel.textColor = .lightGray
    }

    @objc fileprivate func changeColors() {
        backgroundColor = .clear
        textField?.textColor = darkMode ? .white : .black
        textField.keyboardAppearance = darkMode ? .dark : .light
    }
}

// MARK - Actions
extension CustomTextField {
    @objc fileprivate func tapAction(_ sender: UITapGestureRecognizer) {
        textField.becomeFirstResponder()
    }
}

// MARK: - Gesture delegate
extension CustomTextField: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return gestureRecognizer.view == touch.view
    }
}

// MARK: - TextField delegate methods
extension CustomTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        changeLabelPositionToTop()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        changeLabelPositionToBottom()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.textFieldShouldReturn(self)
        return true
    }
}

// MARK: - Animations
extension CustomTextField {
    fileprivate func changeLabelPositionToTop() {
        guard placeholderLabel.transform == .identity else { return }
        let origin = self.placeholderLabel.frame.origin
        let transform = CGAffineTransform(a: 0.75, b: 0, c: 0, d: 0.75, tx: -(origin.x + self.placeholderLabel.frame.width / 10), ty: -origin.y)
        UIView.animate(withDuration: Constants.animationDuration) {
            self.placeholderLabel.transform = transform
        }
    }

    fileprivate func changeLabelPositionToBottom() {
        guard textField.text == "" else { return }
        UIView.animate(withDuration: Constants.animationDuration) {
            self.placeholderLabel.transform = .identity
        }
    }
}

// MARK: - Public methods
extension CustomTextField {
    public func setPlaceholder(_ string: String) {
        placeholderLabel.setLocalizableText(string)
    }

    public func startEditing() {
        textField.becomeFirstResponder()
    }

    public func changeKeyboardType(to type: BaseTextFieldType) {
        switch type {
        case .email:
            textField.autocorrectionType = .no
            textField.keyboardType = .emailAddress

            if #available(iOS 10.0, *) {
                textField.textContentType = .emailAddress
            }

            if #available(iOS 11.0, *) {
                textField.smartDashesType = .no
                textField.smartQuotesType = .no
                textField.smartInsertDeleteType = .default
            }
        case .password:
            textField.isSecureTextEntry = true
            textField.autocorrectionType = .no
            textField.keyboardType = .default

            if #available(iOS 11.0, *) {
                textField.smartDashesType = .no
                textField.smartQuotesType = .no
                textField.smartInsertDeleteType = .no
                textField.textContentType = .password
            }
        }
    }

    public func changeDoneButton(to type: UIReturnKeyType) {
        textField.returnKeyType = type
    }
}
