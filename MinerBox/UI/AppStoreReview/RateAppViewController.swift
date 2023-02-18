//
//  RateAppViewController.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 2/6/20.
//  Copyright © 2020 WitPlex. All rights reserved.
//

import UIKit

class RateAppViewController: BaseViewController {

    @IBOutlet weak var cancelButton: AlertControllerButton!
    @IBOutlet weak var rateButton: AlertControllerButton!
    @IBOutlet weak var containerView: BaseView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }

    private func initialSetup() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        cancelButton.layer.borderColor = UIColor.clear.cgColor
        rateButton.layer.borderColor = UIColor.clear.cgColor
        rateButton.changeFont(to: Constants.semiboldFont)
        containerView.layer.cornerRadius = CGFloat(10)
    }
    
    @IBAction func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func rateAppButtonTapped() {
        guard let url = URL(string: "itms-apps://itunes.apple.com/app/minerbox/id1445878254?ls=1&mt=8") else { return }
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
