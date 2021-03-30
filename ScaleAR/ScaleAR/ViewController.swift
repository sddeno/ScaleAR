//
//  ViewController.swift
//  AR Ruler
//
//  Created by shubham on 11/05/20.
//  Copyright © 2020 Shubham Deshmukh. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var textNode = SCNNode()
    var dotNodes = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    // MARK:- Detect User Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // remove node for new session.
        if dotNodes.count >= 2{
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first{
                addDot(at: hitResult)
            }
        }
    }
    // MARK:- Add child node at vertices
    func addDot(at hitResult: ARHitTestResult) {
        
        let dotGeometry = SCNSphere(radius: 0.005)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        
        dotNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x,
                                      y: hitResult.worldTransform.columns.3.y,
                                      z: hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    // MARK:- Calculate Distnace using Pythagoras Theorem d = √a sq + b sq + c sq
    func calculate(){
        
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        print("Start: \(start), end: \(end)")
        
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let c = end.position.z - start.position.z
        
        
        let distance = sqrt(pow(2,a) + pow(2,b) + pow(2,c))
        
        print(abs(distance))
        
        updateText(Text: "\(abs(distance)) meters", atPosition: end.position)
    }
    
    
    // MARK:- Updating Distance in AR Space
    func updateText(Text: String, atPosition position: SCNVector3) {
        
        textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: Text, extrusionDepth: 1.0)
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.systemOrange
        
        textNode = SCNNode(geometry: textGeometry)
        
        textNode.position = SCNVector3(x: position.x, y: position.y, z: position.z)
        
        textNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
}
