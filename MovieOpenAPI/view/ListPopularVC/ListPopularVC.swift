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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTable()
        bindViewModel()
        viewModel.fetchPopular()
    }
    
    func setupUI() {
        searchView.onTextChanged = {[weak self] text in
            self?.handleSearch(text: text)}
    }
    
    func setupTable() {
        tableView.register(UINib(nibName: "MovieTableCell", bundle: nil), forCellReuseIdentifier: MovieTableCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
    }
    
    func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .loading:
                    print("loading...")
                case .popular(let movies),
                    .searchResult(let movies):
                    self?.movies = movies
                    self?.tableView.reloadData()
                case .empty:
                    self?.movies = []
                case .error(let message):
                    print(message)
                default:
                    break
                }
            }
        }
    }
    
    private func handleSearch(text: String) {
        print(text)
        if text.count >= 3 {
            viewModel.searchMovie(query: text)
        } else if text.isEmpty {
            viewModel.fetchPopular()
        }
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
    
    
}
