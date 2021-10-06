//
// GeoJSONViewController.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import Combine
import CoreLocation
import UIKit
import VLTMaps

class GeoJSONViewController: UIViewController, VLTMapViewDelegate, VisibleFeaturesControllerDelegate {
    // MARK: - Public members
    typealias GeoJsonVC = VLTLiterals.GeoJSONVCLiterals
    /// The current features that can be shown on the map and their visibility
    @Published var featureVisibility: MapFeatureVisiblity = MapFeature.initialGeoJSONVisibility

    var mixedGeoJSON: VLTGeoJSON?
    var polylineGeoJSON: VLTGeoJSON?
    var polygonGeoJSON: VLTGeoJSON?
    var pointGeoJSON: VLTGeoJSON?
    var vltCustomImage: VLTImage?

    /// GeoJSON data that encompasses multiple GeoJSON objects in a single FeatureCollection
    var mixedGeoJSONData = Data.from(fileNamed: "MixedFeatureCollection", withExtension: ".json")
    /// GeoJSON data that encompasses a MultiPolyline object in a FeatureCollection
    var polylineGeoJSONData = Data.from(fileNamed: "Polylines", withExtension: ".json")
    /// GeoJSON data that encompasses a MultiPolygon object in a FeatureCollection
    var polygonGeoJSONData = Data.from(fileNamed: "Polygons", withExtension: ".json")
    /// GeoJSON data that encompasses a MultiPoint object in a FeatureCollection
    var multiPointImageGeoJSONData = Data.from(fileNamed: "Points", withExtension: ".json")

    /// Subscriber that listens for changes in the featureVisibility object and updates the mix label
    var mixSubscriber: AnyCancellable?
    /// Subscriber that listens for changes in the featureVisibility object and updates the point label
    var markerSubscriber: AnyCancellable?
    /// Subscriber that listens for changes in the featureVisibility object and updates the polyline label
    var polylineSubscriber: AnyCancellable?
    /// Subscriber that listens for changes in the featureVisibility object and updates the polygon label
    var polygonSubscriber: AnyCancellable?
    /// Subscriber that listens for changes in the featureVisibility object and updates the statusView
    var statusSubscriber: AnyCancellable?
    /// Subscriber that listens for changes in the featureVisibility object and updates the redrawButton
    var redrawSubscriber: AnyCancellable?

    // MARK: - IBOutlets
    /// The mapView object that displays map data
    @IBOutlet weak var mapView: VLTMapView!
    /// View containing a list of currently visible shapes and features
    @IBOutlet weak var statusView: UIView!
    /// Label indicating whether or not the mixed GeoJSON is being shown on the map
    @IBOutlet weak var mixLabel: VLTLabel!
    /// Label indicating whether or not the point GeoJSON is being shown on the map
    @IBOutlet weak var markerLabel: UILabel!
    /// Label indicating whether or not the polyline GeoJSON is being shown on the map
    @IBOutlet weak var polylineLabel: UILabel!
    /// Label indicating whether or not the polygon GeoJSON being shown on the map
    @IBOutlet weak var polygonLabel: UILabel!
    /// Button for Updating and redrawing shapes being shown on the map
    @IBOutlet weak var redrawButton: UIButton!

    // MARK: - Page life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        /// Set title for view controller
        self.title = GeoJsonVC.title

        /// Get the map mode that matches the device's current interface style
        let mode = VLTMapMode.mapMode(forUserInterfaceStyle: traitCollection.userInterfaceStyle)

        /// Configure the map with the initial mode, any built-in features that should be hidden, and the initial bounded area for the camera
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
        updateMixedObjects()
        updatePolylineObjects()
        updatePolygonObjects()
        updatePointObjects()
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

    /// Update all geoJSON objects on the map according to the featureVisibility object
    private func updateGeoJSONObjects() {
        updateMixedVisibility()
        updatePolylineVisibility()
        updatePolygonVisibility()
        updatePointVisibility()
    }

    // MARK: - Helpers
    /// Prepare subscribers to featureVisibility data
    private func initializeProcessing() {
        /// Subscribe to the featureVisibility object. Update the visibility of the point label when featureVisibility[.mix] is updated
        mixSubscriber = $featureVisibility.map({ !($0[.mixed] ?? false) }).receive(on: DispatchQueue.main).assign(to: \.isHidden, on: mixLabel)
        /// Subscribe to the featureVisibility object. Update the visibility of the point label when featureVisibility[.marker] is updated
        markerSubscriber = $featureVisibility.map({ !($0[.marker] ?? false) }).receive(on: DispatchQueue.main).assign(to: \.isHidden, on: markerLabel)
        /// Subscribe to the featureVisibility object. Update the visibility of the polyline label when featureVisibility[.polyline] is updated
        polylineSubscriber = $featureVisibility.map({ !($0[.polyline] ?? false) }).receive(on: DispatchQueue.main).assign(to: \.isHidden, on: polylineLabel)
        /// Subscribe to the featureVisibility object. Update the visibility of the polygon label when featureVisibility[.polygon] is updated
        polygonSubscriber = $featureVisibility.map({ !($0[.polygon] ?? false) }).receive(on: DispatchQueue.main).assign(to: \.isHidden, on: polygonLabel)
        /// Subscribe to the featureVisibility object. Update the visibility of the statusView when featureVisibility is updated
        statusSubscriber = $featureVisibility.map({ !$0.values.contains(true) }).receive(on: DispatchQueue.main).assign(to: \.isHidden, on: statusView)
        /// Subscribe to the featureVisibility object. Update the visibility of the redrawButton when featureVisibility is updated
        redrawSubscriber = $featureVisibility.map({ !($0[.polygon] ?? false || $0[.polyline] ?? false || $0[.marker] ?? false || $0[.mixed] ?? false ) }).receive(on: DispatchQueue.main).assign(to: \.isHidden, on: redrawButton) // swiftlint:disable:this line_length
    }
}

/// VisibleFeaturesControllerDelegate Conformance
extension GeoJSONViewController {
    func updateFeatures(_ featureVisibility: MapFeatureVisiblity) {
        /// Update feature visibility
        self.featureVisibility = featureVisibility
        /// Update geoJSON objects on the map
        updateGeoJSONObjects()
    }
}

/// Extension giving examples of how to work with user interaction callbacks for the VLTMapViewDelegate
extension GeoJSONViewController {
    /// Handle the map successfully loading
    func didFinishLoadingMap(mapView: VLTMapView) {
        do {
            /// Zoom the camera in to the area where shapes are displayed
            try mapView.camera.set(zoom: 12)
        } catch {
            showError(withMessage: "\(GeoJsonVC.updateCameraError): \(error)")
        }

        /// Pull in a custom image to use as a point marker, and register it for use on the map
        if let customImage = UIImage(named: VLTLiterals.AssetNameLiterals.customMarkerImage) {
            /// Create a VLTImage object using the custom UIImage
            let customImage = VLTImage(image: customImage, imageName: VLTLiterals.AssetNameLiterals.customMarkerImage)
            /// Save the custom image
            vltCustomImage = customImage
        }

        /// Update the map to display the default visible shapes and features
        updateGeoJSONObjects()
    }

    /// Handle the map failing to load
    func didFailLoadingMap(mapView: VLTMapView, error: Error) {
        showError(withMessage: "\(GeoJsonVC.loadMapError): \(error)")
    }

    /// Handle a user tapping on the mapView
    func tappedOnMap(mapView: VLTMapView, point: CGPoint, coordinate: CLLocationCoordinate2D) {
        showAlert(withMessage: GeoJsonVC.tappedOnMap)
    }
}
