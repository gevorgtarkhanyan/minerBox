//
//  ReloadBarButtonItem.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 15.03.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit

class ReloadBarButtonItem: UIBarButtonItem {
    
    private var contentView: UIView!
    private var imageView: UIImageView!
    private var activityIndicator: UIActivityIndicatorView?

    // MARK: - Init
    override init() {
        super.init()
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: - Setup
    private func startupSetup() {
        addContentView()
        addImageView()
        addAction()
        addObservers()
        if #available(iOS 13.0, *) {
            setupIndicator()
        }
        checkReloadState()
    }
    
    private func addAction() {
        let tap = UITapGestureRecognizer(target: target, action: action)
        customView?.addGestureRecognizer(tap)
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(checkReloadState), name: .updateReloadState, object: nil)
    }
    
    @available(iOS 13.0, *)
    fileprivate func setupIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator?.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator?.color = .barSelectedItem
        activityIndicator?.backgroundColor = .clear
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.frame = imageView.bounds
        
        DispatchQueue.main.async {
            self.imageView.addSubview(self.activityIndicator!)
            self.imageView.bringSubviewToFront(self.activityIndicator!)
            self.activityIndicator!.centerYAnchor.constraint(equalTo:  self.imageView.centerYAnchor).isActive = true
            self.activityIndicator!.centerXAnchor.constraint(equalTo:  self.imageView.centerXAnchor).isActive = true
            self.activityIndicator!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    
    //MARK: - Add views
    private func addContentView() {
        contentView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        customView = contentView
    }
    
    private func addImageView() {
        imageView = UIImageView()
        contentView.addSubview(imageView)
        imageView.frame = CGRect(x: 2.5, y: 2.5, width: 20, height: 20)
        imageView.contentMode = .scaleAspectFit
    }
    
    @objc private func checkReloadState() {
        
        if #available(iOS 13.0, *)  {
            switch Cacher.shared.walletUpateState {
            case .loading:
                activityIndicator?.startAnimating()
                imageView.image = UIImage(named: "")?.withRenderingMode(.alwaysOriginal)
            case .show:
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(named: "navi_reload")?.withRenderingMode(.alwaysOriginal)
                }
                self.activityIndicator?.stopAnimating()
            case .noShow:
                print("")
            }
        } else {
            switch Cacher.shared.walletUpateState {
            case .loading:
                self.imageView.image = UIImage(named: "navi_reload")?.withRenderingMode(.alwaysOriginal)
            case .show:
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(named: "navi_reload")?.withRenderingMode(.alwaysOriginal)
                }
            case .noShow:
                print("")
            }
        }
    }
}
