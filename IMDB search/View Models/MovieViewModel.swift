//
//  MovieSearchPresenter.swift
//  IMDB search
//
//  Created by Hesham Ali on 7/11/18.
//  Copyright © 2018 Hesham Ali. All rights reserved.
//

import Foundation
import UIKit


class MovieViewModel {
    
    var totalResults:TotalResults!
    var startSearchingMovies:(() -> Void)!
    var didFinishSearchingMovies:((_ totalMovies: Int,_ totalPages: Int) -> Void)!
    var didFinishSearchingMoviesWithError:(()-> Void)!
    func searchMovies(query:String,page:String){
        self.startSearchingMovies()
        MovieServices.sharedMovieServices.searchMovies(query: query, page: page) { (success, totalResults) in
            if(success){
                if(totalResults?.movies.count == 0){
                    self.didFinishSearchingMovies(0,0)
                }
                else{
                    self.totalResults = totalResults!
                    self.didFinishSearchingMovies((totalResults?.movies.count)!,totalResults!.totalPages)
                }
                
            }
            else{
                self.didFinishSearchingMoviesWithError()
            }
        }
    }
    func getMovie(atIndex index:Int)->Movie{
        return totalResults.movies[index]
    }
}
