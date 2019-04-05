//
//  MainTabBarController.swift
//  PodcastSeries
//
//  Created by Zakir Magdum on 5/26/18.
//  Copyright © 2018 Zakir Magdum. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    let seriesController = SeriesController()
    override func viewDidLoad() {
        super.viewDidLoad()
        //UINavigationBar.appearance().prefers
        tabBar.tintColor = .purple
        view.backgroundColor = .green
        setupViewControllers()
        setupPlayerDetailsView()
//        APIService.shared.loadCategoriesWithEpisodes() { (categories) in
//            for cat in categories {
//                print("Category", cat)
//            }
//        }
//        do {
//            print("Found Categories ", try DB.shared.getCategories().count)
//        } catch {
//            print("Error getting categories \(error)")
//        }

        do {
            try DB.shared.createDatabase()
            print("Found Categories After ", try DB.shared.getCategories().count)
        } catch {
            print("Error creating database \(error)")
        }
        APIService.shared.loadCategoriesWithEpisodes() { (categories, episodes) in
            do {
                try DB.shared.saveEpisodes(episodes: episodes)
                try DB.shared.saveCategories(categories: categories)
                self.seriesController.fetchEpisodes()
            } catch {
                print("Error Saving episodes and categories")
            }
        }
        
    }

    @objc func minimizePlayerDetails() {
        maximizedTopAnchorConstraint.isActive = false
        minimizedTopAnchorConstraint.isActive = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.tabBar.transform = .identity
            self.playerDetailsView.miniPlayerView.alpha = 1
            self.playerDetailsView.maxPlayerView.alpha = 0
        })
    }
    
    func maximizePlayerDetails(episode: Episode?) {
        print(222)
        maximizedTopAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.constant = 0
        minimizedTopAnchorConstraint.isActive = false
        if episode != nil {
            playerDetailsView.episode = episode
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
            self.playerDetailsView.miniPlayerView.alpha = 0
            self.playerDetailsView.maxPlayerView.alpha = 1
        })
    }
    
    //MARK:- Setup Functions
    let playerDetailsView = PlayerDetailsView.initFromNib()

    var maximizedTopAnchorConstraint: NSLayoutConstraint!
    var minimizedTopAnchorConstraint: NSLayoutConstraint!

    fileprivate func setupViewControllers() {
        viewControllers = [
            generateNavigationCOntroller(with: seriesController, title: "Home", image: #imageLiteral(resourceName: "search")),
            generateNavigationCOntroller(with: FavoritesController(), title: "Favorites", image: #imageLiteral(resourceName: "favorites")),
            generateNavigationCOntroller(with: ViewController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads"))
        ]
    }

    fileprivate func setupPlayerDetailsView() {
        print("setting up")
//        playerDetailsView.backgroundColor = .red
        //view.insertSubview(playerDetailsView, belowSubView: tabBar)
        //view.addSubview(playerDetailsView)
        view.insertSubview(playerDetailsView, belowSubview: tabBar)
        playerDetailsView.translatesAutoresizingMaskIntoConstraints = false
        maximizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        
        maximizedTopAnchorConstraint.isActive = true
        
        minimizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        playerDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        playerDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

    }
    //MARK:- Helper Functions
    
    fileprivate func generateNavigationCOntroller(with rootViewController : UIViewController, title: String, image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.navigationBar.prefersLargeTitles = true
        rootViewController.navigationItem.title = title
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        return navController;
    }
}
