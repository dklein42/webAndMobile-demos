//
//  ViewController.swift
//  MLTest
//
//  Created by Daniel Klein on 09.06.17.
//  Copyright © 2017 House of Bytes Software. All rights reserved.
//

import UIKit

class SimpleCoreMLViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let net = MobileNet()
        
        let imageConstraint = net.model.modelDescription.inputDescriptionsByName["image"]!.imageConstraint!
        let bufferWidth = imageConstraint.pixelsWide
        let bufferHeight = imageConstraint.pixelsHigh
        let bufferType = imageConstraint.pixelFormatType
        
        let image = UIImage(named: "Mountain")!
        let pixelBuffer = scaledPixelBufferOfImage(image, width: bufferWidth, height: bufferHeight, type: bufferType)
        
        let out = try! net.prediction(image: pixelBuffer)

        let answer = out.classLabel
        let probability = out.classLabelProbs[answer]
        print("The answer is: \(answer) (\(String(describing: probability)))")
    }

    private func scaledPixelBufferOfImage(_ image: UIImage, width: Int, height: Int, type: OSType) -> CVPixelBuffer {
        let ciImage = CIImage(image: image)!
        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault, width, height, type, nil, &pixelBuffer)
        let context = CIContext()
        context.render(ciImage, to: pixelBuffer!)
        return pixelBuffer!
    }
}

