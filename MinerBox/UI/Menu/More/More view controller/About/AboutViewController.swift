//
//  AboutViewController.swift
//  MinerBox
//
//  Created by Ruben Nahatakyan on 7/18/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit
import FirebaseCrashlytics

class AboutViewController: BaseViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet private weak var tableView: BaseTableView!
    
    private let tableData = AboutAppEnum.getTableData()
    fileprivate var communtiyModel = DatabaseManager.shared.communityModel
    
    ///must be removed
    private var tapCount = 0

    static func initializeStoryboard() -> AboutViewController? {
        return UIStoryboard(name: "More", bundle: nil).instantiateViewController(withIdentifier: AboutViewController.name) as? AboutViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configLogo()
    }
    
    fileprivate func configLogo() {
        let iconName = Date().isChristmasDay ? "christmasLogo" : "logo"
        imageView.image = UIImage(named: iconName)
    }
    
    ///must be removed
    func testCrashlitics() {
        tapCount += 1
        if tapCount == 3 {
            tapCount = 0
            Crashlytics.crashlytics().log(UIApplication.pageName + "testCrashlitics")
        }
    }
    
    override func languageChanged() {
        title = MoreSettingsEnum.aboutApp.rawValue.localized()
    }
    
    private func currentYear() -> Int {
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        
        return year
    }
    
    private func shareApplication() {
        var text = "about_app_share_text".localized()
        text = text.replacingOccurrences(of: "ios_app_link", with: Constants.iosLink)
        text = text.replacingOccurrences(of: "android_app_link", with: Constants.androidLink)
        
        ShareManager.shareText(self, text: text )

        
//        let textToShare = [text]
//        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            activityViewController.popoverPresentationController?.sourceView = self.view
//            let center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height)
//            activityViewController.popoverPresentationController?.sourceRect.origin = center
//        }
//
//        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook]
//
//        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    private func rateApp() {
        guard let url = URL(string: "itms-apps://itunes.apple.com/app/minerbox/id1445878254?ls=1&mt=8") else { return }
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    private func showAppBuildNumber() {
        showToastAlert("", message: Bundle.main.buildVersionNumber)
    }
    
    private func sendFeedback() {
        MailManager.shared.sendFeedback(with: self)

    }
}


// MARK: - Table cell delegate
extension AboutViewController: MoreTableViewCellDelegate {
    func cellTappedFiveTimes(indexPath: IndexPath) {
        guard tableData[indexPath.section][indexPath.row] == .appVersion else { return }
        showAppBuildNumber()
    }
}

// MARK: - TableView delegate data source methods
extension AboutViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MoreTableViewCell.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MoreTableViewCell.name) as! MoreTableViewCell
        let item = tableData[indexPath.section][indexPath.row]
        
        cell.delegate = self
        if item == AboutAppEnum.website {
            cell.setData(title: item.rawValue, indexPath: indexPath, currentYear: currentYear())
        } else {
            cell.setData(title: item.rawValue, indexPath: indexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ///must be removed
        if indexPath.row == 0 {
            testCrashlitics()
        }
        let parameter = tableData[indexPath.section][indexPath.row]
        switch parameter {
        case .feedback:
            sendFeedback()
        case .share:
            shareApplication()
        case .rate:
            rateApp()
        case .website:
            openURL(urlString: communtiyModel?.minerboxUrl ?? "")
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 35
    }
}

// MARK: - Helpers
enum AboutAppEnum: String, CaseIterable {
    case feedback = "about_app_feedback"
    case share = "about_app_share"
    case rate = "about_app_rate"
    case website = "about_app_website"
    case appVersion = "about_app_version"
    
    static func firstSection() -> [AboutAppEnum] {
        return [.feedback, .share, .rate]
    }
    
    static func secondSection() -> [AboutAppEnum] {
        return [.website, .appVersion]
    }
    
    static func getTableData() -> [[AboutAppEnum]] {
        return [firstSection(), secondSection()]
    }
}

//enum MailApplicationsSettings: String {
//    case mail = "mailto:"
//    case gmail = "googlegmail:///co"
//    case outlook = "ms-outlook://compose"
//    case inbox = "inbox-gmail://co"
//    case yahoo = "ymail://mail/compose"
//}
