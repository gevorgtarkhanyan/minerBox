//
//  CoinFiatView.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 26.03.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//


import UIKit

protocol CoinFiatViewDelegate: class {
    func reverse(_ reversed: Bool)
}

class CoinFiatView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var gradientView: BaseView!
    
    @IBOutlet weak var firstLabel: BaseLabel!
    @IBOutlet weak var secondLabel: BaseLabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var separatorView: BaseView!
    
    static var height: CGFloat = 46 // must be more than 40px, the rest is distance from surrounding
    private var reversed = false
    
    weak var delegate: CoinFiatViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }

    // for the save page state
    public func setData(_ reversed: Bool) {
        self.reversed = reversed
        reverse()
    }
    
    public func addRotateAnimation() {
        let rotateAnim = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateAnim.fromValue = 0
        rotateAnim.toValue = 2 * CGFloat.pi
        rotateAnim.duration = 2
        rotateAnim.fillMode = .forwards
        rotateAnim.repeatCount = .infinity
        DispatchQueue.main.async {
            self.iconImageView.layer.add(rotateAnim, forKey: nil)
        }
    }

    private func addGestureToGradient() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(reverseCoinFiat))
        gradientView.addGestureRecognizer(tap)
    }
    
    @objc private func reverseCoinFiat() {
        reversed = !reversed
        reverse()
    }
    
    
    private func reverse() {
        delegate?.reverse(reversed)
        firstLabel.text = reversed ? "fiat".localized() : "coin_sort_coin".localized()
        secondLabel.text = !reversed ? "fiat".localized() : "coin_sort_coin".localized()
    }
    
    private func initialSetup() {
        firstLabel.text = "coin_sort_coin".localized()
        secondLabel.text = "fiat".localized()
    }
    
    
    private func commonInit() {
        Bundle.main.loadNibNamed("CoinFiatView", owner: self, options: nil)
        
        addSubview(contentView)
        self.layer.cornerRadius = 10
        firstLabel.text = reversed ? "fiat".localized() : "coin_sort_coin".localized()
        secondLabel.text = !reversed ? "fiat".localized() : "coin_sort_coin".localized()
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupColor()
        initialSetup()
        addRotateAnimation()
        addGestureToGradient()
    }
    
    private func setupColor() {
        backgroundColor = .barSelectedItem
        gradientView.backgroundColor = .clear
        separatorView.backgroundColor = .clear
        firstLabel.textColor = .white
        secondLabel.textColor = .white
    }
    
}
