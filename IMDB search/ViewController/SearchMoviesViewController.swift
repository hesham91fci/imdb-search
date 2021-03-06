//
//  SearchMoviesViewController.swift
//  IMDB search
//
//  Created by Hesham Ali on 7/11/18.
//  Copyright © 2018 Hesham Ali. All rights reserved.
//

import UIKit
class SearchMoviesViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var recentSearchesTableView: UITableView!
    @IBOutlet weak var movieSearchBar: UISearchBar!
    @IBOutlet weak var movieTableView: UITableView!
    @IBOutlet weak var recentSearchHeightConstraint: NSLayoutConstraint!
    var keyword:String!
    let movieViewModel = MovieViewModel()
    var currentPage=0
    var totalPages:Int!
    var totalMovies=0
    var recentSearches=[String]()
    let maximumRecentSearches = 10
    override func viewDidLoad() {
        super.viewDidLoad()
        initCallbacks()
        self.movieTableView.delegate = self
        self.movieTableView.dataSource = self
        self.movieSearchBar.delegate = self
        
        self.recentSearchesTableView.delegate = self
        self.recentSearchesTableView.dataSource = self
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if(tableView == self.movieTableView){
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell", for: indexPath) as! MovieTableViewCell
            cell.loadMovie(movie: movieViewModel.getMovie(atIndex: indexPath.row))
            return cell
        }
        else if(self.recentSearchHeightConstraint.constant != CGFloat(0)){
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
        if(!self.recentSearches.contains(self.keyword)){
            if(self.recentSearches.count==maximumRecentSearches){
                self.recentSearches.removeFirst()
            }
            self.recentSearches.append(self.keyword)
        }
    }
    
    func getResults(){
        let isKeyWordToSearch = self.keyword != nil
        let isSearchResultsRetrieved = self.totalPages != nil
        let isMoreResultsExists = isSearchResultsRetrieved && self.currentPage<self.totalPages
        if(isKeyWordToSearch && (!isSearchResultsRetrieved || isMoreResultsExists) ) {
            self.currentPage = self.currentPage + 1
            self.movieViewModel.searchMovies(query: self.keyword, page: "\(self.currentPage)")
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(self.movieTableView == scrollView){
            view.endEditing(true)
            self.loadMoreMovies(scrollView: scrollView)
        }
    }
    
    func loadMoreMovies(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height {
            
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
    func initCallbacks(){
        self.movieViewModel.startSearchingMovies = self.startSearchingMovies
        self.movieViewModel.didFinishSearchingMovies = self.didLoadMovies
        self.movieViewModel.didFinishSearchingMoviesWithError = self.setErrorMovies
        
    }
    
    func startSearchingMovies() {
        BusyLoader.showBusyIndicator(mainView: self.view)
    }
    
    func didLoadMovies(totalMovies:Int, totalPages:Int) {
        BusyLoader.hideBusyIndicator()
        self.totalMovies = totalMovies
        self.totalPages = totalPages
        if totalMovies == 0{
            self.setEmptyMovies()
            return
        }
        self.movieTableView.isHidden = false
        self.addKeywordToRecentSearches()
        self.movieTableView.reloadData()
        if self.currentPage == 1{
            self.movieTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: true)
        }
    }
    
    func setErrorMovies() {
        self.movieTableView.isHidden = true
        let alert = UIAlertController(title: "Error", message: "Something went wrong on searching for \(self.keyword!)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setEmptyMovies() {
        self.movieTableView.isHidden = true
        let alert = UIAlertController(title: "No Movies", message: "No results found on searching for \(self.keyword!)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
