//
//  MarkersViewController.swift
//  VLTDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import Combine
import CoreLocation
import UIKit
import VLTMaps

/// View controller that displays VLTMaps' ability to easily add and remove shapes and features on the map
class ShapesViewController: UIViewController {
    // MARK: - Public members
    typealias VCLiterals = VLTLiterals.ShapesVCLiterals
    typealias VCConstants = VLTConstants.ShapesVCConstants
    /// The current features that can be shown on the map and their visibility
    @Published var featureVisibility: MapFeatureVisiblity = MapFeature.initialFeatureVisiblity

    /// ShapesViewController can run in two modes `Shape & Markers` and `Listeners`.  This is the switch.
    var runListeners = false

    var markers = [VLTMapMarker]()
    var circles = [VLTMapCircle]()
    var polyline: VLTMapPolyline?
    var polygon: VLTMapPolygon?
    var vltCustomImage: VLTImage?

    /// The list of coordinates that the polyline will consist of
    let polylineCoordinates = VCConstants.polylineCoordinates
    /// List of coordinates that the polygon will encompass
    let polygonCoordinates = VCConstants.polygonCoordinates

    /// Subscriber that listens for changes in the featureVisibility object and updates the circle label
    var circleSubscriber: AnyCancellable?
    /// Subscriber that listens for changes in the featureVisibility object and updates the marker label
    var markerSubscriber: AnyCancellable?
    /// Subscriber that listens for changes in the featureVisibility object and updates the polyline label
    var polylineSubscriber: AnyCancellable?
    /// Subscriber that listens for changes in the featureVisibility object and updates the polygon label
    var polygonSubscriber: AnyCancellable?
    /// Subscriber that listens for changes in the featureVisibility object and updates the traffic flow label
    var trafficFlowSubscriber: AnyCancellable?
    /// Subscriber that listens for changes in the featureVisibility object and updates the traffic incident label
    var trafficIncidentSubscriber: AnyCancellable?
    /// Subscriber that listens for changes in the featureVisibility object and updates the statusView
    var statusSubscriber: AnyCancellable?
    /// Subscriber that listens for changes in the featureVisibility object and updates the redrawButton
    var redrawSubscriber: AnyCancellable?

    // MARK: - IBOutlets
    /// The mapView objec that displays map data
    @IBOutlet weak var mapView: VLTMapView!
    /// View containing a list of currently visible shapes and features
    @IBOutlet weak var statusView: UIView!
    /// Label indicating whether or not circles are being shown on the map
    @IBOutlet weak var circleLabel: UILabel!
    /// Label indicating whether or not markers are being shown on the map
    @IBOutlet weak var markerLabel: UILabel!
    /// Label indicating whether or not polylines are being shown on the map
    @IBOutlet weak var polylineLabel: UILabel!
    /// Label indicating whether or not polygons are being shown on the map
    @IBOutlet weak var polygonLabel: UILabel!
    /// Label indicating whether or not traffic flow is being shown on the map
    @IBOutlet weak var trafficFlowLabel: UILabel!
    /// Label indicating whether or not traffic incidents are being shown on the map
    @IBOutlet weak var trafficIncidentLabel: VLTLabel!
    /// Button for Updating and redrawing shapes being shown on the map
    @IBOutlet weak var redrawButton: UIButton!

    // MARK: - Page life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        /// Set title for view controller
        self.title = runListeners ? VCLiterals.titleForListeners : VCLiterals.titleForShapes

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

        initializeProcessing()
    }

    /// Update Visible Shape Properties
    @IBAction func updateButtonTapped() {
        updateMarkers()
        updateCircles()
        updatePolyline()
        updatePolygon()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /// If the next controller being segued to is a ShapeOptionsViewController, pass it the current feature visibiltiy and this controller as its delegate
        if let optionsController = segue.destination as? VisibleFeaturesViewController {
            optionsController.delegate = self
            optionsController.featureVisibility = featureVisibility
        }
        super.prepare(for: segue, sender: sender)
    }

    /// Update all shapes and features on the map according to the featureVisibility object
    private func updateShapesAndFeatures() {
        updateMarkerVisibility()
        updateCircleVisibility()
        updatePolylineVisibility()
        updatePolygonVisibility()
        updateTrafficFlowVisibility()
        updateTrafficIncidentVisibility()
    }

    // MARK: - Helpers
    /// Prepare subscribers to featureVisibility data
    private func initializeProcessing() {
        /// Subscribe to the featureVisibility object. Update the visibility of the circle label when featureVisibility[.circle] is updated
        circleSubscriber = $featureVisibility.map({ !($0[.circle] ?? false) }).receive(on: DispatchQueue.main).assign(to: \.isHidden, on: circleLabel)
        /// Subscribe to the featureVisibility object. Update the visibility of the marker label when featureVisibility[.marker] is updated
        markerSubscriber = $featureVisibility.map({ !($0[.marker] ?? false) }).receive(on: DispatchQueue.main).assign(to: \.isHidden, on: markerLabel)
        /// Subscribe to the featureVisibility object. Update the visibility of the polyline label when featureVisibility[.polyline] is updated
        polylineSubscriber = $featureVisibility.map({ !($0[.polyline] ?? false) }).receive(on: DispatchQueue.main).assign(to: \.isHidden, on: polylineLabel)
        /// Subscribe to the featureVisibility object. Update the visibility of the polygon label when featureVisibility[.polygon] is updated
        polygonSubscriber = $featureVisibility.map({ !($0[.polygon] ?? false) }).receive(on: DispatchQueue.main).assign(to: \.isHidden, on: polygonLabel)
        /// Subscribe to the featureVisibility object. Update the visibility of the traffic flow label when featureVisibility[.trafficFlow] is updated
        trafficFlowSubscriber = $featureVisibility.map({ !($0[.trafficFlow] ?? false) }).receive(on: DispatchQueue.main).assign(to: \.isHidden, on: trafficFlowLabel)
        /// Subscribe to the featureVisibility object. Update the visibility of the traffic incidents label when featureVisibility[.trafficIncidents] is updated
        trafficIncidentSubscriber = $featureVisibility.map({ !($0[.trafficIncidents] ?? false) }).receive(on: DispatchQueue.main).assign(to: \.isHidden, on: trafficIncidentLabel)
        /// Subscribe to the featureVisibility object. Update the visibility of the statusView when featureVisibility is updated
        statusSubscriber = $featureVisibility.map({ !$0.values.contains(true) }).receive(on: DispatchQueue.main).assign(to: \.isHidden, on: statusView)
        /// Subscribe to the featureVisibility object. Update the visibility of the redrawButton when featureVisibility is updated
        redrawSubscriber = $featureVisibility.map({ !($0[.polygon] ?? false || $0[.polyline] ?? false || $0[.circle] ?? false || $0[.marker] ?? false ) }).receive(on: DispatchQueue.main).assign(to: \.isHidden, on: redrawButton) // swiftlint:disable:this line_length
    }
}

// MARK: - VLTMapViewDelegate
extension ShapesViewController: VLTMapViewDelegate {
    func tappedOnCallout(mapView: VLTMapView, object: VLTMapObject) {
    }

    /// Handle the map successfully loading
    func didFinishLoadingMap(mapView: VLTMapView) {
        do {
            /// Zoom the camera in to the area where shapes are displayed
            try mapView.camera.set(zoom: 12)
        } catch {
            showError(withMessage: "\(VCLiterals.updateCameraError): \(error)")
        }
        /// Update the map to display the default visible shapes and features
        updateShapesAndFeatures()
    }

    /// Handle the map failing to load
    func didFailLoadingMap(mapView: VLTMapView, error: Error) {
        showError(withMessage: "\(VCLiterals.loadMapError): \(error)")
    }
}

// MARK: - ShapeOptionsControllerDelegate
extension ShapesViewController: VisibleFeaturesControllerDelegate {
    func updateFeatures(_ featureVisibility: [MapFeature: Bool]) {
        /// Update feature visibility
        self.featureVisibility = featureVisibility
        /// Update shapes and features on the map
        updateShapesAndFeatures()
    }
}
