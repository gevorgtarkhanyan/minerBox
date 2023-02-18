//
//  DetailsHeaderView.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/25/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

protocol DetailsHeaderViewDelegate: AnyObject {
    func sectionSelected(type: DetailsTableSectionEnum)
    func alertButtonSelected(type: DetailsTableSectionEnum)
}

class DetailsHeaderView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var alertButton: UIButton!
    @IBOutlet weak var imageParentView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: BaseLabel!
    
    static var height: CGFloat = 36
    private var expandable = false
    private var sectionType: DetailsTableSectionEnum = .hashrate
    weak var delegate: DetailsHeaderViewDelegate?
    
    override init(frame: CGRect) {
           super.init(frame: frame)
           commonInit()
       }
       
       required init?(coder: NSCoder) {
           super.init(coder: coder)
           commonInit()
       }
       
       private func commonInit() {
        Bundle.main.loadNibNamed("DetailsHeaderView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        initialSetup()
        addGesture()
       }
    
    func initialSetup() {
        contentView.backgroundColor = .detailsSectionHeader
        contentView.layer.cornerRadius = CGFloat(10)
        
        imageParentView.layer.cornerRadius = CGFloat(5)
        titleLabel.font = Constants.semiboldFont.withSize(17)
    }
    
    func addGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
        contentView.addGestureRecognizer(tap)
    }
    
    func setData(sectionType: DetailsTableSectionEnum, expandable: Bool) {
        self.sectionType = sectionType
        titleLabel.setLocalizableText(sectionType.rawValue)

        self.expandable = expandable
        arrowImageView.isHidden = !expandable
        iconImageView.image = UIImage(named: "details_" + sectionType.rawValue)
        alertButton.isHidden = sectionType != .hashrate && sectionType != .workers && sectionType != .groupWorker
    }
    
    @IBAction func alertButtonTapped() {
        delegate?.alertButtonSelected(type: sectionType)
    }
    
    @objc func headerTapped() {
        if expandable {
            delegate?.sectionSelected(type: sectionType)
        }
    }
    
}
