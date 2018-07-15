//
//  IMDB_searchTests.swift
//  IMDB searchTests
//
//  Created by Hesham Ali on 7/10/18.
//  Copyright © 2018 Hesham Ali. All rights reserved.
//

import XCTest
@testable import IMDB_search

class IMDB_searchTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEmptySearch() {
        let presenter = MoviePresenter()
        let testableView = TestableMovieView()
        testableView.keyword = " "
        presenter.attachView(view: testableView)
        presenter.searchMovies(query: testableView.keyword, page: "1")
        let searchingExpectation = expectation(description: "Searching waiting expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(testableView.movies.count == 0)
            searchingExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testNormalResult(){
        let presenter = MoviePresenter()
        let testableView = TestableMovieView()
        testableView.keyword = "Batman"
        presenter.attachView(view: testableView)
        presenter.searchMovies(query: testableView.keyword, page: "1")
        
        let searchingExpectation = expectation(description: "Searching waiting expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(testableView.movies.count != 0)
            XCTAssert(testableView.movies.first?.name.count != 0)
            searchingExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testManyPages(){
        let presenter = MoviePresenter()
        let testableView = TestableMovieView()
        testableView.keyword = "man"
        presenter.attachView(view: testableView)
        presenter.searchMovies(query: testableView.keyword, page: "1")
        
        let initialExpectation = expectation(description: "Searching waiting expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssert(testableView.movies.count != 0)
            XCTAssert(testableView.movies.first?.name.count != 0)
            DispatchQueue.global(qos: .background).async {
                for currentPage in 2...presenter.totalResults.totalPages{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        print(currentPage)
                        presenter.searchMovies(query: testableView.keyword, page: "\(currentPage)")
                        if(currentPage == presenter.totalResults.totalPages){
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                                print("total movies: \(testableView.movies.count)")
                                XCTAssert(testableView.movies.count == presenter.totalResults.totalResults)
                                initialExpectation.fulfill()
                            }
                            
                        }
                    }
                    sleep(1)
                }
            }
        }
        waitForExpectations(timeout: 15*60, handler: nil)
        
    }
    
    func testUpdateRecentSearches(){
        let presenter = MoviePresenter()
        let testableView = TestableMovieView()
        testableView.keyword = "Batman"
        presenter.attachView(view: testableView)
        presenter.searchMovies(query: testableView.keyword, page: "1")
        
        let searchingExpectation = expectation(description: "Searching waiting expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(testableView.movies.count != 0)
            XCTAssert(testableView.movies.first?.name.count != 0)
            testableView.keyword = "Rocky"
            presenter.searchMovies(query: testableView.keyword, page: "1")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                XCTAssert(testableView.movies.count != 0)
                XCTAssert(testableView.movies.first?.name.count != 0)
                XCTAssert(testableView.recentSearches.count==2)
                searchingExpectation.fulfill()
            }
        }
        
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRedudauntSearches(){
        let presenter = MoviePresenter()
        let testableView = TestableMovieView()
        testableView.keyword = "Batman"
        presenter.attachView(view: testableView)
        presenter.searchMovies(query: testableView.keyword, page: "1")
        
        let searchingExpectation = expectation(description: "Searching waiting expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(testableView.movies.count != 0)
            XCTAssert(testableView.movies.first?.name.count != 0)
            presenter.searchMovies(query: testableView.keyword, page: "1")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                XCTAssert(testableView.recentSearches.count==1)
                searchingExpectation.fulfill()
            }
        }
        
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testEmptyRecentSearches(){
        let presenter = MoviePresenter()
        let testableView = TestableMovieView()
        testableView.keyword = " "
        presenter.attachView(view: testableView)
        presenter.searchMovies(query: testableView.keyword, page: "1")
        
        let searchingExpectation = expectation(description: "Searching waiting expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(testableView.recentSearches.count == 0)
            searchingExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
