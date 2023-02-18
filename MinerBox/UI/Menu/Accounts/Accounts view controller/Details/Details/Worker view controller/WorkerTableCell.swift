//
//  WorkerTableCell.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/5/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import Localize_Swift

class WorkerTableCell: BaseTableViewCell {

    // MARK: - Views
    fileprivate var backView: BaseView!

    fileprivate var iconImageView: BaseImageView!
    fileprivate var nameAndDateStack: UIStackView!
    fileprivate var nameLabel: UILabel!
    fileprivate var dateLabel: BaseLabel!
    fileprivate var progressView: BaseProgressView!

    fileprivate var infoTableView: UITableView!

    // MARK: - Properties
    fileprivate var rows = [[(key: String, value: String)]]()
    fileprivate var sections = [String]()

    override func prepareForReuse() {
        rows.removeAll()
        sections.removeAll()
    }

    override func startupSetup() {
        super.startupSetup()
        setupUI()
    }

    override func changeColors() {
        backgroundColor = .clear
        nameLabel?.textColor = darkMode ? .white : UIColor.black.withAlphaComponent(0.85)
    }
}

// MARK: - Setup UI
extension WorkerTableCell {
    fileprivate func setupUI() {
        setupBackView()

        addIconImage()
        addNameAndDate()
        addProgressLine()

        addWorkerInfoTable()
    }

    fileprivate func setupBackView() {
        backView = BaseView(frame: .zero)
        backView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(backView)

        backView.clipsToBounds = true
        backView.layer.cornerRadius = 10

        backView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        backView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 5).isActive = true
        backView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5).isActive = true
        backView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
    }

    fileprivate func addIconImage() {
        iconImageView = BaseImageView(frame: .zero)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        backView.addSubview(iconImageView)

        iconImageView.image = UIImage(named: "cell_worker_icon")?.withRenderingMode(.alwaysTemplate)

        iconImageView.addEqualRatioConstraint()
        iconImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        iconImageView.topAnchor.constraint(equalTo: backView.topAnchor, constant: 10).isActive = true
        iconImageView.leftAnchor.constraint(equalTo: backView.leftAnchor, constant: 15).isActive = true
    }

    fileprivate func addNameAndDate() {
        // Add stack
        nameAndDateStack = UIStackView(frame: .zero)
        nameAndDateStack.translatesAutoresizingMaskIntoConstraints = false
        backView.addSubview(nameAndDateStack)

        nameAndDateStack.alignment = .fill
        nameAndDateStack.axis = .horizontal
        nameAndDateStack.distribution = .equalSpacing

        nameAndDateStack.topAnchor.constraint(equalTo: iconImageView.topAnchor).isActive = true
        nameAndDateStack.bottomAnchor.constraint(equalTo: iconImageView.bottomAnchor).isActive = true
        nameAndDateStack.leftAnchor.constraint(equalTo: iconImageView.rightAnchor, constant: 10).isActive = true
        nameAndDateStack.rightAnchor.constraint(equalTo: backView.rightAnchor, constant: -15).isActive = true

        // Add nameLabel
        nameLabel = UILabel(frame: .zero)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameAndDateStack.addArrangedSubview(nameLabel)

        nameLabel.font = Constants.regularFont.withSize(13)
        changeColors()

        // Add dateLabel
        dateLabel = BaseLabel(frame: .zero)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        nameAndDateStack.addArrangedSubview(dateLabel)

        dateLabel.font = Constants.regularFont.withSize(13)
    }

    fileprivate func addProgressLine() {
        progressView = BaseProgressView(frame: .zero)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        backView.addSubview(progressView)

        progressView.heightAnchor.constraint(equalToConstant: 1.2).isActive = true
        progressView.leftAnchor.constraint(equalTo: iconImageView.leftAnchor).isActive = true
        progressView.rightAnchor.constraint(equalTo: nameAndDateStack.rightAnchor).isActive = true
        progressView.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 10).isActive = true
    }

    fileprivate func addWorkerInfoTable() {
        infoTableView = UITableView(frame: .zero)
        infoTableView.translatesAutoresizingMaskIntoConstraints = false
        backView.addSubview(infoTableView)

        infoTableView.isScrollEnabled = false
        infoTableView.separatorColor = .clear
        infoTableView.backgroundColor = .clear
        infoTableView.tableFooterView = UIView(frame: .zero)
        infoTableView.register(InfoTableCell.self, forCellReuseIdentifier: InfoTableCell.name)

        infoTableView.widthAnchor.constraint(equalTo: progressView.widthAnchor).isActive = true
        infoTableView.centerXAnchor.constraint(equalTo: progressView.centerXAnchor).isActive = true
        infoTableView.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 5).isActive = true
        infoTableView.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -10).isActive = true
    }
}

// MARK: Set data
extension WorkerTableCell {
    public func setWorkerData(worker: PoolWorkerModel, pool: PoolAccountModel) {
        // Set name and Date
        nameLabel.text = worker.name
        if worker.lastSeen != 0 {
            dateLabel.setLocalizableText(worker.lastSeen.getDateFromUnixTime())
        }

        setupTableValues(worker: worker, pool: pool)
    }

    fileprivate func setupTableValues(worker: PoolWorkerModel, pool: PoolAccountModel) {
        nameLabel.textColor = worker.isActive ? .workerGreen : .workerRed

        // Need to calculate and set table height manually
        var tableHeight: CGFloat = 0
        
        // Config referral, algorithm, monitor
        var header = [(String, String)]()
        
        if let difficulty = worker.difficulty { header.append(("diff", difficulty))}
        if let luck = worker.luck { header.append(("luck", luck + " " + "hr".localized()))}
        if let paid = worker.paid { header.append(("paid", paid))}
        if let balance = worker.balance { header.append(("balance", balance))}
        
        
        if let firsConnect = worker.firstConnection { header.append(("first_connection", firsConnect))}
        if let algorithm = worker.algorithm { header.append(("algorithm", algorithm)) }
        if worker.loadPer != -1 { header.append(("load", worker.loadPer.getFormatedString() + " %")) }
        if let luckPer = worker.luckStr { header.append(("luck", luckPer))}
        if let temperature = worker.temperature { header.append(("temperature", temperature)) }
        if let monitor = worker.monitor { header.append(("monitor", monitor)) }
        if let referral = worker.referral { header.append(("Referral", referral)) }
        
        if let participationPer = worker.participationStr { header.append(("participation", participationPer))}
        if let mode = worker.mode { header.append(("mode", mode))}
        if let workerId = worker.workerId { header.append(("worker_id", workerId)) }
        if let efficiency = worker.efficiencyStr { header.append(("efficiency", efficiency)) }
        if header.count > 0 {
            rows.append(header)
            tableHeight += CGFloat(header.count) * InfoTableCell.height + 5
        }

        // Config hashrate
        var hashrate = [(String, String)]()
        if let current = worker.currentHashrate?.toDouble()?.textFromHashrate(account: pool) { hashrate.append(("current", current)) } // For HsUnit
        if let average = worker.averageHashrate?.toDouble()?.textFromHashrate(account: pool) { hashrate.append(("average", average)) } // For HsUnit
        if let reported = worker.reportedHashrate?.toDouble()?.textFromHashrate(account: pool) { hashrate.append(("reported", reported)) } // For HsUnit
        if let real = worker.realHashrate?.toDouble()?.textFromHashrate(account: pool) { hashrate.append(("real", real)) } // For HsUnit

        if hashrate.count > 0 {
            sections.append("hashrate")
            rows.append(hashrate)

            tableHeight += WorkerSectionHeader.height
            tableHeight += CGFloat(hashrate.count) * InfoTableCell.height

            // Section footer height
            tableHeight += 10
        }

        // Config share
        var shares = [(String, String)]()
        if let valid = worker.validShares { shares.append(("valid", valid)) }
        if let invalid = worker.invalidShares { shares.append(("invalid", invalid)) }
        if let round = worker.roundShares { shares.append(("round", round)) }
        if let stale = worker.staleShares { shares.append(("stale", stale)) }
        if let stale = worker.expiredShares { shares.append(("expired", stale)) }

        if shares.count > 0 {
            sections.append("shares")
            rows.append(shares)

            tableHeight += WorkerSectionHeader.height
            tableHeight += CGFloat(shares.count) * InfoTableCell.height
            
            // Section footer height
            tableHeight += 5
        }

        // Config monitor
//        var monitorSection = [(String, String)]()
//        if let monitor = worker.monitor { monitorSection.append(("monitor", monitor)) }
//
//        if monitorSection.count > 0 {
//            sections.append("monitor")
//            rows.append(monitorSection)
//
//            tableHeight += WorkerSectionHeader.height
//            tableHeight += CGFloat(monitorSection.count) * InfoTableCell.height
//        }
//
        infoTableView.delegate = self
        infoTableView.dataSource = self

        infoTableView.removeConstraints(infoTableView.constraints)

        // Set table height constraint
        let heightConstraint = infoTableView.heightAnchor.constraint(equalToConstant: tableHeight)
        heightConstraint.identifier = "customHeight"
        heightConstraint.isActive = true

        DispatchQueue.main.async {
            self.infoTableView.reloadData()
        }
    }
}

// MARK: - TableView methods
extension WorkerTableCell: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return rows.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if rows.count > sections.count && section == 0 { return nil }
        let index = rows.count > sections.count ? section - 1 : section
        
        let header = WorkerSectionHeader(frame: .zero)
        header.setName(sections[index])
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return rows.count > sections.count && section == 0 ? 0 : WorkerSectionHeader.height
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[section].count
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return InfoTableCell.height
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InfoTableCell.name) as! InfoTableCell

        let item = rows[indexPath.section][indexPath.row]
        cell.setData(key: item.key, value: item.value)

        return cell
    }

    // Footer
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear

        let separator = UIView(frame: .zero)
        separator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(separator)

        separator.backgroundColor = .separator

        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        return view
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0.0
        }
        return section == rows.count - 1 ? 0 : 10
    }
}
