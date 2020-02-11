//
//  Movie.swift
//  IMDB search
//
//  Created by Hesham Ali on 7/11/18.
//  Copyright © 2018 Hesham Ali. All rights reserved.
//

import Foundation
import ObjectMapper
struct Movie: Mappable, Equatable{
    var poster:String!
    var name:String!
    var releaseDate:String!
    var overview:String!
    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        name    <- map["title"]
        poster         <- map["poster_path"]
        releaseDate      <- map["release_date"]
        overview       <- map["overview"]
    }
}
