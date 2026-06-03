//
//  MovieServiceProtocol.swift
//  MovieOpenAPI
//
//  Created by Abiyyu on 28/02/26.
//

import Foundation
import Combine

protocol MovieServiceProtocol {
    func fetchGenres() -> AnyPublisher<[Genre], Error>
    func discoverMovies(genreId: Int, page: Int) -> AnyPublisher<MovieResponse, Error>
    func searchMovie(query: String, page: Int) -> AnyPublisher<MovieResponse, Error>
    func fetchReviews(movieId: Int, page: Int) -> AnyPublisher<ReviewResponse, Error>
    func fetchVideos(movieId: Int) -> AnyPublisher<[Video], Error>
}
