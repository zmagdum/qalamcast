//
//  Category.swift
//  QalamCast
//
//  Created by Zakir Magdum on 3/23/19.
//  Copyright © 2019 Zakir Magdum. All rights reserved.
//

import Foundation
import Squeal

struct ResponseData: Decodable {
    var categories: [Category]
}

struct Category: Decodable {
    var id: Int?
    var title: String?
    var speakers: String?
    var artwork: String?
    var episodeCount: Int?
    var lastUpdated: Date?
    var tokens: [String]?
    var order: Int?

    init(row:Statement) throws {
        self.id = row.intValue("id") ?? 0
        self.title = row.stringValue("title")!
        self.speakers = row.stringValue("speakers")!
        self.episodeCount = row.intValue("episodeCount") ?? 0
        self.artwork = row.stringValue("artwork")!
        self.lastUpdated = Date(timeIntervalSince1970: row.doubleValue("lastUpdated") ?? 0)
        self.tokens = row.stringValue("tokens")?.components(separatedBy: ",")
        self.order = row.intValue("order") ?? 0
    }

}
