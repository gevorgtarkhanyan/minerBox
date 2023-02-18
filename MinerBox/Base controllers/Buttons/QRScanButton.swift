//
//  QRScanButton.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 5/31/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import QRCodeReader

@objc protocol QRButtonDelegate: AnyObject {
    @objc func scanResult(text: String)
}

class QRScanButton: UIButton {

    // MARK: - Properties
    weak var delegate: QRButtonDelegate?
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }

        return QRCodeReaderViewController(builder: builder)
    }()

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
        debugPrint("QRScanButton deinit")
    }
}

// MARK: - Default startup settings
extension QRScanButton {
    fileprivate func startupSetup() {
        setupUI()
        addAction()
    }

    fileprivate func addAction() {
        addTarget(self, action: #selector(showQRController(_:)), for: .touchUpInside)
    }
}

// MARK: - Setup UI
extension QRScanButton {
    fileprivate func setupUI() {
        let image = UIImage(named: "qr_scan")
        setImage(image, for: .normal)
        tintColor = darkMode ? .white : .black
    }
}

// MARK: - Actions
extension QRScanButton {
    @objc fileprivate func showQRController(_ sender: QRScanButton) {
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
extension QRScanButton: QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }

    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }
}
