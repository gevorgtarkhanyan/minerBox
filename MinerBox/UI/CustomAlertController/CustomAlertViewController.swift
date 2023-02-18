//
//  CustomAlertViewController.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/17/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
 
protocol CustomAlertViewControllerDelegate: AnyObject {
    func sendFilterType(_ filteredType: String) -> Void
}

class CustomAlertViewController: BaseViewController {

    @IBOutlet weak var alertTableView: BaseTableView!
    @IBOutlet weak var alertHeightConstraint: NSLayoutConstraint!
    @IBOutlet var cancelView: UIView!
    private var blurView: UIVisualEffectView!
    
    var alertModels: [CustomAlertModel] = []
    var deltaHeight: CGFloat = 0
    
    weak var delegate: CustomAlertViewControllerDelegate?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .overCurrentContext
        isPageRotationEnabled = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.modalPresentationStyle = .overCurrentContext
        isPageRotationEnabled = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        changeBlureViewSize(with: size)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIComponents()
        addGestures()
    }
    private func setupUIComponents() {
        setupTableView()
        setupBlureEffect()
        alertTableView.backgroundColor = darkMode ? .viewDarkBackgroundWithAlpha : .viewLightBackgroundWithAlpha
        cancelView.backgroundColor =  darkMode ? .viewDarkBackground : .sectionHeaderLight
        view.backgroundColor = .clear
        view.bringSubviewToFront(alertTableView)
        view.bringSubviewToFront(cancelView)
    }
    
    private func setupTableView() {
        alertHeightConstraint.constant = CGFloat(alertModels.count) * CustomAlertTableViewCell.height + deltaHeight
        alertTableView.register(UINib(nibName: "CustomAlertTableViewCell", bundle: nil), forCellReuseIdentifier: "alertCell")
        alertTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: alertTableView.frame.width, height: 1))
        alertTableView.isScrollEnabled = false
        
        if #available(iOS 11.0, *) {
            alertTableView.layer.maskedCorners = [.topLeft, .topRight,.bottomLeft,.bottomRight]
            alertTableView.layer.cornerRadius = CGFloat(10)
        }
    }
    
    private func setupBlureEffect() {
        blurView = UIVisualEffectView(frame: view.frame)
        view.addSubview(blurView)
        blurView.alpha = darkMode ? 0.2: 0.7
        blurView.effect = UIBlurEffect(style: .dark)
    }
    
    @objc func cancelTap() {
        dismiss(animated: true)
    }
    
    private func changeBlureViewSize(with size: CGSize) {
        if blurView != nil {
            blurView.frame.size = size
        } else {//exist some bug , when called this line will determine what is bug
            debugPrint("Alert crash find")
//            setupBlureEffect()
//            blurView.frame.size = size
        }
        
    }
    
    private func addGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hidePage))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(hidePage))
        blurView.contentView.addGestureRecognizer(tap)
        blurView.contentView.addGestureRecognizer(pan)
        let cancelTapGesture = UITapGestureRecognizer(target: self, action: #selector(cancelTap))
        cancelView.addGestureRecognizer(cancelTapGesture)
    }
    
    @objc private func hidePage() {
        view.endEditing(true)
        isPageRotationEnabled = true
        controllPageRotation()
        dismiss(animated: true, completion: nil)
    }
    
    func checkSendedData(for indexPath: IndexPath) {
        let model = alertModels[indexPath.row]
        if let filtereType = model.filter {
            delegate?.sendFilterType(filtereType)
        } else {
            delegate?.sendFilterType(model.actionTitle)
        }
    }
}

extension CustomAlertViewController: CustomAlertTableViewCellDelegate {
    func buttonTapped(indexPath: IndexPath) {
        checkSendedData(for: indexPath)
    }
}

extension CustomAlertViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alertModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "alertCell") as? CustomAlertTableViewCell {
            cell.setupCell(cellData: alertModels[indexPath.row])
            cell.indexPath = indexPath
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        checkSendedData(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CustomAlertTableViewCell.height
    }
}
