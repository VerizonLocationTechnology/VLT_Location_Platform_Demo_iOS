//
//  ShapesViewController+PolygonExamples.swift
//  VLTDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import UIKit
import VLTMaps
import CoreLocation

/// Extension giving examples of how to interact with VLTMapPolygon objects on the map
extension ShapesViewController {
    /// Show or hide a polygon based on current settings
    func updatePolygonVisibility() {
        if let polygonVisible = featureVisibility[.polyline], polygonVisible {
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
                                        title: literals.polygonTitle,
                                        subtitle: literals.polygonSubtitle,
                                        shouldCallout: true,
                                        fillColor: .orange,
                                        strokeWidth: 4,
                                        strokeColor: .white)
            
            /// Add the polygon to the map
            try mapView.add(object: polygon)
            /// Store a reference to the polygon for future use
            self.polygon = polygon
            
        } catch {
            /// If adding polygon to the map fails, display an error
            showError(withMessage: "\(literals.addPolygonErrorMessage): \(error)")
        }
    }
    
    /// Updates the polygon on the map with different colors and properties
    func updatePolygon() {
        /// Ensure that there is a polygon to update
        guard let polygon = polygon else { return }
        
        do {
            /// Create a reduced set of coordinates for the polygon to encompass
            var newCoordinates = polylineCoordinates
            newCoordinates.removeLast(.random(in: 1...4))
            
            /// Update the list of coordinates comprising the polygon
            polygon.coordinates = newCoordinates
            
            /// Update the stroke color of the polygon
            polygon.strokeColor = .random
            /// Update the fill color of the polygon
            polygon.fillColor = .random
            /// Update the title of the polygon with new ones
            polygon.title = Bool.random() ? "\(literals.polylineText) \(literals.shapeTitleUpdated)" : nil
            /// Update the subtitle of the polygon with new ones
            polygon.subtitle = Bool.random() ? "\(literals.polylineText) \(literals.shapeSubtitleUpdated)" : nil
            /// Update whether or not the polygon should display a callout when tapped
            polygon.shouldCallout = .random()
            
            /// Notify the map that the polygon needs to be updated
            try mapView.update(object: polygon)
        } catch {
            /// If updating the polygon fails, display an error
            showError(withMessage: "\(literals.updatePolygonErrorMessage): \(error)")
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
            showError(withMessage: "\(literals.removePolygonErrorMessage): \(error)")
        }
    }
}
