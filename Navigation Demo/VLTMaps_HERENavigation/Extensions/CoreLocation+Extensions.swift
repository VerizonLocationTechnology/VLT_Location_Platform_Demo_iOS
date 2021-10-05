//
// CLLocation+Extensions.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import CoreLocation
import heresdk

extension CLLocationCoordinate2D {
    /// Heresdk.GeoCoordinates synonym to CoreLocation.CLLocationCoordinate2D
    var geoCoordinates: GeoCoordinates {
        return GeoCoordinates(latitude: self.latitude, longitude: self.longitude)
    }
}

extension CLLocation {
    /// Heresdk.Location synomym to CoreLocation.CLLocation
    var location: Location {
         Location(
             coordinates: GeoCoordinates(
                 latitude: self.coordinate.latitude,
                 longitude: self.coordinate.longitude,
                 altitude: self.altitude),
             bearingInDegrees: self.course,
             speedInMetersPerSecond: self.speed,
             timestamp: self.timestamp,
             horizontalAccuracyInMeters: self.horizontalAccuracy,
             verticalAccuracyInMeters: self.verticalAccuracy
         )
    }

    /// Method to calculate the proper course/bearing if needed.
    /// - Parameter destination: Location to get course/bearing to
    /// - Returns: New CLocation with the proper course to the destination
    public func withCourse(to destination: CLLocation) -> CLLocation {
        let lat1 = .pi * coordinate.latitude / 180.0
        let long1 = .pi * coordinate.longitude / 180.0
        let lat2 = .pi * destination.coordinate.latitude / 180.0
        let long2 = .pi * destination.coordinate.longitude / 180.0

        let rads = atan2(
            sin(long2 - long1) * cos(lat2),
            cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(long2 - long1))
        let degrees = rads * 180 / Double.pi
        let newCourse = (degrees + 360).truncatingRemainder(dividingBy: 360)
        if #available(iOS 13.4, *) {
            return CLLocation(coordinate: destination.coordinate,
                              altitude: destination.altitude,
                              horizontalAccuracy: destination.horizontalAccuracy,
                              verticalAccuracy: destination.verticalAccuracy,
                              course: newCourse,
                              courseAccuracy: 1,
                              speed: destination.speed,
                              speedAccuracy: destination.speedAccuracy,
                              timestamp: destination.timestamp)
        } else {
           return CLLocation(coordinate: destination.coordinate,
                             altitude: destination.altitude,
                             horizontalAccuracy: destination.horizontalAccuracy,
                             verticalAccuracy: destination.verticalAccuracy,
                             course: newCourse,
                             speed: destination.speed,
                             timestamp: destination.timestamp)
        }
    }
}
