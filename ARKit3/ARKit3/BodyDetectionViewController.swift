//
//  BodyDetectionViewController.swift
//  ARKit3
//
//  Created by Daniel Klein on 28.07.19.
//  Copyright © 2019 Daniel Klein. All rights reserved.
//

import UIKit
import SceneKit
import SceneKit.ModelIO
import ARKit

class LineView: UIView {
    var color: UIColor = UIColor.green
    
    var pointOne: CGPoint = CGPoint.zero {
        didSet {
            self.setNeedsDisplay()
            
        }
    }
    
    var pointTwo: CGPoint = CGPoint.zero {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not available")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let superview = superview else {return}
        self.frame = CGRect(x: 0, y: 0, width: superview.bounds.width, height: superview.bounds.height)
    }
    
    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            context.setStrokeColor(color.cgColor)
            context.setLineWidth(3)
            
            context.beginPath()
            context.move(to: pointOne)
            context.addLine(to: pointTwo)
            context.strokePath()
        }
    }
}

class BodyDetectionViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    @IBOutlet var sceneView: ARSCNView!
    
    static let frame = CGRect(x: 0, y: 0, width: 10, height: 10)
    let hipView = UIView(frame: frame)
    let leftHandView = UIView(frame: frame)
    let rightHandView = UIView(frame: frame)
    let headView = UIView(frame: frame)
    let leftFootView = UIView(frame: frame)
    let rightFootView = UIView(frame: frame)
    let leftShoulderView = UIView(frame: frame)
    let rightShoulderView = UIView(frame: frame)

    let leftHandToShoulderLine = LineView()
    let rightHandToShoulderLine = LineView()
    let headToHipLine = LineView()
    let hipToLeftFootLine = LineView()
    let hipToRightFootLine = LineView()
    let leftShoulderToRightShoulderLine = LineView()

    var bodyConfiguration: ARBodyTrackingConfiguration {
        guard ARBodyTrackingConfiguration.isSupported else {
            fatalError("Body tracking not supported!")
        }
        
        let configuration = ARBodyTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        return configuration
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.debugOptions = [ .showFeaturePoints ]
                
        hipView.backgroundColor = .red
        leftHandView.backgroundColor = .red
        rightHandView.backgroundColor = .red
        headView.backgroundColor = .red
        leftFootView.backgroundColor = .red
        rightFootView.backgroundColor = .red
        leftShoulderView.backgroundColor = .red
        rightShoulderView.backgroundColor = .red

        self.sceneView.addSubview(leftHandToShoulderLine)
        self.sceneView.addSubview(rightHandToShoulderLine)
        self.sceneView.addSubview(headToHipLine)
        self.sceneView.addSubview(hipToLeftFootLine)
        self.sceneView.addSubview(hipToRightFootLine)
        self.sceneView.addSubview(leftShoulderToRightShoulderLine)

        self.sceneView.addSubview(hipView)
        self.sceneView.addSubview(leftHandView)
        self.sceneView.addSubview(rightHandView)
        self.sceneView.addSubview(headView)
        self.sceneView.addSubview(leftFootView)
        self.sceneView.addSubview(rightFootView)
        self.sceneView.addSubview(leftShoulderView)
        self.sceneView.addSubview(rightShoulderView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneView.session.run(self.bodyConfiguration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let body = frame.detectedBody else { return }
        let skeleton = body.skeleton
        
        hipView.center = scaleToViewCoordinates(skeleton.landmark(for: .root))
        leftHandView.center = scaleToViewCoordinates(skeleton.landmark(for: .leftHand))
        rightHandView.center = scaleToViewCoordinates(skeleton.landmark(for: .rightHand))
        headView.center = scaleToViewCoordinates(skeleton.landmark(for: .head))
        leftFootView.center = scaleToViewCoordinates(skeleton.landmark(for: .leftFoot))
        rightFootView.center = scaleToViewCoordinates(skeleton.landmark(for: .rightFoot))
        leftShoulderView.center = scaleToViewCoordinates(skeleton.landmark(for: .leftShoulder))
        rightShoulderView.center = scaleToViewCoordinates(skeleton.landmark(for: .rightShoulder))
        
        leftHandToShoulderLine.pointOne = leftHandView.center
        leftHandToShoulderLine.pointTwo = leftShoulderView.center
        rightHandToShoulderLine.pointOne = rightHandView.center
        rightHandToShoulderLine.pointTwo = rightShoulderView.center
        headToHipLine.pointOne = headView.center
        headToHipLine.pointTwo = hipView.center
        hipToLeftFootLine.pointOne = hipView.center
        hipToLeftFootLine.pointTwo = leftFootView.center
        hipToRightFootLine.pointOne = hipView.center
        hipToRightFootLine.pointTwo = rightFootView.center
        leftShoulderToRightShoulderLine.pointOne = leftShoulderView.center
        leftShoulderToRightShoulderLine.pointTwo = rightShoulderView.center
    }
    
    private func scaleToViewCoordinates(_ normalizedCoordinates: SIMD2<Float>?) -> CGPoint {
        guard let normalizedCoordinates = normalizedCoordinates else {
            return self.sceneView.center
        }

        guard !normalizedCoordinates.x.isNaN && !normalizedCoordinates.y.isNaN else {
            return CGPoint.zero
        }

        let x = CGFloat(normalizedCoordinates.x) * self.sceneView.frame.width
        let y = CGFloat(normalizedCoordinates.y) * self.sceneView.frame.height
        return CGPoint(x: x, y: y)
    }
}
