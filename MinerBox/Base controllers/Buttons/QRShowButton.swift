//
//  QRShowButton.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/11/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class QRShowButton: UIButton {
    
    // MARK: - Properties
    fileprivate var qrString = ""
    fileprivate weak var controller: UIViewController?

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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Default startup settings
extension QRShowButton {
    fileprivate func startupSetup() {
        setupUI()
        addAction()
    }

    fileprivate func addAction() {
        addTarget(self, action: #selector(showQR(_:)), for: .touchUpInside)
    }
}

// MARK: - Setup UI
extension QRShowButton {
    fileprivate func setupUI() {
        let image = UIImage(named: "qr_scan")?.withRenderingMode(.alwaysTemplate)
        setImage(image, for: .normal)
        tintColor = darkMode ? .white : .black
    }
}

// MARK: - Set data
extension QRShowButton {
    public func setValueForQR(_ value: String) {
        qrString = value
    }
    
    public func setController(_ controller: UIViewController) {
        self.controller = controller
    }
}

// MARK: - Actions
extension QRShowButton {
    @objc fileprivate func showQR(_ sender: QRShowButton) {
        guard let viewController = controller else { return }
        let newVC = QRShowController()
        newVC.setString(qrString)
        newVC.modalPresentationStyle = .overFullScreen
        DispatchQueue.main.async {
            viewController.present(newVC, animated: true, completion: nil)
        }
    }
}
