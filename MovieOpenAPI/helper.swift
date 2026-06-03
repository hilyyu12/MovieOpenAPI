//
//  helper.swift
//  MovieOpenAPI
//
//  Created by Abiyyu on 28/02/26.
//

import Foundation
import UIKit

enum APIConfig {
    static let baseURL = "https://api.themoviedb.org/3"
    static let bearerToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkMmNiYTc0N2ZlOTQxOTQyZGRlMmRkNTVjMDZiNTVhYyIsIm5iZiI6MTc3MjIyNzE1MS40MzIsInN1YiI6IjY5YTIwYTRmOWE3Y2RiN2JlN2MxNmM0MiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.AXnZpaZLCe_0zPLLjEMiO3CE4D_WSIp94pRtHnRwQ8g"
    static let imageBaseURL = "https://image.tmdb.org/t/p/w500"
}

extension UIImageView {
    func setImage(from urlString: String?, placeholder: UIImage? = UIImage(systemName: "photo")) {
        image = placeholder
        guard let urlString, let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self?.image = image
            }
        }.resume()
    }
}
