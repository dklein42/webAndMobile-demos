//
//  ViewController.swift
//  RealityKit
//
//  Created by Daniel Klein on 26.08.19.
//  Copyright © 2019 Daniel Klein. All rights reserved.
//

import UIKit
import RealityKit

class ViewController: UIViewController {
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the "Box" scene from the "Experience" Reality File
        let loadedBoxAnchor = try! Experience.loadBox()
        // load async!
        arView.scene.addAnchor(loadedBoxAnchor)

		let myScene = try! SomeStuff.loadSzene()
		//let burger = myScene.burger
		arView.scene.addAnchor(myScene)

		// Robot
		// let bodyAnchor = AnchorEntity(.body)
		// arView.scene.addAnchor(bodyAnchor)

		// let robot = try! BodyTrackedEntity.loadBodyTracked(named: "robot")
		// bodyAnchor.addChild(robot)

		// Plane Anchor
        let planeAnchor = AnchorEntity(plane: .horizontal/*, classification: .table*/, minimumBounds: [0.1, 0.1])

		// planeAnchor.addChild(burger!)

		// Box Shape
        let boxShape = MeshResource.generateBox(size: 0.1, cornerRadius: 0.01)
        let boxMaterial = SimpleMaterial(color: .purple, roughness: 0, isMetallic: true)
        let boxEntity = ModelEntity(mesh: boxShape, materials: [boxMaterial])
        boxEntity.position = [0, boxShape.bounds.extents.y/2, 0]
        boxEntity.generateCollisionShapes(recursive: false)
        boxEntity.physicsBody = PhysicsBodyComponent(massProperties: .init(mass: 1.0), mode: .dynamic)
        planeAnchor.addChild(boxEntity)

		// Text Shape
        let textShape = MeshResource.generateText("w&m")
        var textMaterial = SimpleMaterial()
        textMaterial.baseColor = try! .texture(.load(named: "yellow wall"))
        let textEntity = ModelEntity(mesh: textShape, materials: [textMaterial])
        
        // Removes entity from lightning, makes it glow
        textEntity.components.remove(DirectionalLightComponent.self)
        
        boxEntity.addChild(textEntity)
        textEntity.scale = [0.01, 0.01, 0.01]
        let textWidthHalf = textEntity.model!.mesh.bounds.extents.x/2 * textEntity.scale.x
        textEntity.position = [-textWidthHalf, 0.1, 0]
        
        boxEntity.generateCollisionShapes(recursive: true)

		// Cloned Box
        // let clonedBox = boxEntity.clone(recursive: true)
        // clonedBox.position = [-0.5, boxShape.bounds.extents.y/2, 0]
        // planeAnchor.addChild(clonedBox)
        
		// Half Recessed Object
        // let recessedBoxColor = SimpleMaterial(color: .orange, isMetallic: true)
        // let recessedBox = ModelEntity(mesh: boxShape, materials: [recessedBoxColor])
        // planeAnchor.addChild(recessedBox)
        // recessedBox.position = [0.1, 0, 0]
        
        // Occlusion Material
        let occlusionBox = MeshResource.generateBox(size: 0.5)
        //let occlusionPlaneMaterial = SimpleMaterial(color: .magenta, isMetallic: false)
        let occlusionPlaneMaterial = OcclusionMaterial()
        let occlusionEntity = ModelEntity(mesh: occlusionBox, materials: [occlusionPlaneMaterial])
        occlusionEntity.position = [0, -(occlusionBox.bounds.extents.y/2) + 0.001, 0]
        planeAnchor.addChild(occlusionEntity)
        
        // Gestures
        // self.arView.installGestures(.all, for: boxEntity)
        
        // Hit Testing -> Animate
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.arView.addGestureRecognizer(tapRecognizer)

        arView.scene.addAnchor(planeAnchor)
    }
    
    @objc func handleTap(_ sender: UIGestureRecognizer) {
        let pointInView = sender.location(in: self.arView)
        if let tappedEntity = self.arView.entity(at: pointInView) {
            if let tappedModelEntity = tappedEntity as? ModelEntity {
				// Apply Impulse
				tappedModelEntity.applyLinearImpulse([0, 2, 0], relativeTo: tappedModelEntity)

				// Play Sound
				// let pingSound = try! AudioFileResource.load(named: "ping")
				// tappedModelEntity.playAudio(pingSound)

				// Transform Animation
				// var newTransform = tappedEntity.transform
				// newTransform.scale.x *= 1.25
				// newTransform.scale.y *= 1.25
				// newTransform.scale.z *= 1.25
				// tappedEntity.move(to: newTransform, relativeTo: tappedEntity, duration: 1.0, timingFunction: .easeInOut)
			}
        }
    }
}
