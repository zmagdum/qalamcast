//
//  SeriesListVC.swift
//  QalamCast
//
//  Created by apple on 11/08/21.
//  Copyright © 2021 Zakir Magdum. All rights reserved.
//

import UIKit
import FeedKit

class SeriesListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var blurImgView: UIImageView!
    @IBOutlet weak var podcastImgView: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var podcastTitle: UILabel!
    @IBOutlet weak var podcastDescription: UILabel!
    @IBOutlet weak var podcastLike: UILabel!
    @IBOutlet weak var podcastFavBtn: UIButton!
    @IBOutlet weak var playEpisodView: UIView!
    
    @IBOutlet weak var seriesListTblView: UITableView!
    
    
    var episodes = [Episode]()
    
    var series: Category? {
        didSet {
            fetchEpisodes()
        }
    }
    
    fileprivate func fetchEpisodes() {
        do {
            var fetched = try DB.shared.getEpisodesForSeries(series: (series?.title)!)
            APIService.shared.sortFilterWithPreferences(&fetched)
            self.episodes = fetched
        } catch {
            print("Error Loading Episodes")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        podcastTitle.text = series?.title
        
        let imageUrl = series?.artwork ?? ""
        if (imageUrl.starts(with: "http")) {
            let url = URL(string: imageUrl)
            blurImgView.sd_setImage(with: url, completed: nil)
            podcastImgView.sd_setImage(with: url, completed: nil)
        } else {
            blurImgView.image = UIImage(named: imageUrl)
            podcastImgView.image = UIImage(named: imageUrl)
        }
        
        setupObservers()
    }
    
    fileprivate func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadComplete), name: .downloadComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    @objc func defaultsChanged() {
        fetchEpisodes()
        refreshView()
        print("defaults changed refreshingh episodes")
    }

    //MARK: - UITableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let episodeListCell = tableView.dequeueReusableCell(withIdentifier: "EpisodeListCell", for: indexPath) as! EpisodeListCell
        let episode = episodes[indexPath.row]
        episodeListCell.episode = episode
        episodeListCell.episode.imageUrl = self.series?.artwork
        
        if episode.played! > 0.0 {
            
            episodeListCell.episodeProgressBar.isHidden = false
            episodeListCell.episodeTimeLeft.isHidden = false
            
        }
        else {
            
            episodeListCell.episodeProgressBar.isHidden = true
            episodeListCell.episodeTimeLeft.isHidden = true
            
        }
        
        return episodeListCell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyBoardNew = UIStoryboard.init(name: "NewDesign", bundle: nil)
        
        let episodePlayerVC = storyBoardNew.instantiateViewController(withIdentifier: "EpisodePlayerVC") as! EpisodePlayerVC
                
        let episode = self.episodes[indexPath.row]
        
        episodePlayerVC.series = series
        
        if episode != nil {
            episodePlayerVC.episodeId = episode.id
        }
        
        self.navigationController?.pushViewController(episodePlayerVC, animated: true)
        
    }
    
    fileprivate func refreshView() {
        DispatchQueue.main.async {
            self.seriesListTblView.reloadData()
        }
    }
    
    @objc fileprivate func handleDownloadComplete(notification: Notification) {
        print("Downloaded ", notification.name, notification.object!)
        guard (notification.object as? APIService.EpisodeDownloadCompleteTuple) != nil else { return }
        guard let index = self.episodes.index(where: { $0.title == title }) else { return }
        guard (seriesListTblView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeListCell) != nil else { return }
        //cell.downloadProgressBar.isHidden = true
        //cell.progressLabel.isHidden = true
    }
    
    @objc fileprivate func handleDownloadProgress(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any] else { return }
        
        guard let progress = userInfo["progress"] as? Double else { return }
        guard let id = userInfo["id"] as? Int else { return }
        
        // lets find the index using id
        guard let index = self.episodes.index(where: { $0.id == id }) else { return }
        
        guard let cell = seriesListTblView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeListCell else { return }
        //cell.downloadProgressBar.setProgress(Float(progress), animated: true)
        //cell.downloadProgressBar.isHidden = false
        if progress == 1 {
            //cell.downloadProgressBar.isHidden = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Button Clicks
    
    @IBAction func backBtnClick(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func podcastFavBtnClick(_ sender: Any) {
        
        if podcastFavBtn.isSelected {
            
            podcastFavBtn.isSelected = false
            
        }
        else {
            
            podcastFavBtn.isSelected = true
            
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
