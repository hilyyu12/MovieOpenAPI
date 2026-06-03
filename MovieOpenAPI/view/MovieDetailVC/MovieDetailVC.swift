//
//  MovieDetailVC.swift
//  MovieOpenAPI
//

import UIKit
import WebKit

final class MovieDetailVC: UIViewController {
    private let viewModel: MovieDetailViewModel
    private var reviews: [Review] = []
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let headerView = UIView()
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let ratingLabel = UILabel()
    private let overviewLabel = UILabel()
    private lazy var trailerWebView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.backgroundColor = .secondarySystemBackground
        webView.scrollView.isScrollEnabled = false
        return webView
    }()
    private let reviewStateLabel = UILabel()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    init(movie: Movie) {
        self.viewModel = MovieDetailViewModel(movie: movie, service: MovieService())
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTable()
        bindViewModel()
        viewModel.loadInitialData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderSize()
    }
    
    private func setupUI() {
        title = "Movie Detail"
        view.backgroundColor = .systemBackground
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTable() {
        tableView.register(ReviewTableCell.self, forCellReuseIdentifier: ReviewTableCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        tableView.tableHeaderView = makeHeaderView()
    }
    
    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                guard let self else { return }
                switch state {
                case .loading:
                    self.showLoading()
                case .movie(let movie):
                    self.configureMovie(movie)
                case .trailer(let url):
                    self.configureTrailer(url)
                case .reviews(let reviews):
                    self.loadingIndicator.stopAnimating()
                    self.tableView.tableFooterView = nil
                    self.reviewStateLabel.text = nil
                    self.reviews = reviews
                    self.tableView.reloadData()
                    self.updateHeaderSize()
                case .emptyReviews:
                    self.loadingIndicator.stopAnimating()
                    self.tableView.tableFooterView = nil
                    self.reviewStateLabel.text = "No reviews yet"
                    self.updateHeaderSize()
                case .error(let message):
                    self.loadingIndicator.stopAnimating()
                    self.tableView.tableFooterView = nil
                    self.reviewStateLabel.text = message
                    self.updateHeaderSize()
                default:
                    break
                }
            }
        }
    }
    
    private func makeHeaderView() -> UIView {
        headerView.backgroundColor = .systemBackground
        
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 10
        posterImageView.backgroundColor = .secondarySystemBackground
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.numberOfLines = 0
        
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        ratingLabel.textColor = .secondaryLabel
        
        overviewLabel.translatesAutoresizingMaskIntoConstraints = false
        overviewLabel.font = .systemFont(ofSize: 15)
        overviewLabel.textColor = .label
        overviewLabel.numberOfLines = 0
        
        trailerWebView.translatesAutoresizingMaskIntoConstraints = false
        reviewStateLabel.translatesAutoresizingMaskIntoConstraints = false
        reviewStateLabel.font = .systemFont(ofSize: 15, weight: .medium)
        reviewStateLabel.textColor = .secondaryLabel
        reviewStateLabel.textAlignment = .center
        reviewStateLabel.numberOfLines = 0
        
        let infoStack = UIStackView(arrangedSubviews: [titleLabel, ratingLabel, overviewLabel])
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        infoStack.axis = .vertical
        infoStack.spacing = 8
        
        let topStack = UIStackView(arrangedSubviews: [posterImageView, infoStack])
        topStack.translatesAutoresizingMaskIntoConstraints = false
        topStack.axis = .horizontal
        topStack.alignment = .top
        topStack.spacing = 16
        
        let trailerTitleLabel = UILabel()
        trailerTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        trailerTitleLabel.text = "Trailer"
        
        let reviewTitleLabel = UILabel()
        reviewTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        reviewTitleLabel.text = "Reviews"
        
        let stackView = UIStackView(arrangedSubviews: [
            topStack,
            trailerTitleLabel,
            trailerWebView,
            reviewTitleLabel,
            reviewStateLabel
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 14
        
        headerView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            posterImageView.widthAnchor.constraint(equalToConstant: 120),
            posterImageView.heightAnchor.constraint(equalToConstant: 180),
            trailerWebView.heightAnchor.constraint(equalToConstant: 210)
        ])
        
        return headerView
    }
    
    private func updateHeaderSize() {
        guard tableView.tableHeaderView === headerView else { return }
        
        headerView.frame.size.width = tableView.bounds.width
        let size = headerView.systemLayoutSizeFitting(
            CGSize(width: tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        if headerView.frame.height != size.height {
            headerView.frame.size.height = size.height
            tableView.tableHeaderView = headerView
        }
    }
    
    private func configureMovie(_ movie: Movie) {
        titleLabel.text = movie.title
        ratingLabel.text = String(format: "Rating %.1f/10", movie.voteAverage)
        overviewLabel.text = movie.overview?.isEmpty == false ? movie.overview : "No overview available"
        
        if let posterPath = movie.posterPath {
            posterImageView.setImage(from: APIConfig.imageBaseURL + posterPath)
        } else {
            posterImageView.image = UIImage(systemName: "photo")
        }
        updateHeaderSize()
    }
    
    private func configureTrailer(_ url: URL?) {
        guard let url else {
            reviewStateLabel.text = "Trailer unavailable"
            updateHeaderSize()
            return
        }
        trailerWebView.load(URLRequest(url: url))
    }
    
    private func showLoading() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 52))
        loadingIndicator.frame = footerView.bounds
        loadingIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        loadingIndicator.startAnimating()
        footerView.addSubview(loadingIndicator)
        tableView.tableFooterView = footerView
    }
}

extension MovieDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ReviewTableCell.identifier,
            for: indexPath
        ) as? ReviewTableCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: reviews[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewModel.loadNextReviewPageIfNeeded(currentIndex: indexPath.row)
    }
}
