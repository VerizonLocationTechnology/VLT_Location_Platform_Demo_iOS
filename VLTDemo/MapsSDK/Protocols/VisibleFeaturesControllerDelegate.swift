//
// VisibleFeaturesControllerDelegate.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import Foundation

/// Protocol description for the delegate of the VisibleFeaturesViewController
protocol VisibleFeaturesControllerDelegate: AnyObject {
    /// Updates the delegate to the new state of a featureVisibility object
    /// - Parameters:
    ///   - featureVisibility: The new FeatureVisibility state to be updated to
    func updateFeatures(_ featureVisibility: MapFeatureVisiblity)
}
