//
// GeoJSONViewController+Polylines.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import Foundation
import VLTMaps

// MARK: Polyline Rendering
extension GeoJSONViewController {
    /// Show or hide the GeoJSON object that contains the polyline feature collection based on current settings
    func updatePolylineVisibility() {
        if let polylineVisible = featureVisibility[.polyline], polylineVisible {
            addPolylineObjects()
        } else {
            removePolylineObjects()
        }
    }

    /// Creates a VLTMapGeoJSON object with the polyline feature collection and displays it on the map
    func addPolylineObjects() {
        /// Ensure that the Mixed GeoJSON isn't already on the map
        guard polylineGeoJSON == nil else { return }
        /// Generate a data object from the Mixed GeoJSON string
        guard let geoJSONData = polylineGeoJSONData else { return }
        /// Create a style object with properties for the geoJSON object on the map
        let geoJSONStyle = VLTGeoJSONStyle(polylineStrokeWidth: 10, polylineStrokeColor: .systemBlue, polylineStrokeOpacity: 1.0)

        do {
            /// Create a customized VLTMapGeoJSON object with properties for being displayed on the map
            let geoJSON = try VLTMapGeoJSON(data: geoJSONData, style: geoJSONStyle)
            /// Add the polyline GeoJSON Object to the map
            try mapView.add(object: geoJSON)
            /// Store a reference the geoJSON for future use
            self.polylineGeoJSON = geoJSON
        } catch {
            /// If creating or adding GeoJSON to the map, display an error
            showError(withMessage: "\(GeoJsonVC.addPolylineErrorMessage): \(error)")
        }
    }

    /// Updates the mixed geoJSON objec on the map with different properties
    func updatePolylineObjects() {
        /// Ensure that there is a mixed geoJSON object to update
        guard let polylineGeoJSON = polylineGeoJSON else { return }

        do {
            /// Create a reference to the existing style
            let style = polylineGeoJSON.style
            /// Update the properties of the existing style
            style.polylineStrokeWidth = .random(in: 5...20)
            style.polylineStrokeColor = .random
            style.polylineStrokeOpacity = .random(in: 0.5...1)

            /// Notify the map that the mixed geoJSON object needs to be updated
            try mapView.update(object: polylineGeoJSON)
        } catch {
            /// If updateing the geoJSON object fails, display an error
            showError(withMessage: "\(GeoJsonVC.updatePolylineErrorMessage): \(error)")
        }
    }

    /// Removes the Mixed GeoJSON object show on the map
    func removePolylineObjects() {
        /// Ensure that the mixed geoJSON object already exists on the map
        guard let polylineGeoJSON = polylineGeoJSON else { return }

        do {
            /// Remove the object from the map
            try mapView.remove(object: polylineGeoJSON)
            /// Reset local polyline geoJSON instance
            self.polylineGeoJSON = nil
        } catch {
            /// If removing geoJSON fails, display an error
            showError(withMessage: "\(GeoJsonVC.removePolylineErrorMessage): \(error)")
        }
    }
}
