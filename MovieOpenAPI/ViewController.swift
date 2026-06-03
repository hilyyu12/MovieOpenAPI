//
//  ViewController.swift
//  MovieOpenAPI
//
//  Created by Abiyyu on 28/02/26.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        showMovieList()
    }

    private func showMovieList() {
        let listVC = ListPopularVC(nibName: "ListPopularVC", bundle: nil)
        let navigationController = UINavigationController(rootViewController: listVC)
        
        addChild(navigationController)
        navigationController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationController.view)
        NSLayoutConstraint.activate([
            navigationController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationController.view.topAnchor.constraint(equalTo: view.topAnchor),
            navigationController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        navigationController.didMove(toParent: self)
    }
}
