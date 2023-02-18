//
//  ComparisionButton.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/4/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

protocol ActionSheetButtonDelegate: AnyObject {
    func alertSelected(type: AccountAlertType)
    func comparisionSelected(type: AlertComparisionType)
    func hashrateTypesSelected(type: AddAccountHashrateTypes)
}

class ActionSheetButton: BackgroundButton {

    // MARK: Properties
    weak var delegate: ActionSheetButtonDelegate?

    fileprivate var controller: UIViewController?
    fileprivate var sheetType: ActionSheetTypeEnum = .comparision
    fileprivate var reportedHashrate:Bool = false
    // MARK: - Startup sefault setup
    override func startupSetup() {
        super.startupSetup()
        addComparisionTarget()
    }

    fileprivate func addComparisionTarget() {
        addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
    }
    public func reportedHashrate(Bool: Bool) {
        reportedHashrate = Bool
    }
}

// MARK: - Actions
extension ActionSheetButton {
    @objc fileprivate func buttonAction(_ sender: ActionSheetButton) {
        guard let viewController = controller else { return }

        let newVC = ActionSheetViewController()
        newVC.delegate = self
        newVC.reportedHashrate(Bool: reportedHashrate)
        newVC.setData(controller: viewController, type: sheetType)
        newVC.modalPresentationStyle = .overCurrentContext
        DispatchQueue.main.async {
            viewController.present(newVC, animated: false, completion: nil)
        }
    }
}

// MARK: - Public methods
extension ActionSheetButton {
    public func setData(controller: UIViewController, type: ActionSheetTypeEnum) {
        self.controller = controller
        self.sheetType = type
    }

    public func selectButton() {
        buttonAction(self)
    }
}

// MARK: - Comparision viewcontroller delegate
extension ActionSheetButton: ActionSheetViewControllerDelegate {
    func comparisionSelected(index: Int) {
        let type = AlertComparisionType.allCases[index]
        delegate?.comparisionSelected(type: type)
    }
    func hashrateTypesSelected(index: Int) {
        let type = AddAccountHashrateTypes.allCases[index]
        delegate?.hashrateTypesSelected(type: type)
    }

    func alertTypeSelected(index: Int) {
        let type = AccountAlertType.allCases[index]
        delegate?.alertSelected(type: type)
    }
}

// MARK: - Helpers
@objc enum ActionSheetTypeEnum: Int {
    case comparision
    case alert
    case addAlert
    case coinSort
    case coinPriceSort
    case coinChangeSort
    
    case payoutsType
    case payoutsCurrency
    case estimationsType
    case estimationsName
    case simple
}
