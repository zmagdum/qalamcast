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
                var toPlay = self.getEpisodeToPlay(series: series)
                if toPlay != nil {
                    let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
                    mainTabBarController?.maximizePlayerDetails(episode: toPlay)
                }
            } catch {
                print("Error Loading Episodes")
            }
            
        }
        play.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        play.image = #imageLiteral(resourceName: "play")
        return UISwipeActionsConfiguration(actions: [play])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let series = self.categories[indexPath.row]
        let moveToTop = UIContextualAction(style: .normal, title: "Move to Top") { (action, view, nil) in
            print("Move to top", indexPath)
            try! DB.shared.updateCategoryOrder(category: series, order: 1)
            self.fetchEpisodes()
        }
        moveToTop.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        moveToTop.image = #imageLiteral(resourceName: "double-up-50")
        let removeFromTop = UIContextualAction(style: .normal, title: "Remove from Top") { (action, view, nil) in
            print("Remove to top", indexPath)
            try! DB.shared.updateCategoryOrder(category: series, order: 0)
            self.fetchEpisodes()
        }
        removeFromTop.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        removeFromTop.image = #imageLiteral(resourceName: "multiply-50")
        let download = UIContextualAction(style: .normal, title: "Download") { (action, view, nil) in
            let episodes = try! DB.shared.getEpisodesForSeries(series: self.categories[indexPath.row].title ?? "")
            APIService.shared.downloadEpisodes(episodes: episodes)
        }
        download.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        download.image = #imageLiteral(resourceName: "icons8-download-from-the-cloud-50")
        return UISwipeActionsConfiguration(actions: [series.order == 0 ? moveToTop : removeFromTop, download])
    }
    
    func getEpisodeToPlay(series: Category) -> Episode? {
        do {
            // see whether current episode belong to this series
            let currentEpisode = DB.shared.getCurrentEpisode()
            if currentEpisode?.category == series.title {
                return currentEpisode
            }
            // get all episodes
            var episodes = try DB.shared.getEpisodesForSeries(series: (series.title)!)
            // find the playing episodes and return least recent one from that
            var playingEpisodes = episodes.filter{$0.played! > 0.0 && $0.played! < $0.duration!}
            if playingEpisodes.count > 0 {
                playingEpisodes.sort{ $0.pubDate < $1.pubDate }
                return playingEpisodes[0]
            }
            // find the least recent from all episodes
            if episodes.count > 0 {
                return episodes[0]
            }
        } catch {
            print("Error Loading Episodes")
        }
        return nil
    }
}
