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
            generateNavigationCOntroller(with: seriesController, title: "Home", image: #imageLiteral(resourceName: "home-50")),
            generateNavigationCOntroller(with: SearchController(), title: "Search", image: #imageLiteral(resourceName: "search")),
            generateNavigationCOntroller(with: FavoritesController(), title: "Favorites", image: #imageLiteral(resourceName: "heart-outline-50")),
            generateNavigationCOntroller(with: RamadanViewController(), title: "Campus", image: #imageLiteral(resourceName: "moon-50")),
            generateNavigationCOntroller(with: SettingsController(), title: "Settings", image: #imageLiteral(resourceName: "settings")),
//            generateNavigationCOntroller(with: DonateViewController(), title: "Donate", image: #imageLiteral(resourceName: "settings"))
            //generateNavigationCOntroller(with: DownloadsController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads")),

        ]
        
        viewControllers?.first?.navigationController?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView:createDonateButton())
        
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
    
    func createDonateButton() -> UIButton {
        
        var button = UIButton(type: .custom)
        button = UIButton(frame: CGRect(x: 0 , y: 0, width: 80, height: 40))
        button.backgroundColor = UIColor(red: 243/255.0, green: 158/255.0, blue: 53/255.0, alpha: 1.0)
        button.setTitle("Donate", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        button.addTarget(self, action: #selector(buttonAction(sender:)) ,for: .touchUpInside)        
                
        //self.navigationController!.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        
        return button
    }
    
    @objc func buttonAction(sender: UIButton!) {
        if let url = URL(string: "https://www.qalam.institute/support-us"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
    
    //MARK:- Helper Functions
    
    fileprivate func  generateNavigationCOntroller(with rootViewController : UIViewController, title: String, image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.navigationBar.prefersLargeTitles = true
        rootViewController.navigationItem.title = title
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        let barButton = UIBarButtonItem(customView: createDonateButton())
        navController.navigationItem.rightBarButtonItem = barButton
        return navController;
    }
}
