//
//  ListPopularViewModel.swift
//  MovieOpenAPI
//
//  Created by Abiyyu on 28/02/26.
//

import Foundation
import Combine

class ListPopularViewModel {
    var onStateChange : ((MovieListState) -> Void)?
    private let service: MovieServiceProtocol
    
    init(service: MovieServiceProtocol) {
        self.service = service
    }
    
    func fetchPopular() {
        onStateChange?(.loading)
        service.fetchPopular(page: 1)
            .sink(receiveCompletion: {completion in
                if case .failure(let error) = completion {
                    print("Error: ", error)
                    self.onStateChange?(.error(error.localizedDescription))
                }
            }, receiveValue: {movies in
                print("Movie Recived: ", movies.count)
                self.onStateChange?(.popular(movies))
            })
            .store(in: &Cancellables)
    }
    
    func searchMovie(query: String) {
        onStateChange?(.loading)
        service.searchMovie(query: query, page: 1)
            .sink(receiveCompletion: {completion in
                if case .failure = completion {
                    self.onStateChange?(.error("Search failed"))
                }
            }, receiveValue: {movies in
                print("Movie Recived: ", movies.count)
                self.onStateChange?(.searchResult(movies))
            })
            .store(in: &Cancellables)
    }
    
    private var Cancellables = Set<AnyCancellable>()
}
