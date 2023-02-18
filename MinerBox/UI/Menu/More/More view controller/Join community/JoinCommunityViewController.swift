//
//  JoinCommunityViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/18/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class JoinCommunityViewController: BaseViewController {
    
    // MARK: - Views
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    
    // MARK: - Properties
    fileprivate let communities = JoinCommunityEnum.allCases
    
    fileprivate var communtiyModel = DatabaseManager.shared.communityModel
        
    // MARK: - Static
    static func initializeStoryboard() -> JoinCommunityViewController? {
        return UIStoryboard(name: "More", bundle: nil).instantiateViewController(withIdentifier: JoinCommunityViewController.name) as? JoinCommunityViewController
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetup()
    }
    
    override func languageChanged() {
        title = MoreSettingsEnum.joinCommunity.rawValue.localized()
    }
}

// MARK: - Startup
extension JoinCommunityViewController {
    
        fileprivate func startupSetup() {
            let isOver24Hors = TimerManager.shared.isLoadingTime(item: .community)
            if isOver24Hors || DatabaseManager.shared.communityModel == nil {
                getCommnity()
            }
        }
    
    fileprivate func getCommnity() {
        Loading.shared.startLoading(ignoringActions: true, for: self.view)
        CommunityManager.shared.getList(success: { (community) in
            self.communtiyModel = community
            Loading.shared.endLoading(for: self.view)
        }) { (error) in
            Loading.shared.endLoading(for: self.view)
            self.showAlertView("", message: error, completion: nil)
        }
    }
}

// MARK: - Actions
extension JoinCommunityViewController {
    fileprivate func openApp(appString: String, webString: String) {
        guard let appURL = URL(string: appString), let webURL = URL(string: webString) else { return }
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL)
            }
        } else {
            //redirect to browser because the user doesn't have application
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(webURL)
            }
        }
    }
}

// MARK: - TableView methods
extension JoinCommunityViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MoreTableViewCell.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return communities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MoreTableViewCell.name) as! MoreTableViewCell
        let community = communities[indexPath.row]
        
        cell.setData(title: community.rawValue, indexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let communtiyModel = communtiyModel else { return }
        let community = communities[indexPath.row]
        switch community {
        case .facebook:
            let screenName = communtiyModel.facebookID
            openApp(appString: "fb://profile/\(screenName)", webString: communtiyModel.facebookURL)
        case .telegram:
            let screenName = "joinchat/HMRTnxA3Wcj0GrtaKwYzZQ"
            openApp(appString: "tg://resolve?domain=\(screenName)", webString: communtiyModel.telegramURL)
        case .twitter:
            let screenName = "box_miner"
            openApp(appString: "twitter:///user?screen_name=\(screenName)", webString: communtiyModel.twitterURL)
        case .reddit:
            let screenName = "minerbox_app"
            openApp(appString: "reddit:///r/\(screenName)", webString: communtiyModel.redditURL)
        }
    }
}

// MARK: - Helpers
enum JoinCommunityEnum: String, CaseIterable {
    case facebook = "community_facebook"
    case telegram = "community_telegram"
    case twitter = "community_twitter"
    case reddit = "community_reddit"
}
