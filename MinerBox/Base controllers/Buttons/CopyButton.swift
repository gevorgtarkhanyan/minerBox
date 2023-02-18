//
//  CopyButton.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/11/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class CopyButton: UIButton {

    // MARK: - Properties
    fileprivate var copyString = ""
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
extension CopyButton {
    fileprivate func startupSetup() {
        setupUI()
        addAction()
        addObservers()
    }

    fileprivate func addAction() {
        addTarget(self, action: #selector(copyAction(_:)), for: .touchUpInside)
    }

    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged(_:)), name: Notification.Name(Constants.themeChanged), object: nil)
    }

    @objc func themeChanged(_ notification: Notification) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.changeColors()
            }
        }
    }
}

// MARK: - Setup UI
extension CopyButton {
    fileprivate func setupUI() {
        let image = UIImage(named: "copy")?.withRenderingMode(.alwaysTemplate)
        setImage(image, for: .normal)

        changeColors()
    }

    fileprivate func changeColors() {
        tintColor = darkMode ? .white : .textBlack
        imageView?.tintColor = darkMode ? .white : .textBlack
    }
}

// MARK: - Set data
extension CopyButton {
    public func setValueForCopy(_ value: String) {
        copyString = value
    }

    public func setController(_ controller: UIViewController) {
        self.controller = controller
    }
}

// MARK: - Actions
extension CopyButton {
    @objc fileprivate func copyAction(_ sender: CopyButton) {
        guard let viewController = controller else { return }
        UIPasteboard.general.string = copyString

        let alertView = UIAlertController(title: "", message: "✓", preferredStyle: .alert)

        DispatchQueue.main.async {
            viewController.present(alertView, animated: true, completion: nil)
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            alertView.dismiss(animated: true, completion: nil)
        }
    }
}
