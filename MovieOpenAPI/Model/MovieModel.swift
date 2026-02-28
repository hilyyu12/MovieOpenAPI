//
//  MovieModel.swift
//  MovieOpenAPI
//
//  Created by Abiyyu on 28/02/26.
//

import Foundation

struct Movie: Codable, Identifiable {
    let id: Int
    let title: String
    let overview: String?
    let posterPath: String?
    let voteAverage: Double
}

struct MovieResponse: Codable {
    let results: [Movie]
}

enum MovieListState {
    case idle
    case loading
    case popular([Movie])
    case searchResult([Movie])
    case empty
    case error(String)
}
