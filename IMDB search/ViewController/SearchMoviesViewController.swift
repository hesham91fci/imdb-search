//
//  SearchMoviesViewController.swift
//  IMDB search
//
//  Created by Hesham Ali on 7/11/18.
//  Copyright © 2018 Hesham Ali. All rights reserved.
//

import UIKit

class SearchMoviesViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var movieSearchBar: UISearchBar!
    @IBOutlet weak var movieTableView: UITableView!
    var movies=[Movie]()
    var keyword:String!
    let presenter = MoviePresenter()
    var currentPage=0
    var totalPages:Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.movieTableView.delegate = self
        self.movieTableView.dataSource = self
        self.movieSearchBar.delegate = self
        self.presenter.attachView(view: self)
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell", for: indexPath) as! MovieTableViewCell
        let movie = movies[indexPath.row]
        cell.loadMovie(movie: movie)
        return cell
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        if(searchBar.text?.count == 0){
            let alert = UIAlertController(title: "Error", message: "please enter a movie to search for", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        self.currentPage = 0
        self.movies = [Movie]()
        self.movieSearchBar.resignFirstResponder()
        self.keyword = searchBar.text!
        getResults()
        
    }
    
    func getResults(){
        
        if(self.totalPages == nil || self.currentPage<self.totalPages){
            print("searching ...")
            self.currentPage = self.currentPage + 1
            self.presenter.searchMovies(query: self.keyword, page: "\(self.currentPage)")
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
        self.loadMoreMovies(scrollView: scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.loadMoreMovies(scrollView: scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.loadMoreMovies(scrollView: scrollView)
    }
    /*func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.loadMoreMovies(scrollView: scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.loadMoreMovies(scrollView: scrollView)
    }*/
    
    func loadMoreMovies(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height {
            
            self.getResults()
        }
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

extension SearchMoviesViewController: MovieView{
    func setCurrentPage(pageIndex: Int) {
        self.currentPage = pageIndex
    }
    
    func setTotalPages(totalPages: Int) {
        self.totalPages = totalPages
    }
    
    func startLoading() {
        BusyLoader.showBusyIndicator(mainView: self.view)
    }
    
    func finishLoading() {
        BusyLoader.hideBusyIndicator()
    }
    
    func setMovies(movies: [Movie]) {
        self.movieSearchBar.isHidden = false
        self.movies.append(contentsOf: movies)
        print("total movies : \(self.movies.count)")
        if self.currentPage == 1{
            self.movieTableView.setContentOffset(.zero, animated: true)
        }
        self.movieTableView.reloadData()
    }
    
    func setErrorMovies() {
        self.movieSearchBar.isHidden = true
        let alert = UIAlertController(title: "Error", message: "Something went wrong on searching for \(self.keyword!)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setEmptyMovies() {
        self.movieSearchBar.isHidden = true
        let alert = UIAlertController(title: "No Movies", message: "No results found on searching for \(self.keyword!)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
