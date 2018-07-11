//
//  Movie.swift
//  IMDB search
//
//  Created by Hesham Ali on 7/11/18.
//  Copyright © 2018 Hesham Ali. All rights reserved.
//

import Foundation
import ObjectMapper
class Movie: Mappable{
    var poster:String!
    var name:String!
    var releaseDate:Date!
    var overview:String!
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        name    <- map["title"]
        poster         <- map["poster_path"]
        releaseDate      <- (map["release_date"], DateTransform())
        overview       <- map["overview"]
    }
}
