//
//  FaceTrackingViewController.swift
//  ARKit3
//
//  Created by Daniel Klein on 28.07.19.
//  Copyright © 2019 Daniel Klein. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class FaceTrackingViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet weak var sceneView: ARSCNView!
    
    var maskNode: SCNNode? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(sceneTapped(_:)))
        self.sceneView.addGestureRecognizer(tapRecognizer)
    }

    @IBAction func sceneTapped(_ sender: UITapGestureRecognizer) {
        let hitTestResult = sceneView.hitTest(sender.location(in: sceneView), types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane])
        let firstResult = hitTestResult.first
        
        if let result = firstResult {
            if self.maskNode != nil {
                let maskAnchor = ARAnchor(name: "Mask", transform: result.worldTransform)
                sceneView.session.add(anchor: maskAnchor)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        
        if ARWorldTrackingConfiguration.supportsUserFaceTracking {
            configuration.userFaceTrackingEnabled = true
        }
        
        sceneView.session.run(configuration)
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARFaceAnchor {
            let maskGeometry = ARSCNFaceGeometry(device: sceneView.device!)!
            self.maskNode = createMask(faceGeometry: maskGeometry)
        }
        
        else if anchor.name == "Mask" {
            if let maskNode = self.maskNode {
                node.addChildNode(maskNode)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else {
            return
        }
        
        let maskGeometry = self.maskNode?.geometry as! ARSCNFaceGeometry
        maskGeometry.update(from: faceAnchor.geometry)
    }
    
    private func createMask(faceGeometry: ARSCNFaceGeometry) -> SCNNode {
        let material = faceGeometry.firstMaterial!
        material.fillMode = .fill
        material.diffuse.contents = UIColor.white
        material.lightingModel = .physicallyBased
        
        let node = SCNNode(geometry: faceGeometry)
        return node
    }
}
