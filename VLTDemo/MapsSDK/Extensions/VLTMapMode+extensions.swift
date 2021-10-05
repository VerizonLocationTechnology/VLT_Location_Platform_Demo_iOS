//
// VLTMapMode+extensions.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import UIKit
import VLTMaps

extension VLTMapMode {
    /// Returns the VLTMap mode that best matches the interface style that is passed in
    static func mapMode(forUserInterfaceStyle style: UIUserInterfaceStyle) -> VLTMapMode {
        switch style {
        case .light, .unspecified:
            return .day
        case .dark:
            return .night
        @unknown default:
            return .day
        }
    }
}
