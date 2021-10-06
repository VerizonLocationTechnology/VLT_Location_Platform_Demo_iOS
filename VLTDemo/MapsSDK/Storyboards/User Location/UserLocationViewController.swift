//
// UserLocationViewController.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import CoreLocation
import UIKit
import VLTMaps

/// View controller that displays VLTMaps' ability to easily view the user's current location
class UserLocationViewController: UIViewController {
    // MARK: - Public Members
    typealias Literals = VLTLiterals.UserLocationVCLiterals
    /// Manager used to access the user's current location data locally
    let locationManager = CLLocationManager()
    /// The user's current location, if allowed access
    var currentLocation: CLLocationCoordinate2D? {
        didSet {
            /// Enable the userLocationButton if a current location exists
            userLocationButton.isEnabled = currentLocation != nil
        }
    }

    // MARK: - IBOutlets
    /// The mapView object that displays map data
    @IBOutlet weak var mapView: VLTMapView!
    /// Button for requesting loaction of fullAccuracy when its currently reduced
    @IBOutlet weak var userLocationPrecisionButton: UIButton!
    /// Button for centering the map onto the user's current location
    @IBOutlet weak var userLocationButton: UIButton!

    // MARK: - Page life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set title of the view controller
        self.title = Literals.title

        /// Get the map mode that matches the device's current interface style
        let mode = VLTMapMode.mapMode(forUserInterfaceStyle: traitCollection.userInterfaceStyle)

        /// Configure the map with the initial mode, any built-in features that should be hidden, and the initial center for the camera
        let mapConfiguration = MapConfiguration(mode: mode,
                                                hiddenFeatures: [.traffic],
                                                cameraCenter: CLLocationCoordinate2D(latitude: 42.3637, longitude: -71.053_604))

        /// Load the map using your given API key
        mapView.loadMap(apiKey: apiKey, configuration: mapConfiguration)

        /// Set this view controller as the VLTMapViewDelegate for the mapView
        mapView.delegate = self

        /// Allow the location manager to interact with this UIViewController instance
        locationManager.delegate = self
        /// Request permission to access the user's current location while the app is in use
        locationManager.requestWhenInUseAuthorization()
        /// Begin updating the user's current location, if granted permission
        locationManager.startUpdatingLocation()
    }

    // MARK: - IBActions
    /// Center the map on the user's current location when the button is tapped
    @IBAction func userLocationButtonTapped(_ sender: UIButton) {
        if let currentLocation = currentLocation {
            do {
                /// Update the camera to center on the user's current location
                try mapView.camera.updateCamera(tilt: nil,
                                                bearing: nil,
                                                zoom: nil,
                                                target: currentLocation,
                                                withAnimation: true)
            } catch {
                /// Display an error if the camera fails to update
                showError(withMessage: "\(Literals.cameraUpdateErrorMessage): \(error)")
            }
        }
    }

    @IBAction func userLocationPrecisionButtonTapped(_ sender: Any) {
        if #available(iOS 14.0, *) {
            locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "VLTLocationManager")
        }
    }

    func showUserLocationOnMap() {
        if #available(iOS 14.0, *) {
            if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
                mapView.showsUserLocation = true
            }
            if locationManager.accuracyAuthorization == .reducedAccuracy {
                userLocationPrecisionButton.isHidden = false
            }
        } else {
            if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                mapView.showsUserLocation = true
            }
            userLocationPrecisionButton.isHidden = true
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension UserLocationViewController: CLLocationManagerDelegate {
    /// Update the user's location if it is found to be accurate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        /// If the user's location is considered accurate, save the user's current location and center the map on that location
        if let coordinate = locations.first?.coordinate, let vertA = locations.first?.verticalAccuracy, vertA <= 10 {
            /// Save the user's current location
            currentLocation = coordinate
            /// Stop updating the user's current location
            locationManager.stopUpdatingLocation()
            /// Center the map on the user's location
            userLocationButtonTapped(userLocationButton)
        } else {
            /// Display the current accuracy of the user's location
            print("\(Literals.horizonalAccuracyAbbreviation): \(locations.first?.horizontalAccuracy ?? -1) | \(Literals.verticalAccuracyAbbreviation): \(locations.first?.verticalAccuracy ?? -1) ")
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        showUserLocationOnMap()
        if #available(iOS 14.0, *) {
            if locationManager.accuracyAuthorization == .reducedAccuracy {
                userLocationPrecisionButton.isHidden = false
            } else {
                userLocationPrecisionButton.isHidden = true
            }
        } else {
            userLocationPrecisionButton.isHidden = true
        }
    }
}

// MARK: - VLTMapViewDelegate
extension UserLocationViewController: VLTMapViewDelegate {
    func tappedOnCallout(mapView: VLTMapView, object: VLTMapObject) {
    }

    /// If the map succeeds in loading, attempt to show the user's current location
    func didFinishLoadingMap(mapView: VLTMapView) {
        /// Attempt to show the user's current location
        showUserLocationOnMap()
    }

    /// If the map fails to load, throw an error
    func didFailLoadingMap(mapView: VLTMapView, error: Error) {
        showError(withMessage: "\(Literals.mapLoadErrorMessage): \(error)")
    }

    /// If the user location fails to load, throw an error
    func failedToShowUserLocation(mapView: VLTMapView, error: Error) {
        showError(withMessage: "\(Literals.locationUpdateErrorMessage): \(error)")
    }
}
