//
//  CameraViewController.swift
//  VLTDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import UIKit
import VLTMaps
import CoreLocation
import Combine

/// View controller that displays VLTMaps' ability to easily update the camera view of the map
class CameraViewController: UIViewController {
    // MARK: - Public members
    /// Typealias pointing to string literals for this controller
    typealias literals = VLTLiterals.CameraVCLiterals
    /// The current camera settings displayed in the statusView
    @Published var cameraMetrics = CameraMetrics()
    /// Subscriber that listens for changes in the cameraMetrics object and updates the zoomValueLabel
    var zoomSubscriber: AnyCancellable?
    /// Subscriber that listens for changes in the cameraMetrics object and updates the bearingValueLabel
    var bearingSubscriber: AnyCancellable?
    /// Subscriber that listens for changes in the cameraMetrics object and updates the tiltValueLabel
    var tiltSubscriber: AnyCancellable?

    // MARK: - IBOutlets
    /// The mapView object that displays map data
    @IBOutlet weak var mapView: VLTMapView!
    /// Navigation button the the CameraMetricsViewController
    @IBOutlet weak var metricsButton: UIBarButtonItem!
    /// View containing the current Camera status of the map
    @IBOutlet weak var statusView: VLTView!
    /// Label containing the current zoom level of the map
    @IBOutlet weak var zoomValueLabel: UILabel!
    /// Label containing the current bearing value of the map
    @IBOutlet weak var bearingValueLabel: UILabel!
    /// Label containing the current tilt value of the map
    @IBOutlet weak var tiltValueLabel: UILabel!

    // MARK: - Page life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        /// Set the title of the view controller
        self.title = VLTLiterals.CameraVCLiterals.title

        /// Get the map mode that matches the device's current interface style
        let mode = VLTMapMode.mapMode(forUserInterfaceStyle: traitCollection.userInterfaceStyle)

        /// Configure the map with the initial mode, any built-in features that should be hidden, and the initial center for the camera
        let mapConfiguration = MapConfiguration(mode: mode,
                                                hiddenFeatures: [.traffic],
                                                cameraCenter: CLLocationCoordinate2D(latitude: 42.3637, longitude: -71.053604))

        /// Load the map using your given API key
        mapView.loadMap(apiKey: apiKey, configuration: mapConfiguration)

        /// Set this view controller as the VLTMapViewDelegate for the mapView
        mapView.delegate = self

        initializeProcessing()
    }

    // MARK: - IBActions
    /// Zoom the map in by two levels when the user taps on the plus button
    @IBAction func plusButtonTapped() {
        /// Retrieve the current zoom level from the camera metrics object
        let currentZoom = cameraMetrics.zoomLevel
        /// Retrieve the maximum allowable zoom level for the map
        let maxZoom = mapView.camera.limits.getMaxZoomLevel()
        /// Determine the next zoom level that the camera can reach
        let newZoom = currentZoom + 2 < maxZoom ? currentZoom + 2 : maxZoom
        /// Update the camera with the new zoom level
        update(CameraMetrics(zoomLevel: newZoom, bearing: cameraMetrics.bearing, tilt: cameraMetrics.tilt))
    }

    /// Zoom the map out by two levels when the user taps on the minus button
    @IBAction func minusButtonTapped() {
        /// Retrieve the current zoom level from the camera metrics object
        let currentZoom = cameraMetrics.zoomLevel
        /// Retrieve the minimum allowable zoom level for the map
        let minZoom = mapView.camera.limits.getMinZoomLevel()
        /// Determine the next zoom level that the camera can reach
        let newZoom = currentZoom - 2 > minZoom ? currentZoom - 2 : minZoom
        /// Update the camera with the new zoom level
        update(CameraMetrics(zoomLevel: newZoom, bearing: cameraMetrics.bearing, tilt: cameraMetrics.tilt))
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /// If the next controller being segued to is the CameraMetricsViewController, pass it the current camera metrics and this controller as its delegate
        if let metricsController = segue.destination as? CameraMetricsViewController {
            metricsController.delegate = self
            metricsController.cameraMetrics = cameraMetrics
        }
        super.prepare(for: segue, sender: sender)
    }

    // MARK: - Private functions
    /// Prepare subscribers to cameraMetrics data
    func initializeProcessing() {
        /// Subscribe to the cameraMetrics object. Update the zoomValueLabel when cameraMetrics is updated
        zoomSubscriber = $cameraMetrics.map({ $0.zoomLevel.roundedString() }).receive(on: DispatchQueue.main).assign(to: \.text, on: zoomValueLabel)
        /// Subscribe to the cameraMetrics object. Update the bearingValueLabel when cameraMetrics is updated
        bearingSubscriber = $cameraMetrics.map({ $0.bearing.roundedString() }).receive(on: DispatchQueue.main).assign(to: \.text, on: bearingValueLabel)
        /// Subscribe to the cameraMetrics object. Update the tiltValueLabel when cameraMetrics is updated
        tiltSubscriber = $cameraMetrics.map({ $0.tilt.roundedString() }).receive(on: DispatchQueue.main).assign(to: \.text, on: tiltValueLabel)
    }

}

// MARK: - VLTMapViewDelegate
extension CameraViewController: VLTMapViewDelegate {
    func tappedOnCallout(mapView: VLTMapView, object: VLTMapObject) {
    }

    /// If the map fails to load, throw an error
    func didFailLoadingMap(mapView: VLTMapView, error: Error) {
        showError(withMessage: "\(literals.mapLoadErrorMessage): \(error)")
    }

    /// When the user interacts with the map (through panning, zooming, etc) update the current camera metrics
    func didUpdateCameraPosition(mapView: VLTMapView) {
        let camera = mapView.camera
        cameraMetrics = CameraMetrics(zoomLevel: camera.zoom, bearing: camera.bearing, tilt: camera.tilt)
    }
}

// MARK: - CameraMetricsControllerDelegate
extension CameraViewController: CameraMetricsControllerDelegate {
    /// Updates the map's camera and local metrics object when new camera metrics are passed along
    /// - Parameters:
    ///   - cameraMetrics: The new CameraMetrics state to update to
    func update(_ cameraMetrics: CameraMetrics) {

        do {
            /// Update the map camera to use the new camera metrics
            try mapView.camera.updateCamera(tilt: cameraMetrics.tilt,
                                            bearing: cameraMetrics.bearing,
                                            zoom: cameraMetrics.zoomLevel,
                                            withAnimation: true)
            /// Save the new metrics to local storage, updating the statusView's Zoom, Bearing, and Tilt labels
            self.cameraMetrics = cameraMetrics
        } catch {
            /// If the camera update fails, display an error
            showError(withMessage: "\(literals.cameraUpdateErrorMessage): \(error)")
        }
    }
}
