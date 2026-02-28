//
//  MovieServiceProtocol.swift
//  MovieOpenAPI
//
//  Created by Abiyyu on 28/02/26.
//

import Foundation
import Combine

protocol MovieServiceProtocol {
    func fetchPopular(page: Int) -> AnyPublisher<[Movie], Error>
    func searchMovie(query: String, page: Int) -> AnyPublisher<[Movie], Error>
}
