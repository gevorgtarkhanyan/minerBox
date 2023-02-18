//
//  BaseTableView.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/19/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class BaseTableView: UITableView {
        
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
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

// MARK: - Startup default setup
extension BaseTableView {
    @objc public func startupSetup() {
        changeColors()
        addObservers()
        separatorColor =  darkMode ? .blackBackground : .white

        tableFooterView = UIView(frame: .zero)
    }

    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: Notification.Name(Constants.themeChanged), object: nil)
    }

    @objc fileprivate func themeChanged() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.changeColors()
        }
    }

    fileprivate func changeColors() {
        backgroundColor = .clear
        indicatorStyle = darkMode ? .white : .black
        separatorColor =  darkMode ? .blackBackground : .white
    }
}

// MARK: - BaseTableViewTouchesDelegate

protocol BaseTableViewTouchesDelegate {
    func touchesBegan(_ touches: Set<UITouch>)
}

class FlexibleTableView: BaseTableView {
    
    var touchDelegate: BaseTableViewTouchesDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDelegate?.touchesBegan(touches)
    }
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        awakeFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        startupSetup()
    }
    
    
}
