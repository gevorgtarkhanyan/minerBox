//
//  NewsContentViewController.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 07.12.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

protocol NewsContentViewControllerDelegate: AnyObject {
    func liked (row: Int)
    func disliked(row: Int)
    func bookmarkTapped(row: Int)
    func wathed(row: Int)
}

class NewsContentViewController: BaseViewController {
    
    //MARK: - Views -
    @IBOutlet weak var baseContentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentTextView: BaseTextView!
    @IBOutlet weak var contentBackgorundView: BaseView!
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: BaseLabel!
    @IBOutlet weak var viewsIconImageView: BaseImageView!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var viewsWidthConstraits: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var newsIconView: BaseImageView!
    @IBOutlet weak var likeButton: BaseButton!
    @IBOutlet weak var likeLabel: BaseLabel!
    @IBOutlet weak var dislikeButton: BaseButton!
    @IBOutlet weak var dislikeLabel: BaseLabel!
    @IBOutlet weak var urlButton: BaseButton!
    @IBOutlet weak var creatorLabel: BaseLabel!
    @IBOutlet weak var headerViewHeightConstraits: NSLayoutConstraint!
    @IBOutlet weak var buttonStackViewHeight: NSLayoutConstraint!
    
   
    @IBOutlet weak var moreButtonView: UIView!
    
    @IBOutlet weak var moreButtonLabel: UILabel!
    private var resizeButton: UIBarButtonItem!
    private var bookmarkButton: UIBarButtonItem!
    private var shareButton: UIBarButtonItem!
    private var isSelectAnyButton = false
    
    @IBOutlet weak var categoresCollectionView: BaseCollectionView!
    @IBOutlet weak var categoriesHeightContraits: NSLayoutConstraint!
    private var countLineCategoresView = 0
    private var collectionTextSize: CGFloat = 12
    
    public var localNews: NewsModel?
    public var indexNews: Int?
    weak var delegate: NewsContentViewControllerDelegate?
    
    private var adsViewForDetailNews: AdsView?
    private var contetTextSize: ContentNewsSize = .firstFont
    
    private var news: NewsModel?
    
    var bottomContentInsets: CGFloat = 0 {
        willSet {
            scrollView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: newValue, right: 0)
        }
    }
    
    // MARK: - Static
    static func initializeStoryboard() -> NewsContentViewController? {
        return UIStoryboard(name: "Menu", bundle: nil).instantiateViewController(withIdentifier: NewsContentViewController.name) as? NewsContentViewController
    }
    
    //MARK: - Live Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.getNewsDetail()
        self.setupNavigation()
        self.addObservers()

    }
    
    override func languageChanged() {
        title = "news".localized()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.checkUserForAds()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
 //       adsViewForDetailNews?.removeFromSuperview()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateCategoriesCollectionView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(likeChanged), name: .likeStatusChanged, object: nil)
    }
    
    func setupViews() {
        self.newsIconView.image = UIImage(named: "coin_alert")
        self.viewsLabel.textColor = .lightGray
        self.dateLabel.textColor = .lightGray
        self.titleLabel.changeFont(to: .boldSystemFont(ofSize: 16))
        self.viewsIconImageView.image = UIImage(named: "views_Icon")
        self.urlButton.tintColor = .barSelectedItem
        
        self.dislikeButton.setImage(localNews?.userAction == 2  ? UIImage(named: "dislike_icon")?.withRenderingMode(.alwaysTemplate) : UIImage(named: "undislike_icon")?.withRenderingMode(.alwaysTemplate)  , for: .normal )
        self.likeButton.setImage(localNews?.userAction == 1  ? UIImage(named: "like_icon")?.withRenderingMode(.alwaysTemplate) : UIImage(named: "unlike_icon")?.withRenderingMode(.alwaysTemplate)  , for: .normal )
        
        self.moreButtonLabel.text = "More".localized()
        self.moreButtonLabel.textColor = .appGreen
        self.moreButtonView.layer.borderColor = UIColor.appGreen.cgColor
        self.moreButtonView.layer.borderWidth = 1
        
            if let contetTextSize = UserDefaults.shared.value(forKey: "contet_text_size") as? String  {
                switch contetTextSize {
                case ContentNewsSize.firstFont.rawValue:
                    self.contetTextSize = .firstFont
                case ContentNewsSize.secondFont.rawValue:
                    self.contetTextSize = .secondFont
                case ContentNewsSize.thirdFont.rawValue:
                    self.contetTextSize = .thirdFont
                default:
                    print("no UserData")
                }
                self.resizeTextFont()
        }
        self.configCollectionLayout()
    }
    
    func configCollectionLayout() {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 5
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.estimatedItemSize = CGSize(width: 50, height: 50)
        flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.categoresCollectionView.collectionViewLayout = flowLayout
        self.categoresCollectionView.roundCorners(radius: 10)
        self.categoresCollectionView.dataSource = self
        self.categoresCollectionView.delegate = self
        self.categoresCollectionView.sizeToFit()
        self.contentTextView.backgroundColor = .clear
        self.contentBackgorundView.backgroundColor = .clear
    }
    
    func updateViews() {
        self.titleLabel.text = news?.title
        let date =  Date()
        let time = date.millisecondsSince1970 - news!.date
        if  time < 86400 {
            if Int(time / 3600) != 0 {
                self.dateLabel.text =   "\(Int(time/3600))" + "hr".localized() + " " + "ago".localized()
            }else if time / 60 != 0 {
                self.dateLabel.text =   "\(Int(time/60))" + "min".localized() + " " + "ago".localized()
            }else{
                self.dateLabel.text =   "\(Int(time) % 60 )" + "sec".localized() + " " + "ago".localized()
            }
        } else {
            self.dateLabel.text =  news!.date.getDateFromUnixTime()
        }

        self.urlButton.setTitle(news?.source, for: .normal)
        self.contentTextView.attributedText = news?.content.htmlAttributed(using: Constants.regularFont.withSize(15))
        if let contetTextSize = UserDefaults.shared.value(forKey: "contet_text_size") as? String  {
            switch contetTextSize {
            case ContentNewsSize.firstFont.rawValue:
                self.contentTextView.font = UIFont(name: "Helvetica", size: 15 * 1.5)
            case ContentNewsSize.secondFont.rawValue:
                self.contentTextView.font = UIFont(name: "Helvetica", size: 15 * 2)
            case ContentNewsSize.thirdFont.rawValue:
                self.contentTextView.font = UIFont(name: "Helvetica", size: 15 * 1)
            default:
                break
            }
        }
        self.contentTextView.textColor = darkMode ? .white : .black
        self.contentTextView.tintColor = .barSelectedItem
        self.newsIconView.sd_setImage(with: URL(string: news!.image), placeholderImage: UIImage(named: "new_placeholder"), completed: nil)
        self.urlButton.addTarget(self, action: #selector(URLButtonAction), for: .touchUpInside)
        self.moreButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openNewURL)))
        self.likeButton.addTarget(self, action: #selector(liked), for: .touchUpInside)
        self.dislikeButton.addTarget(self, action: #selector(disLiked), for: .touchUpInside)
        self.creatorLabel.setLocalizableText(news?.creator ?? "")
        self.likeLabel.text =  localNews?.liked.formatUsingAbbrevation()
        self.dislikeLabel.text =  localNews?.disliked.formatUsingAbbrevation()
        self.viewsLabel.text = (localNews!.watched + 1).getString()
        
    }
    
    func updateCategoriesCollectionView() {
        
        self.view.layoutIfNeeded()
        self.categoresCollectionView.reloadData()
        self.categoresCollectionView.layoutIfNeeded()
        self.contentTextView.adjustUITextViewHeight()
        self.contentViewHeight.constant = self.contentTextView.frame.height
        let height = self.categoresCollectionView.collectionViewLayout.collectionViewContentSize.height
        self.categoriesHeightContraits.constant = height
        self.view.layoutIfNeeded()
        self.view.setNeedsLayout()
        
        self.categoresCollectionView.reloadData()
    }
    
    func setupNavigation() {
        navigationController?.navigationBar.shadowImage = UIImage()
        
        resizeButton = UIBarButtonItem.customButton(self, action: #selector(resizeTextFont), imageName: "navi_text_resize",tag: 1)
        bookmarkButton = UIBarButtonItem.customButton(self, action: #selector(bookmarkTapped), imageName: localNews!.isBookmarked ? "navi_bookmark" :  "navi_unbookmark", tag: 1)
        shareButton = UIBarButtonItem.customButton(self, action: #selector(shareNewsScreen), imageName: "share",tag: 1)
        resizeButton.isEnabled = false
        bookmarkButton.isEnabled = false
        shareButton.isEnabled = false

        
        let buttons: [UIBarButtonItem] = [shareButton, bookmarkButton, resizeButton ]
        navigationItem.setRightBarButtonItems(buttons, animated: false)
    }
}

//MARK: - Action -

extension NewsContentViewController {
    
    func getNewsDetail() {
        Loading.shared.startLoading()
        NewsManager.shared.getNewsDetail(newsId: localNews!.newsId) { news in
            self.news = news
            self.updateCategoriesCollectionView()
            self.updateViews()
            self.categoresCollectionView.isHidden = news.categories.count == 0
            self.scrollView.isHidden = false
            self.patchNewsViews(_id: self.localNews!._id)
            self.resizeButton.isEnabled = true
            self.bookmarkButton.isEnabled = true
            self.shareButton.isEnabled = true
            Loading.shared.endLoading()
        } failer: { err in
            Loading.shared.endLoading()
            print(err)
        }
    }
    
    func patchNewsViews(_id: String) {
        NewsManager.shared.patchNewsViews(_id: _id) {
            print("News Watched")
            self.watched()
        } failer: { err in
            print(err)
        }
    }
    
    @objc func openNewURL() {
        openUrl(url: URL(string: news!.link)!)
    }
    
    @objc func URLButtonAction() {
        NewsCacher.shared.searchText = news?.source
        self.goToNewViewController()
    }
    
    @objc func likeChanged() {
        self.likeButton.isUserInteractionEnabled = true
        self.dislikeButton.isUserInteractionEnabled = true
        self.isSelectAnyButton = false
    }
    
    @objc func resizeTextFont() {
        UserDefaults.shared.setValue( contetTextSize.rawValue , forKey: "contet_text_size")
        
        switch self.contetTextSize {
        case .firstFont:
            self.viewsIconImageView.image = UIImage(named: "views2x_icon")
            self.dislikeButton.setImage( UIImage(named: localNews?.userAction == 2 ? "dislike2x_icon" : "undislike2x_icon")?.withRenderingMode(.alwaysTemplate), for: .normal )
            self.likeButton.setImage( UIImage(named: localNews?.userAction == 1 ? "like2x_icon" : "unlike2x_icon")?.withRenderingMode(.alwaysTemplate), for: .normal )
            self.viewsWidthConstraits.constant = 24
            self.contetTextSize = .secondFont
            self.setResizeValue(value: 1.5)
        case .secondFont:
            self.viewsIconImageView.image = UIImage(named: "views3x_icon")
            self.dislikeButton.setImage( UIImage(named: localNews?.userAction == 2 ? "dislike3x_icon" : "undislike3x_icon")?.withRenderingMode(.alwaysTemplate), for: .normal )
            self.likeButton.setImage( UIImage(named:  localNews?.userAction == 1 ? "like3x_icon" : "unlike3x_icon")?.withRenderingMode(.alwaysTemplate), for: .normal )
            self.viewsWidthConstraits.constant = 30
            self.contetTextSize = .thirdFont
            self.setResizeValue(value: 2)
        case .thirdFont:
            self.viewsIconImageView.image = UIImage(named: "views_Icon")
            self.dislikeButton.setImage( UIImage(named: localNews?.userAction == 2 ? "dislike_icon" : "undislike_icon")?.withRenderingMode(.alwaysTemplate), for: .normal )
            self.likeButton.setImage( UIImage(named: localNews?.userAction == 1 ? "like_icon" : "unlike_icon")?.withRenderingMode(.alwaysTemplate), for: .normal )
            self.viewsWidthConstraits.constant = 17
            self.contetTextSize = .firstFont
            self.setResizeValue(value: 1)
        }
    }
    
    func setResizeValue(value: CGFloat){
        self.titleLabel.font = .boldSystemFont(ofSize: 18 * value)
        self.creatorLabel.font =  .boldSystemFont(ofSize: 14 * value)
        self.moreButtonLabel.font = .boldSystemFont(ofSize: 14 * value)
        self.contentTextView.font = UIFont(name: "Helvetica", size: 15 * value)
        self.viewsLabel.font = .boldSystemFont(ofSize: 10 * value)
        self.dateLabel.font = .boldSystemFont(ofSize: 11 * value)
        self.likeLabel.font = .boldSystemFont(ofSize: 11 * value)
        self.dislikeLabel.font = .boldSystemFont(ofSize: 11 * value)
        self.headerViewHeightConstraits.constant = 12 * value
        self.buttonStackViewHeight.constant = 44 * value
        self.urlButton.titleLabel?.font = .boldSystemFont(ofSize: 15 * value)
        self.collectionTextSize = 12 * value
        self.updateCategoriesCollectionView()
    }
    @objc func shareNewsScreen() {
        
        let currentText = "Shared via MinerBox:\n\(news!.title)\n\(news!.link)"
        ShareManager.shareText( self, text: currentText )
    }
}


//MARK: - UICollectionViewDelegate -

extension NewsContentViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout   {
    func collectionView(collectionviewcell: CategorieCollectionViewCell?, index: Int, didTappedInTableViewCell: BaseTableViewCell) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return news?.categories.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newsCategori", for: indexPath) as? CategorieCollectionViewCell {
            cell.setDate(categoria: news!.categories[indexPath.row])
            cell.categoriesLabel.font = .boldSystemFont(ofSize: collectionTextSize)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        NewsCacher.shared.searchText = news!.categories[indexPath.row]
        self.goToNewViewController()
        
    }
    
}


// MARK: - Delegate Methods-

extension NewsContentViewController {
    
    @objc func liked() {
        
        guard user != nil else { goToLoginPage(); return }
        guard  !isSelectAnyButton else { return }

        self.isSelectAnyButton = true
        likeButton.isUserInteractionEnabled = false
        dislikeButton.isUserInteractionEnabled = false
        
        if let delegate = delegate, let indexNews = self.indexNews {
            guard  user != nil else { return }
            
            delegate.liked(row: indexNews)
            
            if localNews?.userAction != 1 {
                self.likeLabel.text = (localNews!.liked + 1).formatUsingAbbrevation()
                switch contetTextSize {
                case .firstFont:
                    self.likeButton.setImage( UIImage(named: "like_icon")?.withRenderingMode(.alwaysTemplate), for: .normal )
                    if localNews?.userAction == 2 {
                        self.dislikeButton.setImage( UIImage(named: "undislike_icon")?.withRenderingMode(.alwaysTemplate), for: .normal )
                        self.dislikeLabel.text = (localNews!.disliked - 1).formatUsingAbbrevation()
                    }
                case .secondFont:
                    self.likeButton.setImage( UIImage(named: "like2x_icon")?.withRenderingMode(.alwaysTemplate), for: .normal )
                    if localNews?.userAction == 2 {
                        self.dislikeButton.setImage( UIImage(named: "undislike2x_icon")?.withRenderingMode(.alwaysTemplate), for: .normal )
                        self.dislikeLabel.text = (localNews!.disliked - 1).formatUsingAbbrevation()
                    }
                case .thirdFont:
                    self.likeButton.setImage( UIImage(named: "like3x_icon")?.withRenderingMode(.alwaysTemplate), for: .normal )
                    if localNews?.userAction == 2 {
                        self.dislikeButton.setImage( UIImage(named: "undislike3x_icon")?.withRenderingMode(.alwaysTemplate), for: .normal )
                        self.dislikeLabel.text = (localNews!.disliked - 1).formatUsingAbbrevation()
                    }
                }
                localNews?.userAction = 1
            } else {
                self.likeLabel.text = (localNews!.liked - 1).formatUsingAbbrevation()
                localNews?.userAction = 0
                switch contetTextSize {
                case .firstFont:
                    self.likeButton.setImage( UIImage(named: "unlike_icon")?.withRenderingMode(.alwaysTemplate), for: .normal )
                case .secondFont:
                    self.likeButton.setImage( UIImage(named: "unlike2x_icon")?.withRenderingMode(.alwaysTemplate), for: .normal )
                case .thirdFont:
                    self.likeButton.setImage( UIImage(named: "unlike3x_icon")?.withRenderingMode(.alwaysTemplate), for: .normal )
                }            }
        }
    }
    @objc func disLiked() {
        guard user != nil else { goToLoginPage(); return }

        guard  !isSelectAnyButton else { return }

        self.isSelectAnyButton = true
        likeButton.isUserInteractionEnabled = false
        dislikeButton.isUserInteractionEnabled = false
        
        if let delegate = delegate,let indexNews = self.indexNews {
            
            guard  user != nil else { return }

            delegate.disliked(row: indexNews)
            
            if localNews?.userAction != 2 {
                self.dislikeLabel.text = (localNews!.disliked + 1).formatUsingAbbrevation()
                switch contetTextSize {
                case .firstFont:
                    self.dislikeButton.setImage( UIImage(named: "dislike_icon")?.withRenderingMode(.alwaysTemplate), for: .normal )
                    if localNews?.userAction == 1 {
                        self.likeButton.setImage( UIImage(named: "unlike_icon")?.withRenderingMode(.alwaysTemplate), for: .normal )
                        self.likeLabel.text = (localNews!.liked - 1).formatUsingAbbrevation()
                    }
                case .secondFont:
                    self.dislikeButton.setImage( UIImage(named: "dislike2x_icon")?.withRenderingMode(.alwaysTemplate), for: .normal )
                    if localNews?.userAction == 1 {
                        self.likeButton.setImage( UIImage(named: "unlike2x_icon")?.withRenderingMode(.alwaysTemplate), for: .normal )
                        self.likeLabel.text = (localNews!.liked - 1).formatUsingAbbrevation()
                    }
                case .thirdFont:
                    self.dislikeButton.setImage( UIImage(named: "dislike3x_icon")?.withRenderingMode(.alwaysTemplate), for: .normal )
                    if localNews?.userAction == 1 {
                        self.likeButton.setImage( UIImage(named: "unlike3x_icon")?.withRenderingMode(.alwaysTemplate), for: .normal )
                        self.likeLabel.text = (localNews!.liked - 1).formatUsingAbbrevation()
                    }
                }
                localNews?.userAction = 2
            } else {
                self.dislikeLabel.text = (localNews!.disliked - 1).formatUsingAbbrevation()
                localNews?.userAction = 0
                switch contetTextSize {
                case .firstFont:
                    self.dislikeButton.setImage( UIImage(named: "undislike_icon")?.withRenderingMode(.alwaysTemplate), for: .normal )
                case .secondFont:
                    self.dislikeButton.setImage( UIImage(named: "undislike2x_icon")?.withRenderingMode(.alwaysTemplate), for: .normal )
                    
                case .thirdFont:
                    self.dislikeButton.setImage( UIImage(named: "undislike3x_icon")?.withRenderingMode(.alwaysTemplate), for: .normal )
                }
            }
        }
    }
    @objc func bookmarkTapped() {
        if let delegate = delegate,let indexNews = self.indexNews  {
            delegate.bookmarkTapped(row: indexNews)
            guard  user != nil else { return }
            bookmarkButton = UIBarButtonItem.customButton(self, action: #selector(bookmarkTapped), imageName: localNews!.isBookmarked ? "navi_unbookmark" :  "navi_bookmark", tag: 1)
            let buttons: [UIBarButtonItem] = [shareButton, bookmarkButton, resizeButton ]
            navigationItem.setRightBarButtonItems(buttons, animated: false)
        }
    }
    func watched() {
        if let delegate = delegate,let indexNews = self.indexNews  {
            delegate.wathed(row: indexNews)
        }
    }
    
    @objc func goToNewViewController() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.seaarchtTextChanged), object: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            guard let navigation = self.navigationController else { return }
            for controller in navigation.viewControllers {
                if let newsVC = controller as? NewsPageController {
                    navigation.popToViewController(newsVC, animated: true)
                    return
                }
            }
        })
    }
}

// MARK: - Ads Methods -

extension NewsContentViewController {
    
    func checkUserForAds() {
        AdsManager.shared.checkUserForAds(zoneName: .newArticle) { adsView in
            self.adsViewForDetailNews = adsView
            self.setupAds()
        }
    }
    func setupAds() {
        guard let adsViewForAccount = adsViewForDetailNews else { return }
        
        self.view.addSubview(adsViewForAccount)
        
        adsViewForAccount.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leftAnchor.constraint(equalTo: adsViewForAccount.leftAnchor, constant: -10).isActive = true
        scrollView.rightAnchor.constraint(equalTo: adsViewForAccount.rightAnchor, constant: 10).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: adsViewForAccount.bottomAnchor,constant: 24).isActive = true
        bottomContentInsets = 200
    }
}

//Helper
enum ContentNewsSize: String, Codable  {
    case firstFont
    case secondFont
    case thirdFont
    
    func encode() -> Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }

}
