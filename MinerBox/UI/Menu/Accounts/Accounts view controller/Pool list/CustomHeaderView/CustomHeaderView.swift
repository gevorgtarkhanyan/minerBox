//
//  CustomHeaderView.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/16/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class CustomHeaderView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageParentView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var dataContainerView: UIView!
    
    static var height: CGFloat {
        return 48
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        addObservers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
        addObservers()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("CustomHeaderView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        clipsToBounds = true
        dataContainerView.backgroundColor = .barSelectedItem
        dataContainerView.layer.cornerRadius = 10
//        dataContainerView.layer.shadowOpacity = 0.3
//        dataContainerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        imageParentView.layer.cornerRadius = 5
        separatorView.backgroundColor = .clear
    }
    
    public func rotateArrow(angle: CGFloat) {        
        if arrowImageView.transform != CGAffineTransform(rotationAngle: angle) {
            DispatchQueue.main.async {
                UIView.animate(withDuration: Constants.animationDuration) {
                    self.arrowImageView.transform = CGAffineTransform(rotationAngle: angle)
                }
            }
        }
    }
    
    func animateArrow(expanded: Bool) {
        rotateArrow(angle: expanded ? .pi : 0)
    }

    public func setData(pool: PoolTypeModel) {
        nameLabel.text = pool.poolName
        arrowImageView.isHidden = pool.subPools.count == 0
        iconImageView.sd_setImage(with: URL(string: Constants.HttpUrlWithoutApi + pool.poolLogoImagePath), completed: nil)
    }
    
    
    
    // MARK: -- Listen theme changes
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: NSNotification.Name(Constants.themeChanged), object: nil)
    }

    @objc private func themeChanged() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.backgroundColor = .barSelectedItem
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
