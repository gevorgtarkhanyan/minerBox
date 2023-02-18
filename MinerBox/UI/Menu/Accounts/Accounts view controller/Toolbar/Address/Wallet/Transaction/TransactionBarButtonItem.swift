//
//  TransactionBarButtonItem.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 02.03.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit

class TransactionBarButtonItem: UIBarButtonItem {
    
    private var contentView: UIView!
    private var imageView: UIImageView!
    
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
        checkTranascionState()
    }
    
    private func addAction() {
        let tap = UITapGestureRecognizer(target: target, action: action)
        customView?.addGestureRecognizer(tap)
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(checkTranascionState), name: .changeTransactionState, object: nil)
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
    
    @objc private func checkTranascionState() {

        switch Cacher.shared.walletTransactionState {
        case .loading:
            Loading.shared.startLoadingForView(with: imageView,scalePoint: 1)
            imageView.image = nil
        case .show:
            imageView.image = UIImage(named: "transaction")?.withRenderingMode(.alwaysOriginal)
            DispatchQueue.main.async {
                Loading.shared.endLoadingForView(with: self.imageView)
            }        case .noShow:
            imageView.image = UIImage(named: "no_transaction")?.withRenderingMode(.alwaysOriginal)
            DispatchQueue.main.async {
                Loading.shared.endLoadingForView(with: self.imageView)
            }
        }
    }
}

enum LoadingState {
    case loading
    case show
    case noShow
}
