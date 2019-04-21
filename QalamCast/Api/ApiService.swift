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
}
class APIService {
    static let currentEpisodeId = "currentEpisodeId"

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
                                categories[index].speakers = spkr
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
            completionHandler(categories, episodes)
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
        return tst;
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
}



struct SearchResults: Decodable {
    let resultCount: Int
    let results: [Category]
}

