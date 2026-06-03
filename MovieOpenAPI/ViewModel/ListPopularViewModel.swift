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
    private var genres: [Genre] = []
    private(set) var selectedGenre: Genre?
    private(set) var movies: [Movie] = []
    private var currentPage = 0
    private var totalPages = 1
    private var currentQuery = ""
    private var isLoading = false
    private var movieRequestCancellable: AnyCancellable?
    
    init(service: MovieServiceProtocol) {
        self.service = service
    }
    
    func fetchGenres() {
        onStateChange?(.loading)
        service.fetchGenres()
            .sink(receiveCompletion: {completion in
                if case .failure(let error) = completion {
                    self.onStateChange?(.error(error.localizedDescription))
                }
            }, receiveValue: { genres in
                self.genres = genres
                self.selectedGenre = genres.first
                self.onStateChange?(.genres(genres, selected: self.selectedGenre))
                self.loadMovies(reset: true)
            })
            .store(in: &cancellables)
    }
    
    func selectGenre(_ genre: Genre) {
        guard selectedGenre != genre else { return }
        selectedGenre = genre
        currentQuery = ""
        onStateChange?(.genres(genres, selected: selectedGenre))
        loadMovies(reset: true)
    }
    
    func updateSearchText(_ text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedText.isEmpty {
            currentQuery = ""
            loadMovies(reset: true)
        } else if trimmedText.count >= 3 {
            currentQuery = trimmedText
            searchMovie(query: trimmedText, reset: true)
        }
    }
    
    func loadNextPageIfNeeded(currentIndex: Int) {
        guard currentIndex >= movies.count - 4 else { return }
        
        if currentQuery.isEmpty {
            loadMovies(reset: false)
        } else {
            searchMovie(query: currentQuery, reset: false)
        }
    }
    
    private func loadMovies(reset: Bool) {
        guard let genreId = selectedGenre?.id else {
            onStateChange?(.empty)
            return
        }
        loadPage(reset: reset) { [service] page in
            service.discoverMovies(genreId: genreId, page: page)
        }
    }
    
    private func searchMovie(query: String, reset: Bool) {
        loadPage(reset: reset) { [service] page in
            service.searchMovie(query: query, page: page)
        }
    }
    
    private func loadPage(
        reset: Bool,
        request: @escaping (Int) -> AnyPublisher<MovieResponse, Error>
    ) {
        if reset {
            movieRequestCancellable?.cancel()
            isLoading = false
            currentPage = 0
            totalPages = 1
            movies = []
            onStateChange?(.loading)
        }
        
        guard !isLoading, currentPage < totalPages else { return }
        
        isLoading = true
        let nextPage = currentPage + 1
        if !reset {
            onStateChange?(.loading)
        }
        
        movieRequestCancellable = request(nextPage)
            .sink(receiveCompletion: {completion in
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.onStateChange?(.error(error.localizedDescription))
                }
            }, receiveValue: { response in
                self.currentPage = response.page
                self.totalPages = max(response.totalPages, response.page)
                self.movies.append(contentsOf: response.results)
                
                if self.movies.isEmpty {
                    self.onStateChange?(.empty)
                } else {
                    self.onStateChange?(.movies(self.movies))
                }
            })
    }
    
    private var cancellables = Set<AnyCancellable>()
}
