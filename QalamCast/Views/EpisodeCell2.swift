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
                let heartImage = UIImage(named: "green_circle_check")
                let imageView = UIImageView(image: heartImage)
                episodeImageView.addSubview(imageView)
            }
            if episode.favorite! {
                let heartImage = UIImage(named: "favorites")
                let imageView = UIImageView(image: heartImage)
                episodeImageView.addSubview(imageView)
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
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var downloadProgressBar: UIProgressView!
}
