//
//  ViewController.swift
//  TrueDepthCamera
//
//  Created by Daniel Klein on 06.03.18.
//  Copyright © 2018 House of Bytes Software. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var smileyLabel: UILabel!
    
    var maskNode: SCNNode? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard ARFaceTrackingConfiguration.isSupported else {
            return
        }
        
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        let maskGeometry = ARSCNFaceGeometry(device: sceneView.device!)!
        self.maskNode = createMask(faceGeometry: maskGeometry)
        node.addChildNode(self.maskNode!)
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else {
            return
        }
        
        let maskGeometry = self.maskNode?.geometry as! ARSCNFaceGeometry
        maskGeometry.update(from: faceAnchor.geometry)
        
        updateSmiley(with: faceAnchor)
    }

    private func createMask(faceGeometry: ARSCNFaceGeometry) -> SCNNode {
        let material = faceGeometry.firstMaterial!
        material.fillMode = .fill
        // material.diffuse.contents = UIColor.white
        material.diffuse.contents = UIImage(named: "GermanFlags")
        material.lightingModel = .physicallyBased
        
        let node = SCNNode(geometry: faceGeometry)
        return node
    }

    private func updateSmiley(with faceAnchor: ARFaceAnchor) {
        let blendShapes = faceAnchor.blendShapes
        let funnel = blendShapes[.mouthFunnel]!.doubleValue > 0.4
        let pucker = blendShapes[.mouthPucker]!.doubleValue > 0.5
        let smileLeft = blendShapes[.mouthSmileLeft]!.doubleValue > 0.5
        let smileRight = blendShapes[.mouthSmileRight]!.doubleValue > 0.5
        let smile = smileLeft || smileRight
        
        //print("Current blend shapes are: \(blendShapes)")
        //print("Smile: \(smile) Funnel: \(funnel) Pucker: \(pucker)")
        
        var selectedSmiley = "🙂"
        
        if smile {
            selectedSmiley = "😀"
        }
        else if pucker {
            selectedSmiley = "😘"
        }
        else if funnel {
            selectedSmiley = "😮"
        }
        
        DispatchQueue.main.async {
            self.smileyLabel.text = selectedSmiley
        }
    }
}
