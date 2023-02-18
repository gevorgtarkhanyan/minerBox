//
//  SingleSortView.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 14.04.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation
import UIKit


// MARK: - Delegate
protocol SingleSortViewDelegate: AnyObject {
    func sortButtonSelected(_ sender: SortButton)
}

public var sortPreviewTag = 0

class SingleSortView: UIView {
    
    private var baseView: UIView!
    private var contentView: UIView!
    private var sortImageView: UIImageView!
    public var sortButton: SortButton!
    
    weak var delegate: SingleSortViewDelegate?
    
    private let screenSize = UIScreen.main.bounds
    private var sortImageViewFirstTapped = false
    
    // MARK: - Init
    init(frame: CGRect, tag: Int) {
        super.init(frame: frame)
        self.tag = tag
        awakeFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        addBaseView()
        backgroundColor = .clear
    }
    
    private func addBaseView() {
        baseView = UIView()
        baseView.translatesAutoresizingMaskIntoConstraints = false
        addContentView()
        addSubview(baseView)
        
        baseView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        baseView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        baseView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        baseView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }

    private func addContentView() {
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSortButton()
        baseView.addSubview(contentView)
        
        var width = 85
        switch screenSize.width {
        case 0...400:
            width = 80
        case 400...500:
            width = 85
        case 500...5000:
            width = 95
        default:
            width = 85
        }
        
        contentView.centerXAnchor.constraint(equalTo: baseView.centerXAnchor).isActive = true
        contentView.centerYAnchor.constraint(equalTo: baseView.centerYAnchor).isActive = true
        contentView.widthAnchor.constraint(equalToConstant: CGFloat(width)).isActive = true
        contentView.heightAnchor.constraint(equalTo: baseView.heightAnchor).isActive = true
    }
    
    private func addSortButton() {
        sortButton = SortButton(frame: .zero, tag: tag)
        sortButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sortButton)
        sortButton.tag = tag
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        sortButton.addGestureRecognizer(tap)
        
        if tag == 0 {
            sortButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        }
        sortButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        
        sortButton.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        sortButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    @objc fileprivate func tapAction(_ sender: UITapGestureRecognizer) {
        delegate?.sortButtonSelected(sortButton)
        sortPreviewTag = tag
    }
    
    
}
