//
//  PlayerDetailsView.swift
//  PodcastSeries
//
//  Created by Zakir Magdum on 6/2/18.
//  Copyright © 2018 Zakir Magdum. All rights reserved.
//

import UIKit
import AVKit
import SDWebImage
import AVFoundation
import MediaPlayer

class PlayerDetailsView: UIView {

    @IBOutlet weak var miniPlayerView: UIView!
    
    @IBOutlet weak var maxPlayerView: UIStackView!
    
    var episodeId: Int! {
        didSet {
            self.episode = try! DB.shared.getEpisode(id: episodeId)
        }
    }
    var episode: Episode! {
        didSet {
            if oldValue == nil || oldValue.title != episode.title {
                miniPlayerTitleLabel.text = episode.shortTitle
                episodeTitle.text = episode.shortTitle
                authorLabel.text = episode.author
                setupNowPlayingInfo()
                setupAudioSession()
                playEpisode()
                guard let url = URL(string: episode.imageUrl ?? "") else { return }
                playerImageView.sd_setImage(with: url)
                miniPlayerImageView.sd_setImage(with: url)
            }
        }
    }
    
    fileprivate func playEpisode() {
        print("Trying to play url", episode.streamUrl, " ", episode.played)
        guard let url = URL(string: episode.streamUrl) else {return }
        //try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        //try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        if !playEpisodeUsingFileUrl() {
            playEpisode(url: url)
        }
        DB.shared.saveCurrentEpisode(episode: episode)
    }
    
    fileprivate func playEpisode(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        if episode.played! > 0.0 {
            let seekTime = CMTimeMakeWithSeconds(episode.played!, Int32(NSEC_PER_SEC))
            player.seek(to: seekTime)
        }
    }
    
    fileprivate func playEpisodeUsingFileUrl() -> Bool {
        print("Attempt to play episode with downloaded file")
        // let's figure out the file name for our episode file url
        let localUrl = APIService.shared.getEpisodeLocalUrl(episode: self.episode)
        if localUrl != nil {
            let playerItem = AVPlayerItem(url: localUrl!)
            player.replaceCurrentItem(with: playerItem)
            player.play()
            if episode.played! > 0.0 {
                let seekTime = CMTimeMakeWithSeconds(episode.played!, Int32(NSEC_PER_SEC))
                player.seek(to: seekTime)
            }
            return true
        }
        return false
    }
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer;
    }()
    
    fileprivate func oberverPlayerCurrentTime(_ interval: CMTime) {
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            self?.startTimeLabel.text = time.toDisplayString()
            let durationTime = self?.player.currentItem?.duration
            self?.endTimeLabel.text = durationTime?.toDisplayString()
            self?.updateCurrentTimeSlider()
            self?.episode.played = CMTimeGetSeconds(time)
            do {
                try DB.shared.updatePlayed(episode: (self?.episode!)!)
            } catch {
                print("Error updating played \(error)", self?.episode)
            }
        }
    }
    
    fileprivate func setupNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    fileprivate func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let sessionErr {
            print("Failed to activate session:", sessionErr)
        }
    }
    
    fileprivate func setupRemoteControl() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.play()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            
            self.setupElapsedTime(playbackRate: 1)
            return .success
        }
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.pause()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.setupElapsedTime(playbackRate: 0)
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handlePlayPause()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(handlePrevTrack))
    }

    var playlistEpisodes = [Episode]()
    
    @objc fileprivate func handlePrevTrack() {
        // 1. check if playlistEpisodes.count == 0 then return
        // 2. find out current episode index
        // 3. if episode index is 0, wrap to end of list somehow..
        // otherwise play episode index - 1
        if playlistEpisodes.isEmpty {
            return
        }
        
        let currentEpisodeIndex = playlistEpisodes.index { (ep) -> Bool in
            return self.episode.title == ep.title && self.episode.author == ep.author
        }
        guard let index = currentEpisodeIndex else { return }
        let prevEpisode: Episode
        if index == 0 {
            let count = playlistEpisodes.count
            prevEpisode = playlistEpisodes[count - 1]
        } else {
            prevEpisode = playlistEpisodes[index - 1]
        }
        self.episode = prevEpisode
    }
    
    @objc fileprivate func handleNextTrack() {
        if playlistEpisodes.count == 0 {
            return
        }
        
        let currentEpisodeIndex = playlistEpisodes.index { (ep) -> Bool in
            return self.episode.title == ep.title && self.episode.author == ep.author
        }
        
        guard let index = currentEpisodeIndex else { return }
        
        let nextEpisode: Episode
        if index == playlistEpisodes.count - 1 {
            nextEpisode = playlistEpisodes[0]
        } else {
            nextEpisode = playlistEpisodes[index + 1]
        }
        
        self.episode = nextEpisode
    }

    fileprivate func setupElapsedTime(playbackRate: Float) {
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
    }
    
    fileprivate func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(1,1))
        let percentage = currentTimeSeconds / durationSeconds
        self.currentTimeSlider.value = Float(percentage)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))

        let time = CMTimeMake(1, 3)
        let times = [NSValue(time: time)]
        let interval = CMTimeMake(1, 2)
        oberverPlayerCurrentTime(interval)
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enlargeEpisodeImageView()
        }
    }
   
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        //        print("Panning")
        if gesture.state == .began {
            print("Began")
        } else if gesture.state == .changed {
            
            let translation = gesture.translation(in: self.superview)
            self.transform = CGAffineTransform(translationX: 0, y: translation.y)
            
            self.miniPlayerView.alpha = 1 + translation.y / 200
            self.maxPlayerView.alpha = -translation.y / 200
            
            print(translation.y)
            
        } else if gesture.state == .ended {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.transform = .identity
                self.miniPlayerView.alpha = 1
                self.maxPlayerView.alpha = 0
                
            })
        }
    }

    @objc func handleTapMaximize() {
        let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        mainTabBarController?.maximizePlayerDetails(episode: nil)
    }
    
    static func initFromNib() -> PlayerDetailsView {
        return Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
    }
    
    deinit {
        print("PlayerDetailsView memory being reclaimed...")
    }
    
    @objc fileprivate func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
        
        if type == AVAudioSession.InterruptionType.began.rawValue {
            print("Interruption began")
            
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            
        } else {
            print("Interruption ended...")
            
            guard let options = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            
            if options == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
                player.play()
                playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            }
            
            
        }
    }

    //MARK:- Outlets and IBAction
    
    @IBOutlet weak var miniPlayerImageView: UIImageView!
    
    @IBOutlet weak var miniPlayerTitleLabel: UILabel!
    
    @IBOutlet weak var miniPlayerPlayPauseButton: UIButton! {
        didSet {
            miniPlayerPlayPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var miniPlayerFastForwardButton: UIButton! {
        didSet {
            miniPlayerFastForwardButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            miniPlayerFastForwardButton.addTarget(self, action: #selector(handleFastForwardButton), for: .touchUpInside)
        }
    }
    @IBAction func handleDismiss(_ sender: UIButton) {
        //player.cancelPendingPrerolls()
        //self.removeFromSuperview()
        let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        mainTabBarController?.minimizePlayerDetails()
    }
    
    fileprivate func enlargeEpisodeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.playerImageView.transform = .identity
            })
    }
    fileprivate let shrunkenTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    fileprivate func shrinkEpisodeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.playerImageView.transform = self.shrunkenTransform
        })
    }

    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var playerImageView: UIImageView!{
        didSet {
            playerImageView.layer.cornerRadius = 5
            playerImageView.clipsToBounds = true
            playerImageView.transform = shrunkenTransform
        }
    }
    @IBOutlet weak var playerSlider: UISlider!
    @IBOutlet weak var episodeTitle: UILabel! {
        didSet {
            episodeTitle.numberOfLines = 2
        }
    }
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton! {
        didSet {
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    
    @IBAction func handleVolumeSlideChanged(_ sender: UISlider) {
        player.volume = sender.value
    }
    @IBOutlet weak var currentTimeSlider: UISlider!
    
    @IBAction func handleFastForwardButton(_ sender: Any) {
        seekTimeToDelta(delta: 15)
    }
    @IBAction func handleRewindButton(_ sender: Any) {
        seekTimeToDelta(delta: -15)
    }
    
    fileprivate func seekTimeToDelta(delta: Float64) {
        let fifteenSeconds = CMTimeMakeWithSeconds(delta, 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        player.seek(to: seekTime)
    }
    @IBAction func handleCurrentTimeSliderChange(_ sender: Any) {
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else {return}
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, Int32(NSEC_PER_SEC))
        player.seek(to: seekTime)
    }
    
    @objc func handlePlayPause() {
        print("Trying to play pause")
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeEpisodeImageView()
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            shrinkEpisodeImageView()
        }
    }
}
