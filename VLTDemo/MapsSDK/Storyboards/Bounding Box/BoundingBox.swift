//
// BoundingBox.swift
// VLTMaps SDK
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import CoreLocation
import UIKit

class BoundingBox {
    // MARK: Variables
    /// Southwest boundary coordinate
    var sw: CLLocationCoordinate2D
    /// Northeast boundary coordinate
    var ne: CLLocationCoordinate2D
    /// Insets around resultant bounding box that should be visible
    var insets: UIEdgeInsets

    // MARK: Initializers
    /// Generates a new BoundingBox object
    /// - Parameters:
    ///   - sw: The southwest coordinate of the resultant visible bounding box
    ///   - ne: The northeast coordinate of the resultant visible bounding box
    ///   - insets: Area around the resultant bounding box that should also be visible
    init(sw: CLLocationCoordinate2D, ne: CLLocationCoordinate2D, insets: UIEdgeInsets) {
        self.sw = sw
        self.ne = ne
        self.insets = insets
    }

    // MARK: - Static Members
    /// Bounding box for the state of Colorado
    static var colorado = BoundingBox(sw: CLLocationCoordinate2DMake(36.972_034_446_514_2, -109.050_697_042_617_44),
                                      ne: CLLocationCoordinate2DMake(40.967_641_262_743_34, -102.041_419_767_428_48),
                                      insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    /// Bounding box for the state of Texas
    static var texas = BoundingBox(sw: CLLocationCoordinate2DMake(25.559_582_382_264_65, -106.588_301_617_980_92),
                                   ne: CLLocationCoordinate2DMake(36.523_602_760_903_16, -93.825_657_380_665),
                                   insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    /// Bounding box for the state of New York
    static var newYork = BoundingBox(sw: CLLocationCoordinate2DMake(40.912_956_868_098_63, -79.717_146_217_734_67),
                                     ne: CLLocationCoordinate2DMake(45.041_958_421_923_965, -73.191_267_375_318_63),
                                     insets: UIEdgeInsets(top: -120, left: -120, bottom: -120, right: -120))
    /// Bounding box for the state of Utah
    static var utah = BoundingBox(sw: CLLocationCoordinate2DMake(36.946_595_344_476_194, -114.105_868_159_634_64),
                                  ne: CLLocationCoordinate2DMake(41.923_734_248_185_696, -108.986_239_303_460_5),
                                  insets: .zero)
}
