//
//  ViewController.swift
//  SharePlay
//
//  Created by Daniel Klein on 14.03.22.
//

import UIKit
import Combine
import GroupActivities
import AVFoundation
import AVKit

class MovieViewController: UIViewController {
    private var subscriptions = Set<AnyCancellable>()

    private let player = AVPlayer()
    private let waitingInfo = UIView()
    
    private lazy var playerViewController: AVPlayerViewController = {
        let controller = AVPlayerViewController()
        controller.allowsPictureInPicturePlayback = true
        controller.canStartPictureInPictureAutomaticallyFromInline = true
        controller.player = player
        return controller
    }()
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .fullScreen
        
        // Child View Controller
        guard let playerView = playerViewController.view else {
            fatalError("Unable to get playerController view")
        }
        
        self.addChild(playerViewController)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(playerView)
        playerViewController.didMove(toParent: self)
        
        // Content Overlay - Waiting Info
        guard let contentOverlayView = playerViewController.contentOverlayView else {
            fatalError()
        }
        
        contentOverlayView.addSubview(waitingInfo)
        waitingInfo.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            waitingInfo.topAnchor.constraint(equalTo: contentOverlayView.topAnchor),
            waitingInfo.leadingAnchor.constraint(equalTo: contentOverlayView.leadingAnchor),
            waitingInfo.bottomAnchor.constraint(equalTo: contentOverlayView.bottomAnchor),
            waitingInfo.trailingAnchor.constraint(equalTo: contentOverlayView.trailingAnchor)
        ])
        
        // TODO: Handle showing/hiding waitingInfo
        
        MovieCoordinationManager.shared.$currentMovie
            .receive(on: DispatchQueue.main)
            .compactMap { $0 } // Filter non-nil
            .assign(to: \.movie, on: self)
            .store(in: &subscriptions)
        
        MovieCoordinationManager.shared.$groupSession
            .receive(on: DispatchQueue.main)
            .assign(to: \.groupSession, on: self)
            .store(in: &subscriptions)
        
        player.publisher(for: \.timeControlStatus, options: [.initial])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] timeControlStatus in
                if [.playing, .waitingToPlayAtSpecifiedRate].contains(timeControlStatus) {
                    // Only show if we're in a paused state
                    self?.waitingInfo.isHidden = true
                }
            }.store(in: &subscriptions)
        
        // Observe audio session interruptions
        NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                let type = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? AVAudioSession.InterruptionType
                let options = notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? AVAudioSession.InterruptionOptions
                
                if type == .ended && options == .shouldResume {
                    self?.player.play()
                }
            }.store(in: &subscriptions)

        
    }

    

}

