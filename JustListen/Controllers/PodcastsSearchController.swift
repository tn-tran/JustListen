//
//  PodcastsSearchController.swift
//  JustListen
//
//  Created by Tien Tran on 11/1/18.
//  Copyright © 2018 Tien-Enterprise. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
class PodcastsSearchController: UITableViewController, UISearchBarDelegate {
	var podcast =  [Podcast]()
	var timer: Timer?
	let cellId = "cellId"
	let activityIndicator: UIActivityIndicatorView = {
		let ai = UIActivityIndicatorView(style: .whiteLarge)
		ai.translatesAutoresizingMaskIntoConstraints = false
		ai.color = UIColor.lightGray
		return ai
	}()
	override func viewDidLoad() {
		super.viewDidLoad()
		setupSearchController()
		tableView.tableFooterView = UIView() //empty lines
		let nib = UINib(nibName: "PodcastCell", bundle: nil)
		tableView.register(nib, forCellReuseIdentifier: cellId)
		
	}
	
	//MARK:- Setup work
	
	// TODO: replace glass to a activity indicator on left of the searchBar
	//	Right now its just on the header cell when API fetching

	fileprivate func setupActivityIndicator() {
		view.addSubview(activityIndicator)
//		navigationItem.searchController?.searchBar.i
//		activityIndicator.leadingAnchor.constraint(equalToSystemSpacingAfter: <#T##NSLayoutXAxisAnchor#>, multiplier: <#T##CGFloat#>)

		activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		activityIndicator.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
	}
	
	fileprivate func setupSearchController() {
		self.definesPresentationContext = true
		let searchController = UISearchController(searchResultsController: nil)
		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
		searchController.dimsBackgroundDuringPresentation = false
		searchController.searchBar.delegate = self
		setupActivityIndicator()
	}
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		timer?.invalidate()
		activityIndicator.startAnimating()
		timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (timer) in // schedule timer, timer invalidates when text stops changing so it can fire off
			APIService.shared.fetchPodcasts(searchText: searchText) { (podcast) in
				self.podcast = podcast
				self.tableView.reloadData()
				self.activityIndicator.stopAnimating()
			}
		})

	}
	
	
	
	//MARK:- UITableView
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let label = UILabel()
		label.text = "Please enter a search term"
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
		return label
	}
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return self.podcast.count > 0 ? 0 : 250
	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return podcast.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PodcastCell
		cell.podcast = self.podcast[indexPath.row]
		return cell
	}
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let episodesController = EpisodesController()
		episodesController.podcast = self.podcast[indexPath.row]
		navigationController?.pushViewController(episodesController, animated: true)
	}
	
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 132
	}
}
