//
//  CameraMetricsControllerDelegate.swift
//  VLTDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import Foundation

/// Protocol description for the delegate of the CameraMetricsViewController
protocol CameraMetricsControllerDelegate: AnyObject {
    /// Updates the delegate to the new state of a CameraMetrics object
    /// - Parameters:
    ///   - cameraMetrics: The new metrics state to be updated to
    func update(_ cameraMetrics: CameraMetrics)
}
