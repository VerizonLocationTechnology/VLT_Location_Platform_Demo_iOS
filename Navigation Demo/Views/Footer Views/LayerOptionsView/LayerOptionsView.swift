//
// LayerOptionsView.swift
//
// Created by Verizon Location Technology.
// Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import UIKit
import VLTMaps

/// Contract to pass user intent back to the view controller containing the LayerOptionsView
protocol LayerOptionsViewDelegate: ExitableViewDelegate {
    /// Notify the delegate that the map mode should be updated
    func didSelectMapMode(_ mode: VLTMapMode)
    /// Notify the delegate that a feature has been toggled on/off
    func didToggleMapFeature(_ feature: VLTMapFeature)
}

/// Trailer view allowing customer to change map modes and map visible features.
class LayerOptionsView: XibView {
    // MARK: Public variables
    /// Delegate that this view should update with user intent
    weak var delegate: LayerOptionsViewDelegate?

    // MARK: IBOutlets
    /// Segmented control depicting the current map mode
    @IBOutlet private weak var modeSegmentedControl: UISegmentedControl!
    /// Toggle switch depicting the visibility of traffic flow data on the map
    @IBOutlet private weak var trafficFlowToggle: UISwitch!
    /// Toggle switch depicting the visibility of traffic incident data on the map
    @IBOutlet private weak var trafficIncidentsToggle: UISwitch!
    
    // MARK: Functions
    /// Updates the view with a new mode and indicator for traffic data visibility
    /// - Parameters:
    ///   - withMode: The mode that the view should display as selected
    ///   - trafficOn: Indicator of whether the trafficToggle should be in the 'on' or 'off' state
    func update(withMode mode: VLTMapMode, trafficOn: Bool, incidentsOn: Bool) {
        layer.cornerRadius = 16
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        trafficFlowToggle.isOn = trafficOn
        trafficIncidentsToggle.isOn = incidentsOn
        switch mode {
        case .day:
            modeSegmentedControl.selectedSegmentIndex = 0
        case .night:
            modeSegmentedControl.selectedSegmentIndex = 1
        default:
            modeSegmentedControl.selectedSegmentIndex = 2
        }
    }

    // MARK: IBActions
    /// Handle the changing of the segmented control's selected map mode
    /// - Parameter sender: The segmented control whose selected value has been updated
    @IBAction private func modeControlValueChanged(_ sender: UISegmentedControl) {
        let selectedMode = sender.selectedSegmentIndex
        switch selectedMode {
        case 0:
            delegate?.didSelectMapMode(.day)
        case 1:
            delegate?.didSelectMapMode(.night)
        default:
            delegate?.didSelectMapMode(.satellite)
        }
    }

    /// Handle the changing of the traffic toggle's value
    /// - Parameter sender: The toggle switch whose value has been updated
    @IBAction private func toggleValueChanged(_ sender: UISwitch) {
        if sender == trafficFlowToggle {
            delegate?.didToggleMapFeature(.traffic)
        } else if sender == trafficIncidentsToggle {
            delegate?.didToggleMapFeature(.incidents)
        }
    }

    /// Handle the user tapping the 'X' button of the view
    @IBAction private func closeButtonTapped() {
        delegate?.exitView()
    }
}
