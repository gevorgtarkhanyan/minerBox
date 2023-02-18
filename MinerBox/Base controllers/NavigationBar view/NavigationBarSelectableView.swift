//
//  NavigationBarSelectableView.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 6/26/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

protocol NavigationBarSelectableViewDelegate: class {
    func indexSelected(_ index: Int)
}

class NavigationBarSelectableView: BarCustomView {

    // MARK: - Views
    fileprivate var stackView: UIStackView!

    fileprivate var selectedView: UIView!
    fileprivate var selectedViewCenterXConstraint: NSLayoutConstraint!

    fileprivate var buttons = [NavBarButton]()

    // MARK: - Properties
    weak var delegate: NavigationBarSelectableViewDelegate?

    fileprivate var selectedButton: NavBarButton!

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        awakeFromNib()
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
extension NavigationBarSelectableView {
    fileprivate func startupSetup() {
        setupUI()
    }
}

// MARK: - Setup UI
extension NavigationBarSelectableView {
    fileprivate func setupUI() {
        addStackForButtons()
    }

    fileprivate func addStackForButtons() {
        guard let superview = superview else { return }
        stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually

        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        var leftAnchor = superview.leftAnchor
        var rightAnchor = superview.rightAnchor
        if #available(iOS 11.0, *) {
            leftAnchor = superview.safeAreaLayoutGuide.leftAnchor
            rightAnchor = superview.safeAreaLayoutGuide.rightAnchor
        }
        stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
}

// MARK: - Set data
extension NavigationBarSelectableView {
    public func setBarItems(_ items: [String]) {
        guard items.count > 0 else { return }

        for i in items.indices {
            let button = NavBarButton(frame: .zero)
            button.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(button)

            button.tag = i
            button.backgroundColor = .clear
            button.setTitleColor(.white, for: .normal)
            button.setLocalizedTitle(items[i])
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)

            self.buttons.append(button)
        }

        addSelectionView()
    }
}

// MARK: - Actions
extension NavigationBarSelectableView {
    fileprivate func addSelectionView() {
        selectedView = UIView(frame: .zero)
        selectedView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selectedView)

        selectedView.clipsToBounds = true
        selectedView.backgroundColor = .barSelectedItem
        selectedView.layer.cornerRadius = layer.cornerRadius

        guard let firstButton = buttons.first else { return }
        selectedView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        selectedView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        selectedView.widthAnchor.constraint(equalTo: firstButton.widthAnchor).isActive = true

        selectedViewCenterXConstraint = selectedView.centerXAnchor.constraint(equalTo: firstButton.centerXAnchor)
        selectedViewCenterXConstraint.isActive = true

        selectedButton = firstButton
        selectedButton.isSelected = true
    }

    // MARK: UI actions
    @objc fileprivate func buttonAction(_ sender: NavBarButton) {
        standartAnimation(with: sender)
        selectedButton.isSelected = false
        selectedButton = sender
        selectedButton.isSelected = true

        delegate?.indexSelected(sender.tag)
    }
}

// MARK: - Animation
extension NavigationBarSelectableView {
    fileprivate func standartAnimation(with sender: BackgroundButton) {
        removeConstraint(selectedViewCenterXConstraint)
        UIView.animate(withDuration: Constants.animationDuration) {
            self.selectedViewCenterXConstraint = self.selectedView.centerXAnchor.constraint(equalTo: sender.centerXAnchor)
            self.selectedViewCenterXConstraint.isActive = true
            self.layoutIfNeeded()
        }
    }
}
