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
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
}

struct Genre: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
}

struct GenreResponse: Codable {
    let genres: [Genre]
}

struct Review: Codable, Identifiable {
    let id: String
    let author: String
    let content: String
    let createdAt: String?
}

struct ReviewResponse: Codable {
    let id: Int
    let page: Int
    let results: [Review]
    let totalPages: Int
    let totalResults: Int
}

struct Video: Codable, Identifiable {
    let id: String
    let key: String
    let name: String
    let site: String
    let type: String
}

struct VideoResponse: Codable {
    let id: Int
    let results: [Video]
}

enum MovieListState {
    case idle
    case loading
    case genres([Genre], selected: Genre?)
    case movies([Movie])
    case empty
    case error(String)
}

enum MovieDetailState {
    case idle
    case loading
    case movie(Movie)
    case trailer(URL?)
    case reviews([Review])
    case emptyReviews
    case error(String)
}
