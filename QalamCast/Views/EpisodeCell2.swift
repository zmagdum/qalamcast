//
//  EpisodeCell2.swift
//  QalamCast
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
            let imageUrl = episode.imageUrl  ?? ""
            if (imageUrl.starts(with: "http")) {
                let url = URL(string: episode.imageUrl ?? "")
                episodeImageView.sd_setImage(with: url, completed: nil)
            } else {
                episodeImageView.image = UIImage(named: imageUrl)
            }
            for subView in self.episodeImageView.subviews {
                subView.removeFromSuperview()
            }
            if episode.played ?? 0 == episode.duration ?? 100 {
                let image = UIImage(named: "green_circle_check")
                let imageView = UIImageView(image: image)
                episodeImageView.addSubview(imageView)
            }
            if episode.favorite! {
                let image = UIImage(named: "favorites")
                let imageView = UIImageView(image: image)
                imageView.frame = CGRect(x: episodeImageView.frame.width - imageView.frame.width, y: 0, width: imageView.frame.width, height: imageView.frame.height)
                episodeImageView.addSubview(imageView)
            }
            if episode.download! {
                let image = UIImage(named: "downloaded")
                let imageView = UIImageView(image: image)
                imageView.frame = CGRect(x: 0, y: episodeImageView.frame.height - imageView.frame.height, width: imageView.frame.width, height: imageView.frame.height)
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
