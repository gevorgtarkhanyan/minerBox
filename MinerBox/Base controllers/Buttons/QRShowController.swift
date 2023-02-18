//
//  QRShowController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/11/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class QRShowController: UIViewController {

    // MARK: - Views
    fileprivate var middleView: UIView!
    fileprivate var imageView: UIImageView!

    // MARK: - Properties
    fileprivate var string = ""

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
    }
}

// MARK: - Startup
extension QRShowController {
    fileprivate func startupSetup() {
        setupUI()
        addGestureRecognizers()
        generateQRImage()
    }

    fileprivate func addGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }

    fileprivate func generateQRImage() {
        view.layoutIfNeeded()

        let data = string.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        guard let qrCodeImage = filter?.outputImage else { return }

        let scaleX = imageView.frame.size.width / qrCodeImage.extent.size.width
        let scaleY = imageView.frame.size.height / qrCodeImage.extent.size.height
        let transformedImage = qrCodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        imageView.image = UIImage(ciImage: transformedImage)
    }
}

// MARK: - Setup UI
extension QRShowController {
    fileprivate func setupUI() {
        addMiddleView()
        addImageView()

        view.backgroundColor = .blackTransparented
    }

    fileprivate func addMiddleView() {
        middleView = UIView(frame: .zero)
        middleView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(middleView)

        middleView.clipsToBounds = true
        middleView.layer.cornerRadius = 10
        middleView.backgroundColor = .white

        middleView.addEqualRatioConstraint()
        middleView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        middleView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        middleView.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true

        var safeWidth = view.widthAnchor
        if #available(iOS 11.0, *) {
            safeWidth = view.safeAreaLayoutGuide.widthAnchor
        }

        let widthAnch = middleView.widthAnchor.constraint(equalTo: safeWidth, multiplier: 0.8)
        widthAnch.priority = .defaultHigh
        widthAnch.isActive = true
    }

    fileprivate func addImageView() {
        imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        middleView.addSubview(imageView)

        imageView.contentMode = .scaleAspectFit

        imageView.topAnchor.constraint(equalTo: middleView.topAnchor, constant: 10).isActive = true
        imageView.leftAnchor.constraint(equalTo: middleView.leftAnchor, constant: 10).isActive = true
        imageView.rightAnchor.constraint(equalTo: middleView.rightAnchor, constant: -10).isActive = true
        imageView.bottomAnchor.constraint(equalTo: middleView.bottomAnchor, constant: -10).isActive = true
    }
}

// MARK: - Actions
extension QRShowController {
    @objc fileprivate func tapAction(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Set data
extension QRShowController {
    public func setString(_ string: String) {
        self.string = string
    }
}

// MARK: - Tap gesture delegate
extension QRShowController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return gestureRecognizer.view == touch.view
    }
}
