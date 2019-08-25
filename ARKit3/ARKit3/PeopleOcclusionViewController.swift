//
//  ViewController.swift
//  ARKit2Sharing
//
//  Created by Daniel Klein on 15.10.18.
//  Copyright © 2018 Daniel Klein. All rights reserved.
//

import UIKit
import SceneKit
import SceneKit.ModelIO
import ARKit

class PeopleOcclusionViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, ARCoachingOverlayViewDelegate {
    @IBOutlet var sceneView: ARSCNView!
        
    var worldConfiguration: ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            configuration.frameSemantics = [.personSegmentationWithDepth]
        }
                    
//        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentation) {
//            configuration.frameSemantics = [.personSegmentation]
//        }
                        
        return configuration
    }
    
//    private func togglePeopleOcclusion() {
//        guard let config = arView.session.configuration as? ARWorldTrackingConfiguration,
//            ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
//                fatalError("People occlusion is not supported on this device.")
//        }
//
//        switch config.frameSemantics {
//        case [.personSegmentationWithDepth]:
//            config.frameSemantics.remove(.personSegmentationWithDepth)
//            messageLabel.displayMessage("People occlusion off", duration: 1.0)
//        default:
//            config.frameSemantics.insert(.personSegmentationWithDepth)
//            messageLabel.displayMessage("People occlusion on", duration: 1.0)
//        }
//
//        arView.session.run(config)
//    }

    private func addCoachingView() {
        let coachingView = ARCoachingOverlayView()
        coachingView.session = sceneView.session
        coachingView.delegate = self
        //coachingView.activatesAutomatically = true
        coachingView.goal = .horizontalPlane
        self.sceneView.addSubview(coachingView)

        coachingView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            coachingView.centerXAnchor.constraint(equalToSystemSpacingAfter: self.view.centerXAnchor, multiplier: 1),
            coachingView.centerYAnchor.constraint(equalToSystemSpacingBelow: self.view.centerYAnchor, multiplier: 1)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(sceneTapped(_:)))
        self.sceneView.addGestureRecognizer(tapRecognizer)
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.debugOptions = [ .showFeaturePoints ]
        
        addCoachingView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneView.session.run(self.worldConfiguration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    @IBAction func sceneTapped(_ sender: UITapGestureRecognizer) {
        let hitTestResult = sceneView.hitTest(sender.location(in: sceneView), types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane])
        let firstResult = hitTestResult.first
        
        if let result = firstResult {
            let coffeeMugAnchor = ARAnchor(name: "Coffee Mug", transform: result.worldTransform)
            sceneView.session.add(anchor: coffeeMugAnchor)
        }
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARBodyAnchor {
            
            print("This is a body!")
            
        }
        
        guard anchor.name == "Coffee Mug" else { return }
        
        print("Adding: \(anchor)")
        
        let coffeeMugURL = Bundle.main.url(forResource: "CoffeeMug", withExtension: "dae")!
        let refNode = SCNReferenceNode(url: coffeeMugURL)!
        refNode.load()
        refNode.scale = SCNVector3(0.8, 0.8, 0.8)
        node.addChildNode(refNode)
    }
    
//    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        // 2D Bodies
//        if let body: ARBody2D = frame.detectedBody {
//            print("Body detected: \(body.skeleton.jointLandmarks)")
//        }
//    }
}
