//
// BoundingBox.swift
// VLTMaps SDK
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import UIKit
import CoreLocation

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
    static var colorado = BoundingBox(sw: CLLocationCoordinate2DMake(36.9720344465142, -109.05069704261744),
                                      ne: CLLocationCoordinate2DMake(40.96764126274334, -102.04141976742848),
                                      insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    /// Bounding box for the state of Texas
    static var texas = BoundingBox(sw: CLLocationCoordinate2DMake(25.55958238226465, -106.58830161798092),
                                   ne: CLLocationCoordinate2DMake(36.52360276090316, -93.825657380665),
                                   insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    /// Bounding box for the state of New York
    static var newYork = BoundingBox(sw: CLLocationCoordinate2DMake(40.91295686809863, -79.71714621773467),
                                     ne: CLLocationCoordinate2DMake(45.041958421923965, -73.19126737531863),
                                     insets: UIEdgeInsets(top: -120, left: -120, bottom: -120, right: -120))
    /// Bounding box for the state of Utah
    static var utah = BoundingBox(sw: CLLocationCoordinate2DMake(36.946595344476194, -114.10586815963464),
                                  ne: CLLocationCoordinate2DMake(41.923734248185696, -108.9862393034605),
                                  insets: .zero)
}
