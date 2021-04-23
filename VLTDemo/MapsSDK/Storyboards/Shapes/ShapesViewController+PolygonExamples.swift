//
//  ShapesViewController+PolygonExamples.swift
//  VLTDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import CoreLocation
import UIKit
import VLTMaps

/// Extension giving examples of how to interact with VLTMapPolygon objects on the map
extension ShapesViewController {
    /// Show or hide a polygon based on current settings
    func updatePolygonVisibility() {
        if let polygonVisible = featureVisibility[.polygon], polygonVisible {
            addPolygon()
        } else {
            removePolygon()
        }
    }

    /// Creates a polygon and displays it on the map
    func addPolygon() {
        /// Ensure that the polygon isn't already on the map
        guard polygon == nil else { return }

        do {
            /// Create a customized VLTMapPolygon object with a title and subtitle that displays a callout when the polygon is tapped on the map
            let polygon = VLTMapPolygon(coordinates: polygonCoordinates,
                                        title: VCLiterals.polygonTitle,
                                        subtitle: VCLiterals.polygonSubtitle,
                                        showCallout: self.runListeners,
                                        fillColor: .orange,
                                        strokeColor: .white)

            /// Add the polygon to the map
            try mapView.add(object: polygon)
            /// Store a reference to the polygon for future use
            self.polygon = polygon
        } catch {
            /// If adding polygon to the map fails, display an error
            showError(withMessage: "\(VCLiterals.addPolygonErrorMessage): \(error)")
        }
    }

    /// Updates the polygon on the map with different colors and properties
    func updatePolygon() {
        /// Ensure that there is a polygon to update
        guard let polygon = polygon else { return }

        do {
            /// Create a reduced set of coordinates for the polygon to encompass
            var newCoordinates = polygonCoordinates
            newCoordinates.removeLast(.random(in: 1...3))

            /// Update the list of coordinates comprising the polygon
            polygon.coordinates = newCoordinates

            /// Update the stroke color of the polygon
            polygon.strokeColor = .random
            /// Update the fill color of the polygon
            polygon.fillColor = .random
            /// Update the title of the polygon with new ones
            polygon.title = Bool.random() ? "\(VCLiterals.polygonText) \(VCLiterals.shapeTitleUpdated)" : nil
            /// Update the subtitle of the polygon with new ones
            polygon.subtitle = Bool.random() ? "\(VCLiterals.polygonText) \(VCLiterals.shapeSubtitleUpdated)" : nil
            /// Update whether or not the polygon should display a callout when tapped
            polygon.showCallout = self.runListeners

            /// Notify the map that the polygon needs to be updated
            try mapView.update(object: polygon)
        } catch {
            /// If updating the polygon fails, display an error
            showError(withMessage: "\(VCLiterals.updatePolygonErrorMessage): \(error)")
        }
    }

    /// Removes the polygon shown on the map
    func removePolygon() {
        /// Ensure that the polygon already exists on the map
        guard let polygon = polygon else { return }

        do {
            /// Remove the polygon from the map
            try mapView.remove(object: polygon)
            /// Reset local polygon instance
            self.polygon = nil
        } catch {
            /// If removing polygon fails, throw an error
            showError(withMessage: "\(VCLiterals.removePolygonErrorMessage): \(error)")
        }
    }
}
