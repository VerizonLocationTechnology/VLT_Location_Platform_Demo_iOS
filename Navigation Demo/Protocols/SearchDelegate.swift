//
// SearchDelegate.swift
//
// Created by Verizon Location Technology
// Copyright © 2021 Verizon Location Technology
//

/// Defines interaction for a search provider doing the search work on the behalf of parent
protocol SearchDelegate: ExitableViewDelegate {
    /// Search process has started on search provider
    func searchInitiated()

    /// Search has been completed and a set of locations to define a route are returned.
    /// - Parameters:
    ///   - withLocations: Array of locations to determine a route from. First location is the starting location, last location is the destination and location(s) between define rally/waypoints to be visited by the route.
    func searchComplete(withLocations locations: [VLTLocation])

    /// Search process needs to display an OK only alert dialog from the containing parent view
    /// - Parameters:
    ///   - title: Alert title
    ///   - message: Alert message
    func showSearchDialog(title: String, message: String)
}
