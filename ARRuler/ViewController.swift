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
            calculate()
        }
    }
    
    func calculate() {
        let start = points[points.count - 2].position
        let end = points[points.count - 1].position
        
        let distance = sqrt(pow(start.x - end.x, 2) + pow(start.y - end.y, 2) + pow(start.z - end.z, 2)) * 39.3701
        
        print("distance: \(String(format: "%.2f", distance)) inches")
    }

}
