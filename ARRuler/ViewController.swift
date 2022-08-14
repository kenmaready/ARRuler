//
//  ViewController.swift
//  ARRuler
//
//  Created by Ken Maready on 8/14/22.
//

import UIKit
import SceneKit
import ARKit

struct Line {
    var start: SCNNode
    var end: SCNNode?
    var distance: Float {
        get {
            return 3.14
        }
    }
}

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var points = [SCNNode]()
    var start: SCNVector3 {
        get {
            points[points.count - 2].position
        }
    }
    
    var end: SCNVector3 {
        get {
            points[points.count - 1].position
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad() 
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // get location of touch
        if let touchLocation = touches.first?.location(in: sceneView) {
            
            if let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .any) {
                
                let hitTestResults = sceneView.session.raycast(query)
                
                if let hitResult = hitTestResults.first {
                    addDot(at: hitResult)
                }
            }
        }
    }
    
    func addDot(at location: ARRaycastResult) {
        let pointGeometry = SCNSphere(radius: 0.01)
        
        let pink = SCNMaterial()
        pink.diffuse.contents = UIColor.systemPink
        pointGeometry.materials = [pink]
        
        let info = location.worldTransform.columns.3
        
        let locationVector = SCNVector3(
            x: info.x,
            y: info.y,
            z: info.z
        )
        
        let point = SCNNode(geometry: pointGeometry)
        point.position = locationVector
        
        sceneView.scene.rootNode.addChildNode(point)
        points.append(point)
        
        if points.count >= 2 {
            let distance = calculate()
            displayDistance(distance)
        }
    }
    
    func calculate() -> Float {
        
        func sqrd(_ x: Float) -> Float {
            return pow(x, 2)
        }
        
        let distance = sqrt(sqrd(start.x - end.x) + sqrd(start.y - end.y) + sqrd(start.z - end.z)) * 39.3701
        
        return distance
    }
    
    func displayDistance(_ distance: Float) {
        let distanceText = String(format: "%.2f", distance) + " inches"
        // print("distance: \(distanceText) inches")
        let textGeometry = SCNText(string: distanceText, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.systemBlue
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(end.x - 0.15, end.y + 0.02, end.z)
        textNode.scale = SCNVector3(0.003, 0.003, 0.003)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}
