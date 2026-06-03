//
//  ReviewTableCell.swift
//  MovieOpenAPI
//

import UIKit

final class ReviewTableCell: UITableViewCell {
    static let identifier = "ReviewTableCell"
    
    private let authorLabel = UILabel()
    private let contentLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func configure(with review: Review) {
        authorLabel.text = review.author
        contentLabel.text = review.content
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        authorLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        authorLabel.textColor = .label
        authorLabel.numberOfLines = 1
        
        contentLabel.font = .systemFont(ofSize: 14)
        contentLabel.textColor = .secondaryLabel
        contentLabel.numberOfLines = 5
        
        let stackView = UIStackView(arrangedSubviews: [authorLabel, contentLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 6
        
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
}
