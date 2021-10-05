//
// CameraMetrics.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import Foundation

/// Contains a state of settings for the camera of a VLTMap
struct CameraMetrics {
    /// The amount that the camera has been zoomed into the map, where 0 is completely zoomed out and 20 is completely zoomed in
    let zoomLevel: Double
    /// The lateral angle of the camera, where 0 is facing north
    let bearing: Double
    /// The vertical angle of the camera, where 0 is along the zenith above center of the camera
    let tilt: Double

    /// Basic initializer for a CameraMetrics object
    /// - Parameters:
    ///   - zoomLevel: The amount that the camera has been zoomed into the map. Defaults to 20
    ///   - bearing: The lateral angle of the camera, based on geometric north. Defaults to 0
    ///   - tilt: The vertical angle of the camera, based on the zenith above the center of the map. Defaults to 0
    init(zoomLevel: Double = 20, bearing: Double = 0, tilt: Double = 0) {
        self.zoomLevel = zoomLevel
        self.bearing = bearing
        self.tilt = tilt
    }
}
