//
//  EpisodesController.swift
//  PodcastSeries
//
//  Created by Zakir Magdum on 5/28/18.
//  Copyright © 2018 Zakir Magdum. All rights reserved.
//

import UIKit
import FeedKit

class SeriesController : UITableViewController {
    
    fileprivate let cellId = "cellId"
    
    var categories = [Category]()
    
    func fetchEpisodes() {
        do {
            try self.categories = DB.shared.getCategories()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Could not load categories")
        }
        
//        APIService.shared.loadCategoriesWithEpisodes() { (categories, episodes) in
//            self.categories = categories
//            self.categories.sort{ $0.title! < $1.title! }
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationItem.title = "Episodes"
        setupTableView()
        fetchEpisodes()
    }
    
    //MARK:- Setup
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "SeriesCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
    }
    
    //MARK:- UITableView
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.color = .darkGray
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return categories.isEmpty ? 200 : 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SeriesCell
        let series = categories[indexPath.row]
        cell.series = series
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episodesController = EpisodesController()
        episodesController.series = self.categories[indexPath.row]
        navigationController?.pushViewController(episodesController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let play = UIContextualAction(style: .normal, title: "Play") { (action, view, nil) in
            print("Play Next", indexPath)
            let series = self.categories[indexPath.row]
            do {
                var episodes = try DB.shared.getEpisodesForSeries(series: (series.title)!)
                if episodes.count > 0 {
                    episodes.sort{ $0.pubDate < $1.pubDate }
                    let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
                    mainTabBarController?.maximizePlayerDetails(episode: episodes[0])
                }
            } catch {
                print("Error Loading Episodes")
            }
            
        }
        play.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        play.image = #imageLiteral(resourceName: "play")
        return UISwipeActionsConfiguration(actions: [play])
    }
}
