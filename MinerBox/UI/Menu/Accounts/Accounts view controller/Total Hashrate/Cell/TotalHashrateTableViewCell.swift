//
//  TotalHashrateTableViewCell.swift
//  MinerBox
//
//  Created by Armen Gasparyan on 22.11.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

class TotalHashrateTableViewCell: BaseTableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var hashrateLabel: UILabel!
    @IBOutlet weak var hashrateImageView: UIImageView!
    
    @IBOutlet weak var workerCountLabel: UILabel!
    @IBOutlet weak var workerCountImageView: UIImageView!
    
    static let height: CGFloat = 20
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func startupSetup() {
        super.startupSetup()
        
        workerCountImageView.image = UIImage(named: "cell_worker_icon")?.withRenderingMode(.alwaysTemplate)
        hashrateImageView.image = UIImage(named: "cell_hashrate_icon")?.withRenderingMode(.alwaysTemplate)

        workerCountImageView.tintColor = .gray
        hashrateImageView.tintColor = .gray
        nameLabel.textColor = .gray
        hashrateLabel.textColor = .gray
        workerCountLabel.textColor = .gray
    }
    
    public func setData(_ data: TotalAccountValue) {
        nameLabel.text = data.name
        hashrateLabel.text = data.hashrate?.textFromHashrate(hsUnit: data.hsUnit!)
        workerCountLabel.text = data.worker?.getFormatedString()
        
        
        if data.worker == nil {
            workerCountImageView.isHidden = true
        } else{
            workerCountImageView.isHidden = false
        }
        
        if data.hashrate == nil {
            hashrateImageView.isHidden = true
        } else{
            hashrateImageView.isHidden = false
        }
    }
    
}
