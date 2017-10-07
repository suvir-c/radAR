//
//  ViewController.swift
//  radAR
//
//  Created by Olivia Brown on 10/6/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation
import SceneKit
import ModelIO
import SceneKit.ModelIO

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    fileprivate let locationManager = CLLocationManager()
    
    var mostRecentUserLocation: CLLocation? {
        didSet {
            print("LOADED USER LOCATION")
        }
    }
    
    lazy var bearObject: MDLObject = {
        let bearObjectURL = Bundle.main.url(forResource: "bear", withExtension: "obj")!
        return MDLAsset(url: bearObjectURL).object(at: 0)
    }()

    func makeBearNode() -> SCNNode {
        let node = SCNNode(mdlObject: bearObject)
        return node
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        let scene = SCNScene()
        sceneView.scene = scene
        
        let bearNode = makeBearNode()
        
        sceneView.scene.rootNode.addChildNode(bearNode)

        // Comment next line once app is ready - good to check performance
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        sceneView.session.run(configuration)
        setUpLocationManager()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        let node = makeBearNode()
        
        node.position = SCNVector3(x: 0, y: 0, z: 0)
        node.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
    }

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

// MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    
    func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    // Updates location variable every time location changes
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mostRecentUserLocation = locations[0] as CLLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("\(error)")
    }
}

// MARK: - MDLMaterial
extension MDLMaterial {
    func setTextureProperties(textures: [MDLMaterialSemantic:String]) -> Void {
        for (key,value) in textures {
            guard let url = Bundle.main.url(forResource: value, withExtension: "") else {
                fatalError("Failed to find URL for resource \(value).")
            }
            let property = MDLMaterialProperty(name:value, semantic: key, url: url)
            self.setProperty(property)
        }
    }
}
