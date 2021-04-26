//
//  DemoFeature.swift
//  VLTDemo
//
//  Created by Verizon Location Technology.
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import Foundation

/// Enumeration describing the current features to be demoed in this application
enum DemoFeature: CaseIterable {
    /// Typealias pointing to string literals for this enum
    private typealias DemoFeatures = VLTLiterals.DemoFeatureLiterals

    case welcome, camera, modes, userLocation, shapes, geoJson, listeners, relativePositioning, boundingBox, mapbox, navigation

    /// Overarching label for each feature to be demoed
    var title: String {
        switch self {
        case .welcome:
            return DemoFeatures.welcomeTitle
        case .camera:
            return DemoFeatures.cameraTitle
        case .modes:
            return DemoFeatures.modesTitle
        case .userLocation:
            return DemoFeatures.userLocationTitle
        case .shapes:
            return DemoFeatures.shapesTitle
        case .geoJson:
            return DemoFeatures.geoJsonTitle
        case .listeners:
            return DemoFeatures.listenersTitle
        case .relativePositioning:
            return DemoFeatures.relativePositioningTitle
        case .boundingBox:
            return DemoFeatures.boundingBoxTitle
        case .mapbox:
            return DemoFeatures.mapboxTitle
        case .navigation:
            return DemoFeatures.navigationTitle
        }
    }

    /// Detailed description for each feature to be demoed
    var content: String {
        switch self {
        case .welcome:
            return DemoFeatures.welcomeContent
        case .camera:
            return DemoFeatures.cameraContent
        case .modes:
            return DemoFeatures.modesContent
        case .userLocation:
            return DemoFeatures.userLocationContent
        case .shapes:
            return DemoFeatures.shapesContent
        case .geoJson:
            return DemoFeatures.geoJsonContent
        case .listeners:
            return DemoFeatures.listenersContent
        case .relativePositioning:
            return DemoFeatures.relativePositioningContent
        case .boundingBox:
            return DemoFeatures.boundingBoxContent
        case .mapbox:
            return DemoFeatures.mapboxContent
        case .navigation:
            return DemoFeatures.navigationContent
        }
    }

    /// Segue to be used when a cell describing any feature is tapped
    var segueTitle: String? {
        switch self {
        case .welcome:
            return nil
        case .camera:
            return DemoFeatures.cameraSegue
        case .modes:
            return DemoFeatures.modesSegue
        case .userLocation:
            return DemoFeatures.userLocationSegue
        case .shapes:
            return DemoFeatures.shapesSegue
        case .geoJson:
            return DemoFeatures.geoJsonSegue
        case .listeners:
            return DemoFeatures.listenersSegue
        case .relativePositioning:
            return DemoFeatures.relativePositioningSegue
        case .boundingBox:
            return DemoFeatures.boundingBoxSegue
        case .mapbox:
            return DemoFeatures.mapboxSegue
        case .navigation:
            return nil
        }
    }
}
