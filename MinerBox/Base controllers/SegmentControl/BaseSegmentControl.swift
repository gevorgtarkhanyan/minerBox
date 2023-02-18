//
//  BaseSegmentControl.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/25/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

@objc protocol BaseSegmentControlDelegate: AnyObject {
    @objc optional func segmentSelected(index: Int)
    @objc optional func segmentSelected(_ sender: BaseSegmentControl, index: Int)
    @objc optional func segmentSelectedFirstTime(index: Int)
}

class BaseSegmentControl: UIView {

    // MARK: - Views
    private var stackView: UIStackView!

    private var selectedView: UIView!
    private var selectedViewCenterXConstraint: NSLayoutConstraint!

    private var buttons = [UIView]()
    private var badgeLabels = [BadgeLabel]()

    // MARK: - Properties
    weak var delegate: BaseSegmentControlDelegate?

    private var selectedButton: UIView!
    private var selectedCornerRadius: CGFloat?

    // MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
//        awakeFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
}

// MARK: - Setup UI
extension BaseSegmentControl {
    private func setupUI() {
        addStackForButtons()
        changeColors()

        clipsToBounds = true
        layer.cornerRadius = 9
    }

    private func addStackForButtons() {
        stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        stackView.spacing = 1
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        // rounded style time set segment tag 10
        let constant: CGFloat = tag == 10 ? 2 : 4
        
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: constant).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: constant).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -constant).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -constant).isActive = true
    }

    private func changeColors() {
        backgroundColor = .segmentBackground
    }
}

// MARK: - Set data
extension BaseSegmentControl {
    public func setSegments(_ segments: [String],_ isSecondSegmentView: Bool = false) {
        guard segments.count > 0 else { return }

        for i in segments.indices {
            let button = SegmentButton(frame: .zero)
            button.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(button)
            
            button.tag = i
            if isSecondSegmentView {button.tag = i + 2}
            button.setLocalizedTitle(segments[i])
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)

            self.buttons.append(button)

            if i != segments.indices.last {
                let separatorView = UIView(frame: .zero)
                separatorView.translatesAutoresizingMaskIntoConstraints = false
                insertSubview(separatorView, at: i)

                separatorView.backgroundColor = .separator

                separatorView.widthAnchor.constraint(equalToConstant: 1).isActive = true
                separatorView.leftAnchor.constraint(equalTo: button.rightAnchor).isActive = true
                separatorView.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
                separatorView.heightAnchor.constraint(equalTo: button.heightAnchor, multiplier: 0.5).isActive = true
            }
        }
        addBadges()
        addSelectionView()
    }

    // For account details
    //MARK: -With image
    public func setSegmentsWithImage(_ segments: [String]) {
        guard segments.count > 0 else { return }

        for i in segments.indices {
            let title = segments[i]

            let view = UIView(frame: .zero)
            view.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(view)
            view.tag = i

            self.buttons.append(view)

            // Add Tap recognizer
            let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapAction(_:)))
            view.addGestureRecognizer(tap)

            // Add image view
            let imageView = BaseImageView(frame: .zero)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(imageView)

            imageView.contentMode = .scaleAspectFit
            imageView.isUserInteractionEnabled = false
            imageView.image = UIImage(named: title)?.withRenderingMode(.alwaysTemplate)

            imageView.addEqualRatioConstraint()
            imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true

            // Add Label
            let label = BaseLabel(frame: .zero)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)

            label.textAlignment = .center
            label.setLocalizableText(title)
            label.isUserInteractionEnabled = false
            label.changeFontSize(to: 10)
            label.changeFont(to: Constants.semiboldFont)

            label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 2).isActive = true
            label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -2).isActive = true
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 2).isActive = true

            if i != segments.indices.last {
                let separatorView = UIView(frame: .zero)
                separatorView.translatesAutoresizingMaskIntoConstraints = false
                insertSubview(separatorView, at: i)

                separatorView.backgroundColor = .separator

                separatorView.widthAnchor.constraint(equalToConstant: 1).isActive = true
                separatorView.leftAnchor.constraint(equalTo: view.rightAnchor).isActive = true
                separatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
                separatorView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
            }
        }
        addSelectionView()
    }
    
    //MARK: -Rounded Spacing
    public func setRoundedSpacingSegment(_ segments: [String]) {
        guard segments.count > 0 else { return }

        backgroundColor = .clear
        stackView.spacing = 10
        selectedCornerRadius = (frame.height - 4) / 2
        
        for i in segments.indices {
            let title = segments[i]
            
            // Add Label
            let label = BaseLabel(frame: .zero)
            label.clipsToBounds = true
            label.textAlignment = .center
            label.isUserInteractionEnabled = true
            label.backgroundColor = .textFieldBackground
            label.tag = i
            
            label.setLocalizableText(title)
            label.changeFontSize(to: 10)
            label.changeFont(to: Constants.semiboldFont)
            
            stackView.addArrangedSubview(label)
            label.layer.cornerRadius = (frame.height - 8) / 2
            
            self.buttons.append(label)
            
            // Add Tap recognizer
            let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapAction(_:)))
            label.addGestureRecognizer(tap)
        }
        
        addSelectionView()
    }

    private func addBadges() {
        clipsToBounds = false
        guard let buttons = self.buttons as? [SegmentButton] else { return }
        for button in buttons {
            let badgeLabel = BadgeLabel(frame: .zero)
            badgeLabel.translatesAutoresizingMaskIntoConstraints = false
            badgeLabel.isHidden = true
            button.addSubview(badgeLabel)

            badgeLabels.append(badgeLabel)

            badgeLabel.topAnchor.constraint(equalTo: button.topAnchor, constant: -1).isActive = true
            badgeLabel.rightAnchor.constraint(equalTo: button.rightAnchor, constant: -3).isActive = true
        }
    }
    
    //MARK: -State
    public func setBadgeNumber(_ number: Int, for index: Int) {
        guard badgeLabels.indices.contains(index) else { return }
        badgeLabels[index].isHidden = false
        badgeLabels[index].setBadgeCount(number)
    }
    
    public func setSelectedIndex(with index: Int?) {
        if let index = index {
            selectSegment(index: index)
        } else {
            unselect()
        }
    }
    
    public func selectSegment(index: Int) {
        selectedAction(index)
        
        delegate?.segmentSelected?(index: selectedButton.tag)
        delegate?.segmentSelected?(self, index: selectedButton.tag)
    }
    
    public func selectSegmentFirstTime(index: Int) {
        selectedAction(index)
        
        delegate?.segmentSelectedFirstTime?(index: selectedButton.tag)
    }
    
    public func setEnabledIndexes(_ enabled: Bool, indexes: [Int]) {
        indexes.forEach { buttons[$0].isUserInteractionEnabled = enabled }
    }
    
    public func unselect() {
        selectedView?.isHidden = true
        self.stackView.subviews.forEach {
            $0.backgroundColor = .textFieldBackground
        }
    }
}

// MARK: - Actions
extension BaseSegmentControl {
    private func selectedAction(_ index: Int) {
        let button = buttons.first { $0.tag == index }
        guard let sender = button else { return }
        standartAnimation(with: sender)
        selectedButton = sender
    }
    
    private func addSelectionView() {
        selectedView = UIView(frame: .zero)
        selectedView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(selectedView, belowSubview: stackView)

        selectedView.clipsToBounds = true
        selectedView.backgroundColor = .barSelectedItem
        selectedView.layer.cornerRadius = selectedCornerRadius ?? layer.cornerRadius

        guard let firstButton = buttons.first else { return }
        selectedView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        selectedView.heightAnchor.constraint(equalTo: heightAnchor, constant: -4).isActive = true

        let widthAnch = selectedView.widthAnchor.constraint(equalTo: firstButton.widthAnchor, constant: 4)
        widthAnch.priority = .defaultHigh
        widthAnch.isActive = true

        selectedViewCenterXConstraint = selectedView.centerXAnchor.constraint(equalTo: firstButton.centerXAnchor)
        selectedViewCenterXConstraint.isActive = true

        selectedButton = firstButton
    }

    // MARK: UI actions
    @objc fileprivate func buttonAction(_ sender: UIView) {
        standartAnimation(with: sender)
        selectedButton = sender

        delegate?.segmentSelected?(index: sender.tag)
        delegate?.segmentSelected?(self, index: sender.tag)
    }

    @objc fileprivate func viewTapAction(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        buttonAction(view)
    }
    
}

// MARK: - Get data
extension BaseSegmentControl {
    public func getSelectedIndex() -> Int? {
        guard !selectedView.isHidden else { return nil }
        
        return selectedButton.tag
    }
}

// MARK: - Animation
extension BaseSegmentControl {
    private func standartAnimation(with sender: UIView) {
        removeConstraint(selectedViewCenterXConstraint)
        if selectedView.isHidden {
            selectedView.isHidden = false
            selectedViewCenterXConstraint = self.selectedView.centerXAnchor.constraint(equalTo: sender.centerXAnchor)
            selectedViewCenterXConstraint.isActive = true
            layoutIfNeeded()
        } else {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.selectedViewCenterXConstraint = self.selectedView.centerXAnchor.constraint(equalTo: sender.centerXAnchor)
                self.selectedViewCenterXConstraint.isActive = true
                self.layoutIfNeeded()
            }
        }
    }
}
