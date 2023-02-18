//
//  NewsPageViewController.swift
//  MinerBox
//
//  Created by Vazgen Hovakimyan on 29.11.21.
//  Copyright © 2021 WitPlex. All rights reserved.
//

import UIKit

protocol NewsPageControllerDelegate: AnyObject {
    func setCategory(_ category: NewsSegmentTypeEnum) -> Void
}

class NewsPageController: BaseViewController {
    
    //MARK: - Views -
    @IBOutlet weak var newsSegmentControl: BaseSegmentControl!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchBar: BaseSearchBar!
    @IBOutlet weak var searchBarHeigthConstraits: NSLayoutConstraint!
    
    private let newsCategories = NewsSegmentTypeEnum.allCases
    private var currentController: NewsViewController?
    private var isRefreshed = false
    private var currentIndex: Int?
    
    private var addButton: UIBarButtonItem!
    private var bookmarkButton: UIBarButtonItem!
    private var searchButton: UIBarButtonItem!
    private var isFromContentView = false
    private var isAddedSourceEnpty: Bool = true

    weak var delegate: NewsPageControllerDelegate?
    
    // MARK: - Static
    static func initializeStoryboard() -> NewsPageController? {
        return UIStoryboard(name: "Menu", bundle: nil).instantiateViewController(withIdentifier: NewsPageController.name) as? NewsPageController
    }
    
    //MARK: - Live Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        checkAddedSources()
        setupSegmentControl()
        addObservers()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkAddedSources()
    }
    override func languageChanged() {
        title = "news".localized()
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateChildControler), name: NSNotification.Name(Constants.seaarchtTextChanged), object: nil)
    }
    
    @objc public func refreshPage(_ sender: Any?) {
        isRefreshed = true
        currentIndex = nil
        newsSegmentControl.setSelectedIndex(with: isAddedSourceEnpty ? 2 : 0)
    }
    
    @objc func updateChildControler() {
        _showSearchBar()
        searchBar.text = NewsCacher.shared.searchText
        isFromContentView = true
        switch currentIndex {
        case 0:
            segmentSelected(newsSegmentControl, index: 0)
        case 1:
            segmentSelected(newsSegmentControl, index: 1)
        case 2:
            segmentSelected(newsSegmentControl, index: 2)
        default:
            print("Not exist Tab")
        }
    }
    func checkAddedSources() {
        if let isEnpty = UserDefaults.shared.value(forKey: "added_sources_enpty") as? Bool {
            self.isAddedSourceEnpty = isEnpty
        }
    }
    
    func setupNavigation() {
        navigationController?.navigationBar.shadowImage = UIImage()
        
        addButton = UIBarButtonItem.customButton(self, action: #selector(addNewSources), imageName: "navigation_plus_button", tag: 0)
        bookmarkButton = UIBarButtonItem.customButton(self, action: #selector(openBookmarkPage), imageName: "navi_bookmark", tag: 1)
        searchButton = UIBarButtonItem.customButton(self, action: #selector(_showSearchBar), imageName: "bar_search")

        searchButton.isEnabled = false
        
    }
    
    //MARK: -- SegmentControl Setup
    private func setupSegmentControl() {
        let segmentTitles = newsCategories.map { $0.rawValue }
        
        newsSegmentControl.delegate = self
        
        newsSegmentControl.setSegments(segmentTitles)
        newsSegmentControl.selectSegment(index: isAddedSourceEnpty ? 2 : 0)
        
    }
    
    
    //MARK: - Action -

    @objc func addNewSources() {
        guard user != nil else { goToLoginPage(); return   }
        guard let vc = SourcesViewController.initializeStoryboard() else { return }
        navigationController?.pushViewController(vc, animated: true)
        currentController?.newsTableView.isHidden = true
    }
    
    @objc func openBookmarkPage() {
        guard let vc = NewsViewController.initializeStoryboard() else { return }
        vc.isBookmarked = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //search
    private func hideSearchBar() {
        if !searchBar.isHidden {
            searchBar.text = ""
            view.endEditing(true)
            let buttons: [UIBarButtonItem] = currentIndex == 0 ? [addButton, searchButton, bookmarkButton ] :  [searchButton, bookmarkButton ]
            navigationItem.setRightBarButtonItems(buttons, animated: false)
            
            UIView.animate(withDuration: Constants.animationDuration, animations: {
                self.searchBarHeigthConstraits.constant = 0
                self.view.layoutIfNeeded()
            }) { (_) in
                self.searchBar.isHidden = true
            }
        }
    }

    @objc private func _showSearchBar() {
        if searchBar.isHidden {
            searchBar.isHidden = false
            let buttonItems: [UIBarButtonItem] = currentIndex == 0 ? [addButton, bookmarkButton ] :  [ bookmarkButton ]
            navigationItem.setRightBarButtonItems(buttonItems, animated: true)
            
            UIView.animate(withDuration: Constants.animationDuration) {
                self.searchBarHeigthConstraits.constant = 40
                self.searchBar.becomeFirstResponder()
                self.view.layoutIfNeeded()
            }
        }
    }
}

// MARK: - Segment control delegate
extension NewsPageController: BaseSegmentControlDelegate {
    func segmentSelected(_ sender: BaseSegmentControl, index: Int) {
        segmentAction(with: index)
    }
    
    private func segmentAction(with index: Int) {
        if isRefreshed {
            isRefreshed = false
            newsSegmentControl.selectSegment(index: isAddedSourceEnpty ? 2 : 0)
        }
        
        if index != currentIndex || isFromContentView {
           self.isFromContentView = false
           if let newVC = NewsViewController.initializeStoryboard() {
            searchBar.delegate = newVC
            delegate = newVC
            newVC.delegate = self
            navigationItem.setRightBarButton(nil, animated: false)
            let newsType = newsCategories[index]
            
            delegate?.setCategory(newsType)
            newVC.checkUserForAds()
            let toRight = currentIndex == nil ? nil : index > currentIndex!
            changeChildVC(to: newVC, toRight: toRight)
            
            currentIndex = index
            newsSegmentControl.setBadgeNumber(0, for: index)
            let isShowSearchbar = NewsCacher.shared.searchText.isNil && searchBarHeigthConstraits.constant < 1
            let buttons: [UIBarButtonItem] = index == 0 ? ( isShowSearchbar ? [ addButton, searchButton, bookmarkButton ] : [ addButton, bookmarkButton]) :  ( isShowSearchbar ? [searchButton, bookmarkButton ] : [bookmarkButton ] )
            navigationItem.setRightBarButtonItems(buttons, animated: false)
//            navigationController?.popToRootViewController(animated: true)
          }
       }
    }
}

//MARK: -- Change child VC
extension NewsPageController {
    private func changeChildVC(to controller: NewsViewController, toRight: Bool?) {
        addChild(controller)
        guard let controllerView = controller.view else { return }
        
        let from = currentController
        containerView.addSubview(controllerView)
        controllerView.frame = containerView.frame
        
        if let right = toRight { // Change with animation
            controllerView.frame.origin = CGPoint(x: containerView.frame.width * (right ? 1 : -1), y: 0)
            
            let toFrame = containerView.bounds
            var fromFrame = containerView.bounds
            fromFrame.origin = CGPoint(x: containerView.frame.width * (right ? -1 : 1), y: 0)
            
            UIView.animate(withDuration: 1.5 * Constants.animationDuration, animations: {
                from?.view.frame = fromFrame
                controllerView.frame = toFrame
            }) { (_) in
                from?.willMove(toParent: nil)
                from?.view.removeFromSuperview()
                from?.removeFromParent()
            }
        } else { // Change without animation. Just replace
            controllerView.frame = containerView.bounds
            
            from?.willMove(toParent: nil)
            from?.view.removeFromSuperview()
            from?.removeFromParent()
        }
        
        controller.didMove(toParent: self)
        currentController = controller
    }
}


//MARK: - NewsControllerDelegate -

extension NewsPageController: NewsControllerDelegate {
    
    func searchBarCancelClicked() {
        hideSearchBar()
    }
    
    func searchBarSearchClicked() {
        endEditing()
        searchBar.setCancelButtonEnabled(true)
    }
    
    func endEditing() {
        view.endEditing(true)
        searchBar.setCancelButtonEnabled(true)
    }
    
    
    func disableButton(_ bool: Bool) {
        searchButton.isEnabled = bool
        view.layoutIfNeeded()
    }
}

// MARK: - Helpers
enum NewsSegmentTypeEnum: String, CaseIterable {
    case myNews = "my_feed"
    case topNews = "top"
    case allNews = "all"
    case twitter = "Twitter"

    
    func getRawValue() -> Int {
        switch self {
        case .myNews:
            return 0
        case .topNews:
            return 1
        case .allNews:
            return 4
        case .twitter:
            return 5
        }
    }
}

// MARK: - Helper
class NewsCacher {
    static let shared = NewsCacher()
    
    private init(){}
    
    var myNews: [NewsModel]?
    var topNews: [NewsModel]?
    var allNews: [NewsModel]?
    var tweetNews: [NewsModel]?
    var searchText: String?
    var mySearchText: String?
    var topSearchText: String?
    var allSearchText: String?
    var tweetSearchText: String?
    var updateMyFeed: Bool = false
    
    func removeNewsData() {
        myNews = nil
        topNews = nil
        allNews = nil
        searchText = nil
        tweetNews = nil
    }
    
    func removeNews(for newsCategory: NewsSegmentTypeEnum) {
        switch newsCategory {
        case .myNews:
            myNews = nil
        case .topNews:
            topNews = nil
        case .allNews:
            allNews = nil
        case .twitter:
            tweetNews = nil
        }
    }
}

