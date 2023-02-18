//
//  ProfileTableViewCell.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/9/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

protocol ProfileTableViewCellDelegate: AnyObject {
    func usernameChanged(to username: String)
}

class ProfileTableViewCell: BaseTableViewCell {

    // MARK: - Views
    @IBOutlet fileprivate weak var label: BaseLabel!
    @IBOutlet fileprivate weak var textField: ProfileTextField!
    @IBOutlet fileprivate weak var detailsImageView: UIImageView!

    // MARK: - Properties
    weak var delegate: ProfileTableViewCellDelegate?

    fileprivate var user: UserModel? {
        return DatabaseManager.shared.currentUser
    }
}

// MARK: - Set data
extension ProfileTableViewCell {
    public func setType(_ type: ProfileTableTypeEnum) {
        label.setLocalizableText(type.rawValue)

        switch type {
        case .username:
            textField.text = ""
            textField.delegate = self
            textField.returnKeyType = .done
            textField.isSecureTextEntry = false
            textField.isUserInteractionEnabled = true

            textField.text = user?.name
            textField.setPlaceholder("change_username")

            detailsImageView.isHidden = true
        case .password:
            textField.text = "******"
            textField.isSecureTextEntry = true
            textField.isUserInteractionEnabled = false

            detailsImageView.isHidden = false
        case .mail:
            textField.text = DatabaseManager.shared.currentUser?.email
            textField.isUserInteractionEnabled = false
            detailsImageView.isHidden = true
        }
    }

    public func startEditing() {
        textField.becomeFirstResponder()
    }
}

// MARK: - TextField delegate
extension ProfileTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        contentView.endEditing(true)
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text else { return true }
        let newText = (oldText as NSString).replacingCharacters(in: range, with: string)
        delegate?.usernameChanged(to: newText)
        let maxLength = 64
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)

         return  newString.count <= maxLength
    }
}

// MARK: - Helpers
enum ProfileTableTypeEnum: String, CaseIterable {
    case username = "username"
    case mail = "login_email"
    case password = "password"
}
