//
//  ApiService.swift
//  PodcastSeries
//
//  Created by Zakir Magdum on 5/27/18.
//  Copyright © 2018 Zakir Magdum. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit

class APIService {
    // singleton
    static let shared = APIService()
    let speakers = ["Mufti Hussain Kamani","Abdul Nasir Jangda","Abdul Rahman Murphy","Mikaeel Ahmed Smith", "Mikaeel Smith"]
    
    func fetchEpisodes(feedUrl: String, completionHandler: @escaping ([Episode]) -> ()) {
        let secureFeedUrl = feedUrl.toSecureHTTPS()
        guard let url = URL(string: secureFeedUrl) else { return }
        DispatchQueue.global(qos: .background).async {
            let parser = FeedParser(URL: url)
            parser?.parseAsync(result: { (result) in
                print("Successfully parse feed:", result.isSuccess)
                if let err = result.error {
                    print("Failed to parse XML feed:", err)
                    return
                }
                
                guard let feed = result.rssFeed else { return }
                
                let episodes = feed.toEpisodes()
                completionHandler(episodes)
            })
        }
    }
    
    func loadCategories() -> [Category]? {
        if let url = Bundle.main.url(forResource: "categories", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode([Category].self, from: data)
                return jsonData
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
    
    func loadCategoriesWithEpisodes(completionHandler: @escaping ([Category], [Episode]) -> ()) {
        var categories = APIService.shared.loadCategories() ?? []
        var podcastDict: [String: Category] = [:]
        var speakersDict: [String: String] = [:]
        var uncatId = -1
        for index in 0..<categories.count {
            podcastDict[categories[index].title ?? ""] = categories[index]
            categories[index].episodeCount = 0
            if categories[index].title == "Uncategorized" {
                uncatId = index
            }
        }
        
        let feedUrl = "http://feeds.feedburner.com/QalamPodcast"
        APIService.shared.fetchEpisodes(feedUrl: feedUrl) { (received) in
            //print("Found episodes", episodes)
            var episodes = received
            for ii in 0..<episodes.count {
                let title = episodes[ii].title.trimmingCharacters(in: .whitespaces)
                var found = false
                for index in 0..<categories.count {
                    if title.starts(with: categories[index].title!) {
                        episodes[ii].category = categories[index].title!
                        categories[index].episodeCount? += 1
                        let catDate = categories[index].lastUpdated ?? episodes[ii].pubDate
                        categories[index].lastUpdated = max(catDate, episodes[ii].pubDate)
                        for spkr in self.speakers {
                            if (episodes[ii].categories?.contains(spkr))! {
                                categories[index].speakers = spkr
                            }
                        }
                        found = true
                        break
                    }
                }
                if !found && uncatId > 0 {
                    categories[uncatId].episodeCount? += 1
                    episodes[ii].category = categories[uncatId].title!
                    //cat.lastUpdated = max(cat.lastUpdated?, episode.pubDate)
                    for spkr in self.speakers {
                        if (episodes[ii].categories?.contains(spkr))! {
                            categories[uncatId].speakers = spkr
                        }
                    }
                }
                for cat in episodes[ii].categories ?? [] {
                    speakersDict[cat] = cat
                }
            }
            //            for pk in podcastDict.keys {
            //                print("found", pk)
            //            }
                        for pk in speakersDict.keys {
                            print("found category", pk)
                        }
            completionHandler(categories, episodes)
        }
    }
    

    
    func fetchPodcasts(searchText: String, completionHandler: @escaping ([Category]) -> ()) {
        print("Searching Podcasts")
        let url = "https://itunes.apple.com/search"
        let parameters = ["term": searchText]
        Alamofire.request(url, method: HTTPMethod.get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponse) in
            if let err = dataResponse.error {
                print("Failed to connect itunes", err)
                return
            }
            guard let data = dataResponse.data else {return}
            do {
                let searchResults = try
                    JSONDecoder().decode(SearchResults.self, from: data)
                completionHandler(searchResults.results)
            } catch let decodeErr {
                print("Failed to decode", decodeErr)
            }
        }
    }
}

struct SearchResults: Decodable {
    let resultCount: Int
    let results: [Category]
}
