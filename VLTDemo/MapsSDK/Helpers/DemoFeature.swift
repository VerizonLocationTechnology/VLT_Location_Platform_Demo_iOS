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
    private typealias literals = VLTLiterals.DemoFeatureLiterals

    case welcome, camera, modes, userLocation, shapes, geoJson, listeners, relativePositioning, boundingBox, mapbox

    /// Overarching label for each feature to be demoed
    var title: String {
        switch self {
        case .welcome:
            return literals.welcomeTitle
        case .camera:
            return literals.cameraTitle
        case .modes:
            return literals.modesTitle
        case .userLocation:
            return literals.userLocationTitle
        case .shapes:
            return literals.shapesTitle
        case .geoJson:
            return literals.geoJsonTitle
        case .listeners:
            return literals.listenersTitle
        case .relativePositioning:
            return literals.relativePositioningTitle
        case .boundingBox:
            return literals.boundingBoxTitle
        case .mapbox:
            return literals.mapboxTitle
        }
    }

    /// Detailed description for each feature to be demoed
    var content: String {
        switch self {
        case .welcome:
            return literals.welcomeContent
        case .camera:
            return literals.cameraContent
        case .modes:
            return literals.modesContent
        case .userLocation:
            return literals.userLocationContent
        case .shapes:
            return literals.shapesContent
        case .geoJson:
            return literals.geoJsonContent
        case .listeners:
            return literals.listenersContent
        case .relativePositioning:
            return literals.relativePositioningContent
        case .boundingBox:
            return literals.boundingBoxContent
        case .mapbox:
            return literals.mapboxContent
        }
    }

    /// Segue to be used when a cell describing any feature is tapped
    var segueTitle: String? {
        switch self {
        case .welcome:
            return nil
        case .camera:
            return literals.cameraSegue
        case .modes:
            return literals.modesSegue
        case .userLocation:
            return literals.userLocationSegue
        case .shapes:
            return literals.shapesSegue
        case .geoJson:
            return literals.geoJsonSegue
        case .listeners:
            return literals.listenersSegue
        case .relativePositioning:
            return literals.relativePositioningSegue
        case .boundingBox:
            return literals.boundingBoxSegue
        case .mapbox:
            return literals.mapboxSegue
        }
    }
}
