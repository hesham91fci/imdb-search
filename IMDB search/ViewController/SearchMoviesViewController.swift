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
class SearchMoviesViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet weak var recentSearchesTableView: UITableView!
    @IBOutlet weak var movieSearchBar: UISearchBar!
    @IBOutlet weak var movieTableView: UITableView!
    @IBOutlet weak var recentSearchHeightConstraint: NSLayoutConstraint!
    let disposeBag = DisposeBag()
    var keyword:String!
    let movieViewModel = MovieViewModel()
    var currentPage=0
    var totalPages:Int = 0
    var totalMovies=0
    var recentSearches=[String]()
    let maximumRecentSearches = 10
    override func viewDidLoad() {
        super.viewDidLoad()
        initSubscribers()
        self.movieSearchBar.delegate = self

        self.movieTableView.estimatedRowHeight = 550
        self.movieTableView.rowHeight = UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.movieTableView){
            return self.totalMovies
        }
        else{
            return recentSearches.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if(self.recentSearchHeightConstraint.constant != CGFloat(0)){
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecentSearchesTableViewCell", for: indexPath) as! RecentSearchesTableViewCell
            cell.loadSearch(recentSearch: self.recentSearches[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView == self.recentSearchesTableView){
            self.updateRecentSearchesTableHeight(height: 0)
            self.keyword = self.recentSearches[indexPath.row]
            self.initSearchMovies()
            self.getResults()
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if(self.recentSearches.count != 0){
            self.updateRecentSearchesTableHeight(height: 300)
            self.recentSearchesTableView.reloadData()
        }
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        if(searchBar.text?.count == 0){
            let alert = UIAlertController(title: "Error", message: "please enter a movie to search for", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        self.keyword = searchBar.text!
        self.updateRecentSearchesTableHeight(height: 0)
        self.initSearchMovies()
        getResults()
    }
    
    func initSearchMovies(){
        self.currentPage = 0
        self.movieSearchBar.resignFirstResponder()
    }
    
    func addKeywordToRecentSearches(){
        if(!self.recentSearches.contains(self.keyword.lowercased())){
            if(self.recentSearches.count==maximumRecentSearches){
                self.recentSearches.removeFirst()
            }
            self.recentSearches.append(self.keyword.lowercased())
        }
    }
    
    func getResults(){
        let isMoreResultsExists = self.currentPage<self.totalPages || self.currentPage == 0
        if(isMoreResultsExists && !BusyLoader.isLoading() ) {
            self.currentPage = self.currentPage + 1
            print("will search in page \(self.currentPage)")
            self.movieViewModel.searchMovies(query: self.keyword, page: "\(self.currentPage)")
        }
        
    }
    

    
    func loadMoreMovies() {
        let offsetY = self.movieTableView.contentOffset.y
        let contentHeight = self.movieTableView.contentSize.height
        
        if offsetY > contentHeight - self.movieTableView.frame.size.height {
            
            self.getResults()
        }
    }
    
    func updateRecentSearchesTableHeight(height:Int){
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

extension SearchMoviesViewController{
    
    func initSubscribers(){
        initLoadingObservable()
        initMoviesObservables()
        initErrorSubscription()
    }
    
    func initLoadingObservable(){
        self.movieViewModel.isLoading.asObservable().subscribe(
            onNext: { [unowned self] isLoading in
                if isLoading{
                    BusyLoader.showBusyIndicator(mainView: self.view)
                }
                else{
                    BusyLoader.hideBusyIndicator()
                }
                
        })
    }

    
    func initMoviesObservables() {
        self.movieViewModel.observableMovies
            .bind(to: self.movieTableView
                .rx
                .items(cellIdentifier: "MovieTableViewCell",
                       cellType: MovieTableViewCell.self)) { row, movie, cell in
                        cell.loadMovie(movie: movie)
            }
            .disposed(by: disposeBag)
        self.movieViewModel.observableResults.subscribe(onNext: { [unowned self] totalResults in
            self.totalPages = totalResults.totalPages
            
            self.movieTableView.rx.contentOffset.subscribe(
                onNext: { [unowned self] _ in
                    self.loadMoreMovies()
            }).disposed(by: self.disposeBag)
        })
    }
    
    func initErrorSubscription() {
        self.movieViewModel.error.subscribe(onNext: { [unowned self] String in
            let alert = UIAlertController(title: "Error", message: "Something went wrong on searching for \(self.keyword!)", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        })
        
    }
    
    func setEmptyMovies() {
        let alert = UIAlertController(title: "No Movies", message: "No results found on searching for \(self.keyword!)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
