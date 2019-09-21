//
//  EpisodeCell2.swift
//  QalamCast
//
//  Created by Zakir Magdum on 5/31/18.
//  Copyright © 2018 Zakir Magdum. All rights reserved.
//

import UIKit

class SeriesCell : UITableViewCell {
    let dateFormatter = DateFormatter()

    var series: Category! {
        didSet {
            seriesNameLabel.text = series.title
            dateFormatter.dateFormat = "MMM dd, yyyy"
            //let lastUpdated = dateFormatter.string(from: series.lastUpdated!)
//            let unplayed = try! DB.shared.getUnplayedCount(series: series.title ?? "")
            var desc = "Episodes \(series.episodeCount ?? 0)"
            if series.lastUpdated != nil {
                desc += " " + dateFormatter.string(from: series.lastUpdated!)
            }
            descriptionLabel.text = desc
            speakerNameLabel.text = series.speakers
            let url = URL(string: series.artwork ?? "")
            artworkImageView.sd_setImage(with: url, completed: nil)
        }
    }

    
    @IBOutlet weak var seriesNameLabel: UILabel! {
        didSet {
            seriesNameLabel.numberOfLines = 2
        }
    }
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var speakerNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.numberOfLines = 2
        }
    }
}
