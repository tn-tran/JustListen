//
//  PlayerDetailsView.swift
//  JustListen
//
//  Created by Tien Tran on 11/1/18.
//  Copyright © 2018 Tien-Enterprise. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import MediaPlayer


class PlayerDetailsView: UIView {
	var episode: Episode! {
		didSet {
			
			miniTitleLabel.text = episode.title
			episodeTitleLabel.text = episode.title
			authorLabel.text = episode.author
			
			let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
			episodeImageView.sd_setImage(with: url, completed: nil)
//			miniEpisodeImageView.sd_setImage(with: url)
			
			miniEpisodeImageView.sd_setImage(with: url) { (image, _, _, _) in
				// lockscreen artwork setup code
				guard let image = image else { return }
				var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
				let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (_) -> UIImage in
					return image
				})
				nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
				MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
			}
			setupNowPlayingInfo()
			setupAudioSession()
			playEpisode()
		}
	}
	var panGesture: UIPanGestureRecognizer!
	let player: AVPlayer = {
		let avPlayer = AVPlayer()
		avPlayer.automaticallyWaitsToMinimizeStalling = false
		return avPlayer
	}()
	
	fileprivate func setupGestures() {
		addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
		panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
		miniPlayerView.addGestureRecognizer(panGesture)
		maximizedStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))
	}

	
	fileprivate func setupNowPlayingInfo() {
		var nowPlayingInfo = [String:Any]()
		nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
		nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
		MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
	}
	// setup background audio playback
	fileprivate func setupAudioSession() {
		do {
			try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: .defaultToSpeaker)
			try AVAudioSession.sharedInstance().setActive(true)
		} catch let err {
			print("failed to audio session", err)
		}
	}
	// CC toggling
	fileprivate func setupRemoteControl()  {
		UIApplication.shared.beginReceivingRemoteControlEvents()
		let commandCenter = MPRemoteCommandCenter.shared()
		commandCenter.playCommand.isEnabled = true
		commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
			self.player.play()
			self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
			self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
			self.setupElapsedTime(playbackRate: 1)
			
			MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 1
			return .success
		}
		commandCenter.pauseCommand.isEnabled = true
		commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
			self.player.pause()
			self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
			self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
			self.setupElapsedTime(playbackRate: 0)
			
			return .success
		}
		commandCenter.togglePlayPauseCommand.isEnabled = true
		commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
			self.handlePlayPause()
			return .success
		}
		
		commandCenter.previousTrackCommand.addTarget(self, action: #selector(handlePrevTrack))
		commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
	}
	var playlistEpisodes = [Episode]()
	
	@objc fileprivate func handlePrevTrack() {
		if playlistEpisodes.count == 0 { // empty list
			return
		}
		
		let currentEpisodeIndex = playlistEpisodes.index { (ep) -> Bool in
			return self.episode.title == ep.title && self.episode.author == ep.author
		}
		let prevEpisode: Episode
		guard let index = currentEpisodeIndex else { return }
		if playlistEpisodes.count == 1  {
			prevEpisode = playlistEpisodes[0]
		} else {
			prevEpisode = playlistEpisodes[index - 1]
		}
		self.episode = prevEpisode
	}
	
	@objc fileprivate func handleNextTrack() {
		if playlistEpisodes.count == 0 { // empty list
			return
		}
		
		let currentEpisodeIndex = playlistEpisodes.index { (ep) -> Bool in
			return self.episode.title == ep.title && self.episode.author == ep.author 
		}
		let nextEpisode: Episode
		guard let index = currentEpisodeIndex else { return }
		if index == playlistEpisodes.count - 1  {
			nextEpisode = playlistEpisodes[0]
		} else {
			nextEpisode = playlistEpisodes[index + 1]
		}
		self.episode = nextEpisode
	}
	fileprivate func setupElapsedTime(playbackRate: Float) {
		let elapsedTime = CMTimeGetSeconds(player.currentTime())
		MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
		MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
	}
	fileprivate func observeBoundaryTime() {
		let time = CMTimeMake(value: 1, timescale: 3)
		let times = [NSValue(time: time)]
		//player % self has retain cycle
		player.addBoundaryTimeObserver(forTimes: times, queue: .main) {
			[weak self] in
			print("Episode started playing")
			self?.enlargeEpisodeImageView()
			self?.setupLockScreenDuration()
		}
	}
	fileprivate func setupLockScreenDuration() {
		guard let duration = player.currentItem?.duration else { return }
		let durationInSeconds = CMTimeGetSeconds(duration)
		MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = durationInSeconds
		
	}
	fileprivate func setupInterruptionObserver() {
		NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
	}
	@objc fileprivate func handleInterruption(notification: Notification) {
		guard let userInfo = notification.userInfo else { return }
		guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
		if type == AVAudioSession.InterruptionType.began.rawValue {
			
			playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
			miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
		} else {
			guard let options = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
			if options == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
				player.play()
				playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
				miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
			}

		}
	}
	override func awakeFromNib() {
		super.awakeFromNib()
		
		setupRemoteControl()
		setupGestures()
		observePlayerCurrentTime()
		observeBoundaryTime()
		setupInterruptionObserver()
	}
	
	fileprivate func enlargeEpisodeImageView() {
		//		self.removeFromSuperview()
		UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			self.episodeImageView.transform = .identity
			
		})
	}
	
	fileprivate let shrunkenTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
	fileprivate func shrinkEpisodeImageView() {
		//		self.removeFromSuperview()
		UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			self.episodeImageView.transform = self.shrunkenTransform
			
		})
	}
	
	fileprivate func observePlayerCurrentTime() {
		let interval = CMTimeMake(value: 1, timescale: 2)
		// another retain cycle
		player.addPeriodicTimeObserver(forInterval: interval, queue: .main) {
			[weak self] (time) in
			self?.currentTimeLabel.text = time.toDisplayString()
			let durationTime = self?.player.currentItem?.duration
			self?.durationLabel.text = durationTime?.toDisplayString()

			self?.updateCurrentTimeSlider()
		}
	}

	fileprivate func updateCurrentTimeSlider() {
		let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
		let durationSeconds =  CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
		let percentage =  currentTimeSeconds / durationSeconds
		self.currentTimeSlider.value = Float(percentage)
	}
	

	fileprivate func playEpisode() {
		if episode.fileUrl != nil {
			playEpisodeUsingFileUrl()
		} else {
			guard let url = URL(string: episode.streamUrl ?? "") else { return }
			let playerItem = AVPlayerItem(url: url)
			player.replaceCurrentItem(with: playerItem)
			player.play()
		}
	}
	
	fileprivate func playEpisodeUsingFileUrl() {
		print("Attempg to play episode with file url", episode.fileUrl ?? "")
		guard let fileUrl = URL(string: episode.fileUrl ?? "" ) else { return }
		let fileName = fileUrl.lastPathComponent
		guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
		trueLocation.appendPathComponent(fileName)
		let playerItem = AVPlayerItem(url: trueLocation)
		player.replaceCurrentItem(with: playerItem)
		player.play()
	}
	
	//MARK:- Outlets and actions
	@IBAction func handleDismiss(_ sender: Any) {
		UIApplication.mainTabBarController().minimizePlayerDetails()
	}
	@IBOutlet weak var episodeImageView: UIImageView! {
		didSet {
			episodeImageView.layer.cornerRadius = 5
			episodeImageView.clipsToBounds = true
			episodeImageView.transform = shrunkenTransform
		}
	}
	@IBOutlet weak var episodeTitleLabel: UILabel! {
		didSet {
			episodeTitleLabel.numberOfLines = 2
		}
	}
	
	@IBOutlet weak var authorLabel: UILabel!
	
	@IBOutlet weak var playPauseButton: UIButton! {
		didSet {
			playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
			playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
		}
	}
	
	@objc func handlePlayPause() {
		if player.timeControlStatus == .paused {
			player.play()
			playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
			miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
			self.setupElapsedTime(playbackRate: 1)
			enlargeEpisodeImageView()
		} else {
			player.pause()
			playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
			miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
			self.setupElapsedTime(playbackRate: 0)
			shrinkEpisodeImageView()
		}
	}
	
	@IBOutlet weak var currentTimeLabel: UILabel!
	@IBOutlet weak var durationLabel: UILabel!
	@IBOutlet weak var currentTimeSlider: UISlider!
	@IBAction func handleCurrentTimeSliderChange(_ sender: Any) {
		print("slider value", currentTimeSlider.value)
		let percent = currentTimeSlider.value
		guard let duration = player.currentItem?.duration else { return }
		let durationInSeconds = CMTimeGetSeconds(duration)
		let seekTimeInSeconds = Float64(percent) * durationInSeconds
		let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: Int32(NSEC_PER_SEC)) // can replace with 1
		MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds
		player.seek(to: seekTime)
	}
	
	
	 func seekToCurrentTime(delta: Int64) {
		let fifteenSeconds = CMTimeMake(value: delta, timescale: 1)
		let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
		player.seek(to: seekTime)
	}
	@IBAction func handleRewind(_ sender: Any) {
		seekToCurrentTime(delta: -15)
	}
	
	@IBAction func handleFastForward(_ sender: Any) {
		seekToCurrentTime(delta: 15)
	}
	
	@IBAction func handleVolumeChange(_ sender: UISlider) {
		player.volume = sender.value
	}
	
	@IBOutlet weak var maximizedStackView: UIStackView!
	@IBOutlet weak var miniPlayerView: UIView!
	
	@IBOutlet weak var miniEpisodeImageView: UIImageView!
	
	@IBOutlet weak var miniTitleLabel: UILabel!
	
	@IBOutlet weak var miniPlayPauseButton: UIButton! {
		didSet {
			miniPlayPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
			miniPlayPauseButton.imageView?.contentMode = .scaleAspectFit
			miniPlayPauseButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15.0, right: 5.0)
		}
	}
	@IBOutlet weak var miniFastForwardButton: UIButton! {
		didSet {
			miniFastForwardButton.addTarget(self, action: #selector(handleFastForward), for: .touchUpInside)
			miniFastForwardButton.imageView?.contentMode = .scaleAspectFit
			miniFastForwardButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15.0, right: 5.0)
		}
	}
	
	static func initfromNib() -> PlayerDetailsView {
		return Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
	}
	deinit {
		NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
	}

	
}
