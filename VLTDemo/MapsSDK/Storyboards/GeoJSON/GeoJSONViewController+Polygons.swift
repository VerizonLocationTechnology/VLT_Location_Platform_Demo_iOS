//
//  GeoJSONViewController+Polygons.swift
//  VLTMapsDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import Foundation
import VLTMaps

// MARK: Polygon Rendering
extension GeoJSONViewController {
    // MARK: - Polygon GeoJSON Objects
    /// Show or hide the GeoJSON object that contains the polygon feature collection based on current settings
    func updatePolygonVisibility() {
        if let polygonVisible = featureVisibility[.polygon], polygonVisible {
            addPolygonObjects()
        } else {
            removePolygonObjects()
        }
    }

    /// Creates a VLTMapGeoJSON object with the polygon feature collection and displays it on the map
    func addPolygonObjects() {
        /// Ensure that the Mixed GeoJSON isn't already on the map
        guard polygonGeoJSON == nil else { return }
        /// Generate a data object from the polygon GeoJSON string
        guard let geoJSONData = polygonGeoJSONData else { return }
        /// Create a style object with properties for the geoJSON object on the map
        let geoJSONStyle = VLTGeoJSONStyle(polygonFillColor: .yellow, polygonStrokeColor: .black, polygonFillOpacity: 0.75)

        do {
            /// Create a customized VLTMapGeoJSON object with properties for being displayed on the map
            let geoJSON = try VLTMapGeoJSON(data: geoJSONData, style: geoJSONStyle)
            /// Add the polygon GeoJSON Object to the map
            try mapView.add(object: geoJSON)
            /// Store a reference the geoJSON for future use
            self.polygonGeoJSON = geoJSON
        } catch {
            /// If creating or adding GeoJSON to the map, display an error
            showError(withMessage: "\(literals.addPolygonErrorMessage): \(error)")
        }
    }

    /// Updates the polygon geoJSON object on the map with different properties
    func updatePolygonObjects() {
        /// Ensure that there is a polygon geoJSON object to update
        guard let polygonGeoJSON = polygonGeoJSON else { return }

        do {
            /// Create a reference to the existing style
            let style = polygonGeoJSON.style
            /// Update the properties of the existing style
            style.polygonFillColor = .random
            style.polygonStrokeColor = .random
            style.polygonFillOpacity = .random(in: 0.5...1)

            /// Notify the map that the polygon geoJSON object needs to be updated
            try mapView.update(object: polygonGeoJSON)
        } catch {
            /// If updating the geoJSON object fails, display an error
            showError(withMessage: "\(literals.updatePolygonErrorMessage): \(error)")
        }
    }

    /// Removes the polygon geoJSON object show on the map
    func removePolygonObjects() {
        /// Ensure that the polygon geoJSON object already exists on the map
        guard let polygonGeoJSON = polygonGeoJSON else { return }

        do {
            /// Remove the object from the map
            try mapView.remove(object: polygonGeoJSON)
            /// Reset local polygon instance
            self.polygonGeoJSON = nil
        } catch {
            /// If removing geoJSON fails, display an error
            showError(withMessage: "\(literals.removePolygonErrorMessage): \(error)")
        }
    }
}
