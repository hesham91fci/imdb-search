//
//  RecentSearchesViewModel.swift
//  IMDB search
//
//  Created by HHasaneen on 10/1/19.
//  Copyright © 2019 Hesham Ali. All rights reserved.
//

import Foundation
import Combine
class RecentSearchesViewModel: ObservableObject {
    @Published private(set) var recentSearchesSubject: [String] = []
    @Published var keyword: String = ""
    let maximumRecentSearches = 10

    func addKeywordToRecentSearches() {
        if !isKeywordAlreadyExists() {
            var oldRecentSearches = self.recentSearchesSubject
            if self.recentSearchesSubject.count==maximumRecentSearches {
                oldRecentSearches.removeFirst()
            }
            recentSearchesSubject = oldRecentSearches + [keyword]
        }
    }
    private func isKeywordAlreadyExists() -> Bool {
        return recentSearchesSubject.contains(
            where: { $0.lowercased() == keyword.lowercased()})
    }

}
