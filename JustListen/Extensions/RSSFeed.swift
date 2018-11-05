//
//  RSSFeed.swift
//  JustListen
//
//  Created by Tien Tran on 11/1/18.
//  Copyright © 2018 Tien-Enterprise. All rights reserved.
//

import Foundation
import FeedKit
extension RSSFeed {
	func toEpisodes() -> [Episode] {
		let imageUrl = iTunes?.iTunesImage?.attributes?.href ?? ""
		var episodes = [Episode]() //blank array
		items?.forEach({ (feedItem) in
			var episode = Episode(feedItem: feedItem)
			episode.imageUrl = imageUrl
			episodes.append(episode)
			
		})
		return episodes
	}
}
