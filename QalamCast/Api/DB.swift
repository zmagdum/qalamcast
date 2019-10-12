//
//  DB.swift
//  QalamCast
//
//  Created by Zakir Magdum on 3/28/19.
//  Copyright © 2019 Zakir Magdum. All rights reserved.
//

import Foundation
import Squeal

extension String: Error {}

let AppSchema = Schema(identifier:"contacts") { schema in
    // Version 1:
    schema.version(1) { v1 in
        // Create a Table:
        v1.createTable("categories") { contacts in
            contacts.primaryKey("id")
            contacts.column("title", type:.Text, constraints:["NOT NULL", "UNIQUE"])
            contacts.column("feedUrl", type:.Text)
            contacts.column("speakers", type:.Text)
            contacts.column("artwork", type:.Text)
            contacts.column("tokens", type:.Text)
            contacts.column("episodeCount", type:.Integer)
            contacts.column("order", type:.Integer)
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
            contacts.column("played", type:.Real)
            contacts.column("favorite", type:.Integer)
            contacts.column("download", type:.Integer)
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
    private let syncQueue = DispatchQueue(label: "db.sync.queue")
    static let shared = DB()
    var db: Database!
    let taskGroup = DispatchGroup()

    func createDatabase() throws {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        self.db = try! Database(path: "\(path)/qalamcast.sqllite")
        // Migrate to the latest version:
        //try AppSchema.reset(db)
        let didMigrate = try AppSchema.migrate(db)
        // Get the database version:
        let migratedVersion = try db.queryUserVersionNumber()
//        try db.execute("DELETE FROM categories")
//        try db.execute("DELETE FROM episodes")
        print("Migrated database version \(didMigrate)  \(migratedVersion)")
    }
    
    func resetDatabase() throws {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        self.db = try! Database(path: "\(path)/qalamcast.sqllite")
        // Migrate to the latest version:
        print("Resetting database")
        try AppSchema.reset(db)
        let didMigrate = try AppSchema.migrate(db)
        // Get the database version:
        let migratedVersion = try db.queryUserVersionNumber()
        //        try db.execute("DELETE FROM categories")
        //        try db.execute("DELETE FROM episodes")
        print("Migrated database version \(didMigrate)  \(migratedVersion)")
    }
    
    func fetchEpisodesFromSeries() {
        let series = try! getCategories()
        if series.count == 0 {
            var updateEpisodes = [Episode]()
            var updatedCategories = [Category]()
            let categories = APIService.shared.loadCategories() ?? []
            NotificationCenter.default.post(name: .catalogStart, object: nil, userInfo: ["count": categories.count])
            //DB.shared.saveCategories(categories: categories)
            var loaded = 0
            var requested = 0
            for cat in categories {
                if cat.feedUrl == nil || cat.feedUrl?.count == 0 {
                    continue
                }
                taskGroup.enter()
                requested += 1
                print("Loading podcasts from " + cat.feedUrl! + " \(requested)")
                APIService.shared.loadCategoryEpisodes(cat: cat) { (category, episodes) in
                        //self.syncQueue.sync {
                    loaded += 1
                    print("found epsidoes \(requested) \(loaded) \(cat.feedUrl!)  \(episodes.count) \(categories.count)")
                            updateEpisodes.append(contentsOf: episodes)
                            updatedCategories.append(category)
                            //DB.shared.saveEpisodes(episodes: episodes)
                            //try! DB.shared.saveCategory(category: category)
                            NotificationCenter.default.post(name: .catalogProgress, object: nil, userInfo: ["count": loaded])
                            self.taskGroup.leave()
                            //print("appended episodes \(cat.feedUrl!)  \(updateEpisodes.count) \(updatedCategories.count)")
                    //}
                }
            }
            taskGroup.notify(queue: .main) {
                print("Saving episodes \(updateEpisodes.count) \(updatedCategories.count)")
                DB.shared.saveEpisodes(episodes: updateEpisodes)
                DB.shared.saveCategories(categories: updatedCategories)
                DB.shared.fetchEpisodesFromMainUrl()
            }
            //4. Notify when all task completed
//            taskGroup.notify(queue: DispatchQueue.main, work: DispatchWorkItem(block: {
//                print("Saving episodes \(updateEpisodes.count) \(updatedCategories.count)")
//                DB.shared.saveEpisodes(episodes: updateEpisodes)
//                DB.shared.saveCategories(categories: updatedCategories)
//                DB.shared.fetchEpisodesFromMainUrl()
//            }))
        } else {
            print("Episodes already loaded from series")
            DB.shared.fetchEpisodesFromMainUrl()
        }
        print("Started fetching episodes RSS")
    }
    
    func fetchEpisodesFromMainUrl() {
        APIService.shared.loadCategoriesWithEpisodes(feedUrl: APIService.qalamFeedUrl) { (categories, episodes) in
            DB.shared.saveEpisodes(episodes: episodes)
            DB.shared.saveCategories(categories: categories)
            NotificationCenter.default.post(name: .catalogComplete, object: nil, userInfo: ["count": categories.count])
            print("Loaded episodes \(episodes.count) and categories \(categories.count) from main url ")
        }

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
                "played": episode.played,
                "duration": episode.duration
            ]
        )
    }

    func saveCategory(category: Category) throws {
        do {
            try self.db.insertInto(
                "categories",
                values: [
                    "title": category.title,
                    "artwork": category.artwork,
                    "speakers": category.speakers,
                    "tokens": category.tokens?.joined(separator: ","),
                    "episodeCount": category.episodeCount,
                    "order": category.order,
                    "lastUpdated": category.lastUpdated?.timeIntervalSince1970
                ]
            )
        } catch {
            let episodesCount:Int = self.getEpisodeCount(series: category.title!)
            try self.db.update("categories", set: ["artwork": category.artwork,
                                                   "speakers": category.speakers,
                                                   "tokens": category.tokens?.joined(separator: ","),
                                                   "episodeCount": episodesCount,
                                                   "order": category.order,
                                                   "lastUpdated" : category.lastUpdated?.timeIntervalSince1970], whereExpr: "title = '\(category.title!)'")
            print("Updated series \(category.title!) \(episodesCount)")

        }
    }
    
    func saveCategories(categories: [Category]) {
        for category in categories {
            try? saveCategory(category: category)
        }
    }
    
    func saveEpisodes(episodes: [Episode]) {
        for episode in episodes {
            try? saveEpisode(episode: episode)
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

    func getEpisodeCount(series: String) -> Int {
        do {
            let episodes:[Episode] = try self.db.selectFrom(
                "episodes",
                whereExpr:"category = '" + series + "'",
                block: Episode.init
            )
            return episodes.count;
        } catch {
            return 0
        }
    }
    
    func getUnplayedCount(series: String) throws -> Int {
        let episodes:[Episode] = try self.db.selectFrom(
            "episodes",
            whereExpr:"category = '" + series + "' and (duration - played) > 3",
            block: Episode.init
        )
        return episodes.count;
    }
    
    func getFavoriteEpisodes() throws -> [Episode] {
        if self.db == nil {
            return []
        }
        let episodes:[Episode] = try self.db.selectFrom(
            "episodes",
            whereExpr:"favorite = 1",
            block: Episode.init
        )
        return episodes;
    }

    func search(term: String) throws -> [Episode] {
        if self.db == nil || term.count == 0 {
            return []
        }
        var episodes:[Episode] = try self.db.selectFrom(
            "episodes",
            whereExpr:"title like '%" + term + "%' or author like '%" + term + "%'" ,
            block: Episode.init
        )
        episodes.sort{$1.pubDate < $0.pubDate}
        return episodes;
    }

    func getDownloadedEpisodes() throws -> [Episode] {
        if self.db == nil {
            return []
        }
        let episodes:[Episode] = try self.db.selectFrom(
            "episodes",
            whereExpr:"download = 1",
            block: Episode.init
        )
        return episodes;
    }
    
    func getEpisode(id: Int) throws -> Episode {
        let episodes:[Episode] = try self.db.selectFrom(
            "episodes",
            whereExpr:"id = " + String(id),
            block: Episode.init
        )
        if episodes.count > 0 {
            return episodes[0]
        }
        throw "Episode not found for \(id)"
    }
    
    func getCategories() throws -> [Category] {
        var categories:[Category] = try self.db.selectFrom(
            "categories",
            block: Category.init
        )
        categories.sort{ ($1.order!, $0.title!) < ($0.order!, $1.title!) }
        print("Fetched series")
        return categories;
    }
    
    func updateFavorite(episode: Episode) throws {
        try self.db.update("episodes", set: ["favorite": episode.favorite! ? 1 : 0], whereExpr: "title = '" + episode.title + "'")
    }
    
    func updatePlayed(episode: Episode) throws {
        try self.db.update("episodes", set: ["played": episode.played], whereExpr: "title = '" + episode.title + "'")
    }
    
    func updateDownload(episode: Episode, download: Bool) throws {
        try self.db.update("episodes", set: ["download": download ? 1 : 0], whereExpr: "title = '" + episode.title + "'")
    }
    func updateCategoryOrder(category: Category, order: Int) throws {
        try self.db.update("categories", set: ["order": 0])
        try self.db.update("categories", set: ["order": order], whereExpr: "id = \(category.id ?? 0)")
    }
    
    func deleteEpisode(episode: Episode) {
        try! DB.shared.updateDownload(episode: episode, download: false)
        let url = APIService.shared.getEpisodeLocalUrl(episode: episode)
        try! FileManager.default.removeItem(at: url!)
    }
    
    func saveCurrentEpisode(episode: Episode) {
        let defaults = UserDefaults.standard
        defaults.set(episode.id, forKey: APIService.currentEpisodeId)
    }
    
    func getCurrentEpisode() -> Episode? {
        let defaults = UserDefaults.standard
        let id = defaults.integer(forKey: APIService.currentEpisodeId)
        if id > 0 {
            do {
                return try getEpisode(id: id)
            } catch {
                return nil
            }
        }
        return nil
    }
}
