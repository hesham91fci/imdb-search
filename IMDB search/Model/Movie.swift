//
//  Movie.swift
//  IMDB search
//
//  Created by Hesham Ali on 7/11/18.
//  Copyright © 2018 Hesham Ali. All rights reserved.
//
import Combine
struct Movie: Codable, Identifiable {
    let id: Int
    let title: String
    let releaseDate: String?
    let overview: String
    let posterPath: String?

    enum CodingKeys: String, CodingKey {
        case title, id
        case releaseDate = "release_date"
        case overview
        case posterPath = "poster_path"
    }
}
