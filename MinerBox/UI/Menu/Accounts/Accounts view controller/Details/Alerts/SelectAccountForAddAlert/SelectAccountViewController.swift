//
//  SelectAccountViewController.swift
//  MinerBox
//
//  Created by Gevorg Tarkhanyan on 04.08.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit


class SelectAccountViewController: BaseViewController {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var tableView: BaseTableView!
    @IBOutlet weak var titleLabel: BaseLabel!
    @IBOutlet weak var CloseButton: BaseButton!
    @IBOutlet weak var middleView: BaseView!
    private var model = AccountModel()
    
    
    // MARK: - Static
    static func initializeStoryboard() -> SelectAccountViewController? {
        return UIStoryboard(name: "Menu", bundle: nil).instantiateViewController(withIdentifier: SelectAccountViewController.name) as? SelectAccountViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
        // Do any additional setup after loading the view.
    }
    
    func startupSetup() {
        setupUI()
        addGestureRecognizers()
        getAccounts()
        CloseButton.addTarget(self, action: #selector(tapGestureAction), for: .touchUpInside)
    }
    
    func setupUI() {
        contentView.backgroundColor = .blackTransparented
        titleLabel.setLocalizableText("Select accounts")
    }
    
    
    func getAccounts() {
        Loading.shared.startLoadingForView(with: middleView )
        PoolRequestService.shared.getAccounts(success: { (accounts) in
            self.model.setAccounts(accounts)
            Loading.shared.endLoadingForView(with: self.middleView)
            self.tableView.reloadData()
        }) { (error) in
            Loading.shared.endLoadingForView(with: self.middleView)
            self.showAlertView("", message: error, completion: nil)
        }
        
    }
    
    // MARK: - UI actions
    @objc fileprivate func tapGestureAction() {
        dismiss(animated: true) {
            NotificationCenter.default.removeObserver(self)
            self.view = nil
        }
    }
    
    fileprivate func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(tapGestureAction), name: .goToBackground, object: nil)
    }
}

// MARK: - TableView methods
extension SelectAccountViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.accounts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectAccountTableViewCell.name ) as! SelectAccountTableViewCell
        let account = model.accounts[indexPath.row]
        cell.setData(model: account, indexPath: indexPath)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return SelectAccountTableViewCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let newVC = AccountDetailsPageController.initializeStoryboard() else {
            return }
        newVC.setAccount(model.accounts[indexPath.row])
        UserDefaults.standard.set(Constants.url_open_account_alert, forKey: Constants.url_open_account_alert)
        guard let presentedViewController = UIApplication.getTopViewController() else { return }
        navigationController?.navigationBar.isHidden = false
        presentedViewController.dismiss(animated: true) {
            UIApplication.getTopViewController()?.navigationController?.pushViewController(newVC, animated: true)
        }
    }
}

// MARK: - TapGesture delegate
extension SelectAccountViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return gestureRecognizer.view == touch.view
    }
}
