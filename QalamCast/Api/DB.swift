//
//  DB.swift
//  QalamCast
//
//  Created by Zakir Magdum on 3/28/19.
//  Copyright © 2019 Zakir Magdum. All rights reserved.
//

import Foundation
import Squeal

let AppSchema = Schema(identifier:"contacts") { schema in
    // Version 1:
    schema.version(1) { v1 in
        // Create a Table:
        v1.createTable("categories") { contacts in
            contacts.primaryKey("id")
            contacts.column("title", type:.Text, constraints:["NOT NULL", "UNIQUE"])
            contacts.column("speakers", type:.Text)
            contacts.column("artwork", type:.Text)
            contacts.column("tokens", type:.Text)
            contacts.column("episodeCount", type:.Integer)
            contacts.column("lastUpdated", type:.Real)
        }
        // Add an index
        v1.createIndex(
            "categories_title",
            on: "categories",
            columns: [ "title" ]
        )
        v1.createTable("episodes") { contacts in
            contacts.primaryKey("id")
            contacts.column("title", type:.Text, constraints:["NOT NULL", "UNIQUE"])
            contacts.column("category", type:.Text, constraints:["NOT NULL"])
            contacts.column("description", type:.Text)
            contacts.column("imageUrl", type:.Text)
            contacts.column("author", type:.Text)
            contacts.column("played", type:.Integer)
            contacts.column("favorite", type:.Integer)
            contacts.column("pubDate", type:.Real)
            contacts.column("duration", type:.Real)
            contacts.column("streamUrl", type:.Text)
            contacts.column("shortTitle", type:.Text)
        }
        // Add an index
        v1.createIndex(
            "episodes_title",
            on: "episodes",
            columns: [ "title" ]
        )
        // Add an index
        v1.createIndex(
            "episodes_category",
            on: "episodes",
            columns: [ "category" ]
        )
    }
}


class DB {
    static let shared = DB()
    var db: Database!
    
    func createDatabase() throws {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        self.db = try! Database(path: "\(path)/qalamcast.sqllite")
//        try db.createTable("series", definitions: [
//            "id INTEGER PRIMARY KEY",
//            "title TEXT NOT NULL",
//            "speakers TEXT",
//            "artwork TEXT",
//            "episodeCount INT",
//            "lastUpdated DATE",
//            "tokens TEXT"
//            ])
//        try db.createTable("episodes", definitions: [
//            "id INTEGER PRIMARY KEY",
//            "title TEXT NOT NULL UNIQUE",
//            "category TEXT NOT NULL",
//            "description TEXT",
//            "imageUrl TEXT",
//            "author TEXT",
//            "pubDate DATE",
//            "streamUrl TEXT",
//            "shortTitle TEXT"
//            ])
        // Migrate to the latest version:
        try AppSchema.reset(db)
        let didMigrate = try AppSchema.migrate(db)
        // Get the database version:
        let migratedVersion = try db.queryUserVersionNumber()
//        try db.execute("DELETE FROM categories")
//        try db.execute("DELETE FROM episodes")
        print("Migrated database version \(didMigrate)  \(migratedVersion)")
    }
    
    func saveEpisode(episode: Episode) throws {
        try self.db.insertInto(
            "episodes",
            values: [
                "title": episode.title,
                "category": episode.category,
                "description": episode.description,
                "imageUrl": episode.imageUrl,
                "author": episode.author,
                "pubDate": episode.pubDate.timeIntervalSince1970,
                "streamUrl": episode.streamUrl,
                "shortTitle": episode.shortTitle,
                "played": episode.played?.rawValue,
                "duration": episode.duration
            ]
        )
    }

    func saveCategory(category: Category) throws {
        try self.db.insertInto(
            "categories",
            values: [
                "title": category.title,
                "artwork": category.artwork,
                "speakers": category.speakers,
                "tokens": category.tokens?.joined(separator: ","),
                "episodeCount": category.episodeCount,
                "lastUpdated": category.lastUpdated?.timeIntervalSince1970
            ]
        )
    }
    
    func saveCategories(categories: [Category]) throws {
        for category in categories {
            try saveCategory(category: category)
        }
    }
    
    func saveEpisodes(episodes: [Episode]) throws {
        for episode in episodes {
            try saveEpisode(episode: episode)
        }
    }
    
    func getEpisodesForSeries(series: String) throws -> [Episode] {
        let episodes:[Episode] = try self.db.selectFrom(
            "episodes",
            whereExpr:"category = '" + series + "'",
            block: Episode.init
        )
        return episodes;
    }

    func getFavoriteEpisodes() throws -> [Episode] {
        let episodes:[Episode] = try self.db.selectFrom(
            "episodes",
            whereExpr:"favorite = 1",
            block: Episode.init
        )
        return episodes;
    }

    func getCategories() throws -> [Category] {
        var categories:[Category] = try self.db.selectFrom(
            "categories",
            block: Category.init
        )
        categories.sort{ $0.title! < $1.title! }
        return categories;
    }
    
    func updateFavorite(episode: Episode) throws {
        try self.db.update("episodes", set: ["favorite": episode.favorite! ? 1 : 0], whereExpr: "title = '" + episode.title + "'")
    }
    
    func updatePlayed(episode: Episode) throws {
        try self.db.update("episodes", set: ["played": episode.played?.rawValue], whereExpr: "title = '" + episode.title + "'")
    }
}
