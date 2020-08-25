//
//  GeoJSONViewController+MixedFeatures.swift
//  VLTMapsDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import Foundation
import VLTMaps

// MARK: Mixed Feature Collection Rendering
extension GeoJSONViewController {
    /// Show or hide the GeoJSON object that contains the mixed feature collection based on current settings
    func updateMixedVisibility() {
        if let mixedVisible = featureVisibility[.mixed], mixedVisible {
            addMixedObjects()
        } else {
            removeMixedObjects()
        }
    }

    /// Creates a VLTMapGeoJSON object with the mixed feature collection and displays it on the map
    func addMixedObjects() {
        /// Ensure that the Mixed GeoJSON isn't already on the map
        guard mixedGeoJSON == nil else { return }
        /// Generate a data object from the Mixed GeoJSON string
        guard let geoJSONData = mixedGeoJSONData else { return }
        /// Create a style object with properties for the geoJSON object on the map
        let geoJSONStyle = VLTGeoJSONStyle(polygonFillColor: .cyan,
                                           polygonStrokeColor: .black,
                                           polygonFillOpacity: 0.5,
                                           polylineStrokeWidth: 15,
                                           polylineStrokeColor: .systemPink,
                                           polylineStrokeOpacity: 1,
                                           imageName: VLTMapObjectConstants.Defaults.markerImage.imageName)

        do {
            /// Register a VLTImage for use with Point objects
            try mapView.register(images: [VLTMapObjectConstants.Defaults.markerImage])
            /// Create a customized VLTMapGeoJSON object with properties for being displayed on the map
            let geoJSON = try VLTMapGeoJSON(data: geoJSONData, style: geoJSONStyle)
            /// Add the Mixed GeoJSON Object to the map
            try mapView.add(object: geoJSON)
            /// Store a reference the geoJSON for future use
            self.mixedGeoJSON = geoJSON
        } catch {
            /// If creating or adding GeoJSON to the map, display an error
            showError(withMessage: "\(literals.addMixedErrorMessage): \(error)")
        }
    }

    /// Updates the mixed geoJSON objec on the map with different properties
    func updateMixedObjects() {
        /// Ensure that there is a mixed geoJSON object to update
        guard let mixedGeoJSON = mixedGeoJSON, let customMarker = vltCustomImage else { return }

        do {
            let imageName = Bool.random() ? customMarker.imageName : VLTMapObjectConstants.Defaults.markerImage.imageName
            try mapView.register(images: [customMarker])
            /// Create a reference to the existing style
            let style = mixedGeoJSON.style
            /// Update the properties of the existing style
            style.polygonFillColor = .random
            style.polygonStrokeColor = .random
            style.polygonFillOpacity = .random(in: 0.5...1)
            style.polylineStrokeWidth = .random(in: 5...20)
            style.polylineStrokeColor = .random
            style.polylineStrokeOpacity = .random(in: 0.5...1)
            style.imageName = imageName

            /// Notify the map that the mixed geoJSON object needs to be updated
            try mapView.update(object: mixedGeoJSON)
        } catch {
            /// If updateing the geoJSON object fails, display an error
            showError(withMessage: "\(literals.updateMixedErrorMessage): \(error)")
        }
    }

    /// Removes the Mixed GeoJSON object show on the map
    func removeMixedObjects() {
        /// Ensure that the mixed geoJSON object already exists on the map
        guard let mixedGeoJSON = mixedGeoJSON else { return }

        do {
            /// Remove the object from the map
            try mapView.remove(object: mixedGeoJSON)
            /// Reset local mixed geoJSON instance
            self.mixedGeoJSON = nil
        } catch {
            /// If removing geoJSON fails, display an error
            showError(withMessage: "\(literals.removeMixedErrorMessage): \(error)")
        }
    }
}
