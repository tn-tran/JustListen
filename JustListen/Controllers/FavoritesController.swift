//
//  FavoritesController.swift
//  JustListen
//
//  Created by Tien Tran on 11/3/18.
//  Copyright © 2018 Tien-Enterprise. All rights reserved.
//

import Foundation
import UIKit

class FavoritesController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
	fileprivate let cellId = "cellId"
	override func viewDidLoad() {
		super.viewDidLoad()
		setupCollectionView()
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		podcasts = UserDefaults.standard.savedPodcasts()
		collectionView.reloadData()
		UIApplication.mainTabBarController().viewControllers?[1].tabBarItem.badgeValue = nil
	}
	var podcasts = UserDefaults.standard.savedPodcasts()

	//MARK:- SetupCollectionView / Delegate & Sizing
	fileprivate func setupCollectionView() {
		collectionView.backgroundColor = .white
		collectionView.register(FavoritePodcastCell.self, forCellWithReuseIdentifier: cellId)
		let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
		collectionView.addGestureRecognizer(gesture)
	}
	
	@objc fileprivate func handleLongPress(gesture: UILongPressGestureRecognizer) {
		let location = gesture.location(in: collectionView)
		guard let selectedIndexPath = collectionView.indexPathForItem(at: location) else { return }
		print(selectedIndexPath.item)
		let alertController = UIAlertController(title: "Remove Podcast?", message: nil, preferredStyle: .actionSheet)
		alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
			UserDefaults.standard.deletePodcast(podcast: self.podcasts[selectedIndexPath.item])
			self.podcasts.remove(at: selectedIndexPath.item)
			self.collectionView.deleteItems(at: [selectedIndexPath])
			
		}))
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		present(alertController, animated: true)
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return podcasts.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let episodeController = EpisodesController()
		episodeController.podcast = self.podcasts[indexPath.item]
		navigationController?.pushViewController(episodeController, animated: true)
	}
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FavoritePodcastCell
		cell.podcast = podcasts[indexPath.item]
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = (view.frame.width - 3 * 16) / 2
		return CGSize(width: width, height: width + 46)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 16
	}
}
