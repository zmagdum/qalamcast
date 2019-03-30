//
//  EpisodesController.swift
//  PodcastSeries
//
//  Created by Zakir Magdum on 5/28/18.
//  Copyright © 2018 Zakir Magdum. All rights reserved.
//

import UIKit
import FeedKit

class EpisodesController : UITableViewController {
    
    fileprivate let cellId = "cellId"
    
    var episodes = [Episode]()
    
    var series: Category? {
        didSet {
            navigationItem.title = series?.title
            fetchEpisodes()
        }
    }
    
    fileprivate func fetchEpisodes() {
        do {
            self.episodes = try DB.shared.getEpisodesForSeries(series: (series?.title)!)
        } catch {
            print("Error Loading Episodes")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationItem.title = "Episodes"
        setupTableView()
    }
    
    //MARK:- Setup
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "EpisodeCell2", bundle: nil)
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
}
