//
//  TableView_Animation.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/25/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import FirebaseCrashlytics

extension UITableView {

    enum ScrollsTo {
        case top, bottom
    }
    
    //MARK: - animation
    func animate(duration: TimeInterval = 0.5,
                 delay: TimeInterval = 0.7,
                 deltaDelay: TimeInterval = 0.08,
                 springWithDamping: CGFloat = 0.7,
                 springVelocity: CGFloat = 0) {
        
        var changeAbleDelay: TimeInterval = delay
        self.reloadData()
        let cells = self.visibleCells
        
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: cell.transform.ty + 100).scaledBy(x: 1.3, y: 1.3)
            cell.alpha = 0
        }
        
        for cell in cells {
            UIView.animate(withDuration: duration,
                           delay: changeAbleDelay * deltaDelay,
                           usingSpringWithDamping: springWithDamping,
                           initialSpringVelocity: springVelocity,
                           options: .curveEaseInOut,
                           animations: {
                            cell.transform = CGAffineTransform(translationX: 0, y: 0).scaledBy(x: 1, y: 1)
                            cell.alpha = 1
            },
                           completion: nil)
            
            changeAbleDelay += 1
        }
    }
    
    //MARK: - Scrolling
    func scroll(to: ScrollsTo, animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            let numberOfSections = self.numberOfSections
            let numberOfRows = self.numberOfRows(inSection: numberOfSections - 1)
            guard numberOfRows > 0 else { return }
            
            switch to {
            case .top:
                let indexPath = IndexPath(row: 0, section: 0)
                self.scrollToRowSafely(at: indexPath, at: .top, animated: animated)
            case .bottom:
                let indexPath = IndexPath(row: numberOfRows - 1, section: (numberOfSections - 1))
                self.scrollToRowSafely(at: indexPath, at: .bottom, animated: animated)
            }
        }
    }
    
    func scrollToRowSafely(at indexPath: IndexPath, at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        Crashlytics.crashlytics().setCustomValue(indexPathExists(with: indexPath), forKey: "indexPathExists")
//        guard indexPathExists(with: indexPath) else { return }
//        self.scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
//
        let exist = self.numberOfSections > indexPath.section && self.numberOfRows(inSection: indexPath.section) > indexPath.row
        Crashlytics.crashlytics().setCustomValue(exist, forKey: "exist")
        if exist {
            self.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    //for the safe scrolling
    private func indexPathExists(with indexPath: IndexPath) -> Bool {
        if indexPath.section >= self.numberOfSections {
            return false
        }
        if indexPath.row >= self.numberOfRows(inSection: indexPath.section) {
            return false
        }
        return true
    }
    
    func reloadDataScrollUp() {
        reloadData()
        scroll(to: .top, animated: false)
    }
    
}
