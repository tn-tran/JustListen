//
//  Episode.swift
//  JustListen
//
//  Created by Tien Tran on 11/1/18.
//  Copyright © 2018 Tien-Enterprise. All rights reserved.
//

import Foundation
import FeedKit
struct Episode: Codable {
	let title: String
	let pubDate: Date
	let description: String
	let author: String
	var imageUrl: String?
	let streamUrl: String?
	var fileUrl: String?
	init(feedItem: RSSFeedItem) {
		self.title = feedItem.title ?? ""
		self.pubDate = feedItem.pubDate ?? Date()
		self.description = feedItem.iTunes?.iTunesSubtitle ?? feedItem.description ?? ""
		self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
		self.author = feedItem.author ?? "" 
		self.streamUrl = feedItem.enclosure?.attributes?.url ?? ""
	}
}
