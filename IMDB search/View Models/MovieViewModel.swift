//
//  MovieSearchPresenter.swift
//  IMDB search
//
//  Created by Hesham Ali on 7/11/18.
//  Copyright © 2018 Hesham Ali. All rights reserved.
//

import Foundation
import UIKit
import Combine
class MovieViewModel: ObservableObject {

    private var subscriptions: [AnyCancellable] = []
    private(set) var totalResults: TotalResults!
    @Published private(set) var totalMovies: [Movie] = []
    private var page: Int! = 1
    @Published var keyword = ""
    let saveRecentSearch: PassthroughSubject<Void, Never> = PassthroughSubject()
    func searchMovies() {
        if page==1 {
            self.totalMovies = []
        }
        subscriptions.forEach { $0.cancel() }
        subscriptions.append(MovieServices().searchMovies(query: keyword, page: page.description)
        .sink(receiveCompletion: { (error) in
            print("error \(error)")
        }, receiveValue: { [weak self] (totalResults) in
            self?.saveRecentSearch(movies: totalResults.movies)
            self?.totalResults = totalResults
            self?.totalMovies += totalResults.movies
        }))
    }

    func saveRecentSearch(movies: [Movie]) {
        if !movies.isEmpty {
            saveRecentSearch.send()
        }
    }

    func shouldLoadMorePages(movie: Movie) -> Bool {
        return totalMovies.firstIndex(where: {$0.id == movie.id}) ?? -1 == totalMovies.count-1
    }

    func loadMoreMovies() {
        if page<totalResults.totalPages {
            page+=1
            searchMovies()
        }
    }

    func resetSearch() {
        page = 1
    }

}
