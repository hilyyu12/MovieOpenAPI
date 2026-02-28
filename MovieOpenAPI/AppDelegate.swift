//
//  AppDelegate.swift
//  MovieOpenAPI
//
//  Created by Abiyyu on 28/02/26.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let rootVC = ListPopularVC(nibName: "ListPopularVC", bundle: nil)
        let navigation = UINavigationController(rootViewController: rootVC)
        
        window?.rootViewController = navigation
        window?.makeKeyAndVisible()
        return true
    }



}

