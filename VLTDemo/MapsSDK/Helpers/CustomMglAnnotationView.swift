//
// CustomMglAnnotationView.swift
// VLTDemo
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import Mapbox

/// Custom MGLAnnotationView subclass to demonstrate Mapbox's MGLMapViewDelegate
class CustomMglAnnotationView: MGLAnnotationView {
    /// Create a new non-scalling dark gray circle annotation view with a white border
    /// - Parameters:
    ///   - reuseIdentifier: Annotation reuse identifier
    ///   - size: How big do you want the circle to be?
    init(reuseIdentifier: String, size: CGFloat) {
        super.init(reuseIdentifier: reuseIdentifier)

        // This property prevents the annotation from changing size when the map is tilted.
        scalesWithViewingDistance = false

        // Begin setting up the view.
        frame = CGRect(x: 0, y: 0, width: size, height: size)

        backgroundColor = .darkGray

        // Use CALayer’s corner radius to turn this view into a circle.
        layer.cornerRadius = size / 2
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
    }

    // These two initializers are forced upon us by Swift.
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable) // This is really not available to anyone to use
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
