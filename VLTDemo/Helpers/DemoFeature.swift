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
    
    case welcome, camera, modes, userLocation, shapes, listeners
    
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
        case .listeners:
            return literals.listenersTitle
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
        case .listeners:
            return literals.listenersContent
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
        case .listeners:
            return literals.listenersSegue
        }
    }
}
