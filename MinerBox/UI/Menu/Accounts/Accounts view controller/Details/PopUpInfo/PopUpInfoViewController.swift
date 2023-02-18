//
//  PayoutInfoViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/3/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class PopUpInfoViewController: BaseViewController {

    // MARK: - Views
    @IBOutlet fileprivate weak var middleView: BaseView!
    @IBOutlet fileprivate weak var closeButton: BaseButton!
    @IBOutlet fileprivate weak var detailsLabel: BaseLabel!

    @IBOutlet fileprivate weak var tableView: UITableView!
    

//    @IBOutlet fileprivate weak var copyButton: CopyButton!
//    @IBOutlet fileprivate weak var qrButton: QRShowButton!

    @IBOutlet fileprivate weak var tableHeightConstraint: NSLayoutConstraint!

    // MARK: - Properties
    fileprivate var rows = [(name: String, value: String, showQrCopy: Bool)]()
    fileprivate var isWebsiteState = false
    fileprivate var websites = [String]()

    // MARK: - Static
    static func initializeStoryboard() -> PopUpInfoViewController? {
        return UIStoryboard(name: "AccountDetails", bundle: nil).instantiateViewController(withIdentifier: PopUpInfoViewController.name) as? PopUpInfoViewController
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
    }
    deinit {
        debugPrint("PopUpInfoViewController Deinit")
    }
}

// MARK: - Startup default actions
extension PopUpInfoViewController {
    fileprivate func startupSetup() {
        setupUI()
        configLabels()
        configTableView()

        addGestureRecognizers()
//        configCopyAndQRButtons()
        closeButton.addTarget(self, action: #selector(tapGestureAction), for: .touchUpInside)
    }

    fileprivate func configTableView() {
        tableView.separatorColor = .separator
        tableView.tableFooterView = UIView(frame: .zero)
        let constant = isWebsiteState ?  CGFloat(websites.count) * PopUpInfoTableViewCell.height - 1 :  CGFloat(rows.count) * PopUpInfoTableViewCell.height - 1
        tableHeightConstraint.constant = constant
        self.tableView.register(UINib(nibName: PopUpLinksTableViewCell.name, bundle: nil), forCellReuseIdentifier: PopUpLinksTableViewCell.name)
    }

    fileprivate func configLabels() {
        detailsLabel.setLocalizableText(isWebsiteState ? "explorers" :"account_details")
        detailsLabel.changeFont(to: Constants.boldFont)
        detailsLabel.changeFontSize(to: 17)
    }

    fileprivate func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(tapGestureAction), name: .goToBackground, object: nil)
    }
}

// MARK: - Setup UI
extension PopUpInfoViewController {
    fileprivate func setupUI() {
        configMiddleView()

        view.backgroundColor = .blackTransparented
    }

    fileprivate func configMiddleView() {
        middleView.layer.cornerRadius = 15
      
    }
}

// MARK: - Actions
extension PopUpInfoViewController {
    // MARK: - UI actions
    @objc fileprivate func tapGestureAction() {
        dismiss(animated: true) {
            NotificationCenter.default.removeObserver(self)
            self.view = nil
        }
    }
}

// MARK: - Set data
extension PopUpInfoViewController {
    public func setData(rows: [(name: String, value: String,showQrCopy: Bool)]) {
        self.rows = rows
    }
    public func setwebsites(websites: [String]) {
        self.websites = websites
        self.isWebsiteState = true
    }
}

// MARK: - TableView methods
extension PopUpInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isWebsiteState ? websites.count : rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isWebsiteState {
            let cell = tableView.dequeueReusableCell(withIdentifier: PopUpLinksTableViewCell.name) as! PopUpLinksTableViewCell
            cell.setDate(link: websites[indexPath.row])
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PopUpInfoTableViewCell.name) as! PopUpInfoTableViewCell
        let item = rows[indexPath.row]
        if indexPath.row != rows.count - 1 {
            cell.addSeparatorView(from: cell, to: cell, color: .white)
        }
        cell.setPayoutData(item: item, vc: self)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        PopUpInfoTableViewCell.height
    }
    
}

// MARK: - TapGesture delegate
extension PopUpInfoViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return gestureRecognizer.view == touch.view
    }
}
