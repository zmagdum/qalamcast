//
//  FavoritesController.swift
//  QalamCast
//
//  Created by Zakir Magdum on 4/3/19.
//  Copyright © 2019 Zakir Magdum. All rights reserved.
//

import UIKit
import FeedKit

class FavoritesController : UITableViewController {
    
    fileprivate let cellId = "cellId"
    
    var episodes = [Episode]()
    
    fileprivate func fetchEpisodes() {
        do {
            var fetched = try DB.shared.getFavoriteEpisodes()
            APIService.shared.sortFilterWithPreferences(&fetched)
            self.episodes = fetched
        } catch {
            print("Error Loading Episodes")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationItem.title = "Episodes"
        setupTableView()
        fetchEpisodes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchEpisodes()
        refreshView()
    }
    
    fileprivate func refreshView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    //MARK:- Setup
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "EpisodeCell2", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
    }
    //MARK:- UITableView
//    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
//        activityIndicatorView.color = .darkGray
//        activityIndicatorView.startAnimating()
//        return activityIndicatorView
//    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return episodes.isEmpty ? 200 : 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell2
        let episode = episodes[indexPath.row]
        cell.episode = episode
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        let episode = self.episodes[indexPath.row]
        mainTabBarController?.maximizePlayerDetails(episode: episode)
        //
        //        print("Trying to play ", episode.title)
        //        let window = UIApplication.shared.keyWindow
        //        let playerDetailsView = PlayerDetailsView.initFromNib()
        //        playerDetailsView.episode = episode
        //        playerDetailsView.frame = self.view.frame
        //        window?.addSubview(playerDetailsView)
    }
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let play = UIContextualAction(style: .normal, title: "Played") { (action, view, nil) in
            print("mark listened")
            do {
                self.episodes[indexPath.row].played = (self.episodes[indexPath.row].played?.isLess(than: self.episodes[indexPath.row].duration!))! ? self.episodes[indexPath.row].duration : 0
                try DB.shared.updatePlayed(episode: self.episodes[indexPath.row])
            } catch {
                print("Error Loading Episodes")
            }
        }
        play.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        play.image = #imageLiteral(resourceName: "icons8-checkmark-filled-50")
        let download = UIContextualAction(style: .normal, title: "Download") { (action, view, nil) in
            print("download")
        }
        download.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        download.image = #imageLiteral(resourceName: "icons8-download-from-the-cloud-50")
        let favorites = UIContextualAction(style: .normal, title: "Favorites") { (action, view, nil) in
            print("mark favorites")
            do {
                self.episodes[indexPath.row].favorite = !self.episodes[indexPath.row].favorite!
                try DB.shared.updateFavorite(episode: self.episodes[indexPath.row])
            } catch {
                print("Error Loading Episodes")
            }
        }
        favorites.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        favorites.image = #imageLiteral(resourceName: "icons8-bookmark-50")
        return UISwipeActionsConfiguration(actions: [play, download, favorites])
    }
    
}
