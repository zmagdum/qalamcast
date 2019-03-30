//
//  Podcast.swift
//  PodcastSeries
//
//  Created by Zakir Magdum on 5/26/18.
//  Copyright © 2018 Zakir Magdum. All rights reserved.
//

import Foundation

struct Podcast: Decodable {
    let trackName: String?
    let artistName: String?
    let artworkUrl600: String?
    let trackCount: Int?
    let feedUrl: String?
}
