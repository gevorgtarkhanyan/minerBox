//
//  NewsViewController.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 29.11.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

protocol NewsControllerDelegate: AnyObject {
    func disableButton(_ bool: Bool) -> Void
    
    func searchBarCancelClicked()
    func searchBarSearchClicked()
    func endEditing()
}

class NewsViewController: BaseViewController {
    
    //MARK: - Views -
    @IBOutlet weak var newsTableView: BaseTableView!
    
    private var searchText = NewsCacher.shared.searchText {
        didSet {
            switch newsCategory {
            case .myNews:
                NewsCacher.shared.mySearchText  = self.searchText
            case .topNews:
                NewsCacher.shared.topSearchText = self.searchText
            case .allNews:
                NewsCacher.shared.allSearchText = self.searchText
            case .twitter:
                NewsCacher.shared.tweetSearchText = self.searchText
            }
        }
    }
    
    private var news: [NewsModel] = [] {
        didSet {
            if news.count == 0 {
                if  isBookmarked || !searchText.isNil {
                    showNoDataLabel()
                    noDataButton?.isHidden = true
                } else if newsCategory == .myNews{
                    noDataButton?.isHidden = false
                    hideNoDataLabel()
                }
                delegate?.disableButton(false)
            } else {
                hideNoDataLabel()
                delegate?.disableButton(true)
            }
        }
    }
    
    weak var delegate: NewsControllerDelegate?
    
    private var refreshControl: UIRefreshControl?
    var newsCategory: NewsSegmentTypeEnum = .myNews
    private var isPaginating = false
    private var indexPathForVisibleRow: IndexPath?
    public var isBookmarked: Bool = false
    
    private var skip: Int {
        news.count
    }
    
    private var adsViewForNews = AdsView()
    private var adsManager = AdsManager.shared
    private var isAdsCome = false
    
    private var searchTimer = Timer()
    
    // MARK: - Static
    static func initializeStoryboard() -> NewsViewController? {
        return UIStoryboard(name: "Menu", bundle: nil).instantiateViewController(withIdentifier: NewsViewController.name) as? NewsViewController
    }
    
    //MARK: - Live Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configTableView()
        self.setupNews()
        self.addObservers()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if NewsCacher.shared.updateMyFeed {
            NewsCacher.shared.updateMyFeed = false
            noDataButton?.isHidden = true
            refreshControl = nil
            self.getNews()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeRefreshAction()
        NewsCacher.shared.searchText = nil
    }
    override func languageChanged() {
        title = isBookmarked ? "bookmarks".localized() : "news".localized()
    }
    
    override func configNoDataButton() {
        super.configNoDataButton()
        noDataButton!.setTransferButton(text: "add_sources", subText: "", view: self.view)
        noDataButton?.layoutIfNeeded()
        noDataButton!.addTarget(self, action: #selector(addNewSources), for: .touchUpInside)
    }
    
    //MARK: -- Observers code part
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(hideAds), name: .hideAdsForSubscribeUsers, object: nil)
    }
    
    func configTableView() {
        self.newsTableView.register(UINib(nibName: NewsTableViewCell.name, bundle: nil), forCellReuseIdentifier: NewsTableViewCell.name)
        self.newsTableView.register(UINib(nibName: TopNewsViewCell.name, bundle: nil), forCellReuseIdentifier: TopNewsViewCell.name)
        self.newsTableView.register(AdsTableViewCell.self, forCellReuseIdentifier: AdsTableViewCell.name)
        
    }
    
    //MARK: - Refresh control
    func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = .barSelectedItem
        refreshControl?.addTarget(self, action: #selector(refreshNewsPage), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            newsTableView.refreshControl = refreshControl
        } else {
            newsTableView.backgroundView = refreshControl
        }
    }
    
    func setupNews() {
        guard !isBookmarked else { getNews(); return }
        
        switch self.newsCategory {
        case .myNews:
            let isTimeToGetNews = TimerManager.shared.isLoadingTime(item: .myNews)
            
            if let myNews = NewsCacher.shared.myNews, !isTimeToGetNews, self.searchText ==  NewsCacher.shared.mySearchText {
                self.news = myNews
            } else {
                getNews(searchText: self.searchText)
                NewsCacher.shared.mySearchText = self.searchText
            }
        case .topNews:
            let isTimeToGetNews = TimerManager.shared.isLoadingTime(item: .topNews)
            
            if let topNews = NewsCacher.shared.topNews, !isTimeToGetNews, self.searchText ==  NewsCacher.shared.topSearchText  {
                self.news = topNews
            } else {
                getNews(searchText: self.searchText)
                NewsCacher.shared.topSearchText = self.searchText
            }
        case .allNews:
            let isTimeToGetNews = TimerManager.shared.isLoadingTime(item: .allNews)
            
            if let allNews = NewsCacher.shared.allNews, !isTimeToGetNews, self.searchText ==  NewsCacher.shared.allSearchText  {
                self.news = allNews
            } else {
                getNews(searchText: self.searchText)
                NewsCacher.shared.allSearchText = self.searchText
            }
        case .twitter:
            let isTimeToGetNews = TimerManager.shared.isLoadingTime(item: .tweetNews)
            
            if let tweetNews = NewsCacher.shared.tweetNews, !isTimeToGetNews, self.searchText ==  NewsCacher.shared.tweetSearchText  {
                self.news = tweetNews
            } else {
                getNews(searchText: self.searchText)
                NewsCacher.shared.tweetSearchText = self.searchText
            }
        }
        self.addRefreshControl()
    }
    
    @objc func refreshNewsPage() {
        NewsCacher.shared.removeNews(for: newsCategory)
        getNews(searchText: self.searchText )
    }
    @objc func addNewSources() {
        guard user != nil else { goToLoginPage(); return }
        guard let vc = SourcesViewController.initializeStoryboard() else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func getNews( searchText: String? = nil) {
        if newsCategory == .myNews  {
            guard user != nil  else {
                noDataButton?.isHidden = false
                return }
        }
        if refreshControl.isNil {
            Loading.shared.startLoading()
            addRefreshControl()
        }
        
        NewsManager.shared.getNews(searchText: searchText, skip: 0,tab: isBookmarked ? 3 : newsCategory.getRawValue() ) { news, allNewsCount  in
            self.news = news
            //must be modified //old
            if !self.isBookmarked {
                switch self.newsCategory {
                case .myNews:
                    NewsCacher.shared.myNews = news
                case .topNews:
                    NewsCacher.shared.topNews = news
                case .allNews:
                    NewsCacher.shared.allNews = news
                case .twitter:
                    NewsCacher.shared.tweetNews = news
                }
            }
            self.refreshControl?.endRefreshing()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.isPaginating = news.count == allNewsCount
                self.newsTableView.reloadData()
                self.newsTableView.isHidden = false
                Loading.shared.endLoading()
            }
        } failer: { err in
            print(err)
            self.refreshControl?.endRefreshing()
            Loading.shared.endLoading()
        }
    }
    
    func putLikeOrDiseLike (news: NewsModel,  userActionType: UserAction) {
        
        self.newsTableView.isUserInteractionEnabled = false
        let lastUserAction = news.userAction
        
        NewsManager.shared.putLikeOrDisLikeToBackend( userActionType: userActionType, userAction: news.userAction, _id: news._id) {
            
            self.changeLocalUserAction( news: news, lastUserAction: lastUserAction, userActionType: userActionType)
            self.newsTableView.isUserInteractionEnabled = true
            NotificationCenter.default.post(name: .likeStatusChanged, object: nil)
            print("likedChanged")
        } failer: { err in
            self.newsTableView.isUserInteractionEnabled = true
            print(err)
        }
    }
    
    func putBookmarkState (news: NewsModel, success: @escaping() -> Void) {
        self.newsTableView.isUserInteractionEnabled = false
        NewsManager.shared.putBookmarkState(isBookmarked: news.isBookmarked, _id: news._id) {
            success()
            self.newsTableView.isUserInteractionEnabled = true
            print("Bookmarked State Changed")
        } failer: { err in
            self.newsTableView.isUserInteractionEnabled = true
            print(err)
        }
    }
    
    func removeRefreshAction() {
        // newsTableView.reloadData()
        refreshControl?.endRefreshing()
    }
}

// MARK: - Search delegate
extension NewsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchText.trimmingCharacters(in: .whitespaces)

        
        guard searchText != "" else {
            NewsCacher.shared.searchText = nil
            self.searchText = nil
            self.getNews(searchText: nil)
            return
        }
        guard searchText != NewsCacher.shared.searchText else { return }
        
        NewsCacher.shared.searchText = searchText
        self.searchText = searchText
        
        self.searchTimer.invalidate()
        self.searchTimer = Timer.scheduledTimer(timeInterval: Constants.searchTimeInterval, target: self, selector: #selector(self.searching), userInfo: nil, repeats: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        delegate?.searchBarSearchClicked()
        searchBar.setCancelButtonEnabled(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        NewsCacher.shared.searchText = nil
        self.searchText = nil
        self.getNews(searchText: nil)
        delegate?.searchBarCancelClicked()
        
    }
    
    @objc private func searching() {
        searchTimer.invalidate()
        self.getNews(searchText: self.searchText)
    }
}

//MARK: -NewsPageControllerDelegate -
extension NewsViewController: NewsPageControllerDelegate {
    
    func setCategory(_ category: NewsSegmentTypeEnum) {
        self.newsCategory = category
    }
}

//MARK: - TableViewDelegate  -

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isAdsCome && !news.isEmpty { return news.count + 1 }
        return self.news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if newsCategory == .topNews && indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: TopNewsViewCell.name) as? TopNewsViewCell {
                cell.setData(news: news[indexPath.row], indexPath: indexPath)
                cell.delegate = self
                return cell
            }
        }
        if   news.count < 2  && isAdsCome && indexPath.row == news.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: AdsTableViewCell.name) as! AdsTableViewCell
            adsViewForNews.translatesAutoresizingMaskIntoConstraints = false
            cell.setData(view: adsViewForNews)
            return cell
            
        }
        if isAdsCome && indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: AdsTableViewCell.name) as! AdsTableViewCell
            adsViewForNews.translatesAutoresizingMaskIntoConstraints = false
            cell.setData(view: adsViewForNews)
            return cell
            
        }
        
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.name) as? NewsTableViewCell {
            guard news.count > 0 else { return UITableViewCell() }
            
            let currentNews = isAdsCome && indexPath.row > 2 ? news[indexPath.row - 1] : news[indexPath.row]
            let currentRow =  isAdsCome && indexPath.row > 2 ? indexPath.row - 1 : indexPath.row
            
            
            cell.setData(news: currentNews, row: currentRow)
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isAdsCome && indexPath.row == 2 {return}
        if  !news.isEmpty && news.count < 2  && isAdsCome && indexPath.row == news.count { return }
        guard let vc = NewsContentViewController.initializeStoryboard() else { return }
        let currentNews = isAdsCome && indexPath.row > 2 ? news[indexPath.row - 1] : news[indexPath.row]
        
        vc.localNews = currentNews
        vc.indexNews = isAdsCome && indexPath.row > 2 ? indexPath.row - 1:  indexPath.row
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if isAdsCome && indexPath.row == 2  { return AdsTableViewCell.height }
        
        if newsCategory == .topNews && indexPath.row == 0 {
            return TopNewsViewCell.height
        }
        
        if isAdsCome && indexPath.row   == news.count && news.count < 2 { return AdsTableViewCell.height }
        
        return NewsTableViewCell.height
    }
}


//MARK: - Pagination
extension NewsViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if newsCategory == .myNews  {
            guard user != nil  else {
                noDataButton?.isHidden = false
                removeRefreshAction()
                return
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard let indexPathsForVisibleRows = self.newsTableView.indexPathsForVisibleRows, !indexPathsForVisibleRows.isEmpty else { return }
            self.indexPathForVisibleRow = indexPathsForVisibleRows.first
        }
        
        let position = scrollView.contentOffset.y
        
        if position > newsTableView.contentSize.height - scrollView.frame.size.height * 0.85 {
            if !isPaginating {
                newsTableView.tableFooterView = createIndicatorFooter()
                Loading.shared.endLoading()
                self.isPaginating = true
                
                NewsManager.shared.getNews(searchText: self.searchText, skip: skip, tab:  isBookmarked ? 3 : newsCategory.getRawValue() ) { news, allNewsCount in
                    self.news += news
                    if !self.isBookmarked {
                        //must be modified //old
                        switch self.newsCategory {
                        case .myNews:
                            NewsCacher.shared.myNews = news
                        case .topNews:
                            NewsCacher.shared.topNews = news
                        case .allNews:
                            NewsCacher.shared.allNews = news
                        case .twitter:
                            NewsCacher.shared.tweetNews = news
                        }
                    }
                    DispatchQueue.main.async {
                        self.newsTableView.tableFooterView = nil
                        if news.count < 1 {
                            self.newsTableView.separatorStyle = .none
                        }
                        self.newsTableView.reloadData()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.isPaginating = news.count == allNewsCount
                    }
                } failer: { err in
                    print(err)
                    self.showAlertView("", message: err.localized(), completion: nil)
                    self.newsTableView.tableFooterView = nil
                    self.isPaginating = false
                }
            }
        }
    }
    
    private func createIndicatorFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        Loading.shared.startLoadingForView(with: footerView)
        return footerView
    }
}

//MARK: - TopNewsViewCellDelegate and NewsTableViewCellDelegate  -

extension NewsViewController: NewsTableViewCellDelegate, TopNewsViewCellDelegate, NewsContentViewControllerDelegate {
    
    func wathed(row: Int) {
        // += 1
        let news = self.news[row]
        _ = NewsCacher.shared.myNews?.map{
            if $0.newsId == news.newsId {
                $0.watched += 1
            }
        }
        _ = NewsCacher.shared.topNews?.map {
            if $0.newsId == news.newsId {
                $0.watched += 1
            }
        }
        _ = NewsCacher.shared.allNews?.map {
            if $0.newsId == news.newsId {
                $0.watched += 1
            }
        }
        _ = NewsCacher.shared.tweetNews?.map {
            if $0.newsId == news.newsId {
                $0.watched += 1
            }
        }

        if isBookmarked {
            self.news[row].watched += 1
        }
        self.newsTableView.reloadData()
    }
    
    func liked(row: Int) {
        guard user != nil else { goToLoginPage(); return }
        
        let news = self.news[row]
        putLikeOrDiseLike(news: news, userActionType:news.userAction == 1 ? .unlike : .like)
        
    }
    
    func disliked(row: Int) {
        guard user != nil else { goToLoginPage(); return }
        
        let news = self.news[row]
        putLikeOrDiseLike(news: news, userActionType: news.userAction == 2 ? .undislike : .dislike)
    }
    
    func changeLocalUserAction( news: NewsModel, lastUserAction: Double, userActionType: UserAction ) {
        switch userActionType {
        case .like:
            if lastUserAction == 2 { news.disliked -= 1 }
            news.liked += 1
            news.userAction = 1
        case .dislike:
            if lastUserAction == 1 { news.liked -= 1 }
            news.disliked += 1
            news.userAction = 2
        case .undislike:
            news.disliked -= 1
            news.userAction = 0
        case.unlike:
            news.liked -= 1
            news.userAction = 0
        }
        
        _ = NewsCacher.shared.myNews?.map {
            if $0.newsId == news.newsId {
                $0.liked = news.liked
                $0.disliked = news.disliked
                $0.userAction = news.userAction
            }
        }
        _ = NewsCacher.shared.topNews?.map {
            if $0.newsId == news.newsId {
                $0.liked = news.liked
                $0.disliked = news.disliked
                $0.userAction = news.userAction
            }
        }
        _ = NewsCacher.shared.allNews?.map {
            if $0.newsId == news.newsId {
                $0.liked = news.liked
                $0.disliked = news.disliked
                $0.userAction = news.userAction
            }
        }
        self.newsTableView.reloadData()
    }
    
    func bookmarkTapped(row: Int) {
        guard user != nil else { goToLoginPage(); return }
        
        let news = self.news[row]
        
        putBookmarkState(news: news) {
            news.isBookmarked.toggle()
            if self.isBookmarked { self.news.remove(at: row) }
            self.newsTableView.reloadData()
            
            _ = NewsCacher.shared.myNews?.map{
                if $0.newsId == news.newsId {
                    $0.isBookmarked = news.isBookmarked
                }
            }
            _ = NewsCacher.shared.topNews?.map{
                if $0.newsId == news.newsId {
                    $0.isBookmarked = news.isBookmarked
                }
            }
            _ = NewsCacher.shared.allNews?.map{
                if $0.newsId == news.newsId {
                    $0.isBookmarked = news.isBookmarked
                }
            }
        }
        
    }
}

// MARK: - Ads Methods
extension NewsViewController {
    
    @objc func hideAds() {
        self.isAdsCome = false
        self.newsTableView.reloadData()
    }
    
    func checkUserForAds() {
        var zoneName: ZoneName = .newsMyFeed
        switch newsCategory {
        case .myNews:
            zoneName = .newsMyFeed
        case .topNews:
            zoneName = .newsTop
        case .allNews:
            zoneName = .newsAll
        case .twitter:
            zoneName = .newsTweets
        }
        self.adsManager.checkUserForAds(zoneName: zoneName,isAdsTableView: true) { adsView in
            self.adsViewForNews = adsView
            self.isAdsCome = true
            self.newsTableView.reloadData()
        }
    }
}



