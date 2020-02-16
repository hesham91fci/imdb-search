//
//  IMDB_searchTests.swift
//  IMDB searchTests
//
//  Created by Hesham Ali on 7/10/18.
//  Copyright © 2018 Hesham Ali. All rights reserved.
//

import XCTest
@testable import IMDB_search
import RxCocoa
import RxSwift
import RxTest
import RxBlocking
class IMDBSearchTests: XCTestCase {
    let disposeBag = DisposeBag()
    let movieViewModel = MovieViewModel()
    var keyword: BehaviorRelay<String> = BehaviorRelay(value: "")
    var page: BehaviorRelay<Int> = BehaviorRelay(value: 0)
    var scheduler: TestScheduler!
    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(initialClock: 0)
        keyword.bind(to: movieViewModel.keywordRelay).disposed(by: disposeBag)
        page.bind(to: movieViewModel.pageRelay).disposed(by: disposeBag)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEmptySearch() {
        let searchingExpectation = expectation(description: "Searching waiting expectation")
        keyword.accept("Batman")
        page.accept(1)
        let movies = scheduler.createObserver([Movie].self)
        movieViewModel.observableMovies.bind(to: movies).disposed(by: disposeBag)
        movieViewModel.searchMovies()
        scheduler.start()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertEqual(movies.events.last!.value.element, [])
            searchingExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testNormalResult() {
        let searchingExpectation = expectation(description: "Searching waiting expectation")
        keyword.accept(" ")
        page.accept(1)
        let movies = scheduler.createObserver([Movie].self)
        movieViewModel.observableMovies.bind(to: movies).disposed(by: disposeBag)
        keyword.accept("Batman")
        movieViewModel.searchMovies()
        scheduler.start()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertNotEqual(movies.events[2].value.element?.count, 0)
            searchingExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
//

    func testManyPages() {
        keyword.accept("Batman")
        page.accept(1)
        let movies = scheduler.createObserver([Movie].self)
        let totalResults = scheduler.createObserver(TotalResults.self)
        movieViewModel.observableMovies.bind(to: movies).disposed(by: disposeBag)
        movieViewModel.observableResults.bind(to: totalResults).disposed(by: disposeBag)
        movieViewModel.searchMovies()
        scheduler.start()
        let initialExpectation = expectation(description: "Searching waiting expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssert(movies.events.last!.value.element?.count != 0)
            DispatchQueue.global(qos: .background).async {
                self.scrollThroughManyPages(totalResults: totalResults, movies: movies, initialExpectation: initialExpectation)
            }
        }
        waitForExpectations(timeout: 15*60, handler: nil)
    }

    fileprivate func scrollThroughManyPages(totalResults: TestableObserver<TotalResults>, movies: TestableObserver<[Movie]>, initialExpectation: XCTestExpectation) {
        for currentPage in 2...totalResults.events.last!.value.element!.totalPages {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print(currentPage)
                self.page.accept(currentPage)
                self.movieViewModel.searchMovies()
                if currentPage == totalResults.events.last!.value.element!.totalPages {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        print("total movies: \(movies.events.last?.value.element?.count)")
                        XCTAssert(movies.events.last?.value.element?.count == totalResults.events.last?.value.element?.totalResults)
                        initialExpectation.fulfill()
                    }

                }
            }
            sleep(1)
        }
    }
//    
//    func testUpdateRecentSearches(){
//        let presenter = MoviePresenter()
//        let testableView = TestableMovieView()
//        testableView.keyword = "Batman"
//        presenter.attachView(view: testableView)
//        presenter.searchMovies(query: testableView.keyword, page: "1")
//        
//        let searchingExpectation = expectation(description: "Searching waiting expectation")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            XCTAssert(testableView.movies.count != 0)
//            XCTAssert(testableView.movies.first?.name.count != 0)
//            testableView.keyword = "Rocky"
//            presenter.searchMovies(query: testableView.keyword, page: "1")
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                XCTAssert(testableView.movies.count != 0)
//                XCTAssert(testableView.movies.first?.name.count != 0)
//                XCTAssert(testableView.recentSearches.count==2)
//                searchingExpectation.fulfill()
//            }
//        }
//        
//        
//        waitForExpectations(timeout: 10, handler: nil)
//    }
//    
//    func testRedudauntSearches(){
//        let presenter = MoviePresenter()
//        let testableView = TestableMovieView()
//        testableView.keyword = "Batman"
//        presenter.attachView(view: testableView)
//        presenter.searchMovies(query: testableView.keyword, page: "1")
//        
//        let searchingExpectation = expectation(description: "Searching waiting expectation")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            XCTAssert(testableView.movies.count != 0)
//            XCTAssert(testableView.movies.first?.name.count != 0)
//            presenter.searchMovies(query: testableView.keyword, page: "1")
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                XCTAssert(testableView.recentSearches.count==1)
//                searchingExpectation.fulfill()
//            }
//        }
//        
//        
//        waitForExpectations(timeout: 10, handler: nil)
//    }
//    
//    func testEmptyRecentSearches(){
//        let presenter = MoviePresenter()
//        let testableView = TestableMovieView()
//        testableView.keyword = " "
//        presenter.attachView(view: testableView)
//        presenter.searchMovies(query: testableView.keyword, page: "1")
//        
//        let searchingExpectation = expectation(description: "Searching waiting expectation")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            XCTAssert(testableView.recentSearches.count == 0)
//            searchingExpectation.fulfill()
//        }
//        waitForExpectations(timeout: 5, handler: nil)
//    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
