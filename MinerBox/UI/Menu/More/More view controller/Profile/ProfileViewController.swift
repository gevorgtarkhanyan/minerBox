//
//  ProfileViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/9/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import WidgetKit

class ProfileViewController: BaseViewController {
    
    // MARK: - Views
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    // MARK: - Properties
    fileprivate let editabaleTypes = ProfileTableTypeEnum.allCases
    fileprivate let cellTypes = ProfileTableBottomAction.allCases
    
    fileprivate var username = DatabaseManager.shared.currentUser?.name ?? ""
    
    fileprivate var saveButton: UIBarButtonItem!
    
    // MARK: - Static
    static func initializeStoryboard() -> ProfileViewController? {
        return UIStoryboard(name: "More", bundle: nil).instantiateViewController(withIdentifier: ProfileViewController.name) as? ProfileViewController
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.usernameChanged(to: self.username)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationItem.rightBarButtonItem = nil
    }
    
    override func languageChanged() {
        title = MoreSettingsEnum.profile.rawValue.localized()
        saveButton?.title = "save".localized()
    }
    
    deinit {
        debugPrint("ProfileViewController deinit")
    }
}

// MARK: - Startup default setup
extension ProfileViewController {
    fileprivate func startupSetup() {
        configTableView()
        addGestureRecognizers()
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        saveButton = UIBarButtonItem(title: "save".localized(), style: .done, target: self, action: #selector(saveButtonAction(_:)))
    }
    
    fileprivate func configTableView() {
        tableView.separatorColor = .separator
    }
    
    fileprivate func addGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(_:)))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
}

// MARK: - TableView methods
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MoreTableViewCell.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? editabaleTypes.count : cellTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.name) as! ProfileTableViewCell
            
            cell.delegate = self
            cell.setType(editabaleTypes[indexPath.row])
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: MoreTableViewCell.name) as! MoreTableViewCell
            
            cell.setData(title: cellTypes[indexPath.row].rawValue, indexPath: indexPath)
            
            return cell
        default:
            return BaseTableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
        guard let cell = tableView.cellForRow(at: indexPath) as? ProfileTableViewCell else { break }
            let type = editabaleTypes[indexPath.row]
        
            switch type {
            case .username:
                cell.startEditing()
            case .password:
                performSegue(withIdentifier: "changePasswordSegue", sender: self)
            default:
                view.endEditing(true)
                break
            }
        case 1:
            let type = cellTypes[indexPath.row]
            switch type {
            case .userDelete:
                guard let vc = accountDeleteViewController.initializeStoryboard() else { return }
                navigationController?.pushViewController(vc, animated: true)
            }
        default:
            break
        }
    }
    
    // Footer
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 35
    }
}

// MARK: - ProfileTableCell delegate
extension ProfileViewController: ProfileTableViewCellDelegate {
    func usernameChanged(to username: String) {
        navigationItem.rightBarButtonItem = saveButton
        saveButton.isEnabled = (username != user?.name) && (username != "")
        self.username = username
    }
}

// MARK: - Actions
extension ProfileViewController {
    
    // MARK: - UI actions
    @objc fileprivate func tapGestureAction(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc fileprivate func saveButtonAction(_ sender: UIBarButtonItem) {
        guard username != "" else {
            return
        }
        Loading.shared.startLoading(ignoringActions: true, for: self.view)
        UserRequestsService.shared.changeUsername(to: username, success: { message in
            Loading.shared.endLoading(for: self.view)
            self.usernameChanged(to: self.username)
            self.showToastAlert("", message: message.localized())
        }) { (error) in
            Loading.shared.endLoading(for: self.view)
            self.showAlertView("", message: error, completion: nil)
        }
    }
}

// MARK: - GestureRecognizer delegate
extension ProfileViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return gestureRecognizer.view == touch.view || touch.view is UITableView
    }
}

// MARK: - Helpers
enum ProfileTableBottomAction: String, CaseIterable {
    case userDelete = "delete_account"
}
