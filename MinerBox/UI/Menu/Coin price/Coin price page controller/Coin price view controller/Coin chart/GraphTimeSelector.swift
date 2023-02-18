//
//  GraphTimeSelector.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/15/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import Localize_Swift

protocol GraphTimeSelectorDelegate: AnyObject {
    func timeSelected(time: GraphTimeFilter)
}

class GraphTimeSelector: UIView {
    
    private var stackView: UIStackView!
    
    weak var delegate: GraphTimeSelectorDelegate?
    
    private let graphCases = GraphTimeFilter.allCases
    
    private var selectedButton: TimeSelectorButton?
    private var buttons: [TimeSelectorButton] = []
    private(set) var currentTime = GraphTimeFilter.day
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
    
    @objc public func startupSetup() {
        setupUI()
        changeColors()
        addObservers()
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeColors), name: Notification.Name(Constants.themeChanged), object: nil)
    }
    
    @objc public func changeColors() {
        backgroundColor = .clear
    }
    
    private func setupUI() {
        addStackView()
        addButtons()
    }
    
    private func addStackView() {
        stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    private func addButtons() {
        for (index, timeFilter) in graphCases.enumerated() {
            let button = TimeSelectorButton(frame: .zero)
            stackView.addArrangedSubview(button)
            
            buttons.append(button)
            button.tag = index
            button.setLocalizedTitle(timeFilter.rawValue)
            button.changeFontSize(to: 12)
            button.changeFont(to: Constants.semiboldFont)
            
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func buttonAction(_ sender: TimeSelectorButton) {
        guard graphCases.indices.contains(sender.tag), selectedButton != sender else { return }
        selectedButton?.setSelected(selected: false)
        selectedButton = sender
        selectedButton?.setSelected(selected: true)
        currentTime = graphCases[sender.tag]
        delegate?.timeSelected(time: currentTime)
    }
    
    public func selectTime(_ time: GraphTimeFilter) {
        let index = graphCases.firstIndex { $0 == time }
        buttonAction(buttons[index ?? 0])
    }
    
}

enum GraphTimeFilter: String, CaseIterable {
    case day = "24h"
    case week = "1w"
    case month = "1m"
    case treeMonth = "3m"
    case sixMonth = "6m"
    case year = "1y"
    case all = "all"
}
