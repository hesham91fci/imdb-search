//
//  MovieSearchPresenter.swift
//  IMDB search
//
//  Created by Hesham Ali on 7/11/18.
//  Copyright © 2018 Hesham Ali. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
class MovieViewModel {
    
    private var totalResults:PublishSubject<TotalResults> = PublishSubject()
    private var totalMovies:BehaviorRelay<[Movie]> = BehaviorRelay(value: [])
    private let errorSubject = PublishSubject<String>()
    private let isLoadingSubject = PublishSubject<Bool>()
    
    var error: Observable<String> {
        return self.errorSubject.asObservable()
    }
    var observableMovies: Observable<[Movie]>{
        return self.totalMovies.asObservable()
    }
    var observableResults: Observable<TotalResults>{
        return self.totalResults.asObservable()
    }
    var isLoading: Observable<Bool> {
        return self.isLoadingSubject.asObservable()
    }
    func searchMovies(query:String,page:String){
        isLoadingSubject.onNext(true)
        if page=="1"{
            self.totalMovies.accept([])
        }
        MovieServices.sharedMovieServices.searchMovies(query: query, page: page)
            .subscribe(
                onNext: { [weak self] totalResults in
                    self!.totalResults.onNext(totalResults)
                    self!.totalMovies.accept(totalResults.movies + self!.totalMovies.value)
                    self!.isLoadingSubject.onNext(false)
            },
                onError: { [weak self] error in
                    self!.errorSubject.onNext("Error fetching movies")
                    self!.isLoadingSubject.onNext(false)
                }
        )
    }
}
