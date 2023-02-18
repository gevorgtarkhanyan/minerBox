//
//  ChooseGraphWorkersViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/12/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

protocol ChooseGraphWorkersViewControllerDelegate: NSObjectProtocol {
    func graphWorkersSelected(_ selectedWorkers: [GraphWorker])
}

class ChooseGraphWorkersViewController: BaseViewController {

    // MARK: - Views
    @IBOutlet fileprivate weak var tableView: BaseTableView!

    // MARK: - Properties
    weak var delegate: ChooseGraphWorkersViewControllerDelegate?

    fileprivate var graphType: GraphTypeEnum = .hashrate
    fileprivate var workers = [GraphWorker]()
    fileprivate var selectedIndexes = [0]

    // Disable rotate
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        disablePageRotate()
    }

    override func languageChanged() {
        title = graphType.rawValue.localized()
    }
}

// MARK: - Startup default setup
extension ChooseGraphWorkersViewController {
    fileprivate func startupSetup() {
        getPageState()
        selectWorkers()
    }

    fileprivate func selectWorkers() {
        for i in selectedIndexes {
            guard workers.indices.contains(i) else { continue }
            let indexPath = IndexPath(row: i, section: 0)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
            tableView(tableView, didSelectRowAt: indexPath)
        }
    }
    
    //MARK: - Page state
    fileprivate func savePageState() {
        guard let account = Cacher.shared.account else { return }
        UserDefaults.shared.set(selectedIndexes, forKey: "\(account.keyPath + graphType.rawValue)ChooseGraphWorkersViewController")
    }

    fileprivate func getPageState() {
        guard let account = Cacher.shared.account else { return }
        selectedIndexes = UserDefaults.shared.array(forKey: "\(account.keyPath + graphType.rawValue)ChooseGraphWorkersViewController") as? [Int] ?? [0]
    }
}

// MARK: - TableView methods
extension ChooseGraphWorkersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CheckmarkTableViewCell.name) as! CheckmarkTableViewCell
        let worker = workers[indexPath.row]

        cell.setData(name: worker.name, indexPath: indexPath, last: indexPath.row == workers.count - 1)
        cell.isSelected = selectedIndexes.contains(indexPath.row)//selectedWorkers.contains(worker)

        return cell
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let indexPaths = tableView.indexPathsForSelectedRows else { return indexPath }
        if indexPaths.count > 4 {
            showAlertView("", message: "cant_select_more_than_5_items".localized(), completion: nil)
            return nil
        }
        return indexPath
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectWorkers(for: tableView.indexPathsForSelectedRows ?? [])
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        if let selectedIndices = tableView.indexPathsForSelectedRows {
            return selectedIndices.count > 1 ? indexPath : nil
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.selectWorkers(for: tableView.indexPathsForSelectedRows ?? [])
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
}

// MARK: - Set data
extension ChooseGraphWorkersViewController {
    public func setWorkers(all: [GraphWorker]) {
        workers = all
//        selectedWorkers = selected
    }

    public func setType(graphType: GraphTypeEnum) {
        self.graphType = graphType
    }
}

// MARK: - Actions
extension ChooseGraphWorkersViewController {
    fileprivate func selectWorkers(for indexPaths: [IndexPath]) {
        let selectedWorkers = indexPaths.map { workers[$0.row] }
        selectedIndexes = indexPaths.map { $0.row }
        savePageState()
        delegate?.graphWorkersSelected(selectedWorkers)
    }
}
