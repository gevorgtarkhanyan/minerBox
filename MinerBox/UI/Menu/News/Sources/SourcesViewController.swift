//
//  SourcesViewController.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 07.12.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

class SourcesViewController: BaseViewController {
    
    //MARK: - Views -
    @IBOutlet weak var sourceSearchBar: BaseSearchBar!
    @IBOutlet weak var sourceTableView: BaseTableView!
    private var searchButton: UIBarButtonItem!
    @IBOutlet weak var searchBarHeigthConstraits: NSLayoutConstraint!


    private var addedSources = [String]()
    private var allSources = [String]()
    private var filtredAddSeources = [String]()
    private var filtredAllSources = [String]()
    
    // MARK: - Static
    static func initializeStoryboard() -> SourcesViewController? {
        return UIStoryboard(name: "Menu", bundle: nil).instantiateViewController(withIdentifier: SourcesViewController.name) as? SourcesViewController
    }
    
    //MARK: - Live Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getSources()
        self.setupNavigation()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NewsCacher.shared.updateMyFeed = true
        UserDefaults.shared.setValue(addedSources.isEmpty, forKey: "added_sources_enpty")
    }
    
    func setupNavigation() {
        navigationController?.navigationBar.shadowImage = UIImage()
        sourceSearchBar.delegate = self
        
        searchButton = UIBarButtonItem.customButton(self, action: #selector(_showSearchBar), imageName: "bar_search")
        searchButton.isEnabled = false
        let buttons: [UIBarButtonItem] = [searchButton]
        navigationItem.setRightBarButtonItems(buttons, animated: false)
    }
    override func languageChanged() {
        title =  "sources".localized()
    }
    
    
    //MARK: - Action - 
    func getSources() {
        Loading.shared.startLoading()

        NewsManager.shared.getSources { sources in
            
            self.addedSources = sources.added.sorted { (lhs: String, rhs: String) -> Bool in
                return lhs.compare(rhs, options: .caseInsensitive) == .orderedAscending
            }
            self.allSources = sources.all.sorted { (lhs: String, rhs: String) -> Bool in
                return lhs.compare(rhs, options: .caseInsensitive) == .orderedAscending
            }
            self.filtredAddSeources = self.addedSources
            self.filtredAllSources = self.allSources
            self.searchButton.isEnabled = true
            self.sourceTableView.reloadData()
            Loading.shared.endLoading()
            
        } failer: { err in
            print(err)
            Loading.shared.endLoading()
        }
    }
    func addSource(source: String, success: @escaping() -> Void){
        Loading.shared.startLoading()
        NewsManager.shared.addSource(source: source) {
            success()
            Loading.shared.endLoading()
        } failer: { err in
            print(err)
            Loading.shared.endLoading()
        }

    }
    func removeSource(source: String,success: @escaping() -> Void ){
        Loading.shared.startLoading()
        NewsManager.shared.removeSource(source: source) {
            success()
            Loading.shared.endLoading()
        } failer: { err in
            print(err)
            Loading.shared.endLoading()
        }
    }
}

//MARK: - TableViewDelegate  -

extension SourcesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return  addedSources.count > 0 ? filtredAddSeources.count + 1 :  filtredAddSeources.count
        } else {
            return filtredAllSources.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SourceTableViewCell") as? SourceTableViewCell {
            if  indexPath.section == 0 {
                if indexPath.row == 0 &&  addedSources.count > 0 {
                    cell.setData(sourceName: "added_sources", indexPath: indexPath, isAdded: true, isTitle: true)
                } else {
                    cell.delegate = self
                    cell.setData(sourceName: filtredAddSeources[indexPath.row - 1], indexPath: indexPath, isAdded: true, isTitle: false)
                }
            } else {
                if indexPath.row == 0 {
                    cell.setData(sourceName: "all_sources", indexPath: indexPath, isAdded: false, isTitle: true)
                } else {
                    cell.delegate = self
                    cell.setData(sourceName: filtredAllSources[indexPath.row - 1], indexPath: indexPath, isAdded: false, isTitle: false)
                }
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SourceTableViewCell.height
    }
}


extension SourcesViewController : SourceTableViewCellDelegate {
    
    func minusAction(indexPath: IndexPath) {
        
        let source = filtredAddSeources[indexPath.row - 1]
        self.sourceTableView.isUserInteractionEnabled = false

        self.removeSource(source: source) {
            
            self.addedSources.remove(at: indexPath.row - 1)
            self.filtredAddSeources.remove(at: indexPath.row - 1)
            self.allSources.append(source)
            self.filtredAllSources.append(source)
            self.filtredAllSources.sort { (lhs: String, rhs: String) -> Bool in
                return lhs.compare(rhs, options: .caseInsensitive) == .orderedAscending
            }
            self.sourceTableView.reloadData()
            self.sourceTableView.isUserInteractionEnabled = true
        }
    }
    
    func plusAction(indexPath: IndexPath) {
        let source = filtredAllSources[indexPath.row - 1]
        
        self.sourceTableView.isUserInteractionEnabled = false
        self.addSource(source: source) {
            
            self.allSources.remove(at: indexPath.row - 1)
            self.filtredAllSources.remove(at: indexPath.row - 1)
            self.addedSources.append(source)
            self.filtredAddSeources.append(source)
            self.filtredAddSeources.sort { (lhs: String, rhs: String) -> Bool in
                return lhs.compare(rhs, options: .caseInsensitive) == .orderedAscending
            }
            self.sourceTableView.reloadData()
            self.sourceTableView.isUserInteractionEnabled = true
        }
    }
}

// MARK: - Search delegate
extension SourcesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let searchText = searchText.lowercased().trimmingCharacters(in: .whitespaces)

        guard searchText != "" else {
            filtredAddSeources =  addedSources
            filtredAllSources  =  allSources
            sourceTableView.reloadData()
            return
        }
        
        filtredAddSeources =  addedSources.filter({$0.lowercased().contains(searchText)})
        filtredAllSources  =  allSources.filter({$0.lowercased().contains(searchText)})
        sourceTableView.reloadData()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setCancelButtonEnabled(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setCancelButtonEnabled(false)
        searchBar.text = ""
        filtredAddSeources =  addedSources
        filtredAllSources  =  allSources
        sourceTableView.reloadData()
        hideSearchBar()
    }
    
    //search
    private func hideSearchBar() {
        if !sourceSearchBar.isHidden {
            sourceSearchBar.text = ""
            view.endEditing(true)
            let buttons: [UIBarButtonItem] = [searchButton]
            navigationItem.setRightBarButtonItems(buttons, animated: false)
            
            UIView.animate(withDuration: Constants.animationDuration, animations: {
                self.searchBarHeigthConstraits.constant = 0
                self.view.layoutIfNeeded()
            }) { (_) in
                self.sourceSearchBar.isHidden = true
            }
        }
    }

    @objc private func _showSearchBar() {
        if sourceSearchBar.isHidden {
            sourceSearchBar.isHidden = false
            let buttons: [UIBarButtonItem] = []
            navigationItem.setRightBarButtonItems(buttons, animated: true)
            UIView.animate(withDuration: Constants.animationDuration) {
                self.searchBarHeigthConstraits.constant = 40
                self.sourceSearchBar.becomeFirstResponder()
                self.view.layoutIfNeeded()
            }
        }
    }
}
