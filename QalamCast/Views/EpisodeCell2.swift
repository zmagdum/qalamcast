//
//  EpisodeCell2.swift
//  PodcastSeries
//
//  Created by Zakir Magdum on 5/31/18.
//  Copyright © 2018 Zakir Magdum. All rights reserved.
//

import UIKit

class EpisodeCell2: UITableViewCell {

    var episode: Episode! {
        didSet {
            titleLabel.text = episode.shortTitle
            descriptionLabel.text = episode.description
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            pubDateLabel.text = dateFormatter.string(from: episode.pubDate)
            let url = URL(string: episode.imageUrl ?? "")
            episodeImageView.sd_setImage(with: url, completed: nil)
            if episode.played! == episode.duration! {
                titleLabel.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            }
            if episode.favorite! {
                self.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
            }
        }
    }
    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var pubDateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!{
        didSet {
            descriptionLabel.numberOfLines = 2
        }
    }
    @IBOutlet weak var titleLabel: UILabel!{
        didSet {
            titleLabel.numberOfLines = 2
        }
    }
}
