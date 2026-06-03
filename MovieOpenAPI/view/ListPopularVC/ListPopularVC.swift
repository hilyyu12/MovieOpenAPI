//
//  ListPopularVC.swift
//  MovieOpenAPI
//
//  Created by Abiyyu on 28/02/26.
//

import Foundation
import UIKit

class ListPopularVC: UIViewController {
    @IBOutlet private weak var tableView:UITableView!
    @IBOutlet private weak var searchView: SearchTextField!
    @IBOutlet private weak var FavoriteButton: UIButton!
    
    private let viewModel = ListPopularViewModel(service: MovieService())
    private var movies: [Movie] = []
    private var genres: [Genre] = []
    private var selectedGenre: Genre?
    private lazy var genreCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(GenreCollectionCell.self, forCellWithReuseIdentifier: GenreCollectionCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let stateLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTable()
        bindViewModel()
        viewModel.fetchGenres()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func setupUI() {
        searchView.onTextChanged = {[weak self] text in
            self?.handleSearch(text: text)
        }
        
        stateLabel.textAlignment = .center
        stateLabel.textColor = .secondaryLabel
        stateLabel.font = .systemFont(ofSize: 15, weight: .medium)
        stateLabel.numberOfLines = 0
    }
    
    func setupTable() {
        tableView.register(UINib(nibName: "MovieTableCell", bundle: nil), forCellReuseIdentifier: MovieTableCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 120
        tableView.tableHeaderView = genreHeaderView()
    }
    
    func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                guard let self else { return }
                switch state {
                case .loading:
                    self.showLoading()
                case .genres(let genres, let selected):
                    self.genres = genres
                    self.selectedGenre = selected
                    self.genreCollectionView.reloadData()
                case .movies(let movies):
                    self.loadingIndicator.stopAnimating()
                    self.tableView.tableFooterView = nil
                    self.stateLabel.text = nil
                    self.tableView.backgroundView = nil
                    self.movies = movies
                    self.tableView.reloadData()
                case .empty:
                    self.loadingIndicator.stopAnimating()
                    self.movies = []
                    self.tableView.reloadData()
                    self.showStateMessage("No movies found")
                case .error(let message):
                    self.loadingIndicator.stopAnimating()
                    self.showStateMessage(message)
                default:
                    break
                }
            }
        }
    }
    
    private func handleSearch(text: String) {
        viewModel.updateSearchText(text)
    }
    
    private func genreHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 58))
        headerView.backgroundColor = .systemBackground
        genreCollectionView.frame = headerView.bounds
        genreCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        headerView.addSubview(genreCollectionView)
        return headerView
    }
    
    private func showLoading() {
        if movies.isEmpty {
            loadingIndicator.startAnimating()
            tableView.backgroundView = loadingIndicator
        } else {
            tableView.tableFooterView = loadingFooterView()
        }
    }
    
    private func showStateMessage(_ message: String) {
        stateLabel.text = message
        tableView.backgroundView = stateLabel
        tableView.tableFooterView = nil
    }
    
    private func loadingFooterView() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 52))
        loadingIndicator.frame = footerView.bounds
        loadingIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        loadingIndicator.startAnimating()
        footerView.addSubview(loadingIndicator)
        return footerView
    }
}

extension ListPopularVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableCell.identifier, for: indexPath) as? MovieTableCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: movies[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = MovieDetailVC(movie: movies[indexPath.row])
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewModel.loadNextPageIfNeeded(currentIndex: indexPath.row)
    }
}

extension ListPopularVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        genres.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GenreCollectionCell.identifier,
            for: indexPath
        ) as? GenreCollectionCell else {
            return UICollectionViewCell()
        }
        
        let genre = genres[indexPath.item]
        cell.configure(with: genre, isActive: genre == selectedGenre)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        view.endEditing(true)
        let genre = genres[indexPath.item]
        selectedGenre = genre
        collectionView.reloadData()
        viewModel.selectGenre(genre)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let name = genres[indexPath.item].name as NSString
        let width = name.size(withAttributes: [.font: UIFont.systemFont(ofSize: 14, weight: .semibold)]).width + 30
        return CGSize(width: max(width, 72), height: 34)
    }
}
