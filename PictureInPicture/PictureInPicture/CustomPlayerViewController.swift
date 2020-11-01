//
//  CustomPlayerViewController.swift
//  PictureInPicture
//
//  Created by Daniel Klein on 25.10.20.
//

import UIKit
import AVFoundation
import AVKit

class CustomPlayerViewController: UIViewController, AVPictureInPictureControllerDelegate {
    @IBOutlet weak var playerContainerView: UIView!
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var pictureInPictureController: AVPictureInPictureController!

    override func viewDidLoad() {
        super.viewDidLoad()

        let videoURL = Bundle.main.url(forResource: "Test", withExtension: "mp4")!
        player = AVPlayer(url: videoURL)

        playerLayer = AVPlayerLayer(player: player)
        playerContainerView.layer.addSublayer(playerLayer)

        // Setup PiP Controller
        pictureInPictureController = AVPictureInPictureController(playerLayer: playerLayer)
        pictureInPictureController?.delegate = self
        if #available(iOS 14.2, *) {
            pictureInPictureController.canStartPictureInPictureAutomaticallyFromInline = true
        }

        startVideoPlayer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = playerContainerView.bounds
    }
    
    private func startVideoPlayer() {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playback, mode: .moviePlayback)
        
        // Brefore playback do:
        try? audioSession.setActive(true, options: [])
        
        // Enable background audio in project settings (for PiP)
        
        
        
        DispatchQueue.main.async { [self] in
            player.play()
        }

        // Don't forget to disable the session!
        //try? audioSession.setActive(false, options: [])
    }
    
    @IBAction func startPictureInPicture(_ sender: Any) {
        // Check isSupported & isPossible!
        
        pictureInPictureController.startPictureInPicture()
    }
    
    // MARK: - AVPictureInPictureControllerDelegate
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }
    
    
    
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("Will Start")
    }
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("Did Start")
    }
    
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("Will Stop")
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("Did Stop")
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("Error starting PiP: \(error)")
    }
}
