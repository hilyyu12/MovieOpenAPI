//
//  MovieTableCell.swift
//  MovieOpenAPI
//
//  Created by Abiyyu on 28/02/26.
//

import UIKit

class MovieTableCell: UITableViewCell {
    static let identifier = "MovieTableCell"
    
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        posterImageView.layer.cornerRadius = 8
        posterImageView.clipsToBounds = true
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.numberOfLines = 2
    }
    
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        if let path = movie.posterPath {
            let urlString = APIConfig.imageBaseURL + path
            loadImage(from: urlString)
        } else {
            posterImageView.image = UIImage(systemName: "photo")
        }
    }
    
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                self?.posterImageView.image = UIImage(data: data)
            }
        }.resume()
    }
}
