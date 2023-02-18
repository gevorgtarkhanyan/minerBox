//
//  SettingsGraphButton.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/16/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

protocol SettingsGraphButtonDelegate: class {
    func graphButtonSelected(_ sender: SettingsGraphButton)
}

class SettingsGraphButton: UIView {

    // MARK: - Views
    fileprivate var titleLabel: SettingsGraphLabel!
    fileprivate var imageView: BaseImageView!

    // MARK: - Propertis
    weak var delegate: SettingsGraphButtonDelegate?

    fileprivate(set) var isSelected: Bool = false

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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Startup sefault setup
extension SettingsGraphButton {
    @objc public func startupSetup() {
        setupUI()
        changeColors()
        addObservers()
        addGestureRecognizers()
    }

    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeColors), name: Notification.Name(Constants.themeChanged), object: nil)
    }

    @objc public func changeColors() {
        backgroundColor = .clear
        if isSelected {
            imageView.tintColor = .barSelectedItem
            titleLabel.textColor = .barSelectedItem
        } else {
            imageView.tintColor = darkMode ? .white : .textBlack
            titleLabel.textColor = darkMode ? .white : .textBlack
        }
    }

    fileprivate func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        addGestureRecognizer(tap)
    }
}

// MARK: - Setup UI
extension SettingsGraphButton {
    fileprivate func setupUI() {
        addLabel()
        addImageView()
    }

    fileprivate func addLabel() {
        titleLabel = SettingsGraphLabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        titleLabel.changeFontSize(to: 10)
        titleLabel.isUserInteractionEnabled = false
        titleLabel.textAlignment = .center

        titleLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    fileprivate func addImageView() {
        let imageBackground = UIView(frame: .zero)
        imageBackground.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageBackground)

        imageBackground.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageBackground.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        imageBackground.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        imageBackground.bottomAnchor.constraint(equalTo: titleLabel.topAnchor).isActive = true

        imageView = BaseImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageBackground.addSubview(imageView)

        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false

        imageView.addEqualRatioConstraint()
        imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        imageView.centerXAnchor.constraint(equalTo: imageBackground.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: imageBackground.centerYAnchor).isActive = true
    }
}

// MARK: - Actions
extension SettingsGraphButton {
    @objc fileprivate func tapped(_ sender: UITapGestureRecognizer) {
        delegate?.graphButtonSelected(self)
    }
}

// MARK: - Public methods
extension SettingsGraphButton {
    public func setSelected(_ selected: Bool) {
        self.isSelected = selected
        changeColors()
    }

    public func setImage(_ image: UIImage?) {
        imageView.image = image?.withRenderingMode(.alwaysTemplate)
    }

    public func setTitle(_ title: String) {
        titleLabel.setLocalizableText(title)
    }
}

// MARK: - Helpers
fileprivate class SettingsGraphLabel: BaseLabel {
    override func changeColors() { }
}
