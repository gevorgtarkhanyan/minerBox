//
//  PoolListTableViewCell.swift
//  MinerBox
//
//  Created by Yuro Mnatsakanyan on 10/16/19.
//  Copyright © 2019 WitPlex. All rights reserved.
//

import UIKit

class PoolListTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: BaseLabel!
    @IBOutlet weak var separatorView: UIView!
    
    private var indexPath: IndexPath = .zero
    
    static var height: CGFloat {
        return CGFloat(44)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }
    
    func initialSetup() {
        backgroundColor = .tableCellBackground
    }
    
    func setPoolData(pools: [SubPoolItem], indexPath: IndexPath) {
        let pool = pools[indexPath.row - 1]
        let lastIndex = pools.count - 1
        self.indexPath = indexPath
        nameLabel.setLocalizableText(pool.name)
        getImage(url: URL(string: Constants.HttpUrlWithoutApi + pool.coinIconUrl), indexPath: indexPath)
        
        if pools.count != 0 {
            if pool == pools[0] && pools.count != 1 {
                roundCorners([.topRight, .topLeft], radius: 10)
                separatorView.backgroundColor = .separator
            } else if pool == pools[lastIndex] {
                if pools.count == 1 {
                    roundCorners([.bottomLeft, .bottomRight, .topRight, .topLeft], radius: 10)
                } else {
                    roundCorners([.topRight, .topLeft], radius: 0)
                    roundCorners([.bottomLeft, .bottomRight], radius: 10)
                }
                separatorView.backgroundColor = .clear
            } else {
                roundCorners([.topRight, .topLeft, .bottomLeft, .bottomRight], radius: 0)
                separatorView.backgroundColor = .separator
            }
        }
    }
    
    private func getImage(url: URL?, indexPath: IndexPath) {
        if let url = url {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 20)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async() {
                    if indexPath == self.indexPath {
                        self.iconImageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
    }
}
