//
//  ContactSupport.swift
//  MinerBox
//
//  Created by Gevorg Tarkhanyan on 25.07.22.
//  Copyright © 2022 WitPlex. All rights reserved.
//

import Foundation
import UIKit

class ContactSupport {
    
static let shared = ContactSupport()

var supportMail: String {
    let communityModel = DatabaseManager.shared.communityModel
    return communityModel?.feedbackEmail ?? "minerbox@witplex.com"
}

func contactSupport(with vc: UIViewController) {
    Loading.shared.startLoading(ignoringActions: true, for: vc.view)
    if let emailActionSheet = ContactSupport.shared.setupChooseEmailActionSheet() { //setupChooseEmailActionSheet() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            emailActionSheet.popoverPresentationController?.sourceView = vc.view
            let center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height)
            emailActionSheet.popoverPresentationController?.sourceRect.origin = center
        }
        vc.present(emailActionSheet, animated: true, completion: {
            Loading.shared.endLoading(for: vc.view)
        })
    } else {
        Loading.shared.endLoading(for: vc.view)
        vc.showAlertView("", message: "mail_not_configured".localized(), completion: nil)
    }
}

private func setupChooseEmailActionSheet(withTitle title: String? = "choose_email".localized()) -> UIAlertController? {
    let emailActionSheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
    emailActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    if let action = openAction(with: .mail, andTitleActionTitle: "Mail") {
        emailActionSheet.addAction(action)
    }
    
    if let action = openAction(with: .gmail, andTitleActionTitle: "Gmail") {
        emailActionSheet.addAction(action)
    }
    
    if let action = openAction(with: .inbox, andTitleActionTitle: "Inbox") {
        emailActionSheet.addAction(action)
    }
    
    if let action = openAction(with: .outlook, andTitleActionTitle: "Outlook") {
        emailActionSheet.addAction(action)
    }
    
    if let action = openAction(with: .yahoo, andTitleActionTitle: "Yahoo") {
        emailActionSheet.addAction(action)
    }
    
    return emailActionSheet.actions.count > 1 ? emailActionSheet : nil
}

private func openAction(with: MailApplicationsSettingsContactSupport, andTitleActionTitle: String) -> UIAlertAction? {
    let urlStr = getMailString(service: with)
    guard let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) else {
        return nil
    }
    let action = UIAlertAction(title: andTitleActionTitle, style: .default) { (action) in
        guard #available(iOS 10, *) else {
            UIApplication.shared.openURL(url)
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
    }
    return action
}

private func getMailString(service: MailApplicationsSettingsContactSupport) -> String {
//        let supportMail = "minerbox@witplex.com"
    let subject = ""
    var appVersion = "Unknown application version"
    if let info = Bundle.main.infoDictionary, let shortVersion = info["CFBundleShortVersionString"] as? String {
        appVersion = shortVersion
    }
    let systemVersion = UIDevice.current.systemVersion
    let body = "\n\n\nApp version: \(appVersion)\niOS version: \(systemVersion)\nDevice: \(UIDevice.modelName)"
    
    let message = service.rawValue + "?to=\(supportMail)&subject=\(subject)&body=\(body)"
    return message.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? message
}
}

enum MailApplicationsSettingsContactSupport: String {
case mail = "mailto:"
case gmail = "googlegmail:///co"
case outlook = "ms-outlook://compose"
case inbox = "inbox-gmail://co"
case yahoo = "ymail://mail/compose"
}
