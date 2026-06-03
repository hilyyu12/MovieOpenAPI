//
//  MovieService.swift
//  MovieOpenAPI
//
//  Created by Abiyyu on 28/02/26.
//

import Foundation
import Combine

class MovieService: MovieServiceProtocol {
    
    func fetchGenres() -> AnyPublisher<[Genre], Error> {
        request(endpoint: "/genre/movie/list")
            .map { (response: GenreResponse) in response.genres }
            .eraseToAnyPublisher()
    }
    
    func discoverMovies(genreId: Int, page: Int) -> AnyPublisher<MovieResponse, Error> {
        request(endpoint: "/discover/movie", queryItems: [
            URLQueryItem(name: "with_genres", value: "\(genreId)"),
            URLQueryItem(name: "page", value: "\(page)")
        ])
    }
    
    func searchMovie(query: String, page: Int) -> AnyPublisher<MovieResponse, Error> {
        request(endpoint: "/search/movie", queryItems: [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: "\(page)")
        ])
    }
    
    func fetchReviews(movieId: Int, page: Int) -> AnyPublisher<ReviewResponse, Error> {
        request(endpoint: "/movie/\(movieId)/reviews", queryItems: [
            URLQueryItem(name: "page", value: "\(page)")
        ])
    }
    
    func fetchVideos(movieId: Int) -> AnyPublisher<[Video], Error> {
        request(endpoint: "/movie/\(movieId)/videos")
            .map { (response: VideoResponse) in response.results }
            .eraseToAnyPublisher()
    }
    
    private func request<T: Decodable>(
        endpoint: String,
        queryItems: [URLQueryItem] = []
    ) -> AnyPublisher<T, Error> {
        var components = URLComponents(string: APIConfig.baseURL + endpoint)!
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(APIConfig.bearerToken)", forHTTPHeaderField: "Authorization")
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
