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
struct MovieServices {
    static let sharedMovieServices=MovieServices()
    private init(){
        
    }
    
    func searchMovies(query:String, page:String, completionHandler: @escaping (_ success: Bool, _ data: TotalResults?) -> Void){
        let urlPath = NSLocalizedString("HOST_URL", comment: "comment") + NSLocalizedString("SEARCH_ENDPOINT", comment: "comment")
        
        Alamofire.request(URL(string: urlPath)!,
                          method: .get,
                          parameters: ["api_key": apiKey, "query": query, "page":page])
            .validate()
            .responseJSON { response in
                if(!response.result.isSuccess) {
                    completionHandler(false, nil)
                }
                else{
                    let totalResults = Mapper<TotalResults>().map(JSON: response.value as! [String : Any])
                    completionHandler(true,totalResults)
                }
        }
    }
    
    
}
