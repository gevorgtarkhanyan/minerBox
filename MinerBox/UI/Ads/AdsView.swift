//
//  AdsViewController.swift
//  MinerBox
//
//  Created by Vazgen Hovakinyan on 16.03.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation
import UIKit
import Localize_Swift


class AdsView: UIView {
    
    //MARK: - IBOutlet -
    
    @IBOutlet weak var currentAdsView: BaseView!
    @IBOutlet weak var adsLogoImage: UIImageView!
    @IBOutlet weak var title: BaseLabel!
    @IBOutlet weak var cancelButtonLabbel: UIButton!
    @IBOutlet weak var adsShortDesc: BaseLabel!
    @IBOutlet weak var joinNowButtonTint: UIButton!
    @IBOutlet weak var sponsored: BaseLabel!
    var url = ""

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()

        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("AdsView", owner: self, options: nil)
        addSubview(currentAdsView)
        currentAdsView.frame = bounds
        currentAdsView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        currentAdsView.backgroundColor = darkMode ? .viewDarkBackground : .sectionHeaderLight
        currentAdsView.roundCorners([.topLeft, .topRight,.bottomLeft,.bottomRight], radius: 10)
        title.textColor =  darkMode ? .white : UIColor.black.withAlphaComponent(0.85)
        cancelButtonLabbel.imageView?.tintColor = .cellTrailingFirst
        adsShortDesc.textColor =  darkMode ? .white : UIColor.black.withAlphaComponent(0.85)
        joinNowButtonTint.tintColor = .cellTrailingFirst
        sponsored.textColor =  darkMode ? .grayButton : UIColor.black.withAlphaComponent(0.85)
        sponsored.setLocalizableText("Sponsored")
    }
}

