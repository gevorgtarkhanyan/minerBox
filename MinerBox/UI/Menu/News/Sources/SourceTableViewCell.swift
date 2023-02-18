//
//  SourceTableViewCell.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 07.12.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

protocol SourceTableViewCellDelegate: AnyObject {
    func plusAction (indexPath: IndexPath)
    func minusAction (indexPath: IndexPath)

}

class SourceTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var sourceNameLabel: BaseLabel!
    @IBOutlet weak var plusMinus: UIButton!
    
    static var height: CGFloat = 44
    
    var indexPath: IndexPath?
    weak var delegate: SourceTableViewCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.plusMinus.removeTarget(self, action: #selector(plusAction), for: .touchUpInside)
        self.plusMinus.removeTarget(self, action: #selector(minusAction), for: .touchUpInside)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialSetup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func initialSetup() {
    
    }
    
    func setData(sourceName:String, indexPath: IndexPath , isAdded: Bool, isTitle: Bool) {
        
        self.indexPath = indexPath
        self.sourceNameLabel.setLocalizableText(sourceName)
        if isTitle {
            sourceNameLabel.changeFontSize(to: 18)
            sourceNameLabel.textColor = .barSelectedItem
            plusMinus.isHidden = true
        } else {
            sourceNameLabel.changeFontSize(to: 12)
            plusMinus.isHidden = false
            sourceNameLabel.textColor = darkMode ? .white : .textBlack
        }
        
        if isAdded {
            
            self.plusMinus.setImage(UIImage(named: "source_minus")?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.plusMinus.tintColor = darkMode ? .white : .black
            self.plusMinus.addTarget(self, action: #selector(minusAction), for: .touchUpInside)
            
        } else {
            
            self.plusMinus.setImage(UIImage(named: "source_plus")?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.plusMinus.tintColor = .barSelectedItem
            self.plusMinus.addTarget(self, action: #selector(plusAction), for: .touchUpInside)
        }
    }
    
    
    // MARK: - Delegate Methods-
    @objc func plusAction() {
        if let delegate = delegate, let indexPath = indexPath {
            delegate.plusAction(indexPath: indexPath)
        }
    }
    @objc func minusAction() {
        if let delegate = delegate, let indexPath = indexPath {
            delegate.minusAction(indexPath: indexPath)
        }
    }
}
