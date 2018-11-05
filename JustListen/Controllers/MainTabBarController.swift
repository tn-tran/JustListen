//
//  MainTabBarController.swift
//  JustListen
//
//  Created by Tien Tran on 11/1/18.
//  Copyright © 2018 Tien-Enterprise. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
	override func viewDidLoad() {
		super.viewDidLoad()
		UINavigationBar.appearance().prefersLargeTitles = true
		tabBar.tintColor = .purple
		setUpNavControllers()
		setUpPlayerDetailsView()
		
		
	}
	//MARK:- Setup Functions
	var maximizedTopAnchorConstraint: NSLayoutConstraint!
	var minimizedTopAnchorConstraint: NSLayoutConstraint!
	var bottomAnchorConstraint: NSLayoutConstraint!
	let playerDetailsView = PlayerDetailsView.initfromNib()
	fileprivate func setUpNavControllers() {
		let layout = UICollectionViewFlowLayout()
		let favoritesController = FavoritesController(collectionViewLayout: layout)
		
		viewControllers = [generateNavController(with: PodcastsSearchController(), title: "Search", image: #imageLiteral(resourceName: "search")),
						   generateNavController(with: favoritesController, title: "Favorites", image: #imageLiteral(resourceName: "favorites")),
						   generateNavController(with: DownloadsController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads"))]
	}
	
	//MARK:- Helper Functions
	fileprivate func generateNavController(with rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
		let navController = UINavigationController(rootViewController: rootViewController)
		rootViewController.navigationItem.title = title
		navController.tabBarItem.title = title
		navController.tabBarItem.image = image
		return navController
	}
	
	fileprivate func setUpPlayerDetailsView() {
		view.insertSubview(playerDetailsView, belowSubview: tabBar)
		playerDetailsView.translatesAutoresizingMaskIntoConstraints = false
		maximizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
		
		maximizedTopAnchorConstraint.isActive = true
		minimizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64) // final frame
		
		playerDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		playerDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		bottomAnchorConstraint = playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
		bottomAnchorConstraint.isActive = true
		
	}
	
	
	@objc func minimizePlayerDetails() {
		// ordering of the constraint does matter, at some point .isactive is both true. Set false first.
		maximizedTopAnchorConstraint.isActive = false
		bottomAnchorConstraint.constant = view.frame.height
		minimizedTopAnchorConstraint.isActive = true
		
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			self.view.layoutIfNeeded() // called when modifying constraints for animation
			self.playerDetailsView.maximizedStackView.alpha = 0
			self.playerDetailsView.miniPlayerView.alpha = 1
			self.tabBar.transform = .identity
		}, completion: nil)
	}
	
	func maximizePlayerDetails(episode: Episode?, playlistEpisode: [Episode] = []) {
		minimizedTopAnchorConstraint.isActive = false
		maximizedTopAnchorConstraint.isActive = true
		maximizedTopAnchorConstraint.constant = 0
		bottomAnchorConstraint.constant = 0
		
		if episode != nil {
				playerDetailsView.episode = episode
		}
		playerDetailsView.playlistEpisodes = playlistEpisode
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			self.view.layoutIfNeeded() // called when modifying constraints for animation
			self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100) // moves tabbar down
			self.playerDetailsView.maximizedStackView.alpha = 1
			self.playerDetailsView.miniPlayerView.alpha = 0
		}, completion: nil)
	}
}
