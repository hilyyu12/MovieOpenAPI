//
//  MovieDetailViewModel.swift
//  MovieOpenAPI
//

import Foundation
import Combine

final class MovieDetailViewModel {
    var onStateChange: ((MovieDetailState) -> Void)?
    
    private let movie: Movie
    private let service: MovieServiceProtocol
    private(set) var reviews: [Review] = []
    private var currentReviewPage = 0
    private var totalReviewPages = 1
    private var isLoadingReviews = false
    private var cancellables = Set<AnyCancellable>()
    
    init(movie: Movie, service: MovieServiceProtocol) {
        self.movie = movie
        self.service = service
    }
    
    func loadInitialData() {
        onStateChange?(.movie(movie))
        fetchTrailer()
        loadReviews(reset: true)
    }
    
    func loadNextReviewPageIfNeeded(currentIndex: Int) {
        guard currentIndex >= reviews.count - 2 else { return }
        loadReviews(reset: false)
    }
    
    private func fetchTrailer() {
        service.fetchVideos(movieId: movie.id)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.onStateChange?(.error(error.localizedDescription))
                }
            }, receiveValue: { videos in
                let trailer = videos.first {
                    $0.site.lowercased() == "youtube" && $0.type.lowercased() == "trailer"
                } ?? videos.first {
                    $0.site.lowercased() == "youtube"
                }
                let url = trailer.flatMap { URL(string: "https://www.youtube.com/watch?v=\($0.key)&playsinline=1") }
                self.onStateChange?(.trailer(url))
            })
            .store(in: &cancellables)
    }
    
    private func loadReviews(reset: Bool) {
        if reset {
            reviews = []
            currentReviewPage = 0
            totalReviewPages = 1
            onStateChange?(.loading)
        }
        
        guard !isLoadingReviews, currentReviewPage < totalReviewPages else { return }
        
        isLoadingReviews = true
        let nextPage = currentReviewPage + 1
        service.fetchReviews(movieId: movie.id, page: nextPage)
            .sink(receiveCompletion: { completion in
                self.isLoadingReviews = false
                if case .failure(let error) = completion {
                    self.onStateChange?(.error(error.localizedDescription))
                }
            }, receiveValue: { response in
                self.currentReviewPage = response.page
                self.totalReviewPages = max(response.totalPages, response.page)
                self.reviews.append(contentsOf: response.results)
                
                if self.reviews.isEmpty {
                    self.onStateChange?(.emptyReviews)
                } else {
                    self.onStateChange?(.reviews(self.reviews))
                }
            })
            .store(in: &cancellables)
    }
}
