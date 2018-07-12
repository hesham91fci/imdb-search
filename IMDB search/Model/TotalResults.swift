//
//  TotalResults.swift
//  IMDB search
//
//  Created by Hesham Ali on 7/12/18.
//  Copyright © 2018 Hesham Ali. All rights reserved.
//

import Foundation
import ObjectMapper
class TotalResults: Mappable {
    var pageIndex:Int!
    var totalPages:Int!
    var movies:[Movie]!
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        pageIndex    <- map["page"]
        totalPages         <- map["total_pages"]
        movies      <- map["results"]
    }
}
