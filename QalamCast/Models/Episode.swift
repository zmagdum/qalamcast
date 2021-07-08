//
//  Episode.swift
//  QalamCast
//
//  Created by Zakir Magdum on 5/30/18.
//  Copyright © 2018 Zakir Magdum. All rights reserved.
//

import Foundation
import FeedKit
import Squeal

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
    var played: Double?
    var favorite: Bool?
    var duration: Double?
    var download: Bool?

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
        self.duration = feedItem.iTunes?.iTunesDuration ?? 3600 // assume 1 hour if we can not find duration
        self.played = 0.0
        self.favorite = false
        self.download = false
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
        self.played = row.doubleValue("played")!
        self.favorite = row.intValue("favorite") ?? 0 == 1
        self.download = row.intValue("download") ?? 0 == 1
    }

}


