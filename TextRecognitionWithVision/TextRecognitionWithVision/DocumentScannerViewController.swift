//
//  DocumentScannerViewController.swift
//  TextRecognitionWithVision
//
//  Created by Daniel Klein on 20.01.20.
//  Copyright © 2020 Daniel Klein. All rights reserved.
//

import UIKit
import Vision
import VisionKit

class DocumentScannerViewController: UIViewController, VNDocumentCameraViewControllerDelegate {
    @IBOutlet weak var recognizedTextView: UITextView!

    var textRequest: VNRecognizeTextRequest!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard VNDocumentCameraViewController.isSupported else {
           return
        }
        
        print("Supported languages accurate: \(String(describing: try? VNRecognizeTextRequest.supportedRecognitionLanguages(for: .accurate, revision: VNRecognizeTextRequestRevision1)))")
        print("Supported languages fast: \(String(describing: try? VNRecognizeTextRequest.supportedRecognitionLanguages(for: .fast, revision: VNRecognizeTextRequestRevision1)))")

        //print("Languages: \(textRequest.recognitionLanguages)")
        //textRequest.recognitionLanguages = ["de", "en"]

        
        // Setup Vision
        textRequest = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        textRequest.recognitionLevel = .accurate
        textRequest.usesLanguageCorrection = true
        //textRequest.minimumTextHeight = 0.5
        textRequest.customWords = ["1337", "h4xX0r"]
    }
    
    @IBAction func scanDocuments(_ sender: Any) {
        let documentCameraVC = VNDocumentCameraViewController()
        documentCameraVC.delegate = self
        present(documentCameraVC, animated: true)
    }
    
    // MARK: - VNDocumentCameraViewControllerDelegate
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        dismiss(animated: true)

        DispatchQueue.global(qos: .userInitiated).async {
            for pageIndex in 0 ..< scan.pageCount {
                let image = scan.imageOfPage(at: pageIndex)
                if let cgImage = image.cgImage {
                    print("Processing page \(pageIndex)")
                    let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                    try? requestHandler.perform([self.textRequest])
                }
            }
        }
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print("Failed with error: \(error)")
        dismiss(animated: true)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        print("Cancelled!")
        dismiss(animated: true)
    }
    
    // MARK: - Text Recognizer Handler
    
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let textObservations = request.results as? [VNRecognizedTextObservation] else {
            return
        }
        
        print("Text observations: \(textObservations)")
        
        for textObservation in textObservations {
            if let topCandidate = textObservation.topCandidates(1).first {
                let recognizedString = topCandidate.string
                print("Recognized String: \(recognizedString)")
                
                let detector = try! NSDataDetector(types: NSTextCheckingAllTypes)
                let matches = detector.matches(in: recognizedString, options: [], range: NSRange(location: 0, length: recognizedString.count))
                
                var output = recognizedString
                
                for match in matches {
                    switch match.resultType {
                    case .address:
                        for component in match.addressComponents! {
                            print("\(component.key.rawValue): \(component.value)")
                            output += "\n\(component.key.rawValue): \(component.value)"
                        }
                    case .phoneNumber:
                        print("Phone Number: \(match.phoneNumber!)")
                        output += "\nPhone Number detected: \(match.phoneNumber!)"
                    case .link:
                        print("Link: \(match.url!)")
                        output += "\nLink detected: \(match.url!)"
                        
                    default:
                        print("Unhandled match: \(match.resultType)")
                    }
                }

                DispatchQueue.main.async {
                    self.recognizedTextView.text += output + "\n"
                }
            }
        }

        DispatchQueue.main.async {
            self.recognizedTextView.text += "\n"
        }
    }

}
