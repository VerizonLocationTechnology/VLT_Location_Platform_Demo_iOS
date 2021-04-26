//
//  ShapesViewController+MarkerExamples.swift
//  VLTDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import CoreLocation
import UIKit
import VLTMaps

/// Extension giving examples of how to interact with VLTMapMarker objects on the map
extension ShapesViewController {
    /// Show or hide markers based on current settings
    func updateMarkerVisibility() {
        if let markersVisible = featureVisibility[.marker], markersVisible {
            addMarkers()
        } else {
            removeMarkers()
        }
    }

    /// Creates a series of markers with varying traits and displays them on the map
    func addMarkers() {
        /// Ensure that markers aren't already on the map
        guard markers.isEmpty else { return }

        do {
            /// A basic marker that will have a title and subtitle, and display a callout when tapped
            let marker1 = VLTMapMarker(coordinate: CLLocationCoordinate2D(latitude: 42.3637,
                                                                          longitude: -71.053_604),
                                       title: VCLiterals.marker1Title,
                                       subtitle: VCLiterals.marker1Subtitle,
                                       showCallout: self.runListeners)
            /// Add the marker to the map
            try mapView.add(object: marker1)
            /// Store a reference to the marker for future use
            markers.append(marker1)

            /// A basic marker that will have a title and subtitle, and will not display a callout when tapped
            let marker2 = VLTMapMarker(coordinate: CLLocationCoordinate2D(latitude: 42.356_11,
                                                                          longitude: -71.065_944),
                                       title: VCLiterals.marker2Title,
                                       subtitle: VCLiterals.marker2Subtitle,
                                       showCallout: self.runListeners)
            /// Add the marker to the map
            try mapView.add(object: marker2)
            /// Store a reference to the marker for future use
            markers.append(marker2)

            /// A basic marker that has just a title, and will display a callout when tapped
            let marker3 = VLTMapMarker(coordinate: CLLocationCoordinate2D(latitude: 42.374_106,
                                                                          longitude: -71.055_37),
                                       title: VCLiterals.marker3Title,
                                       showCallout: self.runListeners)
            try mapView.add(object: marker3)
            /// Store a reference to the marker for future use
            markers.append(marker3)

            /// Create a basic marker that will not show a callout when tapped
            let marker4 = VLTMapMarker(coordinate: CLLocationCoordinate2D(latitude: 42.358_744,
                                                                          longitude: -71.057_403))
            /// Add the marker to the map
            try mapView.add(object: marker4)
            /// Store a reference to the marker for future use
            markers.append(marker4)

            /// Create a marker with a custom image, title, and subtitle, that will show a callout when tapped
            if let customImage = UIImage(named: VLTLiterals.AssetNameLiterals.customDestinationImage) {
                /// Create a VLTImage object using the custom UIImage
                let customImage = VLTImage(image: customImage, imageName: VLTLiterals.AssetNameLiterals.customDestinationImage)
                vltCustomImage = customImage
                /// Create the marker with the custom image and other optional properties
                let marker5 = VLTMapMarker(coordinate: CLLocationCoordinate2D(latitude: 42.376_331,
                                                                              longitude: -71.060_757),
                                           image: customImage,
                                           title: VCLiterals.marker5Title,
                                           subtitle: VCLiterals.marker5Subtitle,
                                           showCallout: self.runListeners)
                /// Add the marker to the map
                try mapView.add(object: marker5)
                /// Store a reference to the marker for future use
                markers.append(marker5)
            }
        } catch {
            /// If adding markers to the map fails, display an error
            showError(withMessage: "\(VCLiterals.addMarkerErrorMessage): \(error)")
        }
    }

    /// Updates all markers on the map with different colors and properties
    func updateMarkers() {
        /// Ensure that there are markers to update, and that a custom image has been generated
        guard !markers.isEmpty, let customImage = vltCustomImage else { return }
        do {
            for (index, marker) in markers.enumerated() {
                /// Update the image of the marker with a new one
                if marker.image == vltCustomImage {
                    // TODO:Need to fix this at some point
                    // marker.image =  VLTMaps.VLTShapeFilte VLTMaps.ShapeConstants.Defaults.markerImage
                } else {
                    marker.image = customImage
                }

                /// Update the title of the marker with new ones
                marker.title = Bool.random() ? "\(VCLiterals.markerText) \(index) \(VCLiterals.shapeTitleUpdated)" : nil
                /// Update the subtitle of the marker with new ones
                marker.subtitle = Bool.random() ? "\(VCLiterals.markerText) \(index) \(VCLiterals.shapeSubtitleUpdated)" : nil
                /// Update whether or not the marker should display a callout when tapped
                marker.showCallout = self.runListeners

                /// Notify the map that the marker needs to be updated
                try mapView.update(object: marker)
            }
        } catch {
            showError(withMessage: "\(VCLiterals.updateMarkerErrorMessage): \(error)")
        }
    }

    /// Removes all current markers shown on the map
    func removeMarkers() {
        /// Ensure that there are markers to remove
        guard !markers.isEmpty else { return }

        do {
            /// Remove locally stored markers from the map
            for marker in markers {
                /// Remove the individual marker
                try mapView.remove(object: marker)
            }
            /// Reset locally stored list of markers
            markers = []
        } catch {
            /// If removing markers fails, throw an error
            showError(withMessage: "\(VCLiterals.removeMarkerErrorMessage): \(error)")
        }
    }
}
