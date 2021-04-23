//
//  ShapesViewController+UserInteraction.swift
//  VLTDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import CoreLocation
import UIKit
import VLTMaps

/// Extension giving examples of how work with user interaction callbacks for the VLTMapViewDelegate
extension ShapesViewController {
    /// Handle a user tapping on the mapView
    func tappedOnMap(mapView: VLTMapView, point: CGPoint, coordinate: CLLocationCoordinate2D) {
        if runListeners { showAlert(withMessage: VCLiterals.tappedOnMap) }
    }

    /// Handle a user tapping on a VLTMapMarker on the map
    func tappedOnMarker(mapView: VLTMapView, marker: VLTMapMarker, coordinate: CLLocationCoordinate2D) {
        showAlert(withMessage: "\(VCLiterals.tappedOnMarker)\n \(VCLiterals.shapeTitle): \(marker.title ?? "nil")\n \(VCLiterals.shapeSubtitle): \(marker.subtitle ?? "nil")")
    }

    /// Handle a user tapping on a VLTMapCircle on the map
    func tappedOnCircle(mapView: VLTMapView, circle: VLTMapCircle, coordinate: CLLocationCoordinate2D) {
        showAlert(withMessage: "\(VCLiterals.tappedOnCircle)\n \(VCLiterals.shapeTitle): \(circle.title ?? "nil")\n \(VCLiterals.shapeSubtitle): \(circle.subtitle ?? "nil")")
    }

    /// Handle a user tapping on a VLTMapPolyline on the map
    func tappedOnPolyline(mapView: VLTMapView, polyline: VLTMapPolyline, coordinate: CLLocationCoordinate2D) {
        showAlert(withMessage: "\(VCLiterals.tappedOnPolyline)\n \(VCLiterals.shapeTitle): \(polyline.title ?? "nil")\n \(VCLiterals.shapeSubtitle): \(polyline.subtitle ?? "nil")")
    }

    /// Handle a user tapping on a VLTMapPolygon on the map
    func tappedOnPolygon(mapView: VLTMapView, polygon: VLTMapPolygon, coordinate: CLLocationCoordinate2D) {
        showAlert(withMessage: "\(VCLiterals.tappedOnPolygon)\n \(VCLiterals.shapeTitle): \(polygon.title ?? "nil")\n \(VCLiterals.shapeSubtitle): \(polygon.subtitle ?? "nil")")
    }
}
