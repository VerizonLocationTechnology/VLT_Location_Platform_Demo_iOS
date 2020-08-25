//
//  ModesViewController.swift
//  VLTDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import UIKit
import VLTMaps
import CoreLocation

/// View controller that displays VLTMaps' ability to easily change the style mode of the map
class ModesViewController: UIViewController {
    // MARK: - Private Members
    private typealias literals = VLTLiterals.ModesVCLiterals

    // MARK: - IBOutlets
    /// The mapView object that displays map data
    @IBOutlet weak var mapView: VLTMapView!
    /// Segmented control for displaying the currently selected map mode
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    // MARK: - Page life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set title of the view controller
        self.title = literals.title

        /// Retrieve the device's current user interface style
        let interfaceStyle = traitCollection.userInterfaceStyle

        /// Retrieve the map mode that reflects the UI style of the current device
        let mode = VLTMapMode.mapMode(forUserInterfaceStyle: interfaceStyle)

        /// Set the segmented control selected index to reflect the UI style of the current device
        switch interfaceStyle {
        case .light, .unspecified:
            segmentedControl.selectedSegmentIndex = 0
        case .dark:
            segmentedControl.selectedSegmentIndex = 1
        @unknown default:
            segmentedControl.selectedSegmentIndex = 0
        }

        /// Configure the map with the initial mode, any built-in features that should be hidden, and the initial center for the camera
        let mapConfiguration = MapConfiguration(mode: mode,
                                                hiddenFeatures: [.traffic],
                                                cameraCenter: CLLocationCoordinate2D(latitude: 42.3637, longitude: -71.053604))

        /// Load the map using your given API key
        mapView.loadMap(apiKey: apiKey, configuration: mapConfiguration)
    }

    // MARK: - IBActions
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        /// Determine which mode to change to based on the selected index of the UISegmentedControl
        switch sender.selectedSegmentIndex {
        case 2:
            /// Update the map to use satellite mode
            updateMap(.satellite)
        case 1:
            /// Update the map to use night mode
            updateMap(.night)
        default:
            /// Update the map to use day mode
            updateMap(.day)
        }
    }

    // MARK: - Private functions
    func updateMap(_ mode: VLTMapMode) {
        do {
            /// Update the map to use the designated mode
            try mapView.setMode(mode: mode)
        } catch {
            /// If the map mode update fails, display an error
            showError(withMessage: "\(literals.modeUpdateErrorMessage): \(error)")
        }
    }

}
