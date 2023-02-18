//
//  BaseTextField.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/4/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import Localize_Swift

class BaseTextField: UITextField {

    // MARK: - Properties
    fileprivate var localizedPlaceholder = ""

    fileprivate var baseFont = Constants.regularFont

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        awakeFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Awake from NIB
    override func awakeFromNib() {
        super.awakeFromNib()
        startupSetup()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Startup default setup
extension BaseTextField {
    
    
    @objc public func startupSetup() {
        addObservers()
        changeColors()
//        setKeyboardSettings()

        borderStyle = .roundedRect
        localizedPlaceholder = placeholder ?? ""
        languageChanged()
    }

    fileprivate func setKeyboardSettings() {
        autocorrectionType = .no
        keyboardType = .default

        if #available(iOS 11.0, *) {
            smartDashesType = .no
            smartQuotesType = .no
            smartInsertDeleteType = .default
            textContentType = .username
        }
    }

    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeColors), name: Notification.Name(Constants.themeChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }

    @objc public func changeColors() {
        textColor = darkMode ? .white : .textBlack
        keyboardAppearance = darkMode ? .dark : .default
        tintColor = .barSelectedItem
        backgroundColor = .textFieldBackground
        languageChanged()
    }

    @objc fileprivate func languageChanged() {
        attributedPlaceholder = NSAttributedString(string: localizedPlaceholder.localized(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.placeholder])
    }
}

// MARK: - Set data
extension BaseTextField {
    public func setPlaceholder(_ placeholder: String) {
        localizedPlaceholder = placeholder
        languageChanged()
    }

    public func changeFontSize(to value: CGFloat) {
        font = baseFont.withSize(value)
        adjustsFontSizeToFitWidth = true
    }

    public func changeFont(to font: UIFont) {
        baseFont = font
        changeFontSize(to: self.font?.pointSize ?? 13)
    }
}


class TintTextField: BaseTextField {

    private var tintedClearImage: UIImage?

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.layer.masksToBounds = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.masksToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.tintClearImage()
    }

    private func tintClearImage() {
        for view in subviews {
            if view is UIButton {
                  let button = view as! UIButton
                if let image = button.image(for: .highlighted) {
                    if self.tintedClearImage == nil {
                        let buttonTintColor: UIColor = darkMode ? .white : .black
                        tintedClearImage = self.tintImage(image: image, color: buttonTintColor)
                    }
                    button.setImage(tintedClearImage, for: .normal)
                    button.setImage(tintedClearImage, for: .highlighted)
                }
            }
        }
    }

    private func tintImage(image: UIImage, color: UIColor) -> UIImage {
        let size = image.size

        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        let context = UIGraphicsGetCurrentContext()
        image.draw(at: .zero, blendMode: CGBlendMode.normal, alpha: 1.0)

        context?.setFillColor(color.cgColor)
        context?.setBlendMode(CGBlendMode.sourceAtop)
        context?.setAlpha(1.0)

        let rect = CGRect(x: CGPoint.zero.x, y: CGPoint.zero.y, width: image.size.width, height: image.size.height)
        UIGraphicsGetCurrentContext()?.fill(rect)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return tintedImage ?? UIImage()
    }
    
    //MARK: Set Image
    public func setClearImage(imageName: String) {
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        self.tintedClearImage = image
    }
}
