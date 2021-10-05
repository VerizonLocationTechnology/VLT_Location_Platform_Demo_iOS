//
// RouteOverviewFooterView.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import heresdk
import UIKit

/// View displaying route information the user
class RouteOverviewFooterView: XibView {
    /// Label for displaying the remaining travel time for the route
    @IBOutlet private weak var timeLabel: UILabel!
    /// Label for displaying the remaining travel distance for the route
    @IBOutlet private weak var distanceLabel: UILabel!

    /// Stack view containing the 'Route Details' button and label
    @IBOutlet private weak var routeDetailsStackView: UIStackView!
    /// Stack view containing the 'Start Navigation' button and label
    @IBOutlet private weak var startNavigationStackView: UIStackView!
    /// Stack view containing the 'End Navigation' button and label
    @IBOutlet private weak var endNavigationStackView: UIStackView!

    /// Enum describing the various modes that this view can reside in
    enum Mode {
        case preNavigation, navigation, postNavigation
    }

    /// Delegate that this view should report to for navigation events
    weak var navigationCoordinatorDelegate: NavigationCoordinatorDelegate?
    /// Delegate that this view should report to for exit events
    weak var exitableViewDelegate: ExitableViewDelegate?

    /// Current mode of the view
    var mode: Mode = .preNavigation {
        /// Updates the view to the layout matching the given mode
        didSet {
            startNavigationStackView.isHidden = mode != .preNavigation
            endNavigationStackView.isHidden = mode == .preNavigation

            distanceLabel.isHidden = mode == .postNavigation
            timeLabel.isHidden = mode == .postNavigation
        }
    }

    /// Updates the view with a new route and measurement setting
    /// - Parameters:
    ///   - withRoute: The route whose distance data should be displayed to the user
    ///   - imperialMeasure: Indicator of whether or not to use imperial measurements
    func update(withRoute route: Route, imperialMeasure: Bool) {
        layer.cornerRadius = 16
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        timeLabel.text = route.durationInSeconds.formatSecondsIntoTimeDisplay()
        distanceLabel.text = "(" + route.lengthInMeters.formatMetersAsLengthDisplay(imperialMeasure: imperialMeasure) + ")"
    }

    /// Updates the view with new distance and time data
    /// - Parameters:
    ///   - withDistance: The remaining travel distance to be displayed
    ///   - andTime: The remaining travel time to be displayed
    ///   - imperialMeasure: Indicator of whether or not distance should be displayed in Imperial units
    func update(withDistance distance: Int32, andTime time: Int32, imperialMeasure: Bool) {
        timeLabel.text = time.formatSecondsIntoTimeDisplay()
        distanceLabel.text = "(" + distance.formatMetersAsLengthDisplay(imperialMeasure: imperialMeasure) + ")"
    }

    /// Handle the event of the user tapping the 'Route Details' Button
    @IBAction private func routeDetailsButtonTapped() {
        navigationCoordinatorDelegate?.showDirections()
    }

    /// Handle the event of the user tapping the 'Start Navigation' Button
    @IBAction private func startNavigationButtonTapped() {
        navigationCoordinatorDelegate?.startNavigation()
    }

    /// Handle the event of the user tapping the 'End Navigation' Button
    @IBAction private func endNavigationButtonTapped() {
        navigationCoordinatorDelegate?.endNavigation()
    }

    /// Handle the event of the user tapping the 'X' Button
    @IBAction private func exitButtonTapped() {
        exitableViewDelegate?.exitView()
    }
}
