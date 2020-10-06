//
//  MovieServices.swift
//  IMDB search
//
//  Created by Hesham Ali on 7/11/18.
//  Copyright © 2018 Hesham Ali. All rights reserved.
//

import Foundation
import Alamofire
import Combine
struct MovieServices {
    func searchMovies(query: String, page: String) -> AnyPublisher<TotalResults, AFError> {
        let urlPath = NSLocalizedString("HOST_URL", comment: "comment") + NSLocalizedString("SEARCH_ENDPOINT", comment: "comment")

        return AF.request(URL(string: urlPath)!,
                          method: .get,
                          parameters: ["api_key": NSLocalizedString("API_KEY", comment: "comment"), "query": query, "page": page])
            .validate()
            .publishDecodable(type: TotalResults.self)
            .value()

    }

}
