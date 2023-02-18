//
//  MainConvertibleHeaderView.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/21/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class MainConvertibleHeaderView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var criptoNameLabel: BaseLabel!
    @IBOutlet weak var criptoSymbolLabel: BaseLabel!
    @IBOutlet weak var criptoImageView: UIImageView!
    @IBOutlet weak var imageParentView: UIView!
    @IBOutlet weak var bordorBottomView: UIView!
    @IBOutlet weak var imageLeadingConstraint: NSLayoutConstraint!
    
    private var reversed = false
    
    static var height: CGFloat {
        return 50
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        let screenSize = UIScreen.main.bounds
//        let screenWidth = screenSize.width
//        if reversed {
//            let selfViewsWith = imageParentView.frame.width + 10 + criptoNameLabel.frame.width
//            if UIDevice.current.orientation.isLandscape {
//                imageLeadingConstraint.constant = (screenWidth / 2) - (selfViewsWith / 2)
//            } else {
//                imageLeadingConstraint.constant = (screenWidth / 2) - (selfViewsWith / 2)
//            }
//        }
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("MainConvertibleHeaderView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.backgroundColor = .tableCellBackground
        imageParentView.layer.cornerRadius = CGFloat(5)
        bordorBottomView.backgroundColor = .separator
    }
    
    public func setData(_ data: CoinModel) {
        let coinData = MainHeaderDataSource.headerModel(data)
        
        criptoImageView.sd_setImage(with: URL(string: coinData.headerImageName), completed: nil)
        criptoNameLabel.text = coinData.headerName
        criptoSymbolLabel.text = coinData.headerSymbol
        reversed = false
    }
    
    public func setData(_ fiatData: FiatModel) {
        criptoImageView.sd_setImage(with: URL(string: fiatData.flag), completed: nil)
        criptoNameLabel.text = fiatData.currency
        criptoSymbolLabel.isHidden = true
        reversed = true
    }
    
    func animateImageScale() {
        let pulseAnim = CASpringAnimation(keyPath: "transform.scale")
        pulseAnim.duration = 2
        pulseAnim.fromValue = 1.0
        pulseAnim.toValue = 1.12
        pulseAnim.autoreverses = true
        pulseAnim.repeatCount = .infinity
        pulseAnim.initialVelocity = 0.5
        pulseAnim.damping = 0.8

        criptoImageView.layer.add(pulseAnim, forKey: nil)
    }
    
    func removeScaleAnimation() {
        criptoImageView.layer.removeAllAnimations()
    }
      
}
