//
//  DB.swift
//  QalamCast
//
//  Created by Zakir Magdum on 3/28/19.
//  Copyright © 2019 Zakir Magdum. All rights reserved.
//

import Foundation
import Squeal

class DB {
    static let shared = DB()
    var db = Database()
    
    func createDatabase() throws {
        try db.createTable("series", definitions: [
            "id INTEGER PRIMARY KEY",
            "title TEXT NOT NULL",
            "speakers TEXT",
            "artwork TEXT",
            "episodeCount INT",
            "lastUpdated DATE",
            "tokens TEXT"
            ])
        try db.createTable("episodes", definitions: [
            "id INTEGER PRIMARY KEY",
            "title TEXT NOT NULL UNIQUE",
            "category TEXT NOT NULL",
            "description TEXT",
            "imageUrl TEXT",
            "author TEXT",
            "pubDate DATE",
            "streamUrl TEXT",
            "shortTitle TEXT"
            ])
    }
    
    func saveEpisode(episode: Episode) throws {
        try db.insertInto(
            "episodes",
            values: [
                "title": episode.title,
                "category": episode.category,
                "description": episode.description,
                "imageUrl": episode.imageUrl,
                "author": episode.author,
                "pubDate": episode.pubDate.timeIntervalSince1970,
                "streamUrl": episode.streamUrl,
                "shortTitle": episode.shortTitle
            ]
        )
    }
    
    func saveEpisodes(episodes: [Episode]) throws {
        for episode in episodes {
            try saveEpisode(episode: episode)
        }
    }
    
    func getEpisodesForSeries(series: String) throws -> [Episode] {
        let episodes:[Episode] = try db.selectFrom(
            "episodes",
            whereExpr:"category = '" + series + "'",
            block: Episode.init
        )
        return episodes;
    }
}
