//
//  Episode.swift
//  PodcastSeries
//
//  Created by Zakir Magdum on 5/30/18.
//  Copyright © 2018 Zakir Magdum. All rights reserved.
//

import Foundation
import FeedKit
import Squeal

enum PlayStatus : Int {
    case notPlayed = 0, playing, played
}
struct Episode {
    var id: Int?
    var title: String
    var pubDate: Date
    var description: String
    var imageUrl: String?
    var author: String
    var streamUrl: String
    var categories: [String]?
    var category: String
    var shortTitle: String
    var played: PlayStatus?
    var favorite: Bool?
    var duration: Double?

    init(feedItem: RSSFeedItem) {
        self.streamUrl = feedItem.enclosure?.attributes?.url ?? ""
        self.title = feedItem.title ?? ""
        self.pubDate = feedItem.pubDate ?? Date()
        self.description = feedItem.iTunes?.iTunesSubtitle ?? feedItem.description ?? ""
        self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
        self.author = feedItem.iTunes?.iTunesAuthor ?? ""
        var categories = [String]()
        for cat in feedItem.categories ?? [] {
            categories.append(cat.value ?? "")
        }
        self.categories = categories
        self.category = "Uncategorized"
        self.shortTitle = self.title
        self.duration = feedItem.iTunes?.iTunesDuration
        self.played = .notPlayed
        self.favorite = false
    }
    
    init(row:Statement) throws {
        self.id = row.intValue("id") ?? 0
        self.title = row.stringValue("title")!
        self.category = row.stringValue("category")!
        self.description = row.stringValue("description")!
        self.imageUrl = row.stringValue("imageUrl")
        self.author = row.stringValue("author")!
        self.streamUrl = row.stringValue("streamUrl")!
        self.shortTitle = row.stringValue("shortTitle")!
        self.pubDate = Date(timeIntervalSince1970: row.doubleValue("pubDate")!)
        self.duration = row.doubleValue("duration")
        self.played = PlayStatus(rawValue: row.intValue("played")!)
        self.favorite = row.intValue("favorite") ?? 0 == 1
    }

}


