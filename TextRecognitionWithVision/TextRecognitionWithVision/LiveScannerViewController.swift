//
//  ViewController.swift
//  TextRecognitionWithVision
//
//  Created by Daniel Klein on 20.01.20.
//  Copyright © 2020 Daniel Klein. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class VideoView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}

class LiveScannerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var videoView: VideoView!
    
    let session = AVCaptureSession()
    let sequenceHandler = VNSequenceRequestHandler()
    var textRequest: VNRecognizeTextRequest!
    var cameraLayer: AVCaptureVideoPreviewLayer!
    var boxes = [CALayer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup Vision
        textRequest = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        textRequest.recognitionLevel = .fast
        //textRequest.usesLanguageCorrection = false
        // textRequest.regionOfInterest = ...
        
        // Setup Video view
        session.sessionPreset = .high
        let camera = AVCaptureDevice.default(for: .video)!
        let input = try! AVCaptureDeviceInput(device: camera)
        self.session.addInput(input)
        
        cameraLayer = (videoView.layer as! AVCaptureVideoPreviewLayer)
        cameraLayer.session = session

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
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
        try! requestHandler.perform([textRequest])
    }
    
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let textObservations = request.results as? [VNRecognizedTextObservation] else {
            return
        }
        
        print("Text observations: \(textObservations)")
        
        // Clear boxes
        DispatchQueue.main.sync {
            boxes.forEach { box in
                box.removeFromSuperlayer()
            }
            boxes.removeAll()
        }
        
        for textObservation in textObservations {
            if let topCandidate = textObservation.topCandidates(1).first {
                let recognizedString = topCandidate.string
                print("Recognized String: \(recognizedString)")
                
                // Draw boxes around observed regions
                let boundingBox = textObservation.boundingBox
                
                DispatchQueue.main.async {
                    // Translate between coordinate systems and rotate 90°, because AVFoundation's orientation is always landscape left (home button
                    // on the left), due to the native orientation of the sensor
                    let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 1, y: -1).rotated(by: CGFloat.pi/2)
                    let transformedBox = boundingBox.applying(transform)
                    let convertedBox = self.cameraLayer.layerRectConverted(fromMetadataOutputRect: transformedBox)

                    let boxLayer = CALayer()
                    boxLayer.frame = convertedBox
                    boxLayer.borderWidth = 2
                    boxLayer.borderColor = UIColor.red.cgColor
                    boxLayer.opacity = 0.5
                    self.cameraLayer.addSublayer(boxLayer)
                    self.boxes.append(boxLayer)
                }
            }
        }
    }
}
