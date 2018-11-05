//
//  Podcast.swift
//  JustListen
//
//  Created by Tien Tran on 11/1/18.
//  Copyright © 2018 Tien-Enterprise. All rights reserved.
//

import Foundation

struct SearchResults: Codable {
	let resultCount: Int
	let results: [Podcast]
}

class Podcast: NSObject, Codable, NSCoding {
	func encode(with aCoder: NSCoder) {
		print("trying to transform podcast into data")
		aCoder.encode(trackName ?? "", forKey: "trackNameKey")
		aCoder.encode(artistName ?? "", forKey: "artistNameKey")
		aCoder.encode(artworkUrl600 ?? "", forKey: "artworkKey")
		aCoder.encode(feedUrl ?? "", forKey: "feedUrlKey")
	}
	
	required init?(coder aDecoder: NSCoder) {
		print("trying to transform data back into a podcast object")
		self.trackName = aDecoder.decodeObject(forKey: "trackNameKey") as? String
		self.artistName = aDecoder.decodeObject(forKey: "artistNameKey") as? String
		self.artworkUrl600 = aDecoder.decodeObject(forKey:"artworkKey") as? String
		self.feedUrl = aDecoder.decodeObject(forKey:"feedUrlKey") as? String
	}
	

	var trackName: String?
	var artistName: String?
	var artworkUrl600: String?
	var trackCount: Int?
	var feedUrl: String?
}


