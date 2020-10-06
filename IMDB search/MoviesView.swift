//
//  ContentView.swift
//  test ios 13
//
//  Created by Hesham Ali on 8/23/20.
//  Copyright © 2020 Hesham Ali. All rights reserved.
//

import SwiftUI
import struct Kingfisher.KFImage
import Combine
struct MoviesView: View {
    @ObservedObject var movieViewModel = MovieViewModel()
    @ObservedObject var recentSearchesViewModel = RecentSearchesViewModel()
    @State var subscription: AnyCancellable?
    @State var shouldShowRecentSearches: Bool = false

    var body: some View {
        DispatchQueue.main.async {
            self.subscription = self.movieViewModel.saveRecentSearch.sink { _ in
                self.recentSearchesViewModel.addKeywordToRecentSearches()
            }
        }
        return VStack(alignment: .leading, spacing: 16) {
            searchTextField()
            Spacer()
            if shouldShowRecentSearches && !recentSearchesViewModel.recentSearchesSubject.isEmpty {
                recentSearchesListView()
            }
            movieListView()
        }
    }
    fileprivate func searchTextField() -> some View {
        return TextField("Search for a movie",
                         text: Binding<String>(
                            get: { () -> String in
                                self.movieViewModel.keyword
                         }, set: { (text) in
                            self.movieViewModel.keyword = text
                            self.recentSearchesViewModel.keyword = text
                         }
            ),
                         onCommit: {
                            self.movieViewModel.resetSearch()
                            self.movieViewModel.searchMovies()
                            self.shouldShowRecentSearches = false
        }).onTapGesture {
            self.shouldShowRecentSearches = true
        }
        .padding(8.0)
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
    fileprivate func recentSearchesListView() -> some View {
        return List {
            ForEach(recentSearchesViewModel.recentSearchesSubject, id: \.self) { (keyword) in
                Text(keyword)
                    .onTapGesture {
                        self.movieViewModel.keyword = keyword
                        self.movieViewModel.resetSearch()
                        self.movieViewModel.searchMovies()
                        self.shouldShowRecentSearches = false
                }
            }
        }
    }

    fileprivate func movieListView() -> some View {
        return List {
            ForEach(movieViewModel.totalMovies, id: \.id) { (movie) in
                MovieRow(movie: movie).onAppear {
                    if self.movieViewModel.shouldLoadMorePages(movie: movie) {
                        self.movieViewModel.loadMoreMovies()
                    }
                }
            }
        }
    }
}

struct MovieRow: View {
    private let movie: Movie!
    let dateFormatter = DateFormatter()
    let movieDate: String!
    init(movie: Movie) {
        self.movie = movie
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let movieDate = dateFormatter.date(from: movie.releaseDate ?? "")

        dateFormatter.dateFormat = "dd-MMM-yyyy"
        guard let date = movieDate else {
            self.movieDate = ""
            return
        }
        self.movieDate = dateFormatter.string(from: date)
    }
    var body: some View {
        let url = URL(string: NSLocalizedString("POSTERS_ENDPOINT", comment: "comment") + ( movie.posterPath ?? ""))
        return VStack {
            Text(movie.title)
            .font(.largeTitle)
            .fontWeight(.medium)
            .padding(8.0)
            KFImage(url)
                .resizable()
                .padding(8.0)
                .frame(width: 176.0, height: 176.0)
                .aspectRatio(contentMode: .fill)
            Text(self.movieDate)
            Text(movie.overview)
                .padding(8.0)
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        let movieViewModel = MovieViewModel()
//        movieViewModel.keyword = "rocky"
//        movieViewModel.totalMovies = [Movie(id: 1, title: "Rocky", releaseDate: "12-2-2020", overview: "ABCD", posterPath: "i5xiwdSsrecBvO7mIfAJixeEDSg.jpg"),
//                                      Movie(id: 2, title: "Rocky", releaseDate: "12-2-2020", overview: "ABCD", posterPath: "i5xiwdSsrecBvO7mIfAJixeEDSg.jpg")
//        ]
//        return ContentView(movieViewModel: movieViewModel)
//    }
//}
