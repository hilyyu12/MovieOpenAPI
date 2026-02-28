//
//  MovieService.swift
//  MovieOpenAPI
//
//  Created by Abiyyu on 28/02/26.
//

import Foundation
import Combine

class MovieService: MovieServiceProtocol {
    
    func fetchPopular(page: Int) -> AnyPublisher<[Movie], any Error> {
        let endpoint = "/movie/popular"
        return request(endpoint: endpoint, queryItems: [
            URLQueryItem(name: "page", value:  "\(page)")
        ])
    }
    
    func searchMovie(query: String, page: Int) -> AnyPublisher<[Movie], any Error> {
        let endpoint = "/search/movie"
        return request(endpoint: endpoint, queryItems: [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value:  "\(page)")
        ])
    }
    
    private func request(endpoint: String, queryItems: [URLQueryItem]) -> AnyPublisher<[Movie],Error> {
        var components = URLComponents(string: APIConfig.baseURL + endpoint)!
        components.queryItems = queryItems
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(APIConfig.bearerToken)", forHTTPHeaderField: "Authorization")
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: MovieResponse.self, decoder: decoder)
            .map {$0.results}
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
