//
//  VisionViewController.swift
//  MLTest
//
//  Created by Daniel Klein on 26.08.17.
//  Copyright © 2017 House of Bytes Software. All rights reserved.
//

import UIKit
import AVFoundation
import Vision


class VideoVisionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var classificationLabel: UILabel!
    
    let session = AVCaptureSession()
    let sequenceHandler = VNSequenceRequestHandler()
    var frameCount: Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        session.sessionPreset = .photo
        let camera = AVCaptureDevice.default(for: .video)!
        let input = try! AVCaptureDeviceInput(device: camera)
        self.session.addInput(input)
        
        let cameraLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraLayer.frame = videoView.frame
        self.videoView.layer.addSublayer(cameraLayer)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInteractive))
        self.session.addOutput(videoOutput)
    }
        
    override func viewWillAppear(_ animated: Bool) {
        session.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        session.stopRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.frameCount += 1
        
        if self.frameCount % 4 != 0 {
            print("Skipping frame...")
            return
        }
        
        print("Performing classification...")
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let model = try! VNCoreMLModel(for: MobileNet().model)
        let request = VNCoreMLRequest(model: model, completionHandler: self.handleClassification)
        try! sequenceHandler.perform([request], on: pixelBuffer)
    }
    
    func handleClassification(request: VNRequest, error: Error?) {
        guard error == nil else {
            print("Error: \(error!.localizedDescription)")
            return
        }
        
        let observations = request.results as! [VNClassificationObservation]
        let bestObservation = observations[0]
        
        DispatchQueue.main.async {
            self.classificationLabel.text = "This is a \(bestObservation.identifier) (\(bestObservation.confidence))"
        }
    }
}
