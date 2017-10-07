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
    
    var urlPath = "http://192.241.200.251/arobject/"
    
    var param = ["lat": "37.8710434", "long": "-122.2507729", "alt": "10"]
    
    fileprivate let locationManager = CLLocationManager()
    
    // Fake date rn because we don't have data
    var mostRecentUserLocation: CLLocation? {
        didSet {
            print("LOADED USER LOCATION")
        }
    }
    
    // Put API call here
    // Parse JSON to targetArray?
    var targetNodes = [String: SCNNode]()
    
    lazy var bearObject: MDLObject = {
        let bearObjectURL = Bundle.main.url(forResource: "bear", withExtension: "obj")!
        return MDLAsset(url: bearObjectURL).object(at: 0)
    }()
    
    var targetArray: [Target] = [] {
        didSet {
            guard let userLocation = mostRecentUserLocation else {
                return
            }
            
            for target in targetArray {
                //update existing node if it exists
                if let existingNode = targetNodes[target.id] {
                    let move = SCNAction.move (
                        to: target.sceneKitCoordinate(relativeTo: userLocation),
                        duration: TimeInterval(5))
                    
                    existingNode.runAction(move)
                }
                    // otherwise, make a new node
                else {
                    let newNode = makeBearNode()
                    targetNodes[target.id] = newNode
                    
                    newNode.position = target.sceneKitCoordinate(relativeTo: userLocation)
                    sceneView.scene.rootNode.addChildNode(newNode)
                }
            }
        }
    }
    
    func processJson(text: String) {
        guard let targetData = text.toJSON() as? [[String: Any]] else {
            return
        }
        
        targetArray = targetData.map { target in
            let id = target["call"] as? String ?? "Unknown"
            let lat = target["lat"] as? Double ?? 0
            let long = target["lng"] as? Double ?? 0
            let alt = target["alt"] as? Double ?? 0
            
            let target = Target(
                id: id,
                lat: lat,
                long: long,
                alt: alt
                )
            
            return target
            }.filter { target in
                return (target.id != "Unknown")
        }
    }

    func makeBearNode() -> SCNNode {
        let node = SCNNode(mdlObject: bearObject)
        return node
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        let scene = SCNScene()
        sceneView.scene = scene

        // Comment next line once app is ready - good to check performance
        sceneView.showsStatistics = true
    }
    
    func buildQueryString(fromDictionary parameters: [String:String]) -> String {
        var urlVars:[String] = []
        
        for (k, value) in parameters {
            if let encodedValue = value.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed) {
                urlVars.append(k + "=" + encodedValue)
            }
        }
        return urlVars.isEmpty ? "" : "?" + urlVars.joined(separator: "&")
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        urlPath += buildQueryString(fromDictionary:param)
        let url = URL(string: urlPath)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        sceneView.session.run(configuration)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                print(json)
            }
        }
        
        task.resume()
        setUpLocationManager()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.
//    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//
//
//    }

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
        mostRecentUserLocation = locationManager.location
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

// MARK: - String Extension
extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}


