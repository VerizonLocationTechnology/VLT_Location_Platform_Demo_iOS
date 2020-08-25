//
//  MapFeature.swift
//  VLTDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import Foundation

/// Alias to define the the current visibility of the specific features, shapes, and objects available to be show on the map.
typealias MapFeatureVisiblity = [MapFeature: Bool]

/// An objects or features that can be shown on the map above the basemap
enum MapFeature: String, CaseIterable {
    /// An object depicted as a circle with a fill and outline at a location
    case circle
    /// An object depicted as an image at a location
    case marker
    /// An object depicted as a series of points connected by a colorable line
    case polyline
    /// An object depicted as a closed series of points connected by a line and filled in
    case polygon
    /// A feature depicted as additional colored lines above roadways where traffic data is available
    case traffic
    /// A feature depicted as a mix of objects placed on the map
    case mixed

    /// Displayable title for the given feature
    var title: String { return rawValue.capitalized }

    /// Static variable to define the initial state of the `FeatureVisiblity` for the application
    static var initialFeatureVisiblity: MapFeatureVisiblity {
        var featureVisiblity = MapFeatureVisiblity()
        MapFeature.allCases.filter({ $0 != .mixed && $0 != .traffic }).forEach({ featureVisiblity[$0] = false })
        featureVisiblity[.traffic] = true
        return featureVisiblity
    }

    /// Static variable to define the initial state of GeoJSON object visibility for the application
    static var initialGeoJSONVisibility: MapFeatureVisiblity {
        var featureVisiblity = MapFeatureVisiblity()
        MapFeature.allCases.filter({ $0 != .circle && $0 != .traffic }).forEach({ featureVisiblity[$0] = false })
        featureVisiblity[.polyline] = true
        return featureVisiblity
    }
}
