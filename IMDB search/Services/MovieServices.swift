//
//  MovieServices.swift
//  IMDB search
//
//  Created by Hesham Ali on 7/11/18.
//  Copyright © 2018 Hesham Ali. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import RxSwift
struct MovieServices {
    static let sharedMovieServices=MovieServices()
    private init() {

    }

    func searchMovies(query: String, page: String) -> Observable<TotalResults> {
        return Observable.create({ (observer) -> Disposable in
            let urlPath = NSLocalizedString("HOST_URL", comment: "comment") + NSLocalizedString("SEARCH_ENDPOINT", comment: "comment")

            Alamofire.request(URL(string: urlPath)!,
                              method: .get,
                              parameters: ["api_key": NSLocalizedString("API_KEY", comment: "comment"), "query": query, "page": page])
                .validate()
                .responseJSON { response in
                    guard let data = response.data else {
                        observer.onError(response.error ?? MoviesError())
                        return
                    }
                    if !response.result.isSuccess {
                        observer.onError(response.error ?? MoviesError())
                    } else {
                        guard let jsonResponse = response.value as? [String: Any] else {
                            return
                        }
                        guard let totalResults = Mapper<TotalResults>().map(JSON: jsonResponse) else {
                            return
                        }
                        observer.onNext(totalResults)
                    }
            }
            return Disposables.create()
        })

    }

}
