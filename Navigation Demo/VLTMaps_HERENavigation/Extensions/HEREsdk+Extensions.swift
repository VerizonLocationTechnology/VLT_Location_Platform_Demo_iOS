//
//  HEREsdk+Extensions.swift
//  VLTNavigationDemo
//
//  Created by Verizon Location Technology.
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import CoreLocation
import heresdk

extension Location {
    /// CoreLocation.CLLocation synonym to heresdk.Location object
    var clLocation: CLLocation {
        return CLLocation(
            coordinate: self.coordinates.clLocationCoordinate2D,
            altitude: self.coordinates.altitude ?? 0,
            horizontalAccuracy: self.horizontalAccuracyInMeters ?? 0,
            verticalAccuracy: self.verticalAccuracyInMeters ?? 0,
            course: self.bearingInDegrees ?? 0,
            speed: self.speedInMetersPerSecond ?? 0,
            timestamp: self.timestamp
        )
    }
}

extension GeoCoordinates {
    /// CoreLocation.CLLocationCoordinate2D synonym to heresdk.GeoCoordinates
    var clLocationCoordinate2D: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}

extension MapMatchedLocation {
    /// CoreLocation.CLLocation synonym to heresdk.MapMatchedLocation object
    var clLocation: CLLocation {
        return CLLocation(
            coordinate: self.coordinates.clLocationCoordinate2D,
            altitude: self.coordinates.altitude ?? 0,
            horizontalAccuracy: 0,
            verticalAccuracy: 0,
            course: self.bearingInDegrees ?? 0,
            speed: 0,
            timestamp: Date()
        )
    }
}
