//
//  GroupWorkersTableHeader.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/5/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class GroupWorkersTableHeader: BaseView {

    // MARK: - Views
    fileprivate var stackView: UIStackView!

    fileprivate var nameLabel: BaseLabel!
    fileprivate var arrowImageView: BaseImageView!

    fileprivate var bottomStackView: UIStackView!

    fileprivate var workersLabel: BaseLabel!
    fileprivate var hashrateLabel: BaseLabel!
    fileprivate var staleSharesLabel: BaseLabel!

    // MARK: - Static
    static var height: CGFloat = 60

    // MARK: - Startup
    override func startupSetup() {
        super.startupSetup()
        setupUI()
    }
}

// MARK: - Setup UI
extension GroupWorkersTableHeader {
    fileprivate func setupUI() {
        addStackView()
        addNameAndArrow()
        addBottomStackView()
        addLabels()

        clipsToBounds = true
        layer.cornerRadius = 10
    }

    fileprivate func addStackView() {
        // Add stackView
        stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        stackView.spacing = 10
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually

        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
    }

    fileprivate func addNameAndArrow() {
        // Add stack
        let topStack = UIStackView(frame: .zero)
        topStack.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(topStack)

        topStack.axis = .horizontal
        topStack.alignment = .fill
        topStack.distribution = .equalSpacing

        // Add name label
        nameLabel = BaseLabel(frame: .zero)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        topStack.addArrangedSubview(nameLabel)

        nameLabel.changeFont(to: Constants.semiboldFont)
        nameLabel.changeFontSize(to: 15)

        // Add arrowImageView
        arrowImageView = BaseImageView(frame: .zero)
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        topStack.addArrangedSubview(arrowImageView)

        arrowImageView.changeColors()
        arrowImageView.image = UIImage(named: "collapse-arrow-Down")?.withRenderingMode(.alwaysTemplate)

        arrowImageView.addEqualRatioConstraint()
    }

    fileprivate func addBottomStackView() {
        bottomStackView = UIStackView(frame: .zero)
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(bottomStackView)

        bottomStackView.axis = .horizontal
        bottomStackView.alignment = .fill
        bottomStackView.distribution = .fillEqually
    }

    fileprivate func addLabels() {
        // Add hashrate label
        hashrateLabel = BaseLabel(frame: .zero)
        hashrateLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.addArrangedSubview(hashrateLabel)

        hashrateLabel.textAlignment = .left
        hashrateLabel.changeFontSize(to: 15)

        // Add worker count label
        workersLabel = BaseLabel(frame: .zero)
        workersLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.addArrangedSubview(workersLabel)

        workersLabel.textAlignment = .center
        workersLabel.changeFontSize(to: 15)

        // Add stale shares label
        staleSharesLabel = BaseLabel(frame: .zero)
        staleSharesLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.addArrangedSubview(staleSharesLabel)

        staleSharesLabel.textAlignment = .right
        staleSharesLabel.changeFontSize(to: 15)
    }
}

// MARK: - Set data
extension GroupWorkersTableHeader {
    public func setGroupData(group: WorkerGroup, account: PoolAccountModel) {
        nameLabel.setLocalizableText(group.groupName)
        
        hashrateLabel.setLocalizableText(group.currentHashrate.textFromHashrate(account: account))
        workersLabel.setLocalizableText("\(group.activeWorkers)/\(group.allWorkers)")
        
        arrowImageView.isHidden = group.workers.count == 0
        
        if group.staleSharesPer != -1.0 {
            staleSharesLabel.setLocalizableText(group.staleSharesPer.getString() + "%")
        }
    }
    
    public func rotateArrow(angle: CGFloat) {
        guard arrowImageView.transform != CGAffineTransform(rotationAngle: angle) else { return }
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.arrowImageView.transform = CGAffineTransform(rotationAngle: angle)
            }
        }
    }
}
