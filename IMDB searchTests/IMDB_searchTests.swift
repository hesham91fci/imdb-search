//
//  IMDB_searchTests.swift
//  IMDB searchTests
//
//  Created by Hesham Ali on 10/6/20.
//  Copyright © 2020 Hesham Ali. All rights reserved.
//

import XCTest
import Combine
@testable import IMDB_search
class IMDBSearchTests: XCTestCase {
    let moviesView = MoviesView()
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEmptySearch() {
        let searchingExpectation = expectation(description: "Searching waiting expectation")
        moviesView.movieViewModel.keyword = " "
        moviesView.movieViewModel.searchMovies()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertEqual(self.moviesView.movieViewModel.totalMovies.count, 0)
            searchingExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testNormalResult() {
        let searchingExpectation = expectation(description: "Searching waiting expectation")
        moviesView.movieViewModel.keyword = "Batman"
        moviesView.movieViewModel.searchMovies()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertNotEqual(self.moviesView.movieViewModel.totalMovies.count, 0)
            searchingExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
//

    func testManyPages() {
        let initialExpectation = expectation(description: "Searching waiting expectation")
        moviesView.movieViewModel.keyword = "Batman"
        moviesView.movieViewModel.searchMovies()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(self.moviesView.movieViewModel.totalMovies.count != 0)
            DispatchQueue.global(qos: .background).async {
                guard let totalResults = self.moviesView.movieViewModel.totalResults else {
                    XCTFail("No total results")
                    return
                }
                self.scrollThroughManyPages(totalResults: totalResults, initialExpectation: initialExpectation)
            }
        }
        waitForExpectations(timeout: 15*60, handler: nil)
    }

    fileprivate func scrollThroughManyPages(totalResults: TotalResults, initialExpectation: XCTestExpectation) {
        for currentPage in 2...totalResults.totalPages {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.moviesView.movieViewModel.loadMoreMovies()
                if currentPage == totalResults.totalPages {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        print("total movies: \(self.moviesView.movieViewModel.totalMovies.count)")
                        XCTAssert(self.moviesView.movieViewModel.totalMovies.count == totalResults.totalResults)
                        initialExpectation.fulfill()
                    }

                }
            }
            sleep(1)
        }
    }
}
