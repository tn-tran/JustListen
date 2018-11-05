//
//  FavoritePodcastCell.swift
//  JustListen
//
//  Created by Tien Tran on 11/3/18.
//  Copyright © 2018 Tien-Enterprise. All rights reserved.
//

import Foundation
import UIKit
class FavoritePodcastCell: UICollectionViewCell {
	let imageView = UIImageView(image: #imageLiteral(resourceName: "appicon"))
	let nameLabel = UILabel()
	let artistNameLabel = UILabel()
	var podcast: Podcast! {
		didSet {
			nameLabel.text = podcast.trackName
			artistNameLabel.text = podcast.artistName
			
			let url = URL(string: podcast.artworkUrl600 ?? "")
			imageView.sd_setImage(with: url)
			
		}
	}
	
	fileprivate func stylizeUI() {
		nameLabel.text = "Podcast Name"
		nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
		artistNameLabel.text = "Artist Name"
		artistNameLabel.font = UIFont.systemFont(ofSize: 13)
		artistNameLabel.textColor = .lightGray
	}
	
	fileprivate func setupViews() {
		let stackView = UIStackView(arrangedSubviews: [imageView,nameLabel,artistNameLabel])
		stackView.axis = .vertical
		stackView.translatesAutoresizingMaskIntoConstraints = false
		imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
		addSubview(stackView)
		
		stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		stylizeUI()
		setupViews()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
