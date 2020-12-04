//
// MapboxIntegrationViewController.swift
// VLTDemo
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import UIKit
import VLTMaps
import Mapbox

class MapboxIntegrationViewController: UIViewController, VLTMapViewDelegate, MGLMapViewDelegate {
    // MARK: - Private variables
    private typealias literals = VLTLiterals.MapboxIntegrationVCLiterals

    // Coordinates for MGLAnnotations being added to the map
    private let coordinates = [
        CLLocationCoordinate2DMake(0, -70),
        CLLocationCoordinate2DMake(0, -35),
        CLLocationCoordinate2DMake(0, 0),
        CLLocationCoordinate2DMake(0, 35),
        CLLocationCoordinate2DMake(0, 70)
    ]

    // Coordinates for VLTMapMarker objects being added to the map
    private let otherCoordinates = [
        CLLocationCoordinate2DMake(0, -52.5),
        CLLocationCoordinate2DMake(0, -17.5),
        CLLocationCoordinate2DMake(0, 17.5),
        CLLocationCoordinate2DMake(0, 52.5)
    ]

    // MARK: - Outlets
    @IBOutlet weak var mapView: VLTMapView!

    // MARK: - Page life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = literals.title

        /// Configure the map with the initial mode, any built-in features that should be hidden, and the initial center for the camera
        let mapConfiguration = MapConfiguration(mode: .day,
                                                hiddenFeatures: [.traffic],
                                                cameraCenter: CLLocationCoordinate2DMake(0, 0))

        /// Load the map using your given API key
        mapView.loadMap(apiKey: apiKey, configuration: mapConfiguration)

        /// Set this view controller as the VLTMapViewDelegate for the mapView
        mapView.delegate = self
    }
}

// MARK: - VLTMapViewDelegate
extension MapboxIntegrationViewController {
    func didFinishLoadingMap(mapView: VLTMapView) {
        // Set the delegate for the Mapbox - MGLMapViewDelegate to fire properly
        mapView.map?.delegate = self

        // Add MGLAnnotations
        // - Create point annotation array
        var pointAnnotations = [MGLPointAnnotation]()
        coordinates.forEach({
            let point = MGLPointAnnotation()
            point.coordinate = $0
            point.title = "Longitude: \($0.longitude)"
            pointAnnotations.append(point)
        })
        // - Add annotations to the map
        mapView.map?.addAnnotations(pointAnnotations)

        // Add VLTMapMarkers
        let markers = otherCoordinates.map({ VLTMapMarker(coordinate: $0)})
        do {
            try mapView.add(objects: markers)
        } catch {
            showError(withMessage: literals.addMarkersErrorMessage)
        }

        // Adjust the camera out to make the Annotations and Markers visible from the outset
        do {
            try mapView.camera.set(zoom: 0)
        } catch {
            showError(withMessage: literals.cameraUpdateErrorMessage)
        }
    }
}

// MARK: - MGLMapViewDelegate
extension MapboxIntegrationViewController {
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        guard annotation is MGLPointAnnotation else { return nil }

        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "customPoint") {
            return annotationView
        } else {
            return CustomMglAnnotationView(reuseIdentifier: "customPoint", size: 50)
        }
    }

    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
}
