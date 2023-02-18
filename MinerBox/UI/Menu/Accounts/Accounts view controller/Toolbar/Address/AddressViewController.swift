//
//  WalletViewController.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 08.02.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit
import MobileCoreServices


protocol AddressViewControllerDelegate: AnyObject {
    func selectAddres(address: AddressModel?)
}

class AddressViewController: BaseViewController {
    
    //MARK: - Properties
    @IBOutlet weak var addressTableView: BaseTableView!
    
    private var addButton: UIBarButtonItem!
    private var saveButton: UIBarButtonItem?
    private var selectedAddress: AddressModel?
    public var poolType: Int?
    public var subPoolId: Int?
    public var isSelectingMode = false
    private var addressTypies: [AddressType] = [AddressType(name: "None")]
    private var refresAddressTimer: Timer?
    private var refreshTime = 0
    private var isWalletloadEnd: Bool = false
    private var filteredAddress: [AddressModel] = []
    private var addressList: [AddressModel] = []
    @IBOutlet weak var showButtonView: UIView!
    @IBOutlet weak var showLabbel: UILabel!
    @IBOutlet weak var showViewHeighContraits: NSLayoutConstraint!
    @IBOutlet weak var showImageButton: UIButton!
    private var isShowSelected = false
    private var oldSelectedAddresOrder: Int? //for draging Items
    
    weak var delegate: AddressViewControllerDelegate?
    
    var addressLinks: [AddressLinkModel] = []
    var addresses: [AddressModel] = [] {
        didSet {
            if addresses.count == 0 {
                if isSelectingMode {
                    showNoDataLabel()
                } else {
                    noDataButton?.isHidden = false
                }
            } else {
                if isSelectingMode {
                    hideNoDataLabel()
                } else {
                    noDataButton?.isHidden = true
                }
            }
        }
    }
    private var adsViewForAddress: AdsView?

    var bottomContentInsets: CGFloat = 0 {
        willSet {
            addressTableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: newValue, right: 0)
        }
    }
    
    override func languageChanged() {
        title = "wallets".localized()
    }
    
    deinit {
        print("AddressViewController deinit")
    }
    
    // MARK: - Static
    static func initializeStoryboard() -> AddressViewController? {
        return UIStoryboard(name: "Menu", bundle: nil).instantiateViewController(withIdentifier: AddressViewController.name) as? AddressViewController
    }
    
    //MARK: - Live Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addObservers()
        self.setupNavigation()
        self.setupTableView()
        self.getAddressTypes()
        if isSelectingMode {
            self.getFiltedAddressList()
        } else {
            self.getAddresses()
        }
        self.setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.checkUserForAds()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
   //     self.adsViewForAddress?.removeFromSuperview()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        addressTableView?.setEditing(false, animated: false)
        addressTableView?.reloadData()
        let isHidden = UIApplication.shared.statusBarOrientation.isPortrait && UIDevice.current.userInterfaceIdiom == .phone && self.viewIfLoaded?.window != nil
        adsViewForAddress?.isHidden = isHidden
        bottomContentInsets = isHidden || addressTableView == nil ? 0 : 200
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(newWalletAdded(_:)), name: NSNotification.Name(Constants.newWalletAdded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getAddresses), name: Notification.Name(Constants.successfullSubscription), object: nil)
    }
    
    private func setupNavigation() {
        navigationController?.navigationBar.shadowImage = UIImage()
        if !isSelectingMode {
            self.addButton = UIBarButtonItem(image: UIImage(named: "bar_plus"), style: .done, target: self, action: #selector(goToAddAddressPage))
            navigationItem.setRightBarButton(addButton, animated: true)
        }
    }
    private func setupViews() {
        if isSelectingMode {
            self.showImageButton.setImage( UIImage(named:"Slected"), for: .normal)
            self.showImageButton.tintColor = .barSelectedItem
            self.showLabbel.text = "show_all".localized()
            self.showLabbel.textColor = .barSelectedItem
            self.showViewHeighContraits.constant = 28
            let tap = UITapGestureRecognizer(target: self, action: #selector(showButtonAction))
            self.showButtonView.addGestureRecognizer(tap)
        }
    }
    
    private func setupTableView() {
        self.addressTableView.register(UINib(nibName: AddressTableViewCell.name, bundle: nil), forCellReuseIdentifier: AddressTableViewCell.name)
        if #available(iOS 11.0, *) {
            addressTableView.dragDelegate = self
            addressTableView.dropDelegate = self
            addressTableView.dragInteractionEnabled = !isSelectingMode
            
        }
    }
    
    override func configNoDataButton() {
        super.configNoDataButton()
        noDataButton!.setTransferButton(text: "add_wallet", subText: "", view: self.view)
        noDataButton!.addTarget(self, action: #selector(goToAddAddressPage), for: .touchUpInside)
    }
    
    func getAddressTypes() {
        guard  RealmWrapper.sharedInstance.getAllObjectsOfModel(AddressType.self) as? [AddressType] == [] else {return}
            AddressManager.shared.getAddressTypies { addressTypies in
                self.addressTypies = addressTypies
                Loading.shared.endLoading()
            } failer: { error in
                debugPrint(error)
            }
   }
    
  @objc func getAddresses() {
        self.isWalletloadEnd = false
        
        guard DatabaseManager.shared.currentUser != nil else { self.addresses = []; return }
        Loading.shared.startLoading()
        AddressManager.shared.getAddressList { addresses, links in
            self.addresses = addresses
            self.addressList = addresses
            self.addressLinks = links
            self.startAddressTimer()
            self.addressTableView.reloadData()
            Loading.shared.endLoading()
        } failer: { error in
            debugPrint(error)
            self.showAlertView("", message: error.localized(), completion: nil)
            
        }
    }
    func getFiltedAddressList() {
        guard DatabaseManager.shared.currentUser != nil else { self.addresses = []; return }
        Loading.shared.startLoading()
        AddressManager.shared.getFiltedAddressList(poolType: poolType ?? 0, subPoolId: subPoolId ?? 0, success:  { addresses in
            self.addresses = addresses
            self.filteredAddress = addresses
            self.addressTableView.reloadData()
            Loading.shared.endLoading()
        }, failer: { error in
            debugPrint(error)
            self.configNoDataButton()
            Loading.shared.endLoading()
        })
    }
    
    func removeWallet(indexPath : IndexPath) {
        Loading.shared.startLoading()
        addressTableView.isUserInteractionEnabled = false
        AddressManager.shared.removeAddress(addressId: addresses[indexPath.row]._id) {
            debugPrint("Address Reomoved")
            self.addresses.remove(at: indexPath.row)
            self.addressTableView.deleteRows(at: [indexPath], with: .fade)
            Loading.shared.endLoading()
            self.addressTableView.isUserInteractionEnabled = true
        } failer: { error in
            debugPrint(error)
            self.showAlertView("", message: error.localized(), completion: nil)
        }
    }
    
    func editWallet(indexPath : IndexPath) {
        guard let vc = AddAddressViewController.initializeStoryboard() else { return }
        let address = addresses[indexPath.row]
        vc.setAddress(oldAddress: address)
        navigationController?.pushViewController(vc, animated: true)
        vc.setTypeEditWallet(typeName: address)
    }
    
    private func sendAddresNewOrders(oldOrder: Int, newOrder: Int) {

        AddressManager.shared.updateAddressOrder(oldOrder: oldOrder, newOrder: newOrder) {
            debugPrint("Orders updated")
        } failer: { error in
            debugPrint(error)
        }
    }
    
    //MARK: Action
    func startAddressTimer() {
        guard refresAddressTimer == nil else { return }
        self.refresAddressTimer = Timer.scheduledTimer(timeInterval: Constants.singleCallTimeInterval, target: self, selector: #selector(self.checkWalletLoad), userInfo: nil, repeats: true)
    }
    
    func stopAddressTimer() {
        refresAddressTimer?.invalidate()
        refresAddressTimer = nil
    }
    
    @objc func showButtonAction() {
        if isShowSelected {
            self.showImageButton.setImage( UIImage(named:"Slected"), for: .normal)
            self.showImageButton.titleLabel?.text = ""
                addresses = filteredAddress
                self.addressTableView.reloadData()
        } else {
            self.showImageButton.setImage( UIImage(named:"cell_checkmark"), for: .normal)
            self.showImageButton.titleLabel?.text = ""
            if addressList.count == 0 {
            self.getAddresses()
            } else {
                addresses = addressList
                self.addressTableView.reloadData()
            }
            
        }
        isShowSelected.toggle()
    }
    
    @objc private func checkWalletLoad() {
        self.refreshTime += 5
        if refreshTime == Constants.poolRequestTimeInterval {
            self.isWalletloadEnd = true
            self.addressTableView.reloadData()
            self.refreshTime = 0
            self.stopAddressTimer()
            return
        }
        for (addres) in addresses {
            if addres.hasWallet {
                if addres.walletLoaded != nil {
                    guard addres.walletLoaded! else {
                        AddressManager.shared.getAddressList { addresses, links in
                            self.addressLinks = links
                            self.addresses = addresses
                            self.addressTableView.reloadData()
                        } failer: { (err) in
                            print(err)
                        }
                        return
                    }
                }
            }
        }
        self.refreshTime = 0
        self.isWalletloadEnd = false
        self.addressTableView.reloadData()
        self.stopAddressTimer()
    }
    @objc private func deleteAddres(indexPath: IndexPath) {
        self.showAlertViewController(nil, message: "ask_for_delete", otherButtonTitles: ["ok"], cancelButtonTitle: "cancel") { (responce) in
            if responce == "ok" {
                self.removeWallet(indexPath: indexPath)
            }
        }
    }
    
    @objc func goToAddAddressPage() {
        guard let vc = SelectTypeAddressViewController.initializeStoryboard() else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func goToAddPoolViewController() {
        if delegate != nil {
            delegate?.selectAddres(address: self.selectedAddress)
        }
        guard let navigation = self.navigationController else { return }
        for controller in navigation.viewControllers {
            if let addPoolVC = controller as? AddPoolViewController {
                navigation.popToViewController(addPoolVC, animated: true)
                return
            }
        }
    }
    
    @objc private func newWalletAdded(_ sender: Notification) {
        getAddresses()
    }
    /// The traditional method for rearranging rows in a table view.
    func moveAddressItem(at sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex else { return }
        
        let address = addresses[sourceIndex]
        addresses.remove(at: sourceIndex)
        addresses.insert(address, at: destinationIndex)
    }
      
    @available(iOS 11.0, *)
    func canHandleAddress(_ session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    /// The method for adding a new item to the table view's data model.
    func addAddressItem(_ address: AddressModel, at index: Int) {
        addresses.insert(address, at: index)
    }
    
}


//MARK: - TableViewDelegate  -
extension AddressViewController: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.addresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: AddressTableViewCell.name) as? AddressTableViewCell {
            
            let showExplorerIcon = self.addressLinks.contains { link in
                if link.coinId == addresses[indexPath.row].coinId && !link.addressLinks.isEmpty {
                    return true
                }
                return false
            }
            
            cell.setData(address: addresses[indexPath.row], isSelectingMode: isSelectingMode, indexPath: indexPath, loadedEnd: addresses[indexPath.row].walletLoaded ?? true ? false : self.isWalletloadEnd, showExplorerIcon: showExplorerIcon)
            cell.delegate = self
            return cell
        }
        return AddressTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AddressTableViewCell.height
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        debugPrint("canMoveRowAt")

        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        debugPrint("sourceIndexPath")

        self.moveAddressItem(at: sourceIndexPath.row, to: destinationIndexPath.row)
        self.sendAddresNewOrders(oldOrder: sourceIndexPath.row, newOrder: destinationIndexPath.row)

    }
    
    // Cell swipe method for less than iOS 11
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let remove = UITableViewRowAction(style: .normal, title: "delete".localized()) { (_, indexPath) in
            self.deleteAddres(indexPath: indexPath)
        }
        let edit = UITableViewRowAction(style: .normal, title: "edit".localized()) { (_, indexPath) in
            self.editWallet(indexPath: indexPath)
        }
        return [edit, remove]
    }
    // Cell swipe method for greather than iOS 11
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "") { (_, _, completion) in
            self.editWallet(indexPath: indexPath)
            completion(true)
        }
        let remove = UIContextualAction(style: .normal, title: "") { (_, _, completion) in
            self.deleteAddres(indexPath: indexPath)
            completion(true)
        }
        edit.image = UIImage(named: "cell_edit")
        edit.backgroundColor = .cellTrailingFirst
        
        remove.image = UIImage(named: "cell_delete")
        remove.backgroundColor = .red
        
        let swipeAction = UISwipeActionsConfiguration(actions: [remove, edit])
        swipeAction.performsFirstActionWithFullSwipe = false // This is the line which disables full swipe
        return swipeAction
    }
}

// MARK: - TableView drap drop delegate
@available(iOS 11, *)
extension AddressViewController: UITableViewDragDelegate, UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let param = UIDragPreviewParameters()
        param.backgroundColor = .clear
        return param
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return []
    }
    
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return canHandleAddress(session)
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        // The .move operation is available only for dragging within a single app.
        if tableView.hasActiveDrag {
            if session.items.count > 1 {
                return UITableViewDropProposal(operation: .cancel)
            } else {
                return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
        } else {
            return UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, dragSessionDidEnd session: UIDragSession) {
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // Get last index path of table view.
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        let _ = coordinator.session.loadObjects(ofClass: String.self) { items in
            // Consume drag items.
            let idStrings = self.addresses.map { $0._id }
            let stringItems = [idStrings.first { items.contains($0) }!]
            
            var indexPaths = [IndexPath]()
            for (index, item) in stringItems.enumerated() {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                let account = self.addresses.first { $0._id == item }
                self.addAddressItem(account!, at: indexPath.row)
                indexPaths.append(indexPath)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}


extension AddressViewController: AddressTableViewCellDelegate {
    
    func explorerButtonSelect(indexpath: IndexPath) {
        
        var websites = [String]()
        let address = self.addresses[indexpath.row]
        
        if let links = self.addressLinks.filter({$0.coinId == address.coinId}).first
        {
            for link in links.addressLinks {
                let newLink = link.replacingOccurrences(of: "{address}", with: address.credentials["address"] ?? "")
                websites.append(newLink)
            }
        }
        guard let popVC = PopUpInfoViewController.initializeStoryboard() else { return }
        popVC.setwebsites(websites: websites)
        present(popVC, animated: true)
    }
    
    
    func exchangeButtonSelect(indexpath: IndexPath) {
        
        guard user!.isSubscribted else {
            goToSubscriptionPage()
            return
        }
        
        guard let vc = WalletViewController.initializeStoryboard() else { return }
        vc.walletId = self.addresses[indexpath.row].walletId
        vc.walletType = self.addresses[indexpath.row].poolName
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func buttonSelect(indexpath: IndexPath) {
        for (index,address) in self.addresses.enumerated() {
            if index == indexpath.row {
                selectedAddress = address
                address.isSelected = true
                
            } else {
                address.isSelected = false
            }
        }
        self.goToAddPoolViewController()
    }
    
}

// MARK: - Ads Methods -

extension AddressViewController {
    
    func checkUserForAds() {
        AdsManager.shared.checkUserForAds(zoneName: .wallet) {[weak self] adsView in
            self?.adsViewForAddress = adsView
            self?.setupAds()
        }
        
    }
    func setupAds() {
        guard let adsViewForAddress = adsViewForAddress else { return }
        
        self.view.addSubview(adsViewForAddress)
        
        adsViewForAddress.translatesAutoresizingMaskIntoConstraints = false
        addressTableView.leftAnchor.constraint(equalTo: adsViewForAddress.leftAnchor, constant: -10).isActive = true
        addressTableView.rightAnchor.constraint(equalTo: adsViewForAddress.rightAnchor, constant: 10).isActive = true
        addressTableView.bottomAnchor.constraint(equalTo: adsViewForAddress.bottomAnchor,constant: 24).isActive = true
        bottomContentInsets = 200
    }
}
