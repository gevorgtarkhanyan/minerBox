//
//  AdsManager.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 03.08.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import Foundation
import UIKit

class AdsManager: NSObject {
    
    static let shared = AdsManager()
    
    // MARK: - Init
    fileprivate override init() {
        super.init()
    }
    
    private var adsView = AdsView()
    private var allActiveZones = ZoneIdsManager.shared.getAdsZoneFromDirectory()
    private var adsTrack: Bool = false
    private var ads = AdsModel()
    private var providerId = ""
    private var isAdsTableView = false
    private var selectedZone: ActiveZoneModel?
    private var native: Bool = true
    
    public var user: UserModel? {
        return DatabaseManager.shared.currentUser
    }
    
    func checkUserForAds(zoneName: ZoneName,isAdsTableView: Bool = false,success: @escaping(AdsView) -> Void) {
        
        self.allActiveZones = ZoneIdsManager.shared.getAdsZoneFromDirectory()
        self.isAdsTableView = isAdsTableView
        
        let isZoneListNeedUpdate = TimerManager.shared.isLoadingTime(item: .zoneList)
        
        if isZoneListNeedUpdate {
            AdsRequestService.shared.getZoneList {
                debugPrint("Ads List is update")
            } failer: { err in
                debugPrint(err)
            }
        }
 
        guard allActiveZones.contains(where: {$0.zoneName == zoneName.rawValue}) else { return }
        
        self.selectedZone = allActiveZones.filter({$0.zoneName == zoneName.rawValue}).first!
        
        if let user = self.user, user.isSubscribted {
            //Remove Ads Switch check
            guard !UserDefaults.standard.bool(forKey: "removeAds\(user.id)") else {
                adsView.isHidden = true
                return
            }
            let isShowAds = TimerManager.shared.isLoadingTime(item: .adsHide, duration: selectedZone!.hideDuration, additionalKey: selectedZone!.zoneName, updateTime: false)
            guard isShowAds else { return }
        }
        
        self.getAdsFromServer { adsView in
            success(adsView)
        }
    }
    
    func getAdsFromServer(success: @escaping(AdsView) -> Void) {
        AdsRequestService.shared.getAdsFromServer (success: { [weak self] (adsJson) in
            
            guard let self = self else { return }
            
            self.providerId =  adsJson.value(forKey: "providerId") as? String ?? ""
            self.adsTrack = adsJson.value(forKey: "track") as? Bool ?? false
            self.native = adsJson.value(forKey: "native") as? Bool ?? true
            let zoneForImpression =  adsJson.value(forKey: "zone") as? String ?? ""
            
            guard self.native else {
                let redirectParam = adsJson.value(forKey: "redirectParam") as? String ?? ""
                let providerName = adsJson.value(forKey: "providerName") as? String ?? ""
                
                if providerName == AdsProviders.coinzilla.rawValue {
                    self.getAdsFromCoinzila(success: { ads in
                        success(self.configAds(ads: ads, providerName: providerName, zoneForImpression: zoneForImpression))
                    }, endpoint: redirectParam)
                }
                return
            }
            
            if let adsJson =  adsJson.value(forKey: "ad") as? NSDictionary {
                self.ads = AdsModel(jsonFromServer: adsJson)
            }
            success(self.configAds(ads: self.ads, zoneForImpression: zoneForImpression))
            
        }, zoneName: self.selectedZone!.zoneName ) { (err) in
            print(err)
        }
    }
    
    func getAdsFromCoinzila(success: @escaping(AdsModel) -> Void, endpoint: String) {
        AdsRequestService.shared.getAdsFromCoinzila (success: { (ads) in
            success(ads)
        }, endpoint: endpoint) { (err) in
            print(err)
        }
    }
    
    func configAds(ads: AdsModel, providerName: String = "", zoneForImpression: String ) ->  AdsView {
        
        self.adsView.title.setLocalizableText(ads.title)
        
        if ads.shortDesc == "" {
            self.adsView.adsShortDesc.setLocalizableText(ads.descript)
        } else {
            self.adsView.adsShortDesc.setLocalizableText(ads.shortDesc)
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if ads.descript != "" {
                self.adsView.adsShortDesc.setLocalizableText(ads.descript)
            } else {
                self.adsView.adsShortDesc.setLocalizableText(ads.shortDesc)
            }
        }
        self.adsView.adsLogoImage.sd_setImage(with:  URL(string:  self.native ? (Constants.HttpUrlWithoutApi + "images/ads/" + ads.thumbnail) : ads.thumbnail ), completed: nil)
        self.adsView.joinNowButtonTint.setTitle(ads.btnName,for: .normal)
        self.adsView.cancelButtonLabbel.addTarget(self, action: #selector(hideAdsForSubscribeUsers), for: .touchUpInside)
        self.adsView.url = ads.url
        self.adsView.joinNowButtonTint.addTarget(self, action: #selector(goToURLAds), for: .touchUpInside)
        if providerName == AdsProviders.coinzilla.rawValue {
            AdsRequestService.shared.postForCoinzileInpression(url: ads.impressionUrl)
        }
        if self.adsTrack {
            AdsRequestService.shared.putAdsTrackForServer(zone: zoneForImpression, providerId: self.providerId, actionType: .impresion)
            print("Track -- \(zoneForImpression)")
        }
        adsView.isHidden = false
        return adsView
        
    }
    
    @objc func openUrl (url: URL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @objc  func openURL(urlString: String) {
        if let copyRightURL = URL(string: urlString), UIApplication.shared.canOpenURL(copyRightURL) {
            openUrl(url: copyRightURL)
        }
    }
    
    @objc func goToURLAds() {
        openURL(urlString: adsView.url)
        if self.adsTrack {
            AdsRequestService.shared.putAdsTrackForServer(zone: self.selectedZone!.zoneName, providerId: self.providerId, actionType: .click)
        }
    }
    
    @objc func hideAdsForSubscribeUsers() {
        guard let user = self.user, user.isSubscribted else {
            self.goToSubscriptionPage()
            return
        }
        TimerManager.shared.setDurationTime(item: .adsHide, additionalKey: selectedZone!.zoneName)
        
        NotificationCenter.default.post(name: .hideAdsForSubscribeUsers, object: nil)
        adsView.removeFromSuperview()
        return
        
    }
    
    @objc public func goToSubscriptionPage() {
        guard let vc = ManageSubscriptionViewController.initializeStoryboard() else { return }
        UIApplication.getTopViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
}

enum AdsProviders: String {
    case coinzilla = "Coinzilla"
}

enum ActionType: String {
    case impresion = "imp"
    case click = "click"
}
