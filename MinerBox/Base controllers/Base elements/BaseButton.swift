//
//  BaseButton.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 02.12.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit
import Localize_Swift


class BaseButton: UIButton {
    
    // MARK: - Properties
    fileprivate(set) var localizableTitle = ""
    fileprivate(set) var titleFont = Constants.mediumFont
    
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
extension BaseButton {
    @objc public func startupSetup() {
        changeFontSize(to: 13)
        addObservers()
        changeColors()
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: Notification.Name(Constants.themeChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: Notification.Name(LCLLanguageChangeNotification), object: nil)
    }
    
    @objc fileprivate func themeChanged() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.changeColors()
        }
    }
    
    @objc public func changeColors() {
        setTitleColor(darkMode ? .white : UIColor.black.withAlphaComponent(0.85), for: .normal)
        tintColor = darkMode ? .white : UIColor.black.withAlphaComponent(0.85)
    }
    
    @objc public func languageChanged() {
        setTitle(localizableTitle.localized(), for: .normal)
    }
}

// MARK: - Public methods
extension BaseButton {
    public func setLocalizedTitle(_ title: String) {
        localizableTitle = title
        languageChanged()
    }
    
    public func changeFontSize(to size: CGFloat) {
        titleLabel?.font = titleFont.withSize(size)
    }
    
    public func changeTitleColor(color: UIColor, for state: State = .normal) {
        setTitleColor(color, for: .normal)
    }
    
    public func changeTitleColorForDarkmode(color: UIColor, for state: State = .normal) {
        setTitleColor(color.darkMode ? .white : .black, for: .normal)
    }
    
    public func changeFont(to font: UIFont) {
        let size = titleLabel?.font.pointSize ?? 13
        titleFont = font.withSize(size)
    }
    
    public func changeEdgeInsets(constat: CGFloat) {
        self.imageEdgeInsets = UIEdgeInsets(top: constat, left: constat, bottom: constat, right: constat)
    }
    
    public func setTransferButton(text: String, subText:String,view: UIView)  {
        
        translatesAutoresizingMaskIntoConstraints = false
        let text = text.localized().uppercased()
        
        let subText = subText.localized()
        view.addSubview(self)
        
        titleLabel?.text = subText == "" ? text : "\(text)\n\(subText)"
        
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        widthAnchor.constraint(equalTo: view.widthAnchor,multiplier: 0.85).isActive = true
        
        clipsToBounds = true
        isEnabled = true
        layer.cornerRadius = 15
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        style.alignment = .center
        let content = titleLabel!.text!
        let attString = NSMutableAttributedString(string: content)
        
        let dic1 = [NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        let dic2 =  [NSAttributedString.Key.foregroundColor: UIColor.black,
                     NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11.0)]
        
        attString.addAttributes(dic1, range: NSMakeRange(0, content.count))
        if subText != "" {
            attString.addAttributes(dic2, range: NSMakeRange(text.count, subText.count + 1))
        }
        titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        attString.addAttribute(.paragraphStyle, value: style, range: NSMakeRange(0, content.count))
        
        setAttributedTitle(attString, for: .normal)
        contentEdgeInsets = UIEdgeInsets(top: 10,left: 20,bottom: 10,right: 20)
        
    }
}
