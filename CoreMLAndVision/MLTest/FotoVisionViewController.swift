//
//  SimpleVisionViewController.swift
//  MLTest
//
//  Created by Daniel Klein on 26.08.17.
//  Copyright © 2017 House of Bytes Software. All rights reserved.
//

import UIKit
import CoreML
import Vision

class FotoVisionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var fotoView: UIImageView!
    @IBOutlet weak var classificationLabel: UILabel!
    
    @IBAction func loadImageTouched(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true)
        self.classificationLabel.text = "Analyzing..."
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.fotoView.image = image
        performClassification(onImage: image)
    }

    func performClassification(onImage image: UIImage) {
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        
        let model = try! VNCoreMLModel(for: MobileNet().model)
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            let observations = request.results as! [VNClassificationObservation]
            let bestObservation = observations[0]

            DispatchQueue.main.async {
                self.classificationLabel.text = "This is a \(bestObservation.identifier) (\(bestObservation.confidence))"
                print("Best observation: \(bestObservation.identifier) (\(bestObservation.confidence))")
            }
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            try? handler.perform([request])
        }
    }
}
