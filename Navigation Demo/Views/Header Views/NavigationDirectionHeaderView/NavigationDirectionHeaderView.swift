//
// NavigationDirectionHeaderView.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import heresdk
import UIKit

/// Header View displaying navigation directions to the user
class NavigationDirectionHeaderView: XibView {
    /// Label for the description of the direction being given
    @IBOutlet private weak var descriptionLabel: UILabel!
    /// Label for the remaining distance until the navigation direction should be followed
    @IBOutlet private weak var distanceLabel: UILabel!
    /// Image depicting the type of direction being given (Depart, Arrive, Turn Left, etc.)
    @IBOutlet private weak var directionImage: UIImageView!

    /// Updates the view to the current maneuver being displayed
    /// - Parameters:
    ///   - maneuver: The HERE maneuver that the user should perform next
    ///   - withProgress: The user's current progress that the user has made through the current maneuver
    ///   - imperialMeasure: Indicator of whether or not distance should be displayed with imperial units of measure
    func hereManeuver(_ maneuver: Maneuver, withProgress progress: ManeuverProgress, imperialMeasure: Bool) {
        distanceLabel.isHidden = false

        directionImage.image = maneuver.action.image

        distanceLabel.text = progress.remainingDistanceInMeters.formatMetersAsLengthDisplay(imperialMeasure: imperialMeasure)
        descriptionLabel.text = maneuver.action.readable(maneuver.nextRoadTexts.names.preferredValue(for: [.current]))
    }

    /// Updates the view to enter the 'Proceed to Route' state (user has not yet entered the route path)
    func proceedToRoute() {
        distanceLabel.isHidden = true
        directionImage.image = ManeuverAction.depart.image
        descriptionLabel.text = "Proceed to the Route"
    }

    /// Updates the view to enter the 'Destination Reached' state
    /// - Parameter route: The route which has just been completed
    func destinationReached(for route: Route) {
        guard let maneuver = route.sections.last?.maneuvers.last else {
            descriptionLabel.text = "You have arrived at your destination!"
            directionImage.image = ManeuverAction.arrive.image
            return
        }

        distanceLabel.isHidden = true
        descriptionLabel.text = maneuver.text
        directionImage.image = maneuver.action.image
    }
}
