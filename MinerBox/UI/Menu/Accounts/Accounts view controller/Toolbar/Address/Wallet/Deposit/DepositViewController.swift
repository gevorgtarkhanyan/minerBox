//
//  DepositViewController.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 24.02.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit

class DepositViewController: BaseViewController {
    
    
    //MARK: - Properties
    @IBOutlet weak var networkView: BaseView!
    @IBOutlet weak var networkNameLabel: BaseLabel!
    @IBOutlet weak var networkButton: AreaButton!
    @IBOutlet weak var qrbackgroundView: BaseView!
    @IBOutlet weak var qrImageView: QRImageView!
    
    @IBOutlet weak var downloadButton: BaseButton!
    @IBOutlet weak var walletAddresLabel: UILabel!
    
    @IBOutlet weak var addressLabbel: BaseLabel!
    @IBOutlet weak var copyButton: CopyButton!
    @IBOutlet weak var shareButton: UIButton!
    
    public var walletCoin: WalletCoinModel?
    public var walletId: String = ""
    public var exchange: String = ""
    public var selectedIndex: Int?
    public var historyTypes: [String] = []

    private var reloadButton: UIBarButtonItem?
    private var transactionButton: TransactionBarButtonItem?
    
    // MARK: - Static
    static func initializeStoryboard() -> DepositViewController? {
        return UIStoryboard(name: "Menu", bundle: nil).instantiateViewController(withIdentifier: "DepositViewController") as? DepositViewController
    }
    
    override func languageChanged() {
        title = "deposit".localized() + " (\(walletCoin!.currency))"
    }
    
    deinit {
        print("DepositViewController deinit")
    }
    
    //MARK: - Live Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupNavigation()
    }
    
    func setupViews() {
        guard walletCoin != nil  && selectedIndex != nil else { return }
        self.qrImageView.setValueForQR(walletCoin?.addresses[selectedIndex!].address ?? "")
        self.networkButton.imageView?.tintColor = .barSelectedItem
        self.networkButton.addTarget(self, action: #selector(selectNetworks), for: .touchUpInside)
        self.networkButton.isHidden = walletCoin!.addresses.count < 2
        self.networkButton.tintColor = .barSelectedItem
        self.networkButton.setTouchInset(insets: UIEdgeInsets(top: 0, left: -networkView.frame.width, bottom: 0, right: 0))
        self.networkNameLabel.text = walletCoin?.addresses[selectedIndex!].network ?? ""
        self.walletAddresLabel.text = "Wallet address".localized()
        self.addressLabbel.text =  walletCoin?.addresses[selectedIndex!].address ?? ""
        self.copyButton.setValueForCopy(walletCoin?.addresses[selectedIndex!].address ?? "")
        self.copyButton.setController(self)
        self.downloadButton.layer.borderColor = UIColor.barSelectedItem.cgColor
        self.downloadButton.layer.borderWidth = 2
        self.downloadButton.setTitle("download_QR".localized(), for: .normal)
        self.downloadButton.addTarget(self, action: #selector(shareAddressQr), for: .touchUpInside)
        self.shareButton.addTarget(self, action: #selector(shareAddresText), for: .touchUpInside)
        self.shareButton.setImage(UIImage(named: "share")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.shareButton.tintColor = .lightGray
    }
    
    func setupNavigation() {
        navigationController?.navigationBar.shadowImage = UIImage()
        reloadButton =  UIBarButtonItem(image: UIImage(named: "navi_reload"),style: .done, target: self, action:  #selector(reloadWalletCoin))
        transactionButton = TransactionBarButtonItem(target: self, action: #selector(goToTransactionPage))
        let buttons: [UIBarButtonItem] = [transactionButton!, reloadButton!]
        navigationItem.setRightBarButtonItems(buttons, animated: false)
    }
    
    @objc func selectNetworks() {
        let netWorkNames: [String] = walletCoin?.addresses.map({$0.network}) ?? []
        self.showActionShit(self, type: .simple, items: netWorkNames)
    }
    
    @objc func shareAddresText() {
        ShareManager.shareText( self, text: walletCoin?.addresses[selectedIndex!].address ?? "")
    }
    
    @objc func shareAddressQr() {
        ShareManager.share(self, drawViews: [qrbackgroundView], shareType: .png)
    }
    
    @objc func reloadWalletCoin() {
        
        guard let walletcoin = walletCoin else { return }

        Loading.shared.startLoading()

        WalletManager.shared.getWalletCoin(walletId: walletId, coinId: walletcoin.coinId, currency: walletcoin.currency, exchange: exchange) {[weak self]
            walletCoin in
            guard let self = self else { return }
            self.walletCoin = walletCoin
            Loading.shared.endLoading()
        } failer: { error in
            self.showAlertView("", message: error, completion: nil)
            Loading.shared.endLoading()
        }
    }
    
    @objc  private func goToTransactionPage() {
        
        switch Cacher.shared.walletTransactionState  {
        case .show:
            guard let vc = TransactionController.initializeStoryboard() else { return }
            vc.walletId = walletId
            vc.historyTypes = historyTypes
            navigationController?.pushViewController(vc, animated: true)
        case .noShow:
            showToastAlert("Out of date!".localized(), message: nil)
        case .loading:
            return
        }
    }
}


// MARK: - ActionSheetViewControllerDelegate
extension DepositViewController: ActionSheetViewControllerDelegate {
    
    func actionShitSelected(index: Int) {
        self.selectedIndex = index
        self.qrImageView.setValueForQR(walletCoin?.addresses[selectedIndex!].address ?? "")
        self.networkNameLabel.text = walletCoin?.addresses[selectedIndex!].network ?? ""
        self.addressLabbel.text =  walletCoin?.addresses[selectedIndex!].address ?? ""
        self.copyButton.setValueForCopy(walletCoin?.addresses[selectedIndex!].address ?? "")
    }
}
