//
//  AccountsTableViewCell.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/25/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import SDWebImage

class AccountsTableViewCell: BaseTableViewCell {

    // MARK: - Views
    @IBOutlet fileprivate weak var logoBackgroundView: UIView!
    @IBOutlet fileprivate weak var logoImageView: UIImageView!

    @IBOutlet fileprivate weak var accountNameLabel: BaseLabel!
    @IBOutlet fileprivate weak var poolNameLabel: BaseLabel!

    // Account info
    @IBOutlet fileprivate weak var hashrateLabel: BaseLabel!
    @IBOutlet fileprivate weak var hashrateImageView: UIImageView!

    @IBOutlet fileprivate weak var workerLabel: BaseLabel!
    @IBOutlet fileprivate weak var workerImageView: UIImageView!

    @IBOutlet fileprivate weak var poolStateImageView: UIImageView!
    
    @IBOutlet weak var firstStackView: UIStackView!
    @IBOutlet weak var secondStackView: UIStackView!
    
    
    @IBOutlet weak var noLoadedView: UIView!
    @IBOutlet weak var noLoadedInfoButton: UIButton!
    
    
    fileprivate let activityIndicatorForCell = UIActivityIndicatorView()


    // Default value is 15. When State image is showed, value is 50
    @IBOutlet fileprivate weak var infoStackTrailingConstraint: NSLayoutConstraint!
    
    // Default value is 15 . When Indicator  is showed, value is 40
    @IBOutlet weak var infoPoolStateTrallingConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    fileprivate var indexPath: IndexPath = .zero
    fileprivate(set) var state: PoolAccountStateEnum = .inactive
    public var isDisabled = false
    private var invalidCredential = false
    // MARK: Awake from NIB
    override func awakeFromNib() {
        super.awakeFromNib()
        startupSetup()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        logoImageView.image = nil
        poolStateImageView.image = nil
        infoStackTrailingConstraint.constant = 50
    }
}

// MARK: - Default startup setup
extension AccountsTableViewCell {
    override func startupSetup() {
        super.startupSetup()

        logoBackgroundView.layer.cornerRadius = 6.5
        logoImageView.layer.cornerRadius = logoBackgroundView.layer.cornerRadius
        configInfoViews()
        noLoadedInfoButton.addTarget(self, action: #selector(noLoadedButtonAction), for: .touchUpInside)
    }

    fileprivate func configInfoViews() {
        workerImageView.image = UIImage(named: "cell_worker_icon")?.withRenderingMode(.alwaysTemplate)
        hashrateImageView.image = UIImage(named: "cell_hashrate_icon")?.withRenderingMode(.alwaysTemplate)


        workerImageView.tintColor = .accountDisabled
        hashrateImageView.tintColor = .accountDisabled
    }
    
    @objc func noLoadedButtonAction() {
        if invalidCredential  {
            UIApplication.getTopViewController()?.showAlertView(nil, message: "Pool Address Invalid!".localized(), completion: nil)
        } else {
            UIApplication.getTopViewController()?.showToastAlert("Out of date!".localized(), message: nil)
        }
    }
}

// MARK: - Set data
extension AccountsTableViewCell {
    public func setData(model: PoolAccountModel, indexPath: IndexPath, disabled: Bool = false, loadedEnd:Bool, invalidCredentials: Bool) {
        self.indexPath = indexPath
        self.invalidCredential = invalidCredentials
        isDisabled = disabled
        if disabled {
            poolNameLabel.textColor = .workerRed
        } else {
            poolNameLabel.textColor = darkMode ? .white : UIColor.black.withAlphaComponent(0.85)
        }
        
        poolNameLabel.setLocalizableText(model.poolName)
        getLogoImage(model: model, indexPath: indexPath)

        accountNameLabel.setLocalizableText(model.poolAccountLabel)
        workerLabel.text = "\(model.workersCount)"
        hashrateLabel.text = model.currentHashrate.textFromHashrate(account: model)
        
        configAccountState(model, isloadedEnd: loadedEnd, invalidCredentials: invalidCredentials)
        
    }
}

// MARK: - Actions
extension AccountsTableViewCell {
    fileprivate func getLogoImage(model: PoolAccountModel, indexPath: IndexPath) {
        guard let pool = DatabaseManager.shared.getPool(id: model.poolType) else { return }
        logoImageView.sd_setImage(with: URL(string: Constants.HttpUrlWithoutApi + pool.poolLogoImagePath), completed: nil)
    }
    
    
    fileprivate func configAccountState(_ model: PoolAccountModel,isloadedEnd:Bool, invalidCredentials: Bool) {
        state = PoolAccountStateEnum.getState(model)
        
        switch state {
        case .inactive:
            self.noLoadedInfoButton.isHidden = true
            infoStackTrailingConstraint.constant =  15
            infoPoolStateTrallingConstraint.constant = 15
            if isDisabled  {
                poolStateImageView.image = UIImage(named: "maintenance")
            } else {
                poolStateImageView.image = UIImage(named: "account_inactive")
            }
//            poolStateImageView.tintColor = .accountDisabled
            changeInfoLabelsColor(isHidden: true)
            changeInfoImageViewsTintColor(to: .clear)
        case .enabled:
            self.noLoadedInfoButton.isHidden = true
            infoStackTrailingConstraint.constant = 15
            changeInfoLabelsColor(isHidden: false)
            changeInfoImageViewsTintColor(to: .accountEnabled)
            if !isDisabled {
                if !invalidCredentials {
                    if !model.Isloaded  {
                        self.noLoadedInfoButton.isHidden = true
                        if isloadedEnd{
                            self.noLoadedInfoButton.isHidden = false
                            infoStackTrailingConstraint.constant =  50
                        } else {
                            self.noLoadedInfoButton.isHidden = true
                            self.startLoad()
                            infoStackTrailingConstraint.constant =  50
                        }
                    } else {
                        self.noLoadedInfoButton.isHidden = true
                        infoStackTrailingConstraint.constant = 15
                    }
                } else {
                    self.noLoadedInfoButton.isHidden = false
                    infoStackTrailingConstraint.constant = 50
                    changeInfoLabelsColor(isHidden: true)
                    changeInfoImageViewsTintColor(to: .clear)
                }
            } else {
                self.noLoadedInfoButton.isHidden = true
                infoStackTrailingConstraint.constant =  15
                poolStateImageView.image = UIImage(named: "maintenance")
                changeInfoLabelsColor(isHidden: true)
                changeInfoImageViewsTintColor(to: .clear)
            }
            //            changeInfoLabelsColor(isHidden: false)
            //            changeInfoImageViewsTintColor(to: .accountEnabled)
            
        case .disabled:
            self.noLoadedInfoButton.isHidden = true
            infoStackTrailingConstraint.constant = 15
            infoPoolStateTrallingConstraint.constant = 15
            changeInfoLabelsColor(isHidden: false)
            changeInfoImageViewsTintColor(to: .accountDisabled)
            if !isDisabled {
                if !invalidCredentials {
                    if !model.Isloaded  {
                        self.noLoadedInfoButton.isHidden = true
                        if isloadedEnd{
                            self.noLoadedInfoButton.isHidden = false
                            infoStackTrailingConstraint.constant =  50
                        } else {
                            self.noLoadedInfoButton.isHidden = true
                            self.startLoad()
                            infoStackTrailingConstraint.constant =  50
                        }
                    } else {
                        self.noLoadedInfoButton.isHidden = true
                        infoStackTrailingConstraint.constant = 15
                    }
                } else {
                    self.noLoadedInfoButton.isHidden = false
                    infoStackTrailingConstraint.constant = 50
                    changeInfoLabelsColor(isHidden: true)
                    changeInfoImageViewsTintColor(to: .clear)
                }
            } else {
                self.noLoadedInfoButton.isHidden = true
                infoStackTrailingConstraint.constant =  15
                poolStateImageView.image = UIImage(named: "maintenance")
                changeInfoLabelsColor(isHidden: true)
                changeInfoImageViewsTintColor(to: .clear)
            }
            
        case .incorrect:
            self.noLoadedInfoButton.isHidden = true
            infoStackTrailingConstraint.constant = 15
            infoPoolStateTrallingConstraint.constant = 15
            poolStateImageView.image = UIImage(named: "account_incorrect")
            changeInfoLabelsColor(isHidden: true)
            changeInfoImageViewsTintColor(to: .clear)
            if !isDisabled {
                if !invalidCredentials {
                    if !model.Isloaded  {
                        self.noLoadedInfoButton.isHidden = true
                        if isloadedEnd{
                            self.noLoadedInfoButton.isHidden = false
                            infoStackTrailingConstraint.constant =  50
                        } else {
                            self.noLoadedInfoButton.isHidden = true
                            self.startLoad()
                            infoPoolStateTrallingConstraint.constant =  50
                        }
                    } else {
                        self.noLoadedInfoButton.isHidden = true
                        infoPoolStateTrallingConstraint.constant = 15
                    }
                } else {
                    self.noLoadedInfoButton.isHidden = false
                    infoStackTrailingConstraint.constant = 50
                }
            } else {
                self.noLoadedInfoButton.isHidden = true
                infoStackTrailingConstraint.constant =  15
                poolStateImageView.image = UIImage(named: "maintenance")
                changeInfoLabelsColor(isHidden: true)
                changeInfoImageViewsTintColor(to: .clear)
            }
            
        }
        
    }
    
    fileprivate func changeInfoLabelsColor(isHidden: Bool) {
        workerLabel.isHidden = isHidden
        hashrateLabel.isHidden = isHidden
    }
    
    fileprivate func changeInfoImageViewsTintColor(to color: UIColor) {
        workerImageView.tintColor = color
        hashrateImageView.tintColor = color
    }
    fileprivate func startLoad() {
        
        self.activityIndicatorForCell.startAnimating()
        self.activityIndicatorForCell.color = .barSelectedItem
        self.noLoadedView.addSubview(activityIndicatorForCell)
        self.activityIndicatorForCell.frame =  noLoadedView.bounds
        contentView.layoutIfNeeded()
    }
}

// MARK: - Helper
enum PoolAccountStateEnum {
    case inactive
    case incorrect
    case disabled
    case enabled
    
    static func getState(_ model: PoolAccountModel) -> PoolAccountStateEnum {
        guard model.active else { return inactive }

        if model.workersCount < 0 {
            return incorrect
        } else if model.workersCount == 0 || model.currentHashrate == 0 {
            return disabled
        } else {
            return enabled
        }
    }
}
