//
//  TopNewViewCell.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 01.12.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

protocol TopNewsViewCellDelegate: AnyObject {
    func liked (row: Int)
    func disliked(row: Int)
    func bookmarkTapped(row: Int)
}

class TopNewsViewCell: BaseTableViewCell {
    
    @IBOutlet weak var topImageView: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var viewImageView: UIImageView!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var dislikeLabel: UILabel!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var dislikeBackgroundView: UIView!
    @IBOutlet weak var likeButtonBackgroundView: UIView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var contentBackgroundView: UIView!
    @IBOutlet weak var sourceLabel: UILabel!
    
    static var height: CGFloat = 239
    
    var indexPath: IndexPath?
    weak var delegate: TopNewsViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialSetup()

    }
 
    func initialSetup() {
        self.bookmarkButton.setImage(UIImage(named: "bookmark"), for: .normal)
        self.viewImageView.image = UIImage(named: "views_Icon")?.withRenderingMode(.alwaysTemplate)
        self.contentBackgroundView?.roundCorners([.topLeft,.topRight], radius: 10)
        self.contentLabel.font = .boldSystemFont(ofSize: 14)
        let likeGetchur = UITapGestureRecognizer.init(target: self, action: #selector(liked))
        self.likeButtonBackgroundView.addGestureRecognizer(likeGetchur)
        let dislikeGetchur = UITapGestureRecognizer.init(target: self, action: #selector(disLiked))
        self.dislikeBackgroundView.addGestureRecognizer(dislikeGetchur)

    }
    
    func setData(news: NewsModel, indexPath: IndexPath) {
        self.topImageView.sd_setImage(with: URL(string: news.image), placeholderImage: UIImage(named: "new_placeholder"), completed: nil)
        self.indexPath = indexPath
        self.viewsLabel.text    =  news.watched.getString().localized()
        self.likeLabel.text     =  news.liked.getString().localized()
        self.dislikeLabel.text  =  news.disliked.getString().localized()
        self.dateLabel.text     =  news.date.getDateFromUnixTime()
        self.contentLabel.text  =  news.title.localized()
        self.sourceLabel.text   =  news.source.localized()
        
        let date =  Date()
        let time = date.millisecondsSince1970 - news.date
        if  time < 86400 {
            if Int(time / 3600) != 0 {
                self.dateLabel.text =   "\(Int(time/3600))" + "hr".localized() + " " + "ago".localized()
            }else if time / 60 != 0 {
                self.dateLabel.text =   "\(Int(time/60))" + "min".localized() + " " + "ago".localized()
            }else{
                self.dateLabel.text =   "\(Int(time) % 60 )" + "sec".localized() + " " + "ago".localized()
            }
        } else {
            self.dateLabel.text =  news.date.getDateFromUnixTime()
        }

        self.bookmarkButton.setImage( news.isBookmarked ? UIImage(named: "bookmark") : UIImage(named: "unselected_bookmark") , for: .normal)
        self.dislikeButton.setImage(news.userAction == 2  ? UIImage(named: "dislike_icon")?.withRenderingMode(.alwaysTemplate) : UIImage(named: "undislike_icon")?.withRenderingMode(.alwaysTemplate)  , for: .normal )
        self.likeButton.setImage(news.userAction == 1  ? UIImage(named: "like_icon")?.withRenderingMode(.alwaysTemplate) : UIImage(named: "unlike_icon")?.withRenderingMode(.alwaysTemplate)  , for: .normal )
        
        self.likeButton.addTarget(self, action: #selector(liked), for: .touchUpInside)
        self.dislikeButton.addTarget(self, action: #selector(disLiked), for: .touchUpInside)
        self.bookmarkButton.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)

    }
    
    
    // MARK: - Delegate Methods-
    @objc func liked() {
        if let delegate = delegate, let indexPath = indexPath {
            delegate.liked(row: indexPath.row)
        }
    }
    @objc func disLiked() {
        if let delegate = delegate,let indexPath = indexPath {
            delegate.disliked(row: indexPath.row)
        }
    }
    @objc func bookmarkTapped() {
        if let delegate = delegate,let indexPath = indexPath {
            delegate.bookmarkTapped(row: indexPath.row)
        }
    }
}
