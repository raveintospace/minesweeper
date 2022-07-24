//
//  AppDelegate.swift
//  Minesweeper
//
//  Created by Uri on 3/7/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // creation of the mainVC
        
        window = UIWindow(frame: UIScreen.main.bounds)

        do {
            let viewController = try MakabreViewController()
            window?.rootViewController = UINavigationController(rootViewController: viewController)
        } catch {
            let alert = UIAlertController(title: "TODO MAL", message: "Els valors no permeten montar una matriu quadrada", preferredStyle: .alert)
            window?.rootViewController = alert
        }
        
        window?.makeKeyAndVisible()

        return true
    }

}

