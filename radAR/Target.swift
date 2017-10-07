//
//  Target.swift
//  radAR
//
//  Created by Olivia Brown on 10/7/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import Foundation
import CoreLocation
import SceneKit

struct Target {
    // long, lat, alt
    
    let long: Double
    let lat: Double
    let alt: Double
    
    init(lat: Double, long: Double, alt: Double) {
        self.lat = lat
        self.long = long
        self.alt = alt
    }

func sceneKitCoordinate(relativeTo userLocation: CLLocation) -> SCNVector3 {
    let distance = location.distance(from: userLocation)
    let heading = userLocation.coordinate.getHeading(toPoint: location.coordinate)
    let headingRadians = heading * (.pi/180)
    
    let distanceScale: Double = 1/140
    let eastWestOffset = distance * sin(headingRadians) * distanceScale
    let northSouthOffset = distance * cos(headingRadians)  * distanceScale
    
    let altitudeScale: Double = 1/140 //1/20
    let upDownOffset = alt * altitudeScale
    
    //in .gravityAndHeading, (1, 1, 1) is (east, up, south)
    return SCNVector3(eastWestOffset, upDownOffset, -northSouthOffset)
}
    
    var location: CLLocation {
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        return CLLocation(
            coordinate: coordinate,
            altitude: alt,
            horizontalAccuracy: 1,
            verticalAccuracy: 1,
            timestamp: Date()
        )
    }

}

// MARK: CLLocation Coordinate Heading

extension CLLocationCoordinate2D {
    
    func getHeading(toPoint point: CLLocationCoordinate2D) -> Double {
        func degreesToRadians(_ degrees: Double) -> Double { return degrees * .pi / 180.0 }
        func radiansToDegrees(_ radians: Double) -> Double { return radians * 180.0 / .pi }
        
        let lat1 = degreesToRadians(latitude)
        let lon1 = degreesToRadians(longitude)
        
        let lat2 = degreesToRadians(point.latitude);
        let lon2 = degreesToRadians(point.longitude);
        
        let dLon = lon2 - lon1;
        
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x);
        
        return radiansToDegrees(radiansBearing)
    }
}
