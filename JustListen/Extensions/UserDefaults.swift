//
//  UserDefaults.swift
//  JustListen
//
//  Created by Tien Tran on 11/3/18.
//  Copyright © 2018 Tien-Enterprise. All rights reserved.
//

import Foundation
extension UserDefaults {
	static let favoritedPodcastKey = "favoritedPocastKey"
	static let downloadedEpisodesKey = "downloadedEpisodesKey"
	
	func savedPodcasts() -> [Podcast] {
		guard let savedPodcastsData = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else { return [] }
		guard let savedPodcasts = NSKeyedUnarchiver.unarchiveObject(with: savedPodcastsData) as? [Podcast] else { return  []}
		
		return savedPodcasts
		
	}
	
	func deletePodcast(podcast: Podcast){
		let podcasts = savedPodcasts()
		let filteredPodcast = podcasts.filter { (p) -> Bool in
			return p.trackName != podcast.trackName && p.artistName != podcast.artistName
		}
		let data = NSKeyedArchiver.archivedData(withRootObject: filteredPodcast)
		UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
	}
	
	func downloadedEpisodes() -> [Episode] {
		guard let data = UserDefaults.standard.data(forKey: UserDefaults.downloadedEpisodesKey) else { return [] }
		do {
			let episodes = try JSONDecoder().decode([Episode].self, from: data)
			return episodes
		} catch let error {
			print("Failed to decode data: ", error)
		}
		return []
	}
	
	func downloadEpisode(episode: Episode) {
		do {
			var episodes = downloadedEpisodes()
			episodes.append(episode)
			let data = try JSONEncoder().encode(episodes)
			UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
		} catch let error {
			print("Failed to encode episode into data: ", error)
		}
	}
	
	func deleteEpisode(episode: Episode) {
		let episodes = downloadedEpisodes()
		let filteredEpisodes =  episodes.filter { (episodes) -> Bool in
			return episodes.title != episode.title && episodes.author != episode.author && episodes.description != episode.description
		}
		do  {
			let data = try JSONEncoder().encode(filteredEpisodes)
			UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
		} catch let error {
			print("Failed to encode episodes", error)
		}
		
	}
}
