//
//  ShapesViewController+TrafficExamples.swift
//  VLTDemo
//
//  Created by Verizon Location Technology.
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import Foundation
import VLTMaps

/// Extension giving examples of how to interact with the traffic feature on the map
extension ShapesViewController {
    /// Update the visibility of the traffic layer on the map
    func updateTrafficVisibility() {
        do {
            if let trafficVisibility = featureVisibility[.traffic], trafficVisibility {
                /// Shows the traffic content of the map
                try mapView.toggleMapFeatures([.traffic], isHidden: false)
            } else {
                /// Hides the traffic content of the map
                try mapView.toggleMapFeatures([.traffic], isHidden: true)
            }
        } catch {
            /// Display an error to the user if updating the traffic visibility fails
            showError(withMessage: "\(literals.updateTrafficErrorMessage): \(error)")
        }
    }
}
