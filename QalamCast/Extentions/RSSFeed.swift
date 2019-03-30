//
//  RSSFeed.swift
//  PodcastSeries
//
//  Created by Zakir Magdum on 5/31/18.
//  Copyright © 2018 Zakir Magdum. All rights reserved.
//

import FeedKit
extension RSSFeed {
    func toEpisodes() -> [Episode] {
        var episodes = [Episode]() // blank Episode array
        let imageUrl = image?.url
        items?.forEach({ (feedItem) in
            var episode = Episode(feedItem: feedItem)
            if (episode.imageUrl == nil) {
                episode.imageUrl = imageUrl
            }
            episodes.append(episode)
        })
        return episodes
    }
}
