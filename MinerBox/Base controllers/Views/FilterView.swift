//
//  FilterButton.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 13.08.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

class FilterView: UIView {
    
    private var contentView: UIView!
    private var imageView: BaseImageView!
    private var bageView: UIView!
    
    private var action: Selector?
    private var target: AnyObject?
    
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        awakeFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public convenience init(target: AnyObject?, action: Selector?) {
        self.init()
        self.target = target
        self.action = action
        awakeFromNib()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        startupSetup()
    }
    
    //MARK: - Setup
    private func startupSetup() {
        addContentView()
        addAction()
    }
    
    private func addAction() {
        let tap = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(tap)
    }
    
    //MARK: - Public
    public func setBageIsHidden(_ bool: Bool) {
        bageView.isHidden = bool
    }
    
    public func addTarget(_ target: AnyObject?, action: Selector?) {
        self.target = target
        self.action = action
        addAction()
    }
    
    //MARK: - Add views
    private func addContentView() {
        contentView = UIView(frame: .zero)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addImageView()
        addBageView()
        addSubview(contentView)
        backgroundColor = .clear
        contentView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        contentView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        contentView.widthAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    private func addImageView() {
        imageView = BaseImageView(frame: .zero)
        contentView.addSubview(imageView)
        imageView.frame = CGRect(x: 5, y: 5, width: 15, height: 15)
        imageView.image = UIImage(named: "filter-list")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .barSelectedItem
        imageView.contentMode = .scaleAspectFit
    }
    
    private func addBageView() {
        let width: CGFloat = 5
        bageView = UIView(frame: .zero)
        contentView.addSubview(bageView)
        bageView.frame = CGRect(x: imageView.frame.maxX - width/2, y: imageView.frame.minY, width: width, height: width)
        bageView.backgroundColor = .red
        bageView.cornerRadius(radius: width/2)
        bageView.isHidden = true
    }
    
}
