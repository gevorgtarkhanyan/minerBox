//
//  AdsManager.swift
//  MinerBox
//
//  Created by Vazgen Hovakinyan on 25.03.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation


import Foundation
import RealmSwift
import UIKit




class AdsManager {
    
    
    static let shared = AdsManager()

    private var adsViewForAccount = AdsView()

    func checkUser() {
        if let user = user {
            guard !user.isSubscribted else { return }
        }
        self.getAds()
    }
   
    func getAds() {
        AdsRequestService.shared.getAdsList { [self] (ads) in
            
            self.adsViewForAccount.title.text = ads.title
            self.adsViewForAccount.adsShortDesc.text = ads.shortDesc
            self.adsViewForAccount.adsLogoImage.sd_setImage(with:URL(string: "\(ads.thumbnail)"), completed: nil)
            self.adsViewForAccount.joinNowButtonTint.setTitle(ads.btnName,for: .normal)
            self.adsViewForAccount.cancelButtonLabbel.addTarget(self, action: #selector(selectCancelButton), for: .touchUpInside)
            self.adsViewForAccount.url = ads.url
            self.adsViewForAccount.joinNowButtonTint.addTarget(self, action: #selector(goToURLAds), for: .touchUpInside)
            AdsRequestService.shared.postForInpression(url: ads.impressionUrl)
        //    self.setupAds()
            
        } failer: { (err) in
            print(err)
        }
    }
    
    @objc func selectCancelButton() {
         goToSubscriptionPage()
     }
     @objc func goToURLAds() {
        
         openURL(urlString: adsViewForAccount.url)
      }
}
