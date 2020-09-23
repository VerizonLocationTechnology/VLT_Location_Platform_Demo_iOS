//
// BoundingBoxViewController.swift
// VLTMaps SDK
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import UIKit
import VLTMaps
import CoreLocation
import Combine

class BoundingBoxViewController: UIViewController, VLTMapViewDelegate {
    // MARK: - Private Members
    // Reference to the String literals for this controller
    private typealias literals = VLTLiterals.BoundingBoxVCLiterals
    // Boolean representing whether the list of options is expanded
    private var optionsExpanded = false

    // MARK: - IBOutlets
    /// The mapView object that displays map data
    @IBOutlet weak var mapView: VLTMapView!
    
    @IBOutlet weak var coloradoButton: VLTToggleButton!
    @IBOutlet weak var texasButton: VLTToggleButton!
    @IBOutlet weak var newYorkButton: VLTToggleButton!
    @IBOutlet weak var utahButton: VLTToggleButton!

    // MARK: - Internal Members
    /// Initial padding at camera load
    let initialPadding = UIEdgeInsets(top: -120, left: -120, bottom: -120, right: -120)

    // Returns list of VLTToggleButtons on the screen
    var buttons: [VLTToggleButton] {
        [coloradoButton, texasButton, newYorkButton, utahButton]
    }

    // MARK: - Page life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set title of the view controller
        self.title = literals.title

        /// Retrieve the device's current user interface style
        let interfaceStyle = traitCollection.userInterfaceStyle

        /// Retrieve the map mode that reflects the UI style of the current device
        let mode = VLTMapMode.mapMode(forUserInterfaceStyle: interfaceStyle)

        /// Configure the map with an initial mode and the initial bounding box (around Colorado)
        let mapConfiguration = MapConfiguration(mode: mode,
                                                southwestCoordinate: BoundingBox.colorado.sw,
                                                northeastCoordinate: BoundingBox.colorado.ne,
                                                boundaryPadding: initialPadding)

        /// Set the delegate for the mapView
        mapView.delegate = self

        /// Load the map using your given API Key
        mapView.loadMap(apiKey: apiKey, configuration: mapConfiguration)
    }

    @IBAction func locationButtonTapped(_ sender: VLTToggleButton) {
        if optionsExpanded {
            navigateToLocation(for: sender)
        }
        optionsExpanded.toggle()
        updateButtons(selected: sender)
    }

    // MARK: Update Methods
    func updateButtons(selected: VLTToggleButton) {
        self.buttons.forEach({
            $0.showSelected = $0 == selected
            $0.isHidden = $0 == selected ? false : !self.optionsExpanded
        })
    }

    func navigateToLocation(for button: VLTToggleButton) {
        if button == coloradoButton {
            updateBoundingBox(with: .colorado)
        } else if button == texasButton {
            updateBoundingBox(with: .texas)
        } else if button == newYorkButton {
            updateBoundingBox(with: .newYork)
        } else {
            updateBoundingBox(with: .utah)
        }
    }

    func updateBoundingBox(with boundingBox: BoundingBox) {
        do {
            try mapView.camera.updateCamera(southwestBound: boundingBox.sw,
                                            northeastBound: boundingBox.ne,
                                            padding: boundingBox.insets,
                                            withAnimation: true)
        } catch {
            showError(withMessage: literals.cameraUpdateErrorMessage)
        }
    }
}

// MARK: VLTMapViewDelegate Conformance
extension BoundingBoxViewController {
    func tappedOnMap(mapView: VLTMapView, point: CGPoint, coordinate: CLLocationCoordinate2D) {
        print("Coordinate: \(mapView.convertPointToCoordinate(point: point))")
    }
}
