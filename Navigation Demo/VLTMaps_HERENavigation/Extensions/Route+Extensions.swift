//
//  Route+Extensions.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import CoreLocation
import heresdk

extension Route {
    /// CoreLocation synomym to Heresdk.polyline
    var clLocationCoordinates2D: [CLLocationCoordinate2D] {
        return self.polyline.map({ $0.clLocationCoordinate2D })
    }
}
