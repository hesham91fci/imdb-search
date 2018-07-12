//
//  MovieSearchPresenter.swift
//  IMDB search
//
//  Created by Hesham Ali on 7/11/18.
//  Copyright © 2018 Hesham Ali. All rights reserved.
//

import Foundation
import UIKit



protocol MovieView: NSObjectProtocol {
    func startLoading()
    func finishLoading()
    func setMovies(movies: [Movie])
    func setErrorMovies()
    func setEmptyMovies()
    func setCurrentPage(pageIndex: Int)
    func setTotalPages(totalPages: Int)
}
class MoviePresenter {
    weak private var movieView : MovieView?
    
    func attachView(view:MovieView)  {
        self.movieView=view
    }
    func dettachView(){
        self.movieView = nil
    }
    
    func searchMovies(query:String,page:String){
       // movieView?.startLoading()
        MovieServices.sharedMovieServices.searchMovies(query: query, page: page) { (success, totalResults) in
         //   self.movieView?.finishLoading()
            if(success){
                if(totalResults?.movies.count == 0){
                    self.movieView?.setEmptyMovies()
                }
                else{
                    self.movieView?.setMovies(movies: (totalResults?.movies)!)
                    self.movieView?.setTotalPages(totalPages: (totalResults?.totalPages)!)
                    self.movieView?.setCurrentPage(pageIndex: (totalResults?.pageIndex)!)
                }
                
            }
            else{
                self.movieView?.setErrorMovies()
            }
        }
    }
}
