//
//  ShapesViewController+CircleExamples.swift
//  VLTDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import UIKit
import VLTMaps
import CoreLocation

/// Extension giving examples of how to interact with VLTMapCircle objects on the map
extension ShapesViewController {
    /// Show or hide circles based on current settings
    func updateCircleVisibility() {
        if let circlesVisible = featureVisibility[.circle], circlesVisible {
            addCircles()
        } else {
            removeCircles()
        }
    }
    
    /// Creates a series of circles with varying traits and displays them on the map
    func addCircles() {
        /// Ensure that circles aren't already on the map
        guard circles.isEmpty else { return }
        
        do {
            /// Create a circle with a title and subtitle that will display a callout when tapped
            let circle1 = VLTMapCircle(coordinate: CLLocationCoordinate2D(latitude: 42.3600,
                                                                          longitude: -71.06137),
                                       radius: 100,
                                       title: literals.circle1Title,
                                       subtitle: literals.circle1Subtitle,
                                       shouldCallout: true,
                                       fillColor: .blue,
                                       strokeWidth: 4,
                                       strokeColor: .cyan)
            /// Add the circle to the map
            try mapView.add(object: circle1)
            /// Store a reference to the circle for future use
            circles.append(circle1)
            
            /// Create a circle that has no title or subtitle, and has a semi-transparent fill
            let circle2 = VLTMapCircle(coordinate: CLLocationCoordinate2D(latitude: 42.358744,
                                                                          longitude: -71.060403),
                                       radius: 130,
                                       fillColor: UIColor.green.withAlphaComponent(0.5),
                                       strokeWidth: 2,
                                       strokeColor: .yellow)
            /// Add the circle to the map
            try mapView.add(object: circle2)
            /// Store a reference to the circle for future use
            circles.append(circle2)
            
        } catch {
            /// If adding circles to the map fails, display an error
            showError(withMessage: "\(literals.addCircleErrorMessage): \(error)")
        }
    }
    
    /// Update all circles on the map with different colors and properties
    func updateCircles() {
        /// Ensure that there are circles to update
        guard !circles.isEmpty else { return }
        
        do {
            for (index, circle) in circles.enumerated() {
                /// Update location of the center of the circle
                circle.coordinate = CLLocationCoordinate2D(latitude: .random(in: 42.358744...42.3600),
                                                           longitude: .random(in: (-71.06137)...(-71.060403)))
                /// Update the stroke color of the circle
                circle.strokeColor = .random
                /// Update the stroke width of the circle
                circle.strokeWidth = .random(in: 2...10)
                /// Update the fill color of the circle
                circle.fillColor = .random
                /// Update the radius of the circle
                circle.radius = .random(in: 75...160)
                /// Update the title of the circle with new ones
                circle.title = Bool.random() ? "\(literals.circleText) \(index) \(literals.shapeTitleUpdated)" : nil
                /// Update the subtitle of the circle with new ones
                circle.subtitle = Bool.random() ? "\(literals.circleText) \(index) \(literals.shapeSubtitleUpdated)" : nil
                /// Update whether or not the circle should display a callout when tapped
                circle.shouldCallout = .random()
                
                /// Notify the map that the circle needs to be updated
                try mapView.update(object: circle)
            }
        } catch {
            showError(withMessage: "\(literals.updateCircleErrorMessage): \(error)")
        }
    }
    
    /// Removes all current circles shown on the map
    func removeCircles() {
        /// Ensure that there are circles to remove
        guard !circles.isEmpty else { return }
        
        do {
            /// Remove locally stored circles from the map
            for circle in circles {
                /// Remove the individual circle
                try mapView.remove(object: circle)
            }
            /// Reset the locally stored list of circles
            circles = []
        } catch {
            /// If removing any circle fails, throw an error
            showError(withMessage: "\(literals.removeCircleErrorMessage): \(error)")
        }
    }
}
