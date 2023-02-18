//
//  BaseTextView.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 08.12.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

class BaseTextView: UITextView {
    
    /// A UIImage value that set LeftImage to the UITextView
    @IBInspectable open var leftImage: UIImage? {
        didSet {
            if (leftImage != nil) {
                self.applyLeftImage(leftImage!)
            }
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        awakeFromNib()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.startupSetup()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

// MARK: - Startup default setup
extension BaseTextView {
    @objc public func startupSetup() {
        addObservers()
        changeColors()
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
    }

    @objc public func changeColors() {
        textColor = darkMode ? .white : .textBlack
        keyboardAppearance = darkMode ? .dark : .default
        tintColor = .barSelectedItem
        backgroundColor = .clear
    }
    
    fileprivate func applyLeftImage(_ image: UIImage) {
            let icn : UIImage = image
            let imageView = UIImageView(image: icn)
            imageView.frame = CGRect(x: 0, y: 5.0, width: icn.size.width + 20, height: icn.size.height )
            imageView.contentMode = UIView.ContentMode.center
            //Where self = UItextView
            self.addSubview(imageView)
            self.textContainerInset = UIEdgeInsets(top: 2.0, left: icn.size.width + 10.0 , bottom: 2.0, right: 2.0)
        }
    
    
    func adjustUITextViewHeight()
    {
        self.sizeToFit()
        self.isScrollEnabled = false
    }
}

