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

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, MultipeerManagerDelegate {
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var stateLabel: UILabel!

    var multipeerManager: MultipeerManager!
    
    var configuration: ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // configuration.environmentTexturing = .automatic
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
        sceneView.session.run(self.configuration, options: [.resetTracking, .removeExistingAnchors])
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
            
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: coffeeMugAnchor, requiringSecureCoding: true) {
                self.multipeerManager.sendToAll(data)
            }
        }
    }
    
    lazy var mapFileURL: URL = {
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("map.arexperience")
    }()
    
    @IBAction func saveWorld() {
        sceneView.session.getCurrentWorldMap { (worldMap, error) in
            guard let worldMap = worldMap else { return }
            let data = try! NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
            try! data.write(to: self.mapFileURL, options: [.atomic])
        }
    }
    
    @IBAction func loadWorld() {
        guard let mapData = try? Data(contentsOf: mapFileURL) else { return }
        let worldMap = try! NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: mapData)
        
        let configuration = self.configuration
        configuration.initialWorldMap = worldMap
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    @IBAction func shareSession() {
        sceneView.session.getCurrentWorldMap { (worldMap, error) in
            guard let worldMap = worldMap else { return }
            let data = try! NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
            self.multipeerManager.sendToAll(data)
        }
    }
    
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
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        var state: String
        
        switch frame.worldMappingStatus {
        case .notAvailable:
            state = "Not available"
        case .limited:
            state = "Limited"
        case .mapped:
            state = "Mapped"
        case .extending:
            state = "Extending"
        }
        
        switch frame.camera.trackingState {
        case .limited(.relocalizing):
            state = "Relocalizing"
        default:
            break;
        }
        
        self.stateLabel.text = "Status: " + state
    }
    
    // MARK:- MultipeerManagerDelegate
    
    func dataReceived(_ data: Data, name: String) {
        print("New data received from: \(name)")
        
        if let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) {
            let configuration = self.configuration
            configuration.initialWorldMap = worldMap
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }
        else if let anchor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARAnchor.self, from: data) {
            sceneView.session.add(anchor: anchor!)
        }
    }
}
