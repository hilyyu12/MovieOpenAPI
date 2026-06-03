//
//  GenreCollectionCell.swift
//  MovieOpenAPI
//

import UIKit

final class GenreCollectionCell: UICollectionViewCell {
    static let identifier = "GenreCollectionCell"
    
    private let titleLabel = UILabel()
    private var isActive = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        isActive = false
        updateSelectionStyle()
    }
    
    func configure(with genre: Genre, isActive: Bool) {
        titleLabel.text = genre.name
        self.isActive = isActive
        updateSelectionStyle()
    }
    
    private func setupUI() {
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 1
        contentView.clipsToBounds = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7)
        ])
        
        updateSelectionStyle()
    }
    
    private func updateSelectionStyle() {
        if isActive {
            contentView.backgroundColor = UIColor(red: 0.27, green: 0.19, blue: 0.60, alpha: 1.0)
            contentView.layer.borderColor = UIColor.clear.cgColor
            titleLabel.textColor = .white
        } else {
            contentView.backgroundColor = .systemBackground
            contentView.layer.borderColor = UIColor.systemGray4.cgColor
            titleLabel.textColor = .label
        }
    }
}
