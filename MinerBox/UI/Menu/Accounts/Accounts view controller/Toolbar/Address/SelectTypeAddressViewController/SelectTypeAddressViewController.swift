//
//  SelectTypeAddressViewController.swift
//  MinerBox
//
//  Created by Gevorg Tarkhanyan on 07.07.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import UIKit
import SwiftUI

class SelectTypeAddressViewController: BaseViewController {
    
    @IBOutlet weak var tableView: BaseTableView!
    private var selectedType: AddressType!
    private var addressTypies: [AddressType] = [AddressType(name: "None")]
    private var filteredPoolTypes = [ExpandablePoolType]()
    private var poolTypes = [ExpandablePoolType]()
    // MARK: - Static
    static func initializeStoryboard() -> SelectTypeAddressViewController? {
        return UIStoryboard(name: "Menu", bundle: nil).instantiateViewController(withIdentifier: SelectTypeAddressViewController.name) as? SelectTypeAddressViewController
    }
    
    //MARK: - Live Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        getAddresses()
        getPools()
    }
    
    func initialSetup() {
        self.tableView.backgroundColor = .clear
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        title = "add_wallet".localized()
    }
    
     func getAddresses() {
        Loading.shared.startLoading()
        AddressManager.shared.getAddressTypies { addressTypies in
            self.addressTypies = addressTypies
            self.tableView.reloadData()
            Loading.shared.endLoading()
            self.initialSetup()
        } failer: { error in
            debugPrint(error)
            Loading.shared.endLoading()
        }
    }
    
    private func getPools() {
        if let types = DatabaseManager.shared.allEnabledPoolTypes {
            poolTypes = types.map { ExpandablePoolType(expanded: false, model: $0) }
            //            poolTypes.sort { $0.model.poolName < $1.model.poolName }
            filteredPoolTypes = poolTypes
        }
    }
    
  private  func goToAddAddressPage() {
        if DatabaseManager.shared.currentUser != nil {
            guard let navigation = self.navigationController else { return }
            for controller in navigation.viewControllers {
                if let addAddressVC = controller as? AddAddressViewController {
                    navigation.popToViewController(addAddressVC, animated: true)
                    return
                }
            }
    } else {
        goToLoginPage()
    }
}
}

//MARK: - TableViewDelegate  -
extension SelectTypeAddressViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        addressTypies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: SelectTypeAddressTableViewCell.name) as? SelectTypeAddressTableViewCell {
            let type = addressTypies[indexPath.section].typeName
            cell.TypeLabel.text = type
            for pools in filteredPoolTypes {
                if indexPath.section == 0 {
                    cell.TypeLabel.text = "Coin"
                    cell.TypeImage.image = UIImage(named: "empty_coin")
                } else if type == pools.model.poolName {
                    cell.SetData(type: type, poolType: pools.model, indexPath: indexPath)
                }
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if DatabaseManager.shared.currentUser != nil {
        guard let vc = AddAddressViewController.initializeStoryboard() else { return }
        navigationController?.pushViewController(vc, animated: true)
                vc.setTypeImageLabel(indexPath: indexPath)
                vc.actionShitSelected(index: indexPath.section)
            } else {
                goToLoginPage()
            }
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        SelectTypeAddressTableViewCell.height
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
}
