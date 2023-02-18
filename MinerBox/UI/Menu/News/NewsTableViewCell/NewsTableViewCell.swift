//
//  NewsTableViewCell.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 29.11.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

protocol NewsTableViewCellDelegate: AnyObject {
    func liked (row: Int)
    func disliked(row: Int)
    func bookmarkTapped(row: Int)
}

class NewsTableViewCell: BaseTableViewCell {
    
    //MARK: - Views -
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var viewIcon: UIImageView!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var likeButtonBackgroundView: UIView!
    @IBOutlet weak var likeButton: BaseButton!
    @IBOutlet weak var likeLabel: BaseLabel!
    @IBOutlet weak var dislikeBackgroundView: UIView!
    @IBOutlet weak var dislikeButton: BaseButton!
    @IBOutlet weak var dislikeLabel: BaseLabel!
    @IBOutlet weak var contentLabel: BaseLabel!
    @IBOutlet weak var bootomView: UIView!
    @IBOutlet weak var sourceLabel: UILabel!
    
    static var height: CGFloat = 125
    
    var row: Int?
    weak var delegate: NewsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialSetup()
    }
    
    func initialSetup() {
        self.bookmarkButton.setImage(UIImage(named: "bookmark"), for: .normal)
        self.dislikeButton.setImage(UIImage(named: "undislike_icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.likeButton.setImage(UIImage(named: "unlike_icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.viewIcon.image = UIImage(named: "views_Icon")
        self.bookmarkButton.tintColor = .barSelectedItem
        self.viewIcon.tintColor = .barSelectedItem
        let likeGetchur = UITapGestureRecognizer.init(target: self, action: #selector(liked))
        self.likeButtonBackgroundView.addGestureRecognizer(likeGetchur)
        let dislikeGetchur = UITapGestureRecognizer.init(target: self, action: #selector(disLiked))
        self.dislikeBackgroundView.addGestureRecognizer(dislikeGetchur)
        let enptyGetchur = UITapGestureRecognizer.init(target: self, action: #selector(enptyAction))
        self.bootomView.addGestureRecognizer(enptyGetchur)
        self.newsImageView.roundCorners(radius: 10)
        DispatchQueue.main.async {
            self.dateLabel.textColor = .lightGray
            self.viewsLabel.textColor = .lightGray
            self.sourceLabel.textColor = .lightGray
        }
        
    }
    
    func setData(news: NewsModel, row: Int) {
        self.newsImageView.sd_setImage(with: URL(string: news.image), placeholderImage: UIImage(named: "new_placeholder"), completed: nil)
        self.row = row
        self.viewsLabel.text = news.watched.getString()
        self.likeLabel.setLocalizableText(news.liked.formatUsingAbbrevation())
        self.dislikeLabel.setLocalizableText(news.disliked.formatUsingAbbrevation())
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

        self.contentLabel.setLocalizableText(news.title)
        self.sourceLabel.text = news.source
        self.contentLabel.changeFont(to: .boldSystemFont(ofSize: 14))
        
        self.bookmarkButton.setImage( news.isBookmarked ? UIImage(named: "bookmark") : UIImage(named: "unselected_bookmark") , for: .normal)
        self.dislikeButton.setImage(news.userAction == 2  ? UIImage(named: "dislike_icon")?.withRenderingMode(.alwaysTemplate) : UIImage(named: "undislike_icon")?.withRenderingMode(.alwaysTemplate)  , for: .normal )
        self.likeButton.setImage(news.userAction == 1  ? UIImage(named: "like_icon")?.withRenderingMode(.alwaysTemplate) : UIImage(named: "unlike_icon")?.withRenderingMode(.alwaysTemplate)  , for: .normal )
        self.likeButton.addTarget(self, action: #selector(liked), for: .touchUpInside)
        self.dislikeButton.addTarget(self, action: #selector(disLiked), for: .touchUpInside)
        self.bookmarkButton.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)

    }
    
    // MARK: - Delegate Methods-
    @objc func liked() {
        if let delegate = delegate, let row = row {
            delegate.liked(row: row)
        }
    }
    @objc func disLiked() {
        if let delegate = delegate,let row = row {
            delegate.disliked(row: row)
        }
    }
    @objc func bookmarkTapped() {
        if let delegate = delegate,let row = row {
            delegate.bookmarkTapped(row: row)
        }
    }
    @objc func enptyAction() {}
}

