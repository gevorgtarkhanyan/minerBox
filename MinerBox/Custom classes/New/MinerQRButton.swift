//
//  QRButton.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 5/31/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import QRCodeReader

@objc protocol QRButtonDelegate: class {
    @objc func scanResult(text: String)
}

class QRButton: UIButton {

    // Good practice: create the reader lazily to avoid cpu overload during the
    // initialization and each time we need to scan a QRCode
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }

        return QRCodeReaderViewController(builder: builder)
    }()

    weak var delegate: QRButtonDelegate?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        startupSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Setup UI
extension QRButton {
    fileprivate func setupUI() {
        let image = UIImage(named: "qr_code")?.withRenderingMode(.alwaysTemplate)
        setImage(image, for: .normal)

        changeColors()
    }

    fileprivate func changeColors() {
        imageView?.tintColor = darkMode ? .whiteTextColor : .darkGrayColor
    }
}

// MARK: - Default startup settings
extension QRButton {
    fileprivate func startupSetup() {
        addAction()
        addObservers()
    }

    fileprivate func addAction() {
        addTarget(self, action: #selector(showQRController(_:)), for: .touchUpInside)
    }

    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged(_:)), name: Notification.Name(OldConstants.themeChanged), object: nil)
    }

    @objc func themeChanged(_ notification: Notification) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: OldConstants.animationDuration) {
                self.changeColors()
            }
        }
    }
}

// MARK: - Actions
extension QRButton {
    @objc fileprivate func showQRController(_ sender: QRButton) {
        // Retrieve the QRCode content
        // By using the delegate pattern
        readerVC.delegate = self

        // Or by using the closure pattern
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            if let str = result?.value {
                self.delegate?.scanResult(text: str)
            }
        }

        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.present(self.readerVC, animated: true, completion: nil)
        }
    }
}

// MARK: - QRReader delegate
extension QRButton: QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }
}
