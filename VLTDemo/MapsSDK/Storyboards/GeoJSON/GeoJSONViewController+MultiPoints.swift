//
//  GeoJSONViewController+MultiPoints.swift
//  VLTMapsDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import Foundation
import VLTMaps

// MARK: MultiPoint Marker Rendering
extension GeoJSONViewController {
    /// Show or hide the GeoJSON object that contains the point feature collection based on current settings (displays images on the map at designated point locations)
    func updatePointVisibility() {
        if let pointsVisible = featureVisibility[.marker], pointsVisible {
            addPointObjects()
        } else {
            removePointObjects()
        }
    }

    /// Creates a VLTMapGeoJSON object with the Point feature collection and displays it on the map
    func addPointObjects() {
        /// Ensure that the Point GeoJSON isn't already on the map
        guard pointGeoJSON == nil else { return }
        /// Generate a data object from the Mixed GeoJSON string
        guard let geoJSONData = multiPointImageGeoJSONData else { return }
        /// Create a style object with properties for the geoJSON object on the map
        let geoJSONStyle = VLTGeoJSONStyle(imageName: VLTMapObjectConstants.Defaults.markerImage.imageName)

        do {
            /// Register a VLTImage for use with Point objects
            try mapView.register(images: [VLTMapObjectConstants.Defaults.markerImage])
            /// Create a customized VLTMapGeoJSON object with properties for being displayed on the map
            let geoJSON = try VLTMapGeoJSON(data: geoJSONData, style: geoJSONStyle)
            /// Add the points GeoJSON Object to the map
            try mapView.add(object: geoJSON)
            /// Store a reference the geoJSON for future use
            self.pointGeoJSON = geoJSON
        } catch {
            /// If creating or adding GeoJSON to the map, display an error
            showError(withMessage: "\(GeoJsonVC.addMarkerErrorMessage): \(error)")
        }
    }

    /// Updates the points geoJSON objec on the map with different properties
    func updatePointObjects() {
        /// Ensure that there is a point geoJSON object to update and a marker to update it with
        guard let pointGeoJSON = pointGeoJSON, let customMarker = vltCustomImage else { return }

        do {
            let imageName = Bool.random() ? customMarker.imageName : VLTMapObjectConstants.Defaults.markerImage.imageName
            try mapView.register(images: [customMarker])
            /// Create a reference to the existing style
            let style = pointGeoJSON.style
            /// Update the properties of the existing style
            style.imageName = imageName

            /// Notify the map that the point geoJSON object needs to be updated
            try mapView.update(object: pointGeoJSON)
        } catch {
            /// If updating the geoJSON object fails, display an error
            showError(withMessage: "\(GeoJsonVC.updateMarkerErrorMessage): \(error)")
        }
    }

    /// Removes the Point GeoJSON object show on the map
    func removePointObjects() {
        /// Ensure that the point geoJSON object already exists on the map
        guard let pointGeoJSON = pointGeoJSON else { return }

        do {
            /// Remove the object from the map
            try mapView.remove(object: pointGeoJSON)
            /// Reset local point geoJSON instance
            self.pointGeoJSON = nil
        } catch {
            /// If removing geoJSON fails, display an error
            showError(withMessage: "\(GeoJsonVC.removeMarkerErrorMessage): \(error)")
        }
    }
}
