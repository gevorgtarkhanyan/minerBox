//
//  CoinLinkView.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 27.05.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

//protocol CoinLinkViewDelegate: class {
//
//}

class CoinLinkView: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var websiteButton: BackgroundButton!
    @IBOutlet weak var twitterButton: BackgroundButton!
    @IBOutlet weak var redditButton: BackgroundButton!
    @IBOutlet weak var tableView: BaseTableView!
    
//    weak open var delegate: CoinLinkViewDelegate?
    
    private var coin: CoinModel?
    
    private var expLinks: [String] {
        return coin?.explorerLinks ?? []
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        tableView.register(CoinLinkTableViewCell.self, forCellReuseIdentifier: "CoinLinkTableViewCell")
        tableView.register(UINib(nibName: "CoinLinkTableViewCell", bundle: nil), forCellReuseIdentifier: "CoinLinkTableViewCell1")
        commonInit()
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("CoinLinkView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        initialSetup()
    }
    
    private func initialSetup() {
//        self.isHidden = true
        self.backgroundColor = .clear
        self.layer.cornerRadius = 10
        startupSetup()
    }
    
    private func startupSetup() {
        
//        tableView.delegate = self
//        tableView.dataSource = self
        websiteButton.addTarget(self, action: #selector(buttunAction(sender:)), for: .touchUpInside)
        twitterButton.addTarget(self, action: #selector(buttunAction(sender:)), for: .touchUpInside)
        redditButton.addTarget(self, action: #selector(buttunAction(sender:)), for: .touchUpInside)
    }
    
    public func setData(with coin: CoinModel) {
        self.coin = coin
//        DispatchQueue.main.async {
            self.tableView.reloadData()
//        }
    }
    
    @objc private func buttunAction(sender: BackgroundButton) {
        var urlStr = ""
        
        switch sender.tag {
        case 0:
            urlStr = coin?.websiteUrl ?? ""
        case 1:
            urlStr = coin?.twitterUrl ?? ""
        case 2:
            urlStr = coin?.redditUrl ?? ""
        default:
            return
        }

        openUrl(with: urlStr)
    }
    
    private func openUrl(with urlStr: String) {
        if let url = URL(string: urlStr) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
        
}

extension CoinLinkView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expLinks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoinLinkTableViewCell") as! CoinLinkTableViewCell

        cell.linkLabel.text = expLinks[indexPath.row]

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openUrl(with: expLinks[indexPath.row])
    }
}
