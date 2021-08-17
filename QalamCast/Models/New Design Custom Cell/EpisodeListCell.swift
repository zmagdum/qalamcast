//
//  EpisodeListCell.swift
//  QalamCast
//
//  Created by apple on 13/08/21.
//  Copyright © 2021 Zakir Magdum. All rights reserved.
//

import UIKit

class EpisodeListCell: UITableViewCell {
    @IBOutlet weak var episodeTitle: UILabel!
    @IBOutlet weak var episodPostDay: UILabel!
    @IBOutlet weak var episodePlayBtn: UIButton!
    @IBOutlet weak var episodeProgressBar: UIProgressView!
    @IBOutlet weak var episodeTimeLeft: UILabel!
    @IBOutlet weak var episodeReleaseDate: UILabel!
    @IBOutlet weak var episodeFavBtn: UIButton!
    @IBOutlet weak var episodeDownloadBtn: UIButton!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.selectionStyle = .none
    }
    
    var episode: Episode! {
        didSet {
            episodPostDay.text = episode.shortTitle
            episodeTitle.text = episode.description
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            episodeReleaseDate.text = dateFormatter.string(from: episode.pubDate)
            
            let (h, m, s) = secondsToHoursMinutesSeconds(seconds: Int(((episode.duration ?? 3600) - (episode.played ?? 0))))
            
            episodeTimeLeft.text = ("\(h) hr, \(m) min") + " left"
            
            let imageUrl = episode.imageUrl  ?? ""
            if (imageUrl.starts(with: "http")) {
                let url = URL(string: episode.imageUrl ?? "")
                //episodeImageView.sd_setImage(with: url, completed: nil)
            } else {
                //episodeImageView.image = UIImage(named: imageUrl)
            }
            
            print("Epsiode Title \(episode.shortTitle) \(episode.duration ?? 3600) \(episode.played ?? 0)")

            let percentage = episode.played! / episode.duration!
            self.episodeProgressBar.progress = Float(percentage)
            
        }
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

}
