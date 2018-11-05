//
//  EpisodeCell.swift
//  JustListen
//
//  Created by Tien Tran on 11/1/18.
//  Copyright © 2018 Tien-Enterprise. All rights reserved.
//

import UIKit
import SDWebImage
class EpisodeCell: UITableViewCell {
	var episode: Episode! {
		didSet {
			titleLabel.text = episode.title
			descriptionLabel.text = episode.description
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "MMM dd, yyyy"
			pubDateLabel.text = dateFormatter.string(from: episode.pubDate)
			let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
			episodeImageView.sd_setImage(with: url, completed: nil)
		}
	}
    
	@IBOutlet weak var episodeImageView: UIImageView!
	
	@IBOutlet weak var pubDateLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel! {
		didSet {
			titleLabel.numberOfLines = 0
		}
	}
	
	@IBOutlet weak var progressLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel! {
		didSet {
			descriptionLabel.numberOfLines = 2
		}
	}
}
