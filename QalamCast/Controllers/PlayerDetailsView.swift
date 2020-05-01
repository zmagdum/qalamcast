//
//  PlayerDetailsView.swift
//  QalamCast
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
    
    var playerSpeed: Float = 1.0
    
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
                print("playing \(episode.title)  \(episode.duration ?? -1) \(episode.played ?? -2)")
//                if (episode.duration ?? 0) - (episode.played ?? 0.0) < 2 {
//                    episode.played = 0
//                }
                setupNowPlayingInfo()
                setupAudioSession()
                playEpisode(episode: episode)
                let imageUrl = episode.imageUrl  ?? ""
                if (imageUrl.starts(with: "http")) {
                    guard let url = URL(string: episode.imageUrl ?? "") else { return }
                    playerImageView.sd_setImage(with: url)
                    miniPlayerImageView.sd_setImage(with: url)
                } else {
                    playerImageView.image = UIImage(named: imageUrl)
                    miniPlayerImageView.image = UIImage(named: imageUrl)
                }
                playerSpeed = UserDefaults.standard.float(forKey: "player_speed")
                if playerSpeed == 0 {
                    playerSpeed = 1.0
                }
                setPlayerSpeedText()
            }
        }
    }
    
    fileprivate func setPlayerSpeedText() {
        playerSpeedButton.setTitle("\(playerSpeed)x", for: .normal)
        player.rate = playerSpeed
    }
    
    fileprivate func playEpisode(episode: Episode) {
        print("Trying to play url", episode.id as Any, " ", episode.played!)
        guard let url = URL(string: episode.streamUrl) else {return }
        if !playEpisodeUsingFileUrl() {
            playEpisode(url: url)
        }
        if episode.played! > 0.0 {
            let seekTime = CMTimeMakeWithSeconds(episode.played!, preferredTimescale: Int32(NSEC_PER_SEC))
            player.seek(to: seekTime)
        }
        DB.shared.saveCurrentEpisode(episode: episode)
    }
    
    fileprivate func playEpisode(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
    }
    
    fileprivate func playEpisodeUsingFileUrl() -> Bool {
        print("Attempt to play episode with downloaded file")
        // let's figure out the file name for our episode file url
        let localUrl = APIService.shared.getEpisodeLocalUrl(episode: self.episode)
        if localUrl != nil {
            let playerItem = AVPlayerItem(url: localUrl!)
            player.replaceCurrentItem(with: playerItem)
            player.play()
//            if episode.played! > 0.0 {
//                let seekTime = CMTimeMakeWithSeconds(episode.played!, preferredTimescale: Int32(NSEC_PER_SEC))
//                player.seek(to: seekTime)
//            }
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
            //self?.episode.played = CMTimeGetSeconds(time)
            DB.shared.updatePlayed(title: self!.episodeTitle.text!, played: CMTimeGetSeconds(time))
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
        
//        commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
//        commandCenter.previousTrackCommand.addTarget(self, action: #selector(handlePrevTrack))
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            let seriesEpisodes = try! DB.shared.getEpisodesForSeries(series: self.episode.category)
            let currentEpisodeIndex = seriesEpisodes.index { (ep) -> Bool in
                return self.episode.title == ep.title
            }
            guard let index = currentEpisodeIndex else { return .success}
            if index < (seriesEpisodes.count - 1) {
                self.episode = seriesEpisodes[index + 1]
                return .success
            }
            return .commandFailed
        }

        // Add handler for Pause Command
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            let seriesEpisodes = try! DB.shared.getEpisodesForSeries(series: self.episode.category)
            let currentEpisodeIndex = seriesEpisodes.index { (ep) -> Bool in
                return self.episode.title == ep.title
            }
            guard let index = currentEpisodeIndex else { return .success}
            if index > 0 {
                self.episode = seriesEpisodes[index - 1]
                return .success
            }
            return .commandFailed
        }
        
    }
    
    @objc fileprivate func handlePrevTrack() {
        let seriesEpisodes = try! DB.shared.getEpisodesForSeries(series: episode.category)

        let currentEpisodeIndex = seriesEpisodes.index { (ep) -> Bool in
            return self.episode.title == ep.title
        }
        guard let index = currentEpisodeIndex else { return }
        if index < (seriesEpisodes.count - 1) {
            self.episode = seriesEpisodes[index + 1]
        }
    }
    
    @objc fileprivate func handleNextTrack() {
        let seriesEpisodes = try! DB.shared.getEpisodesForSeries(series: episode.category)
        if seriesEpisodes.count == 0 {
            return
        }
        let currentEpisodeIndex = seriesEpisodes.index { (ep) -> Bool in
            return self.episode.title == ep.title
        }
        guard let index = currentEpisodeIndex else { return }
        if index > 0 {
            self.episode = seriesEpisodes[index - 1]
        }
    }

    fileprivate func setupElapsedTime(playbackRate: Float) {
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
    }
    
    fileprivate func observeBoundaryTime() {
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        
        // player has a reference to self
        // self has a reference to player
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            print("Episode started playing")
            self?.enlargeEpisodeImageView()
            self?.setupLockscreenDuration()
        }
    }
    
    fileprivate func setupLockscreenDuration() {
        guard let duration = player.currentItem?.duration else { return }
        let durationSeconds = CMTimeGetSeconds(duration)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationSeconds
    }
    
    fileprivate func observePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            self?.startTimeLabel.text = time.toDisplayString()
            let durationTime = self?.player.currentItem?.duration
            self?.endTimeLabel.text = durationTime?.toDisplayString()
            
            self?.updateCurrentTimeSlider()
            DB.shared.updatePlayed(title: self!.episodeTitle.text!, played: CMTimeGetSeconds(time))
        }
    }
    
    fileprivate func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1,timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        self.currentTimeSlider.value = Float(percentage)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupRemoteControl()
        setupGestures()
        setupInterruptionObserver()
        observePlayerCurrentTime()
        observeBoundaryTime()
        addBorderToMiniPlayerView()
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))

        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        let interval = CMTimeMake(value: 1, timescale: 2)
        oberverPlayerCurrentTime(interval)
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enlargeEpisodeImageView()
        }
        episodeTitle.textColor = .black
        miniPlayerTitleLabel.textColor = .black
    }
   
    var panGesture: UIPanGestureRecognizer!
    
    fileprivate func setupGestures() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        miniPlayerView.addGestureRecognizer(panGesture)
        
        maxPlayerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))
    }
    
    fileprivate func addBorderToMiniPlayerView() {
        let thickness: CGFloat = 1.0
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0.0, y: 0.0, width: 1.2 * self.miniPlayerView.frame.size.width, height: thickness)
        topBorder.backgroundColor = UIColor.lightGray.cgColor
        miniPlayerView.layer.addSublayer(topBorder)
    }
    
    @objc func handleDismissalPan(gesture: UIPanGestureRecognizer) {
        print("maximizedStackView dismissal")
        
        if gesture.state == .changed {
            let translation = gesture.translation(in: superview)
            maxPlayerView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        } else if gesture.state == .ended {
            let translation = gesture.translation(in: superview)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.maxPlayerView.transform = .identity
                
                if translation.y > 50 {
                    let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
                    mainTabBarController?.minimizePlayerDetails()
                }
                
            })
        }
    }
    
    
    static func initFromNib() -> PlayerDetailsView {
        return Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
    }
    
    fileprivate func setupInterruptionObserver() {
        // don't forget to remove self on deinit
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDonePlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
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
    @objc fileprivate func handleDonePlaying(notification: Notification) {
        print("player ended up playing", episode)
        DB.shared.updateDonePlaying(id: self.episodeId)
        handleNextTrack()
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
    
    @IBOutlet weak var playerSpeedButton: UIButton!
    @IBAction func handleSpeedChange(_ sender: Any) {
        switch(playerSpeed) {
        case 1:
            playerSpeed = 1.25
        case 1.25:
            playerSpeed = 1.5
        case 1.5:
            playerSpeed = 2
        case 0.5:
            playerSpeed = 1
        case 2:
            playerSpeed = 0.5
        default:
            playerSpeed = 1
        }
        player.rate = playerSpeed
        UserDefaults.standard.set(playerSpeed, forKey: "player_speed")
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        setPlayerSpeedText()
    }
    
    @IBAction func handleMoveToNext(_ sender: Any) {
        handleNextTrack()
    }
    @IBAction func handleMoveToPrev(_ sender: Any) {
        handlePrevTrack()
    }
    fileprivate func seekTimeToDelta(delta: Float64) {
        let fifteenSeconds = CMTimeMakeWithSeconds(delta, preferredTimescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        player.seek(to: seekTime)
    }
    @IBAction func handleCurrentTimeSliderChange(_ sender: Any) {
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else {return}
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: Int32(NSEC_PER_SEC))
        player.seek(to: seekTime)
        print("Saving played \(self.episodeTitle.text!) \(seekTimeInSeconds)")
        DB.shared.updatePlayed(title: self.episodeTitle.text!, played: seekTimeInSeconds)
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
