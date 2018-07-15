//
//  TestableMovieView.swift
//  IMDB searchTests
//
//  Created by Hesham Ali on 7/15/18.
//  Copyright © 2018 Hesham Ali. All rights reserved.
//

import Foundation
class TestableMovieView: NSObject, MovieView {
    
    var currentPage=0
    var totalPages:Int!
    var movies=[Movie]()
    var recentSearches=[String]()
    var keyword:String!
    func `init`(keyword:String){
        self.keyword = keyword
    }
    func setCurrentPage(pageIndex: Int) {
        self.currentPage = pageIndex
    }
    
    func setTotalPages(totalPages: Int) {
        self.totalPages = totalPages
    }
    
    func startLoading() {
        return
    }
    
    func finishLoading() {
        return
    }
    
    func setMovies(movies: [Movie]) {
        
        self.addKeywordToRecentSearches()
        self.movies.append(contentsOf: movies)
        print("Number of movies \(movies.count)")
    }
    
    func setErrorMovies() {
        self.movies = [Movie]()
    }
    
    func setEmptyMovies() {
        self.movies = [Movie]()
    }
    
    func addKeywordToRecentSearches(){
        if(!self.recentSearches.contains(self.keyword)){
            if(self.recentSearches.count==10){
                self.recentSearches.removeFirst()
            }
            self.recentSearches.append(self.keyword)
        }
    }
}
