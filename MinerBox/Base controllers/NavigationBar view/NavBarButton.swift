//
//  NavBarButton.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/2/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class NavBarButton: BackgroundButton {

    // MARK: - Startup setup
    override func startupSetup() {
        super.startupSetup()
        changeFont(to: Constants.semiboldFont)
        changeFontSize(to: 12)

        setTitleColor(.barSelectedItem, for: .selected)
    }
}

class BagedBarButtonItem: UIBarButtonItem {
    
    private var contentView: UIView!
    private var imageView: BaseImageView!
    private var bageView: UIView!
    
    // MARK: - Init
    override init() {
        super.init()
//        awakeFromNib()
    }
    
    public convenience init(target: AnyObject?, action: Selector?) {
        self.init()
        self.action = action
        self.target = target
        awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        startupSetup()
    }
    
    override var isEnabled: Bool {
        willSet {
            imageView?.tintColor = newValue ? .barSelectedItem : darkMode ? .darkGray : .lightGray
            bageView?.backgroundColor = newValue ? .red : darkMode ? .darkGray : .lightGray
        }
    }
    
    //MARK: - Setup
    private func startupSetup() {
        addContentView()
        addAction()
    }
    
    private func addAction() {
        let tap = UITapGestureRecognizer(target: target, action: action)
        customView?.addGestureRecognizer(tap)
    }
    
    //MARK: - Public
    public func setBageIsHidden(_ bool: Bool) {
        bageView?.isHidden = bool
    }
    
    //MARK: - Add views
    private func addContentView() {
        contentView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        addImageView()
        addBageView()
        customView = contentView
    }
    
    private func addImageView() {
        imageView = BaseImageView(frame: .zero)
        contentView.addSubview(imageView)
        imageView.frame = CGRect(x: 2.5, y: 2.5, width: 20, height: 20)
        imageView.image = UIImage(named: "filter-list")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .barSelectedItem
        imageView.contentMode = .scaleAspectFit
    }
    
    private func addBageView() {
        let width: CGFloat = 7
        bageView = UIView(frame: .zero)
        contentView.addSubview(bageView)
        bageView.frame = CGRect(x: imageView.frame.maxX - width/2, y: imageView.frame.minY, width: width, height: width)
        bageView.backgroundColor = .red
        bageView.cornerRadius(radius: width/2)
        bageView.isHidden = true
    }
    
}
