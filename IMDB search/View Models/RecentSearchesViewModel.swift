//
//  RecentSearchesViewModel.swift
//  IMDB search
//
//  Created by HHasaneen on 10/1/19.
//  Copyright © 2019 Hesham Ali. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
class RecentSearchesViewModel {
    private let recentSearchesSubject: BehaviorRelay<[String]> = BehaviorRelay(value: [])
    let maximumRecentSearches = 10
    var recentSearchesObservable: Observable<[String]> {
        return self.recentSearchesSubject.asObservable()
    }
    func addKeywordToRecentSearches(keyword: String) {
        var oldRecentSearches = self.recentSearchesSubject.value
        if self.recentSearchesSubject.value.count==maximumRecentSearches {
            oldRecentSearches.removeFirst()
        }
        recentSearchesSubject.accept(oldRecentSearches + [keyword])
    }
    func isKeywordAlreadyExists(keyword: String) -> Bool {
        return recentSearchesSubject.value.contains(
            where: { $0.lowercased() == keyword.lowercased()})
    }
    func getKeyword(atIndex index: Int) -> String {
        return self.recentSearchesSubject.value[index]
    }
    func isNotEmptyRecentSearches() -> Bool {
        return !self.recentSearchesSubject.value.isEmpty
    }

}
