//
//  ViewController.swift
//  PictureInPicture
//
//  Created by Daniel Klein on 25.10.20.
//

import UIKit
import AVFoundation
import AVKit

class StandardPlayerViewController: UIViewController, AVPlayerViewControllerDelegate {

    var player: AVPlayer!
    var playerViewController: AVPlayerViewController?
    var playerRateObservation: NSKeyValueObservation?
    
    deinit {
        // Don't forget to disable the session!
        try? AVAudioSession.sharedInstance().setActive(false, options: [])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let isPiPSupported = AVPictureInPictureController.isPictureInPictureSupported()
        print("PiP supported: \(isPiPSupported)")

        let videoURL = Bundle.main.url(forResource: "Test", withExtension: "mp4")!
        player = AVPlayer(url: videoURL)

        self.playerRateObservation = player.observe(\.rate, changeHandler: { player, change in
            print("Rate changed: \(player.rate)")
        })

        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.main) { [self] cmTime in
            print("Player position: \(player.currentTime().seconds)")
        }
        
        startVideoPlayer()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func startVideoPlayer() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
                
        // Enable background audio in project settings (for PiP)
        
        playerViewController = AVPlayerViewController()
        playerViewController!.player = player
        playerViewController!.delegate = self
        //playerViewController!.allowsPictureInPicturePlayback = true // enabled by default, disable if necessary
        
        DispatchQueue.main.async { [self] in
            self.present(playerViewController!, animated: true) {
                try? AVAudioSession.sharedInstance().setActive(true, options: [])
                player.play()
            }
        }
    }
    
    // MARK: - AVPlayerViewControllerDelegate

    // Only necessary when we want false
    func playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart(_ playerViewController: AVPlayerViewController) -> Bool {
        return false
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        print("Restore requested!")
        
        assert(playerViewController == self.playerViewController)
        //guard let playerVC = playerViewController else { return }
        
        self.present(playerViewController, animated: true) { [self] in
            player.play()
        }
        
        completionHandler(true)
    }
    
    func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        print("Will Start")
    }
    
    func playerViewControllerDidStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        print("Did Start")
    }
    
    func playerViewControllerWillStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
        print("Will Stop")
    }
    
    func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
        print("Did Stop")
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, failedToStartPictureInPictureWithError error: Error) {
        print("Failed to start PiP")
    }
}

