//
//  DownloadsController.swift
//  JustListen
//
//  Created by Tien Tran on 11/3/18.
//  Copyright © 2018 Tien-Enterprise. All rights reserved.
//

import Foundation
import UIKit

class DownloadsController: UITableViewController {
	fileprivate var cellId = "cellId"
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTableView()
		setupObservers()
		
	}
	var episodes = UserDefaults.standard.downloadedEpisodes()
	
	
	
	fileprivate func setupObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgress, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadComplete), name: .downloadComplete, object: nil)
	}
	
	// observer listener when file is progressing.
	@objc fileprivate func handleDownloadProgress(notification: Notification) {
		guard let userInfo = notification.userInfo as? [String: Any ] else { return }
		guard let progress = userInfo["progress"] as? Double else { return }
		guard let title = userInfo["title"] as? String else { return }
		
		print(progress,title)
		guard let index = self.episodes.index(where: {$0.title == title}) else { return }
		
		
		guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell else { return }
		cell.progressLabel.text = "\(Int(progress * 100))%"
		cell.progressLabel.isHidden = false
		
		if progress == 1 {
			cell.progressLabel.isHidden = true
		}
	}

	
	// observer listener when file completes
	@objc fileprivate func handleDownloadComplete(notification: Notification) {
		// 1. retrieve notification object
		guard let episodeDownloadComplete = notification.object as? APIService.EpisodeDownloadCompleteTuple else { return }
		// 2. filter by using the tuple's title against the array and set it as index.
			guard let index = self.episodes.index(where: {$0.title == episodeDownloadComplete.episodeTitle}) else { return }
		
		
		// 3. properly updates the fileUrl
		self.episodes[index].fileUrl = episodeDownloadComplete.fileUrl
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		episodes = UserDefaults.standard.downloadedEpisodes()
		tableView.reloadData()
	}
	
	fileprivate func setupTableView() {
		let nib = UINib(nibName: "EpisodeCell", bundle: nil)
		tableView.register(nib, forCellReuseIdentifier: cellId)
	}
	
	//MARK:- UITableView
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return episodes.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
		cell.episode = self.episodes[indexPath.row]
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 134
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			print("Deleteing row...")
			let episode = self.episodes[indexPath.row]
			UserDefaults.standard.deleteEpisode(episode: episode)
			self.episodes.remove(at: indexPath.row)
			self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
			//NOTE: dont call reloaddata for one row, bad practice
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print("Launch episode player")
		let episode = self.episodes[indexPath.row]
		if episode.fileUrl != nil {
			
			UIApplication.mainTabBarController().maximizePlayerDetails(episode: episode, playlistEpisode: self.episodes)
		} else {
			let alertController = UIAlertController(title: "File URL not found", message: "Cannot find local file, play using stream url instead", preferredStyle: .actionSheet)
			alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in	UIApplication.mainTabBarController().maximizePlayerDetails(episode: episode, playlistEpisode: self.episodes)
			}))
			alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
			present(alertController, animated: true)
		}

	}
	
}
