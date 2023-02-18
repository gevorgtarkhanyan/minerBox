//
//  ModelAlgorithmTableViewCell.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/31/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class ModelAlgorithmTableViewCell: BaseTableViewCell {
    @IBOutlet weak var algorithmNameLabel: BaseLabel!
    @IBOutlet weak var algorithmSolutionSpeedLabel: BaseLabel!
    @IBOutlet weak var istrumentPowerLabel: BaseLabel!
    
    static var height: CGFloat {
        return 28
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
    }
    
    func setupCell(with modelsData: [CalculatedModels], for indexPath: IndexPath) {
        let data = modelsData[indexPath.row]
        self.algorithmNameLabel.text = data.name
        self.algorithmSolutionSpeedLabel.text = ""
        if var num = Int(exactly: data.count) {
            if num == 0 {num = 1}
            self.istrumentPowerLabel.text = String(num)
        } else {
            self.istrumentPowerLabel.text = String(data.count)
        }
    }
    
    func setupCell(with algosData: [CalculatedAlgos], for indexPath: IndexPath) {
        let data = algosData[indexPath.row]
        self.algorithmNameLabel.text = data.name
        
        if let num = Int(exactly: data.hs) {
            self.algorithmSolutionSpeedLabel.text = num.getFormatedString() + " Gh/s"
        } else {
            self.algorithmSolutionSpeedLabel.text = data.hs.getString() + " Gh/s"
        }
        
        if let num = Int(exactly: data.w) {
            self.istrumentPowerLabel.text = String(num) + " W"
        } else {
            self.istrumentPowerLabel.text = String(data.w) + " W"
        }
    }
    
}
