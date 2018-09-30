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

class Tracking3DViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!
    
    let sceneKitQueue = DispatchQueue(label: "SceneKitQueue")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints

        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        configuration.detectionObjects = ARReferenceObject.referenceObjects(inGroupNamed: "3D Objects", bundle: nil)!
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let objectAnchor = anchor as? ARObjectAnchor else { return }
        let referenceObject = objectAnchor.referenceObject

        print("Recognized: \(referenceObject)")
        
        self.sceneKitQueue.async {
            let text = SCNText(string: "Dog", extrusionDepth: 0)
            text.firstMaterial!.diffuse.contents = UIColor.gray
            let textNode = SCNNode(geometry: text)
            textNode.scale = SCNVector3(0.01, 0.01, 0.01)
            textNode.position.y += referenceObject.extent.y + 0.05

            // Center text
            let (min, max) = textNode.boundingBox
            let dx = min.x + 0.5 * (max.x - min.x)
            let dy = min.y + 0.5 * (max.y - min.y)
            let dz = min.z + 0.5 * (max.z - min.z)
            textNode.pivot = SCNMatrix4MakeTranslation(dx, dy, dz)
            
            node.addChildNode(textNode)
        }
    }
}
