//
//  ApiService.swift
//  QalamCast
//
//  Created by Zakir Magdum on 5/27/18.
//  Copyright © 2018 Zakir Magdum. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit

extension Notification.Name {
    static let downloadProgress = NSNotification.Name("downloadProgress")
    static let downloadComplete = NSNotification.Name("downloadComplete")
    static let catalogStart = NSNotification.Name("catalogStart")
    static let catalogProgress = NSNotification.Name("catalogProgress")
    static let catalogComplete = NSNotification.Name("catalogComplete")

}
class APIService {
    static let currentEpisodeId = "currentEpisodeId"
    static let episodePlayedKey = "episodePlayed"
    static let qalamFeedUrl = "http://feeds.feedburner.com/QalamPodcast"
    static let seriesFeedUrls = ["http://feeds.feedburner.com/Qalam40Ahadith",
        "http://feeds.feedburner.com/QalamBeginningOfGuidance",
        "http://feeds.feedburner.com/QalamDivineParables",
        "http://feeds.feedburner.com/QalamHeartwork",
        "http://feeds.feedburner.com/QalamKhutbahs",
        "http://feeds.feedburner.com/QalamLegacies",
        "http://feeds.feedburner.com/QalamLivesOfTheProphets",
        "http://feeds.feedburner.com/QalamPurificationOfTheHeart",
        "http://feeds.feedburner.com/QalamQiyam",
        "http://feeds.feedburner.com/QalamQuranicReflections",
        "http://feeds.feedburner.com/QalamRamadanReflections",
        "http://feeds.feedburner.com/QalamReadyForRamadan",
        "http://feeds.feedburner.com/QalamCompanionship",
        "http://feeds.feedburner.com/QalamSeerah",
        "http://feeds.feedburner.com/QalamShamail",
        "http://feeds.feedburner.com/QalamSufficientAnswer",
        "http://feeds.feedburner.com/QalamSuhbahRetreat",
        "http://feeds.feedburner.com/QalamTarawehGems",
        "http://feeds.feedburner.com/QalamHangout",
        "http://feeds.feedburner.com/QalamPursuitOfKnowledge",
        "http://feeds.feedburner.com/QalamDivine"]

    typealias EpisodeDownloadCompleteTuple = (fileUrl: String, episodeTitle: String)
    let ignoreStartCharacters: [Character] = [" ", "–", ":"]
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
    
    func loadCategoriesWithEpisodes(feedUrl: String, completionHandler: @escaping ([Category], [Episode]) -> ()) {
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
        
//        let feedUrl = "http://feeds.feedburner.com/QalamPodcast"
//        let feedUrl = "https://podcasts.apple.com/us/podcast/qalam-institute-podcast/id424397634"
        APIService.shared.fetchEpisodes(feedUrl: feedUrl) { (received) in
            //print("Found episodes", episodes)
            var episodes = received
            for ii in 0..<episodes.count {
                let title = episodes[ii].title.trimmingCharacters(in: .whitespaces).lowercased()
                var found = false
                for index in 0..<categories.count {
                    if title.starts(with: categories[index].title!.lowercased()) {
                        episodes[ii].category = categories[index].title!
                        episodes[ii].shortTitle = self.shortTitle(title: episodes[ii].title, category: categories[index].title!)
                        episodes[ii].imageUrl = categories[index].artwork
                        categories[index].episodeCount? += 1
                        let catDate = categories[index].lastUpdated ?? episodes[ii].pubDate
                        categories[index].lastUpdated = max(catDate, episodes[ii].pubDate)
                        for spkr in self.speakers {
                            if (episodes[ii].categories?.contains(spkr))! {
                                if categories[index].speakers == nil || categories[index].speakers?.count == 0 {
                                    categories[index].speakers = spkr
                                } else if categories[index].speakers != spkr {
                                    categories[index].speakers = "Qalam Instructors"
                                }
                                episodes[ii].author = spkr
                            }
                        }
                        found = true
                        break
                    }
                    for token in categories[index].tokens ?? [] {
                        if title.starts(with: token.lowercased()) {
                            episodes[ii].category = categories[index].title!
                            episodes[ii].shortTitle = self.shortTitle(title: episodes[ii].title, category: token)
                            episodes[ii].imageUrl = categories[index].artwork
                            categories[index].episodeCount? += 1
                            let catDate = categories[index].lastUpdated ?? episodes[ii].pubDate
                            categories[index].lastUpdated = max(catDate, episodes[ii].pubDate)
                            for spkr in self.speakers {
                                if (episodes[ii].categories?.contains(spkr))! {
                                    categories[index].speakers = spkr
                                    episodes[ii].author = spkr
                                }
                            }
                            found = true
                            break
                        }

                    }
                }
                if !found && uncatId > 0 {
                    categories[uncatId].episodeCount? += 1
                    episodes[ii].category = categories[uncatId].title!
                    let catDate = categories[uncatId].lastUpdated ?? episodes[ii].pubDate
                    categories[uncatId].lastUpdated = max(catDate, episodes[ii].pubDate)
                    for spkr in self.speakers {
                        if (episodes[ii].categories?.contains(spkr))! {
                            categories[uncatId].speakers = spkr
                            episodes[ii].author = spkr
                        }
                    }
                }
                for cat in episodes[ii].categories ?? [] {
                    speakersDict[cat] = cat
                }
            }
//                        for pk in speakersDict.keys {
//                            print("found category", pk)
//                        }
            completionHandler(categories.filter { $0.episodeCount ?? 0 > 0 }, episodes)
        }
    }
    
 
    func loadCategoryEpisodes(cat: Category, completionHandler: @escaping (Category, [Episode]) -> ()) {
        if cat.feedUrl == nil || cat.feedUrl?.count == 0 {
            return
        }
        var category = cat
        category.episodeCount = 0
        APIService.shared.fetchEpisodes(feedUrl: category.feedUrl!) { (received) in
            var episodes = received
            print("Fetched episodes ", category.feedUrl!, " ", episodes.count)
            for ii in 0..<episodes.count {
                let title = episodes[ii].title.trimmingCharacters(in: .whitespaces).lowercased()
                episodes[ii].category = category.title!
                episodes[ii].shortTitle = self.shortTitle(title: episodes[ii].title, category: category.title!)
                episodes[ii].imageUrl = category.artwork
                if episodes[ii].duration == nil {
                    episodes[ii].duration = 3600 // assume duration one hour if not specified
                }
                category.episodeCount? += 1
                let catDate = category.lastUpdated ?? episodes[ii].pubDate
                category.lastUpdated = max(catDate, episodes[ii].pubDate)
                for spkr in self.speakers {
                    if (episodes[ii].categories?.contains(spkr))! {
                        if category.speakers == nil || category.speakers?.count == 0 {
                            category.speakers = spkr
                        } else if category.speakers != spkr {
                            category.speakers = "Qalam Instructors"
                        }
                        episodes[ii].author = spkr
                    }
                }
                if !title.starts(with: category.title!.lowercased()) {
                    for token in category.tokens ?? [] {
                        if title.starts(with: token.lowercased()) {
                            episodes[ii].shortTitle = self.shortTitle(title: episodes[ii].title, category: token)
                        }
                    }
                }
            }
            completionHandler(category, episodes)
        }
    }

    fileprivate func shortTitle(title: String, category: String) -> String {
        let shortTitle = title.deletingPrefix(category)
        var tst = ""
        var alphaFound = false
        for ch in shortTitle {
            if !ignoreStartCharacters.contains(ch) || alphaFound {
                alphaFound = true
                tst.append(ch)
            }
        }
        if let ep = tst.range(of: "EP") {
            tst = String(tst.suffix(from: ep.upperBound))
//            for (id, char) in tst.enumerated() {
//                if char == "–" {
//                    let index = tst.index(tst.startIndex, offsetBy: id+1)
//                    tst = String(tst.suffix(from: index))
//                }
//            }
            if let index = tst.firstIndex(of: "–") {
                tst = String(tst.suffix(from: tst.index(after: index)))
            }
            tst = tst.trimmingCharacters(in: .whitespaces)
        }
        alphaFound = false
        var result = ""
        for ch in tst {
            if !ignoreStartCharacters.contains(ch) || alphaFound {
                alphaFound = true
                result.append(ch)
            }
        }
        return result;
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
    
    func downloadEpisodes(episodes: [Episode]) {
        for episode in episodes {
            //try! DB.shared.updateDownload(episode: episode, download: true)
            //TODO: Limit simultenous downloads 
            downloadEpisode(episode: episode)
        }
    }
    
    func downloadEpisode(episode: Episode) {
        print("Downloading episode using Alamofire at stream url:", episode.streamUrl)
        if getEpisodeLocalUrl(episode: episode) != nil {
            print("Episode already downloaded")
        }
        let downloadRequest = DownloadRequest.suggestedDownloadDestination()
        try! DB.shared.updateDownload(episode: episode, download: true)
        Alamofire.download(episode.streamUrl, to: downloadRequest).downloadProgress { (progress) in
            //            print(progress.fractionCompleted)
            // I want to notify DownloadsController about my download progress somehow?
            NotificationCenter.default.post(name: .downloadProgress, object: nil, userInfo: ["id": episode.id ?? 0, "progress": progress.fractionCompleted])
            }.response { (resp) in
                let url = resp.destinationURL?.absoluteString
                print("download complete episode to", url)
                if FileManager.default.fileExists(atPath: url!) {
                    print("File Exists")
                } else {
                    print("*** downloaded file does not exist ***")
                }
                NotificationCenter.default.post(name: .downloadComplete, object: nil, userInfo: ["id": episode.id!])
        }
    }
    
    func getEpisodeLocalUrl(episode: Episode) -> URL? {
        // let's figure out the file name for our episode file url
        guard let fileURL = URL(string: episode.streamUrl ) else { return nil}
        let fileName = fileURL.lastPathComponent
        guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil}
        trueLocation.appendPathComponent(fileName)
        print("Location of episode:", trueLocation.absoluteString)
        if FileManager.default.fileExists(atPath: trueLocation.path) {
            return trueLocation
        }
        return nil
    }
    
    func getEpisodesSortOrderPref() -> Bool {
        return UserDefaults.standard.bool(forKey: "sort_preference")
    }
    
    func getShowPlayedPref() -> Bool {
        return UserDefaults.standard.bool(forKey: "show_played_preference")
    }
    
    func sortFilterWithPreferences(_ episodes: inout [Episode]) {
        if APIService.shared.getEpisodesSortOrderPref() {
            episodes.sort{$1.pubDate < $0.pubDate}
        } else {
            episodes.sort{$0.pubDate < $1.pubDate}
        }
        if !APIService.shared.getShowPlayedPref() {
            episodes = episodes.filter{($0.duration ?? 30.0 - $0.played! ) > 2}
        }
    }
    

}



struct SearchResults: Decodable {
    let resultCount: Int
    let results: [Category]
}

