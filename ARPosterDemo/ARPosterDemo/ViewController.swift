//
//  ViewController.swift
//  ARPosterDemo
//
//  Created by Daniel Klein on 06.03.18.
//  Copyright © 2018 House of Bytes Software. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!
    
    let sceneKitQueue = DispatchQueue(label: "SceneKitQueue")

    let images: [UIImage] = [
        UIImage(named: "Bonn leuchtet 1")!,
        UIImage(named: "Bonn leuchtet 2")!,
        UIImage(named: "Bonn leuchtet 3")!,
        UIImage(named: "Bonn leuchtet 4")!,
        UIImage(named: "Bonn leuchtet 5")!,
        UIImage(named: "Bonn leuchtet 6")!,
        UIImage(named: "Bonn leuchtet 7")!,
        UIImage(named: "Bonn leuchtet 8")!
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = ARReferenceImage.referenceImages(inGroupNamed: "Posters", bundle: nil)!
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let posterImage = imageAnchor.referenceImage
        
        self.sceneKitQueue.async {
            let w = Float(posterImage.physicalSize.width)
            let h = Float(posterImage.physicalSize.height)
            let i = self.images
            
            let planes = [
                self.createPlane(dX: -w, dY: -h, width: w, height: h, image: i[0]),
                self.createPlane(dX:  0, dY: -h, width: w, height: h, image: i[1]),
                self.createPlane(dX:  w, dY: -h, width: w, height: h, image: i[2]),
            
                self.createPlane(dX: -w, dY:  0, width: w, height: h, image: i[3]),
                self.createPlane(dX:  w, dY:  0, width: w, height: h, image: i[4]),
            
                self.createPlane(dX: -w, dY:  h, width: w, height: h, image: i[5]),
                self.createPlane(dX:  0, dY:  h, width: w, height: h, image: i[6]),
                self.createPlane(dX:  w, dY:  h, width: w, height: h, image: i[7])
            ]
            
            planes.forEach({ childNode in
                node.addChildNode(childNode)
            })
        }
    }
    
    private func createPlane( dX: Float, dY: Float, width: Float, height: Float, image: UIImage) -> SCNNode {
        let spacingX: Float = dX/10
        let spacingY: Float = dY/10

        let plane = SCNPlane(width: CGFloat(width), height: CGFloat(height))

        let material = SCNMaterial()
        material.diffuse.contents = image
        plane.materials = [material]

        let planeNode = SCNNode(geometry: plane)
        planeNode.position.x = dX + spacingX
        planeNode.position.z = dY + spacingY
        planeNode.eulerAngles.x = (-.pi/2) //+ (-dY*2)
//        planeNode.eulerAngles.z = dX * 2

        return planeNode
    }
}
