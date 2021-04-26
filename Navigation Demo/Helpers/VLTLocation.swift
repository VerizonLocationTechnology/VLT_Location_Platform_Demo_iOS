//
// VLTLocation.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import CoreLocation
import heresdk
import UIKit

/// Generic minimum location bits needed to run the demo
class VLTLocation {
    // MARK: - Read only variables
    /// Name for the location
    private(set) var name: String
    /// Coordinate point for the location
    private(set) var coordinate: CLLocationCoordinate2D
    /// Distance between this location and the initial search location (likely the user's current location)
    private(set) var distanceFromSearchPoint: CLLocationDistance?
    /// Local address for the location
    private(set) var address: String?
    /// Indicator of whether or not this location is the current location of the user
    private(set) var isCurrentLocation: Bool

    // MARK: - Initializers

    /// Initializing method
    /// - Parameters:
    ///   - named: Name for the location
    ///   - coordinate: Coordinate point for the location on a map
    ///   - distanceFromSearchPoint: Distance between this location and the initial search location
    ///   - address: Local address for the location
    ///   - isCurrentLocation: Indicates whether or not this location is the user's current location
    init(named name: String,
         coordinate: CLLocationCoordinate2D,
         distanceFromSearchPoint: CLLocationDistance? = nil,
         address: String? = nil,
         isCurrentLocation: Bool = false) {
        self.name = name
        self.coordinate = coordinate
        self.address = address
        self.distanceFromSearchPoint = distanceFromSearchPoint
        self.isCurrentLocation = isCurrentLocation
    }

    // MARK: - Functions
    /// Update the coordinate use for this location
    /// - Parameter coordinate: The new coordinate point for this location
    func setCoordinate(_ coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
