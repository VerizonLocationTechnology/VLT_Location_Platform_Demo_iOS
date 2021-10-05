//
// ShapesViewController+TrafficExamples.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import Foundation
import VLTMaps

/// Extension giving examples of how to interact with the traffic feature on the map
extension ShapesViewController {
    /// Update the visibility of the traffic flow layer on the map
    func updateTrafficFlowVisibility() {
        do {
            if let trafficVisibility = featureVisibility[.trafficFlow], trafficVisibility {
                /// Shows the traffic flow content of the map
                try mapView.toggleMapFeatures([.traffic], isHidden: false)
            } else {
                /// Hides the traffic flow content of the map
                try mapView.toggleMapFeatures([.traffic], isHidden: true)
            }
        } catch {
            /// Display an error to the user if updating the traffic visibility fails
            showError(withMessage: "\(VCLiterals.updateTrafficFlowErrorMessage): \(error)")
        }
    }

    /// Update the visibility of the traffic incidents layer on the map
    func updateTrafficIncidentVisibility() {
        do {
            if let incidentVisibility = featureVisibility[.trafficIncidents], incidentVisibility {
                /// Shows the traffic incident content of the map
                try mapView.toggleMapFeatures([.incidents], isHidden: false)
            } else {
                /// Hides the traffic incident content of the map
                try mapView.toggleMapFeatures([.incidents], isHidden: true)
            }
        } catch {
            /// Display an error to the user if updating the traffic visibility fails
            showError(withMessage: "\(VCLiterals.updateTrafficIncidentMessage): \(error)")
        }
    }
}
