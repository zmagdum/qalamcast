//
//  Category.swift
//  QalamCast
//
//  Created by Zakir Magdum on 3/23/19.
//  Copyright © 2019 Zakir Magdum. All rights reserved.
//

import Foundation

struct ResponseData: Decodable {
    var categories: [Category]
}

struct Category: Decodable {
    let title: String?
    var speakers: String?
    let artwork: String?
    var episodeCount: Int?
    var lastUpdated: Date?
    let tokens: [String]?
}
