//
//  MainTabBarController.swift
//  QalamCast
//
//  Created by Zakir Magdum on 5/26/18.
//  Copyright © 2018 Zakir Magdum. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    let seriesController = SeriesController()
    override func viewDidLoad() {
        super.viewDidLoad()
        //UINavigationBar.appearance().prefers
        tabBar.tintColor = .purple
        view.backgroundColor = .green
        setupViewControllers()
        setupPlayerDetailsView()

        do {
            //try DB.shared.resetDatabase()
            try DB.shared.createDatabase()
            DB.shared.fetchEpisodesFromSeries()
            //DB.shared.fetchEpisodesFromMainUrl()
            print("Found Categories After ", try DB.shared.getCategories().count)
        } catch {
            print("Error creating database \(error)")
        }
        // fetch episodes from main URL
//        APIService.shared.loadCategoriesWithEpisodes(feedUrl: APIService.qalamFeedUrl) { (categories, episodes) in
//            do {
////                try DB.shared.saveEpisodes(episodes: episodes)
////                try DB.shared.saveCategories(categories: categories)
////                self.seriesController.fetchEpisodes()
//            } catch {
//                print("Error Saving episodes and categories")
//            }
//        }
        DispatchQueue.main.async {
            let currentEpisode = DB.shared.getCurrentEpisode()
            if currentEpisode != nil {
                self.maximizePlayerDetails(episode: currentEpisode)
            }
        }
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("Selected item")
        minimizePlayerDetails()
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
        maximizedTopAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.constant = 0
        minimizedTopAnchorConstraint.isActive = false
        if episode != nil {
            playerDetailsView.episodeId = episode?.id
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            //self.tabBar.transform = CGAffineTransform(translationX: 0, y: 50)
            self.playerDetailsView.miniPlayerView.alpha = 0
            self.playerDetailsView.maxPlayerView.alpha = 1
        })
        if !APIService.shared.getAutoStartPlay() {
            playerDetailsView.handlePlayPause()
        }
    }
    
    //MARK:- Setup Functions
    let playerDetailsView = PlayerDetailsView.initFromNib()

    var maximizedTopAnchorConstraint: NSLayoutConstraint!
    var minimizedTopAnchorConstraint: NSLayoutConstraint!

    fileprivate func setupViewControllers() {
        viewControllers = [
            generateNavigationCOntroller(with: UIViewController(), title: "yyy", image: #imageLiteral(resourceName: "rights_companionship"))
            generateNavigationCOntroller(with: seriesController, title: "Home", image: #imageLiteral(resourceName: "home-50")),
            generateNavigationCOntroller(with: SearchController(), title: "Search", image: #imageLiteral(resourceName: "search")),
            generateNavigationCOntroller(with: FavoritesController(), title: "Favorites", image: #imageLiteral(resourceName: "heart-outline-50")),
            generateNavigationCOntroller(with: RamadanViewController(), title: "Ramadan", image: #imageLiteral(resourceName: "moon-50")),
            //generateNavigationCOntroller(with: DownloadsController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads")),
            generateNavigationCOntroller(with: SettingsController(), title: "Settings", image: #imageLiteral(resourceName: "settings"))

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
