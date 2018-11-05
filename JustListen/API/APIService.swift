//
//  APIService.swift
//  JustListen
//
//  Created by Tien Tran on 11/1/18.
//  Copyright © 2018 Tien-Enterprise. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit
extension Notification.Name {
	static let downloadProgress = NSNotification.Name("downloadProgress")
	static let downloadComplete = NSNotification.Name("downloadComplete")
}

class APIService {
	static let shared = APIService()
	let baseItunesSearchUrl = "https://itunes.apple.com/search?"
	typealias EpisodeDownloadCompleteTuple = (fileUrl: String, episodeTitle: String)
	
	func fetchEpisodes(feedUrl: String, completionHandler: @escaping ([Episode]) -> ()) {
		//		print(feedUrl ?? "")
		let secureFeedUrl = feedUrl.toSecureHTTPS()
		guard let url = URL(string: secureFeedUrl) else { return }
		
		
		// syncronisally called, blocking UI, read more info about this
		DispatchQueue.global(qos: .background).async {
			let parse = FeedParser(URL: url)

			parse.parseAsync { (result) in
				print("Successfully parse feed:", result.isSuccess)
				if let err = result.error {
					print("failed to parse XML feed",err)
					return
				}
				guard let feed = result.rssFeed else { return }
				let episodes = feed.toEpisodes()
				
				completionHandler(episodes)
			}
		}
	}
	
	
	func fetchPodcasts(searchText: String, completionHandler: @escaping ([Podcast]) -> ()) {
		//		print("searching for podcasts")
		
		let params = ["term": searchText, "media":"podcast"] // allows the space, and filtering
		Alamofire.request(baseItunesSearchUrl, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).response { (dataResponse) in
			if let err = dataResponse.error {
				print("failed to contact apple API", err)
				return
			}
			guard let data = dataResponse.data else { return }
			do {
				let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
				
				completionHandler(searchResult.results) // becomes array
			} catch let err {
				print("Failed to decode", err)
			}
			
			
		}
	}
	
	func downloadEpisode(episode: Episode) {
		//		print("Downloading alamofire", episode.streamUrl)
		guard let streamUrl = episode.streamUrl else {return}
		
		
		// create a download request and use alamofire to download streamurl to destination.
		let downloadRequest = DownloadRequest.suggestedDownloadDestination()
		Alamofire.download(streamUrl, to: downloadRequest).downloadProgress { (progress) in

			print(progress.fractionCompleted)
			
			// notify DownloadsController about progress by observers, probably should refactor this.
			NotificationCenter.default.post(name: .downloadProgress, object: nil, userInfo: ["title": episode.title, "progress": progress.fractionCompleted])
			}.response { (resp) in
				print(resp.destinationURL?.absoluteString ?? "")
				let episodeDownloadComplete = EpisodeDownloadCompleteTuple(resp.destinationURL?.absoluteString ?? "",episode.title)
				NotificationCenter.default.post(name: .downloadComplete, object: episodeDownloadComplete, userInfo: nil)
				
				
				
				// update UserDefaults
				var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
				guard let index = downloadedEpisodes.index(where: {$0.title == episode.title && $0.author == episode.author}) else { return }
				
				downloadedEpisodes[index].fileUrl = resp.destinationURL?.absoluteString ?? ""
				
				do {
					let data = try JSONEncoder().encode(downloadedEpisodes)
					UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
				} catch let error {
					print("failed to encode downloaded episodes", error)
				}
		}
	}
}
