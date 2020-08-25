//
//  ShapesViewController+PolylineExamples.swift
//  VLTDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import UIKit
import VLTMaps
import CoreLocation

/// Extension giving examples of how to interact with VLTMapPolyline objects on the map
extension ShapesViewController {
    /// Show or hide a polyline based on current settings
    func updatePolylineVisibility() {
        if let polylineVisible = featureVisibility[.polyline], polylineVisible {
            addPolyline()
        } else {
            removePolyline()
        }
    }

    /// Creates a polyline and displays it on the map
    func addPolyline() {
        /// Ensure that the polyline isn't already on the map
        guard polyline == nil else { return }

        do {
            /// Create a custom polyline object with a title and subtitle that will display a callout when tapped
            let polyline = VLTMapPolyline(coordinates: polylineCoordinates,
                                          title: literals.polylineTitle,
                                          subtitle: literals.polylineSubtitle,
                                          showCallout: self.runListeners,
                                          strokeWidth: 5,
                                          strokeColor: .red)

            /// Add polyline to the map
            try mapView.add(object: polyline)
            /// Store a reference to the polyline for future use
            self.polyline = polyline

        } catch {
            /// If adding polyline to the map fails, display an error
            showError(withMessage: "\(literals.addPolylineErrorMessage): \(error)")
        }
    }

    /// Updates the polyline on the map with different colors and properties
    func updatePolyline() {
        /// Ensure that there is a polyline to update
        guard let polyline = polyline else { return }

        do {
            /// Create a reduced set of coordinates for the polyline to follow
            var newCoordinates = polylineCoordinates
            newCoordinates.removeLast(.random(in: 0...3))

            /// Update the list of coordinates comprising the polyline
            polyline.coordinates = newCoordinates

            /// Update the stroke color of the polyline
            polyline.strokeColor = .random
            /// Update the stroke width of the polyline
            polyline.strokeWidth = .random(in: 2...15)
            /// Update the title of the polyline with a new one
            polyline.title = Bool.random() ? "\(literals.polylineText) \(literals.shapeTitleUpdated)" : nil
            /// Update the subtitle of the circle with new ones
            polyline.subtitle = Bool.random() ? "\(literals.polylineText) \(literals.shapeSubtitleUpdated)" : nil
            /// Update whether or not the circle should display a callout when tapped
            polyline.showCallout = self.runListeners

            /// Notify the map to update the polyline
            try mapView.update(object: polyline)
        } catch {
            showError(withMessage: "\(literals.updatePolylineErrorMessage): \(error)")
        }
    }

    /// Removes the polyline shown on the map
    func removePolyline() {
        /// Ensure that the polyline is already on the map
        guard let polyline = polyline else { return }

        do {
            /// Remove the polyline from the map
            try mapView.remove(object: polyline)
            /// Reset the local instance of the polyline
            self.polyline = nil
        } catch {
            /// If removing polyline fails, throw an error
            showError(withMessage: "\(literals.removePolylineErrorMessage): \(error)")
        }
    }
}
