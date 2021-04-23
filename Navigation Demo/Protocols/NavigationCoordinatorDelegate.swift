//
// NavigationCoordinatorDelegate.swift
//
// Created by Verizon Location Technology.
// Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import heresdk

/// Defines the events needed for the coordinator to properly manage the navigation experience
/// Note: The root view controller for this navigation experience is a view containing a map
protocol NavigationCoordinatorDelegate: ExitableViewDelegate {
    /// Notify the coordinator that a route has been chosen. Set to nil when new routing interactions are occuring.
    func routeSelected(_ route: Route?)
    /// Notify the coordinator that it should begin navigating
    func startNavigation()
    /// Notify the coordinator to show the direction list based on a route that has been selected
    func showDirections()
    /// Notify the coordinator that the directions list should be dismissed
    func dismissDirections()
    /// Notify the coordinator that navigation should end
    func endNavigation()
}
