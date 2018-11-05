//
//  EpisodesController.swift
//  JustListen
//
//  Created by Tien Tran on 11/1/18.
//  Copyright © 2018 Tien-Enterprise. All rights reserved.
//

import Foundation
import UIKit
import FeedKit

class EpisodesController: UITableViewController {
	var podcast: Podcast? {
		didSet {
			navigationItem.title = podcast?.trackName
			fetchEpisodes()
		}
	}
	var episodes = [Episode]()
	let cellId = "cellId"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTableview()
		setupNavigationBarButtons()
		
	}
	
	fileprivate func fetchEpisodes() {
		guard let feedUrl = podcast?.feedUrl else { return }
		APIService.shared.fetchEpisodes(feedUrl: feedUrl) {(episode) in
			self.episodes = episode
			DispatchQueue.main.async {
				
				self.tableView.reloadData()
			}
			
		}
	}
	
	@objc fileprivate func handleSaveFavorites() {
		guard let podcast = self.podcast else { return }

		var listOfPodcasts = UserDefaults.standard.savedPodcasts()
		listOfPodcasts.append(podcast)
		let data = NSKeyedArchiver.archivedData(withRootObject: listOfPodcasts)
		UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
		showBadgeHighlight()
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-heart-outline-30"), style: .plain, target: self, action: nil)
	}
	
	fileprivate func showBadgeHighlight() {
		UIApplication.mainTabBarController().viewControllers?[1].tabBarItem.badgeValue = "New"
	}
	
	//MARK:- Setup Tableview
	fileprivate func setupNavigationBarButtons() {
		let savedPodcasts = UserDefaults.standard.savedPodcasts()
		let hasFavorited = savedPodcasts.index(where: { ($0.trackName == self.podcast?.trackName && $0.artistName == self.podcast?.artistName) }) != nil
		if hasFavorited {
			navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-heart-outline-30"), style: .plain, target: nil, action: nil)
		} else {
			navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Favorites", style: .plain, target: self, action: #selector(handleSaveFavorites))]
//												  UIBarButtonItem(title: "Fetch", style: .plain, target: self, action: #selector(handleFetchSavedPodcasts))]
		}
		

	}
	fileprivate func setupTableview() {
		tableView.tableFooterView = UIView()
		
		let nib = UINib(nibName: "EpisodeCell", bundle: nil)
		tableView.register(nib, forCellReuseIdentifier: cellId)
	}
	
	//MARK:- TableView
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return episodes.count
		
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
		let episode = episodes[indexPath.row]
		cell.episode = episode
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 134
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let episode = self.episodes[indexPath.row]
		let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
		
		mainTabBarController?.maximizePlayerDetails(episode: episode, playlistEpisode: self.episodes)
	}
	
	
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return episodes.isEmpty ? 200 : 0
	}
	override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
		activityIndicatorView.color = .darkGray
		activityIndicatorView.startAnimating()
		return activityIndicatorView
	}
	
	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let downloadAction = UITableViewRowAction(style: .normal, title: "Download") { (_, _) in
			print("Printing download episode")
		}
		let episode = self.episodes[indexPath.row]
		UserDefaults.standard.downloadEpisode(episode: episode)
		
		// download the podcast episode using alamofire
		APIService.shared.downloadEpisode(episode: episode)
		return [downloadAction]
	}
	
}
