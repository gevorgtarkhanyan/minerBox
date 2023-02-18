//
//  SortButton.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/26/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

//protocol SortButtonDelegate: class {
//    func sortButtonSelected(_ sender: SortButton)
//}
protocol SortButtonDelegate: AnyObject {
    func sortIconTapped(_ sender: SortButton, type: CoinSortEnum, sortIconFirstTapped: Bool)
}

class SortButton: UIView {
    
    // MARK: - Views
    fileprivate var centerView: UIView!
    fileprivate var titleLabel: BaseLabel!
    fileprivate var imageView: BaseImageView!
    fileprivate var sortImageView: BaseImageView!
    fileprivate var imageLeftConstraint: NSLayoutConstraint!
    fileprivate var imageWidthConstraint: NSLayoutConstraint!
    fileprivate var titleLabelLeadingConstraint: NSLayoutConstraint!
    fileprivate var sortImageViewFirstTapped = false
    fileprivate let imageParentView = UIView()
    // MARK: - Properties
    weak var delegate: SortButtonDelegate?
    
    fileprivate(set) var state: SortButtonStatusEnum = .none
    
    // MARK: - Init
    init(frame: CGRect,tag: Int) {
        super.init(frame: frame)
        self.tag = tag
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
}

// MARK: - Startup default setup
extension SortButton {
    fileprivate func startupSetup() {
        setupUI()
        if tag != 0 {
            addSortImageView()
        }
        //        addGestureRecognizers()
    }
    
    //    fileprivate func addGestureRecognizers() {
    //        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
    //        addGestureRecognizer(tap)
    //    }
}

// MARK: - Setup UI
extension SortButton {
    fileprivate func setupUI() {
        addCenterView()
        addTitleLabel()
        addArrowImageView()
    }
    
    fileprivate func addCenterView() {
        centerView = UIView(frame: .zero)
        centerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(centerView)
        
        centerView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        centerView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        centerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        centerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    fileprivate func addTitleLabel() {
        titleLabel = BaseLabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        centerView.addSubview(titleLabel)
        
        titleLabel.changeFontSize(to: 14)
        titleLabel.textAlignment = .center
        titleLabel.isUserInteractionEnabled = false
        
        titleLabel.topAnchor.constraint(equalTo: centerView.topAnchor).isActive = true
        titleLabelLeadingConstraint =  titleLabel.leftAnchor.constraint(equalTo: centerView.leftAnchor, constant: 20)
        titleLabelLeadingConstraint.isActive = true
        titleLabelLeadingConstraint.constant = state == .none ? 30 : 0
        titleLabel.bottomAnchor.constraint(equalTo: centerView.bottomAnchor).isActive = true
        //        titleLabel.centerYAnchor.constraint(equalTo: centerView.centerYAnchor).isActive = true
    }
    
    fileprivate func addArrowImageView() {
        imageView = BaseImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        centerView.addSubview(imageView)
        
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        imageView.image = UIImage(named: "arrow_up")?.withRenderingMode(.alwaysTemplate)
        
        imageView.addEqualRatioConstraint()
        imageView.rightAnchor.constraint(equalTo: centerView.rightAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: centerView.centerYAnchor).isActive = true
        
        imageLeftConstraint = imageView.leftAnchor.constraint(equalTo: titleLabel.rightAnchor)
        imageLeftConstraint.isActive = true
        
        imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 0)
        imageWidthConstraint.isActive = true
    }
    
    private func addSortImageView() {
        
        sortImageView = BaseImageView(frame: .zero)
        imageParentView.translatesAutoresizingMaskIntoConstraints = false
        sortImageView.translatesAutoresizingMaskIntoConstraints = false
        sortImageView.isUserInteractionEnabled = true
        imageParentView.addSubview(sortImageView)
        addSubview(imageParentView)
        
        imageParentView.tag = tag
        sortImageView.image = UIImage(named: "filter_icon_sort")
        sortImageView.contentMode = .scaleToFill
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapSortIcon(gesture:)))
        imageParentView.addGestureRecognizer(tap)
        
        imageParentView.trailingAnchor.constraint(equalTo: centerView.trailingAnchor).isActive = true
        if tag != 3 {
            imageParentView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5).isActive = true
        } else {
            imageParentView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 0).isActive = true
        }
        imageParentView.topAnchor.constraint(equalTo: centerView.topAnchor).isActive = true
        imageParentView.bottomAnchor.constraint(equalTo: centerView.bottomAnchor).isActive = true
        imageParentView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        
        sortImageView.centerXAnchor.constraint(equalTo: imageParentView.centerXAnchor).isActive = true
        sortImageView.centerYAnchor.constraint(equalTo: imageParentView.centerYAnchor).isActive = true
        sortImageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        sortImageView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        sortImageView.isHidden = true
    }
    
    @objc func tapSortIcon(gesture: UITapGestureRecognizer) {
        guard let sender = gesture.view, CoinSortEnum.allCases.indices.contains(sender.tag) else { return }
        sortImageViewFirstTapped = sortPreviewTag == tag
        delegate?.sortIconTapped(self, type: CoinSortEnum.getSegmentCases()[sender.tag], sortIconFirstTapped: sortImageViewFirstTapped)
        sortPreviewTag = tag
    }
    
}

// MARK: - Actions
extension SortButton {
    public func setTitle(_ title: String) {
        titleLabel.setLocalizableText(title)
    }
    
    public func changeState(to state: SortButtonStatusEnum) {
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.imageLeftConstraint.constant = (state == .none) ? 0 : 10
            self.imageWidthConstraint.constant = (state == .none) ? 0 : 10
            self.sortImageView?.isHidden = state == .none ? true : false
            if self.tag != 1 {
                self.titleLabelLeadingConstraint.constant = state == .none ? 10 : 0
            } else {
                self.titleLabelLeadingConstraint.constant = state == .none ? 25 : 0
            }
            
            self.imageView.alpha = (state == .none) ? 0 : 1
            self.layoutIfNeeded()
        })
        
        if state == .highToLow {
            rotateArrow()
        } else {
            imageView.transform = .identity
        }
        
        self.state = state
        layoutIfNeeded()
    }
    
    public func changeState() {
        state = (state == .lowToHigh) ? .highToLow : .lowToHigh
        rotateArrow()
    }
    
    //    @objc fileprivate func tapAction(_ sender: UITapGestureRecognizer) {
    //        delegate?.sortButtonSelected(self)
    //    }
}

// MARK: - Animations
extension SortButton {
    fileprivate func rotateArrow() {
        let angle: CGFloat = (imageView.transform == CGAffineTransform(rotationAngle: 0)) ? .pi : 0
        
        UIView.animate(withDuration: Constants.animationDuration) {
            self.imageView.transform = CGAffineTransform(rotationAngle: angle)
        }
    }
}


// MARK: - Enum
enum SortButtonStatusEnum {
    case none
    case lowToHigh
    case highToLow
}
