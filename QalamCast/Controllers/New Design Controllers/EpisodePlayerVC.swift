//
//  EpisodePlayerVC.swift
//  QalamCast
//
//  Created by apple on 13/08/21.
//  Copyright © 2021 Zakir Magdum. All rights reserved.
//

import UIKit
import AVKit
import SDWebImage
import AVFoundation
import MediaPlayer

class EpisodePlayerVC: UIViewController {

    @IBOutlet weak var playerMinimise: UIButton!
    @IBOutlet weak var podcastImgView: UIImageView!
    @IBOutlet weak var podcastBlurImgView: UIImageView!
    @IBOutlet weak var podcastName: UILabel!
    @IBOutlet weak var episodeName: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var rewindBtn: UIButton!
    @IBOutlet weak var forwardBtn: UIButton!
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var audioProgressBar: UISlider!
    @IBOutlet weak var audioTotalTIme: UILabel!
    @IBOutlet weak var remainingTime: UILabel!
    
    
    var playerSpeed: Float = 1.0
    
    var series: Category? {
        didSet {
            
        }
    }
    
    var episodeId: Int! {
        didSet {
            self.episode = try! DB.shared.getEpisode(id: episodeId)
        }
    }
    var episode: Episode! {
        didSet {
            if oldValue == nil || oldValue.title != episode.title {
                
//                if (episode.duration ?? 0) - (episode.played ?? 0.0) < 2 {
//                    episode.played = 0
//                }
                setupNowPlayingInfo()
                setupAudioSession()
                
                
            }
        }
    }
    
    fileprivate func setPlayerSpeedText() {
        //playerSpeedButton.setTitle("\(playerSpeed)x", for: .normal)
        player.rate = playerSpeed
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        podcastName.text = series?.title
        episodeName.text = episode.shortTitle
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        releaseDate.text = dateFormatter.string(from: episode.pubDate)
        
        print("playing \(episode.title)  \(episode.duration ?? -1) \(episode.played ?? -2)")
        
        let imageUrl = series?.artwork  ?? ""
        if (imageUrl.starts(with: "http")) {
            guard let url = URL(string: series?.artwork ?? "") else { return }
            podcastBlurImgView.sd_setImage(with: url)
            podcastImgView.sd_setImage(with: url)
        } else {
            podcastBlurImgView.image = UIImage(named: imageUrl)
            podcastImgView.image = UIImage(named: imageUrl)
        }
        
        playEpisode(episode: episode)
        
        playerSpeed = UserDefaults.standard.float(forKey: "player_speed")
        if playerSpeed == 0 {
            playerSpeed = 1.0
        }
        setPlayerSpeedText()
        // Do any additional setup after loading the view.
        
//        if !APIService.shared.getAutoStartPlay() {
//            self.handlePlayPause()
//        }
    }
    
    
    fileprivate func playEpisode(episode: Episode) {
        print("Trying to play url", episode.id as Any, " ", episode.played!)
        guard let url = URL(string: episode.streamUrl) else {return }
        player.automaticallyWaitsToMinimizeStalling = false
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
        playBtn.setImage(UIImage(named: "player_pause"), for: .normal)
        //miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
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
            self?.audioTotalTIme.text = time.toDisplayString()
            let durationTime = self?.player.currentItem?.duration
            self?.remainingTime.text = durationTime?.toDisplayString()
            self?.updateCurrentTimeSlider()
            //self?.episode.played = CMTimeGetSeconds(time)
            DB.shared.updatePlayed(title: self!.episodeName.text!, played: CMTimeGetSeconds(time))
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
            self.playBtn.setImage(UIImage(named: "player_pause"), for: .normal)
            //self.miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            
            self.setupElapsedTime(playbackRate: 1)
            return .success
        }
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.pause()
            self.playBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            //self.miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
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
        
        episodeName.text = episode.shortTitle
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        releaseDate.text = dateFormatter.string(from: episode.pubDate)
        
        playEpisode(episode: self.episode)
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
        
        episodeName.text = episode.shortTitle
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        releaseDate.text = dateFormatter.string(from: episode.pubDate)
        
        playEpisode(episode: self.episode)
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
            //self?.enlargeEpisodeImageView()
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
            self?.audioTotalTIme.text = time.toDisplayString()
            let durationTime = self?.player.currentItem?.duration
            self?.remainingTime.text = durationTime?.toDisplayString()
            
            self?.updateCurrentTimeSlider()
            DB.shared.updatePlayed(title: self!.episodeName.text!, played: CMTimeGetSeconds(time))
        }
    }
    
    fileprivate func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1,timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        self.audioProgressBar.value = Float(percentage)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupRemoteControl()
        setupGestures()
        setupInterruptionObserver()
        observePlayerCurrentTime()
        observeBoundaryTime()

        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        let interval = CMTimeMake(value: 1, timescale: 2)
        oberverPlayerCurrentTime(interval)
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            //self?.enlargeEpisodeImageView()
        }
        
        //episodeName.textColor = .black
        //miniPlayerTitleLabel.textColor = .black
    }
   
    var panGesture: UIPanGestureRecognizer!
    
    fileprivate func setupGestures() {
        //addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
        //panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        //miniPlayerView.addGestureRecognizer(panGesture)
        
       // maxPlayerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))
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
            
            playBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            //miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            
        } else {
            print("Interruption ended...")
            
            guard let options = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            
            if options == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
                player.play()
                playBtn.setImage(UIImage(named: "player_pause"), for: .normal)
                //miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            }
            
            
        }
    }
    @objc fileprivate func handleDonePlaying(notification: Notification) {
        print("player ended up playing", episode)
        DB.shared.updateDonePlaying(id: self.episodeId)
        handleNextTrack()
    }
    
    fileprivate func enlargeEpisodeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.podcastImgView.transform = .identity
            })
    }
    fileprivate let shrunkenTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    fileprivate func shrinkEpisodeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.podcastImgView.transform = self.shrunkenTransform
        })
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
        playBtn.setImage(UIImage(named: "player_pause"), for: .normal)
        //miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
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
        print("Saving played \(self.episodeName.text!) \(seekTimeInSeconds)")
        DB.shared.updatePlayed(title: self.episodeName.text!, played: seekTimeInSeconds)
    }
    
    @objc func handlePlayPause() {
        print("Trying to play pause")
        if player.timeControlStatus == .paused {
            player.play()
            playBtn.setImage(UIImage(named: "player_pause"), for: .normal)
            //miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            //enlargeEpisodeImageView()
        } else {
            player.pause()
            playBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            //miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            //shrinkEpisodeImageView()
        }
    }
    
    //MARK: - Button clicks
    
    @IBAction func playerMinimiseBtnClick(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func rewindBtnClick(_ sender: Any) {
        seekTimeToDelta(delta: -15)
    }
    
    @IBAction func forwardBtnClick(_ sender: Any) {
        seekTimeToDelta(delta: 15)
    }
    
    @IBAction func previousBtnClick(_ sender: Any) {
        handlePrevTrack()
    }
    
    @IBAction func nextBtnClick(_ sender: Any) {
        handleNextTrack()
    }
    
    @IBAction func playBtnClick(_ sender: Any) {
        
        print("Trying to play pause")
        if player.timeControlStatus == .paused {
            player.play()
            playBtn.setImage(UIImage(named: "player_pause"), for: .normal)
            //miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            //enlargeEpisodeImageView()
        } else {
            player.pause()
            playBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            //miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            //shrinkEpisodeImageView()
        }
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
