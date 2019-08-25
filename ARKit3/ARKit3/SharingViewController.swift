//
//  SharingViewController.swift
//  ARKit3
//
//  Created by Daniel Klein on 28.07.19.
//  Copyright © 2019 Daniel Klein. All rights reserved.
//

import UIKit
import SceneKit
import SceneKit.ModelIO
import ARKit

class SharingViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, MultipeerManagerDelegate {
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var stateLabel: UILabel!
    
    var multipeerManager: MultipeerManager!
    
    var worldConfiguration: ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        configuration.isCollaborationEnabled = true
        
        return configuration
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(sceneTapped(_:)))
        self.sceneView.addGestureRecognizer(tapRecognizer)
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.debugOptions = [ .showFeaturePoints ]

        self.multipeerManager = MultipeerManager(delegate: self)
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
        var coffeeMugAnchor: ARAnchor?

        if let query = sceneView.raycastQuery(from: sender.location(in: sceneView), allowing: .estimatedPlane, alignment: .horizontal) {
            let raycastResults = sceneView.session.raycast(query)
            if let firstResult = raycastResults.first {
                coffeeMugAnchor = ARAnchor(name: "Coffee Mug", transform: firstResult.worldTransform)
                sceneView.session.add(anchor: coffeeMugAnchor!)
            }
                        
//            let trackedRaycast = sceneView.session.trackedRaycast(query) { raycastResults in
//                if let firstResult = raycastResults.first {
//                    if let mugAnchor = coffeeMugAnchor {
//                        if let mugNode = self.sceneView.node(for: mugAnchor) {
//                            mugNode.transform = SCNMatrix4(firstResult.worldTransform)
//                        }
//                    }
//                }
//            }
            
            //trackedRaycast?.stopTracking()
        }
    }
    
    lazy var mapFileURL: URL = {
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("map.arexperience")
    }()
    
//    @IBAction func saveWorld() {
//        sceneView.session.getCurrentWorldMap { (worldMap, error) in
//            guard let worldMap = worldMap else { return }
//            let data = try! NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
//            try! data.write(to: self.mapFileURL, options: [.atomic])
//        }
//    }
    
//    @IBAction func loadWorld() {
//        guard let mapData = try? Data(contentsOf: mapFileURL) else { return }
//        let worldMap = try! NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: mapData)
//
//        let configuration = self.worldConfiguration
//        configuration.initialWorldMap = worldMap
//        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
//    }
    
//    @IBAction func shareSession() {
//        sceneView.session.getCurrentWorldMap { (worldMap, error) in
//            guard let worldMap = worldMap else { return }
//            let data = try! NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
//            self.multipeerManager.sendToAll(data)
//        }
//    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor.name == "Coffee Mug" else { return }
        
        print("Adding: \(anchor)")
        
        let coffeeMugURL = Bundle.main.url(forResource: "CoffeeMug", withExtension: "dae")!
        let refNode = SCNReferenceNode(url: coffeeMugURL)!
        refNode.load()
        refNode.scale = SCNVector3(0.8, 0.8, 0.8)
        node.addChildNode(refNode)
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        anchors.forEach { anchor in
            if anchor.sessionIdentifier == self.sceneView.session.identifier {
                print("My own anchor was added")
            }
            else {
                print("Another one's anchor was added: \(anchor)")
            }
        }
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        anchors.forEach { anchor in
            if anchor.sessionIdentifier == self.sceneView.session.identifier {
                print("My own anchor was removed")
            }
            else {
                print("Another one's anchor was removed")
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        anchors.forEach { anchor in
            if anchor.sessionIdentifier == self.sceneView.session.identifier {
                print("My own anchor was updated: \(anchor)")
            }
            else {
                print("Another one's anchor was updated: \(anchor)")
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        var state = ""
        
        switch frame.worldMappingStatus {
        case .notAvailable:
            state = "Not available"
        case .limited:
            state = "Limited"
        case .mapped:
            state = "Mapped"
        case .extending:
            state = "Extending"
        @unknown default:
            assert(false)
        }
        
        switch frame.camera.trackingState {
        case .limited(.relocalizing):
            state = "Relocalizing"
        default:
            break;
        }
        
        self.stateLabel.text = "Status: " + state
    }
    
    func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
        //print("Sending new collab data...")
        
        if let encodedCollabData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true) {
            multipeerManager.sendToAll(encodedCollabData)
        }
        else {
            assert(false)
        }
    }
    
    // MARK:- MultipeerManagerDelegate
    
    func dataReceived(_ data: Data, name: String) {
        print("New data received from: \(name)")
        
        if let collabData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARSession.CollaborationData.self, from: data) {
            self.sceneView.session.update(with: collabData)
        }
        else {
            assert(false)
        }
        
//        if let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) {
//            let configuration = self.bodyConfiguration
//            configuration.initialWorldMap = worldMap
//            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
//        }
//        else if let anchor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARAnchor.self, from: data) {
//            sceneView.session.add(anchor: anchor)
//        }
    }
}
