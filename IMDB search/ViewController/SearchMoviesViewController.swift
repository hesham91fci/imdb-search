//
//  SearchMoviesViewController.swift
//  IMDB search
//
//  Created by Hesham Ali on 7/11/18.
//  Copyright © 2018 Hesham Ali. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
class SearchMoviesViewController: UIViewController {
    @IBOutlet weak var recentSearchesTableView: UITableView!
    @IBOutlet weak var movieSearchBar: UISearchBar!
    @IBOutlet weak var movieTableView: UITableView!
    @IBOutlet weak var recentSearchHeightConstraint: NSLayoutConstraint!
    let disposeBag = DisposeBag()
    var keyword: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    let movieViewModel = MovieViewModel()
    let recentSearchesViewModel = RecentSearchesViewModel()
    var currentPage: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    var totalPages: Int = 0
    var totalMovies=0
    override func viewDidLoad() {
        super.viewDidLoad()
        initSubscribers()
        initUISubscribers()
        bindMovieViewModelBehaviors()

        self.movieTableView.estimatedRowHeight = 550
        self.movieTableView.rowHeight = UITableView.automaticDimension
    }

    func bindMovieViewModelBehaviors() {
        self.movieSearchBar.rx.text.orEmpty.bind(to: movieViewModel.keywordRelay).disposed(by: disposeBag)
        self.movieSearchBar.rx.text.orEmpty.bind(to: keyword).disposed(by: disposeBag)
        self.currentPage.bind(to: movieViewModel.pageRelay).disposed(by: disposeBag)
    }

    func initUISubscribers() {
        initSearchBarClickSubscription()
        initRecentSearchesClickSubscription()
        initSearchBarBeginEditSubscription()
        initRecentSearchesSubscription()
    }

    func initSearchBarClickSubscription() {
        self.movieSearchBar.rx.searchButtonClicked.subscribe(onNext: {[unowned self] _ in
            self.view.endEditing(true)
            if self.movieSearchBar.text?.count == 0 {
                let alert = UIAlertController(title: "Error", message: "please enter a movie to search for", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            //self.keyword.accept(<#T##event: String##String#>) = !
            self.updateRecentSearchesTableHeight(height: 0)
            self.initSearchMovies()
            self.getResults()
        }).disposed(by: disposeBag)
    }

    func initRecentSearchesClickSubscription() {
        self.recentSearchesTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.updateRecentSearchesTableHeight(height: 0)
                self?.keyword.accept(self?.recentSearchesViewModel.getKeyword(atIndex: indexPath.row) ?? "")
                self?.initSearchMovies()
                self?.getResults()
            }).disposed(by: disposeBag)
    }
    func initSearchBarBeginEditSubscription() {
        self.movieSearchBar.rx.textDidBeginEditing.subscribe(onNext: { [unowned self] _ in
            if self.recentSearchesViewModel.isNotEmptyRecentSearches() {
                self.updateRecentSearchesTableHeight(height: 300)
            }
        }).disposed(by: disposeBag)
    }

    func initSearchMovies() {
        self.currentPage.accept(0)
        self.movieSearchBar.resignFirstResponder()
    }

    func getResults() {
        let isMoreResultsExists = self.currentPage.value<self.totalPages || self.currentPage.value == 0
        if isMoreResultsExists && !BusyLoader.isLoading() {
            self.currentPage.accept(self.currentPage.value + 1)
            print("will search in page \(self.currentPage.value)")
            self.movieViewModel.searchMovies()
        }

    }

    func loadMoreMovies() {
        let offsetY = self.movieTableView.contentOffset.y
        let contentHeight = self.movieTableView.contentSize.height

        if offsetY > contentHeight - self.movieTableView.frame.size.height {

            self.getResults()
        }
    }

    func updateRecentSearchesTableHeight(height: Int) {
        self.recentSearchHeightConstraint.constant = CGFloat(height)
        self.recentSearchesTableView.layoutIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchMoviesViewController {

    func initSubscribers() {
        initLoadingObservable()
        initMoviesObservables()
        initErrorSubscription()
    }

    func initLoadingObservable() {
        self.movieViewModel.isLoading.asObservable().subscribe(
            onNext: { [unowned self] isLoading in
                if isLoading {
                    BusyLoader.showBusyIndicator(mainView: self.view)
                } else {
                    BusyLoader.hideBusyIndicator()
                }
            }).disposed(by: disposeBag)
    }

    func initMoviesObservables() {
        observeForMovies()
        observeForTotalResults()
    }

    func observeForMovies() {
        self.movieViewModel.observableMovies
            .bind(to: self.movieTableView
                .rx
                .items(cellIdentifier: "MovieTableViewCell",
                       cellType: MovieTableViewCell.self)) { _, movie, cell in
                        cell.loadMovie(movie: movie)
            }
            .disposed(by: disposeBag)
    }

    func observeForTotalResults() {
        self.movieViewModel.observableResults.subscribe(onNext: { [unowned self] totalResults in
            self.totalPages = totalResults.totalPages
            if !self.recentSearchesViewModel.isKeywordAlreadyExists(keyword: self.keyword.value) {
                self.recentSearchesViewModel.addKeywordToRecentSearches(keyword: self.keyword.value)
            }
            if totalResults.movies.isEmpty {
                self.setEmptyMovies()
            }
            self.movieTableView.rx.contentOffset.subscribe(
                onNext: { [unowned self] _ in
                    self.loadMoreMovies()
            }).disposed(by: self.disposeBag)
        }).disposed(by: self.disposeBag)
    }

    func initRecentSearchesSubscription() {
        self.recentSearchesViewModel.recentSearchesObservable
            .bind(to: self.recentSearchesTableView
                .rx
                .items(cellIdentifier: "RecentSearchesTableViewCell",
                       cellType: RecentSearchesTableViewCell.self)) { _, recentSearch, cell in
                        cell.loadSearch(recentSearch: recentSearch)
            }
            .disposed(by: disposeBag)
    }

    func initErrorSubscription() {
        self.movieViewModel.error.subscribe(onNext: { [unowned self] _ in
            let alert = UIAlertController(title: "Error", message: "Something went wrong on searching for \(self.keyword.value)", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            }).disposed(by: disposeBag)

    }

    func setEmptyMovies() {
        let alert = UIAlertController(title: "No Movies", message: "No results found on searching for \(self.keyword.value)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
