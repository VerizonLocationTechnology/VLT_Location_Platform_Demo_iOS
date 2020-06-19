//
//  ShapesViewController+UserInteraction.swift
//  VLTDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import UIKit
import VLTMaps
import CoreLocation

/// Extension giving examples of how work with user interaction callbacks for the VLTMapViewDelegate
extension ShapesViewController {
    
    /// Handle a user tapping on the mapView
    func tappedOnMap(mapView: VLTMapView, point: CGPoint, coordinate: CLLocationCoordinate2D) {
        showAlert(withMessage: literals.tappedOnMap)
    }
    
    /// Handle a user tapping on a VLTMapMarker on the map
    func tappedOnMarker(mapView: VLTMapView, marker: VLTMapMarker, coordinate: CLLocationCoordinate2D) {
        showAlert(withMessage: "\(literals.tappedOnMarker)\n \(literals.shapeTitle): \(marker.title ?? "nil")\n \(literals.shapeSubtitle): \(marker.subtitle ?? "nil")")
    }
    
    /// Handle a user tapping on a VLTMapCircle on the map
    func tappedOnCircle(mapView: VLTMapView, circle: VLTMapCircle, coordinate: CLLocationCoordinate2D) {
        showAlert(withMessage: "\(literals.tappedOnCircle)\n \(literals.shapeTitle): \(circle.title ?? "nil")\n \(literals.shapeSubtitle): \(circle.subtitle ?? "nil")")
    }
    
    /// Handle a user tapping on a VLTMapPolyline on the map
    func tappedOnPolyline(mapView: VLTMapView, polyline: VLTMapPolyline, coordinate: CLLocationCoordinate2D) {
        showAlert(withMessage: "\(literals.tappedOnPolyline)\n \(literals.shapeTitle): \(polyline.title ?? "nil")\n \(literals.shapeSubtitle): \(polyline.subtitle ?? "nil")")
    }
    
    /// Handle a user tapping on a VLTMapPolygon on the map
    func tappedOnPolygon(mapView: VLTMapView, polygon: VLTMapPolygon, coordinate: CLLocationCoordinate2D) {
        showAlert(withMessage: "\(literals.tappedOnPolygon)\n \(literals.shapeTitle): \(polygon.title ?? "nil")\n \(literals.shapeSubtitle): \(polygon.subtitle ?? "nil")")
    }
    
    /// Handle a user tapping on a callout for a VLTMapShape on the map
    func tappedOnCallout(mapView: VLTMapView, shape: VLTMapShape) {
        showAlert(withMessage: "\(literals.tappedOnCallout)\n \(literals.shapeTitle): \(shape.title ?? "nil")\n \(literals.shapeSubtitle): \(shape.subtitle ?? "nil")")
    }
}

