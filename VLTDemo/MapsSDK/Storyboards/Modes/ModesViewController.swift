//
// ModesViewController.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import CoreLocation
import UIKit
import VLTMaps

/// View controller that displays VLTMaps' ability to easily change the style mode of the map
class ModesViewController: UIViewController {
    // MARK: - Private Members
    private typealias VCLiterals = VLTLiterals.ModesVCLiterals
    private var featuresViewHidden = true
    private var hiddenFeatures = [VLTMapFeature.traffic, VLTMapFeature.incidents]
    
    // MARK: - IBOutlets
    /// The mapView object that displays map data
    @IBOutlet weak var mapView: VLTMapView!
    /// Segmented control for displaying the currently selected map mode
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    /// Features view
    @IBOutlet weak var featuresEffectsView: UIVisualEffectView!
    @IBOutlet weak var featureChevronButton: UIButton!
    @IBOutlet weak var trafficSwitch: UISwitch!
    @IBOutlet weak var incidentsSwitch: UISwitch!
    @IBOutlet weak var centerOnMeButton: UIButton!
    
    @IBOutlet weak var featuresLabelToLeading: NSLayoutConstraint!
    @IBOutlet weak var featuresLabelToBotton: NSLayoutConstraint!
    
    // MARK: - Page life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title of the view controller
        self.title = VCLiterals.title
        
        /// Retrieve the device's current user interface style
        let interfaceStyle = traitCollection.userInterfaceStyle
        
        /// Retrieve the map mode that reflects the UI style of the current device
        let mode = VLTMapMode.mapMode(forUserInterfaceStyle: interfaceStyle)
        
        /// Set the segmented control selected index to reflect the UI style of the current device
        switch interfaceStyle {
        case .light, .unspecified:
            segmentedControl.selectedSegmentIndex = 0
        case .dark:
            segmentedControl.selectedSegmentIndex = 2
        @unknown default:
            segmentedControl.selectedSegmentIndex = 0
        }
        
        /// Configure the map with the initial mode, any built-in features that should be hidden, and the initial center for the camera
        let mapConfiguration = MapConfiguration(mode: mode,
                                                hiddenFeatures: hiddenFeatures,
                                                cameraCenter: CLLocationCoordinate2D(latitude: 42.3637, longitude: -71.053_604))
        
        /// Load the map using your given API key
        mapView.loadMap(apiKey: apiKey, configuration: mapConfiguration)
        featuresEffectsView.cornerRadius = 12
        featuresLabelToLeading.constant = 8
        featuresLabelToBotton.constant = 4
    }
    
    // MARK: - IBActions
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        /// Determine which mode to change to based on the selected index of the UISegmentedControl
        switch sender.selectedSegmentIndex {
        case 4:
            /// Update the map to use satellite mode
            updateMap(.satellite)
        case 3:
            /// Update the map to use night 3D mode
            updateMap(.night3D)
        case 2:
            /// Update the map to use night mode
            updateMap(.night)
        case 1:
            /// Update the map to use day 3D mode
            updateMap(.day3D)
        default:
            /// Update the map to use day mode
            updateMap(.day)
        }
    }
    
    @IBAction func toggleFeatures(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            self.featureChevronButton.setImage(UIImage(systemName: self.featuresViewHidden ? "chevron.down" :  "chevron.up"), for: .normal)
            self.featuresLabelToLeading.constant = self.featuresViewHidden ? 150 : 8
            self.featuresLabelToBotton.constant = self.featuresViewHidden ? 85 : 4
            self.featuresViewHidden.toggle()
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func centerOnMe(_ sender: UIButton) {
        mapView.map?.showsUserLocation = true
        mapView.map?.userTrackingMode = .follow
        if let coordinate = mapView.map?.userLocation?.coordinate, coordinate.latitude != -180 {
            mapView.map?.setCenter(coordinate, zoomLevel: 14, animated: false)
        } else {
            centerOnMeButton.setTitle("Zoom In", for: .normal)
        }
    }
    
    @IBAction func trafficFlowToggle(_ sender: UISwitch) {
        didToggleMapFeature(.traffic)
    }
    
    @IBAction func trafficIncidentToggle(_ sender: UISwitch) {
        didToggleMapFeature(.incidents)
    }
    
    // MARK: - Private functions
    private func updateMap(_ mode: VLTMapMode) {
        do {
            /// Update the map to use the designated mode
            try mapView.setMode(mode: mode)
        } catch {
            /// If the map mode update fails, display an error
            showError(withMessage: "\(VCLiterals.modeUpdateErrorMessage): \(error)")
        }
    }
    
    /// Update the map to show/hide specific features
    /// - Parameter feature: The feature to be toggled
    func didToggleMapFeature(_ feature: VLTMapFeature) {
        do {
            if hiddenFeatures.contains(feature) {
                /// Shows the traffic content of the map
                try mapView.toggleMapFeatures([feature], isHidden: false )
                /// Remove the feature from hiddenFeatures now that it is visible
                if let idx = hiddenFeatures.firstIndex(of: feature) {
                    hiddenFeatures.remove(at: idx)
                }
            } else {
                /// Hides the traffic content of the map
                try mapView.toggleMapFeatures([feature], isHidden: true )
                hiddenFeatures.append(feature)
            }
        } catch {
            /// Display an error to the user if updating the traffic visibility fails
            showError(withMessage: "\(VLTLiterals.ShapesVCLiterals.updateTrafficFlowErrorMessage): \(error)")
        }
    }
}
