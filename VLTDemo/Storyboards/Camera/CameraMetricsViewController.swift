//
//  CameraMetricsViewController.swift
//  VLTDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import UIKit

/// View Controller allowing a user to interact with specific metrics of the VLTCamera object
class CameraMetricsViewController: UIViewController {
    // MARK: - Public members
    /// The delegate object to communicate back to when updates are made to the camera metrics
    var delegate: CameraMetricsControllerDelegate?
    /// The current metrics displayed to the user
    var cameraMetrics = CameraMetrics()
    
    // MARK: - IBOutlets
    /// Text field for adjusting the current zoom level value
    @IBOutlet weak var zoomLevelTextField: VLTTextField!
    /// Text field for adjusting the current bearing value
    @IBOutlet weak var bearingTextField: VLTTextField!
    /// Text field for adjusting the current tilt value
    @IBOutlet weak var tiltTextField: VLTTextField!
    
    // MARK: - Page life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the title of the view controller
        self.title = VLTLiterals.CameraMetricsVCLiterals.title
        
        // Update the zoomLevel, bearing, and tilt text fields with initial values
        zoomLevelTextField.text = cameraMetrics.zoomLevel.roundedString()
        bearingTextField.text = cameraMetrics.bearing.roundedString()
        tiltTextField.text = cameraMetrics.tilt.roundedString()
    }
    
    // MARK: - IBActions
    /// Updates the current metrics state and returns to the previous view controller
    @IBAction func updateButtonTapped() {
        updateMetrics()
        self.navigateBack(animated: true)
    }
    
    // MARK: - Private functions
    /// Updates the current metrics state to reflect the values in the zoomLevel, bearing, and tilt text fields, and then update the delegate with the new values
    func updateMetrics() {
        var zoomLevel: Double?
        var bearing: Double?
        var tilt: Double?
        
        if let zoomText = zoomLevelTextField.text {
            zoomLevel = Double(zoomText)
        }
        if let bearingText = bearingTextField.text {
            bearing = Double(bearingText)
        }
        if let tiltText = tiltTextField.text {
            tilt = Double(tiltText)
        }
        
        delegate?.update(CameraMetrics(zoomLevel: zoomLevel ?? cameraMetrics.zoomLevel,
                                       bearing: bearing ?? cameraMetrics.bearing,
                                       tilt: tilt ?? cameraMetrics.tilt))
    }
}
