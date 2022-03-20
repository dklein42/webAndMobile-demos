//
//  SimpleMovieViewController.swift
//  SharePlay
//
//  Created by Daniel Klein on 20.03.22.
//

import UIKit
import Combine
import AVFoundation
import AVKit
import GroupActivities

class MovieViewController: UIViewController {
    private let player = AVPlayer()
    private var playerViewController: AVPlayerViewController!
    private var subscriptions = Set<AnyCancellable>()

    private var movie: Movie? {
        didSet {
            guard let movie = movie else { return }
            let playerItem = AVPlayerItem(url: movie.url)
            player.replaceCurrentItem(with: playerItem)
        }
    }
        
    private var groupSession: GroupSession<MovieWatchingActivity>? {
        didSet {
            guard let session = groupSession else {
                // Stop session if playback terminates
                player.pause()
                return
            }
            
            // Coordinate playback with the active session
            player.playbackCoordinator.coordinateWithSession(session)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        Task {
            for await groupSession in MovieWatchingActivity.sessions() {
                self.groupSession = groupSession
                
                subscriptions.removeAll()
                
                groupSession.$state.sink { [weak self] state in
                    if case .invalidated = state {
                        // Setting groupSession to nil invalidates session state
                        self?.groupSession = nil
                        self?.subscriptions.removeAll()
                    }
                }.store(in: &subscriptions)

                groupSession.$activity.sink { [weak self] activity in
                    self?.movie = activity.movie
                }.store(in: &subscriptions)

                groupSession.join()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerViewController.player = player
//        playerViewController.allowsPictureInPicturePlayback = true
//        playerViewController.canStartPictureInPictureAutomaticallyFromInline = true
        
        // Observe audio session interruptions
//        NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] notification in
//                let type = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? AVAudioSession.InterruptionType
//                let options = notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? AVAudioSession.InterruptionOptions
//
//                if type == .ended && options == .shouldResume {
//                    self?.player.play()
//                }
//            }.store(in: &subscriptions)
    }
    
    func shareActivity(movie: Movie) async {
        let activity = MovieWatchingActivity(movie: movie)
        
        switch await activity.prepareForActivation() {
        case .activationDisabled:
            // No sharing requested, just do the movie locally
            self.movie = movie
        case .activationPreferred:
            // Sharing requested, so activate and play
            // This triggers activity observation above
            _ = try? await activity.activate()
//        case .cancelled:
//            break
        default:
            break
        }

        player.play()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let playerViewController = segue.destination as? AVPlayerViewController else { return }
        self.playerViewController = playerViewController
    }
    
    @IBAction func playMovie() {
        let movieURL = Bundle.main.url(forResource: "Test", withExtension: "mp4")!
        let movie = Movie(url: movieURL, title: "Demo Movie", description: "Some demo movie.")
        
        Task {
            await shareActivity(movie: movie)
        }
    }
    
    @IBAction func reset() {
        self.groupSession = nil
    }
}
