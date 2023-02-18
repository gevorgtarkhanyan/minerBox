//
//  CoinPriceSort.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/25/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

// MARK: - Delegate
protocol CoinPriceSortDelegate: AnyObject {
    func changeSort(with sort: CoinSortModel)
    func sortIconTapped(_ sender: SortButton, type: CoinSortEnum, sortIconFirstTapped: Bool)
}

class CoinPriceSort: UIView {

    // MARK: - Views
    fileprivate var stackView: UIStackView!
    fileprivate var buttons = [SortButton]()
    fileprivate var selectedButton: SortButton!

    // MARK: - Priperties
    weak var delegate: CoinPriceSortDelegate?
    fileprivate var changeType = CoinSortEnum.change1h

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Awake from NIB
    override func awakeFromNib() {
        super.awakeFromNib()
        startupSetup()
    }
}

// MARK: - Startup default setup
extension CoinPriceSort {
    fileprivate func startupSetup() {
        setupUI()
    }
}

// MARK: - Setup UI
extension CoinPriceSort {
    fileprivate func setupUI() {
        addStack()
        addSingleSortViews()

        backgroundColor = .clear
    }

    fileprivate func addStack() {
        stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fill

        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    fileprivate func addSingleSortViews() {
        let cases = CoinSortEnum.getSegmentCases()
        var singleSortViews = [SingleSortView]()
        
        for i in cases.indices {
            let item = cases[i]
            
            let singleSortView = SingleSortView(frame: .zero, tag: i)
            singleSortView.delegate = self
            singleSortView.translatesAutoresizingMaskIntoConstraints = false
            
            singleSortView.tag = i
//            singleSortView.sortButton.delegate = self
            singleSortView.sortButton.setTitle(item.rawValue)
            
            stackView.addArrangedSubview(singleSortView)
            singleSortViews.append(singleSortView)
            buttons.append(singleSortView.sortButton)
        }
        
        // TODO: Fix this
        singleSortViews[0].widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.2).isActive = true
        singleSortViews[1].widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.25).isActive = true
        singleSortViews[2].widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.3).isActive = true
        singleSortViews[3].widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.25).isActive = true
        
        guard let first = buttons.first else { return }
        sortButtonSelected(first)
    }
    
    // MARK: - Update UI
    private func changeSelctedButton(with newButton: SortButton, at state: SortButtonStatusEnum) {
        selectedButton?.changeState(to: .none)
        selectedButton = newButton
        selectedButton.changeState(to: state)
    }

}

// MARK: - Actions
extension CoinPriceSort: SingleSortViewDelegate,SortButtonDelegate {
    func sortButtonSelected(_ sender: SortButton) {
        guard CoinSortEnum.allCases.indices.contains(sender.tag) else { return }
        var sortType = CoinSortEnum.allCases[sender.tag]
        sender.delegate = self
        if sortType == .change {
            sortType = changeType
        }

        if sender == selectedButton {
            selectedButton.changeState()
        } else {
            changeSelctedButton(with: sender, at: .lowToHigh)
        }
        let sort = CoinSortModel(type: sortType, lowToHigh: selectedButton.state == .lowToHigh)
        delegate?.changeSort(with: sort)
    }
    
    func sortIconTapped(_ sender: SortButton, type: CoinSortEnum, sortIconFirstTapped: Bool) {
        if selectedButton !== buttons[type.getIndex()] {
            sortButtonSelected(buttons[type.getIndex()])
        }
        delegate?.sortIconTapped(sender, type: type, sortIconFirstTapped: sortIconFirstTapped)
    }
    
}


// MARK: - Public methods
extension CoinPriceSort {
    public func getCurrentSortState() -> CoinSortModel {
        var sort = CoinSortModel(type: .rank, lowToHigh: true)
        guard let button = selectedButton else { return sort }
        
        sort = CoinSortModel(type: CoinSortEnum.allCases[button.tag], lowToHigh: button.state == .lowToHigh)
        return sort
    }

    public func setChangeType(_ type: CoinSortEnum) {
        changeType = type
        let sort = CoinSortModel(type: type, lowToHigh: selectedButton.state == .lowToHigh)
        delegate?.changeSort(with: sort)
    }
    
    public func setSelectedButtonState(with sort: CoinSortModel) {
        let button = buttons[sort.type.getIndex()]
        let state: SortButtonStatusEnum = sort.lowToHigh ? .lowToHigh : .highToLow
        changeSelctedButton(with: button, at: state)
    }
    
}

