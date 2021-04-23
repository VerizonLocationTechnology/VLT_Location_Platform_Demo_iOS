//
// SearchHeaderView.swift
// VLTMaps SDK
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import CoreLocation
import heresdk
import UIKit
import VLTFoundation
import VLTSearch

/// Header that encompasses a location and route search process
class SearchHeaderView: XibView, UISearchBarDelegate, SearchResultsTableDelegate {
    // MARK: - Private Outlets

    /// Containing stackView for all main components in the searchHeader
    @IBOutlet private weak var mainStackView: UIStackView!

    /// Container for the starting location search bar
    @IBOutlet private weak var startingLocationContainer: UIView!
    /// Search bar for the starting location of a route
    @IBOutlet private weak var startingLocationSearchBar: UISearchBar!
    /// Overlay button for re-entering search mode when the starting location search bar is tapped
    @IBOutlet private weak var startingLocationOverlayButton: UIButton!

    /// Search bar for the final destination of a route
    @IBOutlet private weak var destinationSearchBar: UISearchBar!
    /// Stack view containing the destination search bar and its image
    @IBOutlet private weak var destinationStackView: UIStackView!
    /// Container for the image of the route destination search bar
    @IBOutlet private weak var destinationImageContainer: UIView!
    /// Overlay button for re-entering search mode when the destination location search bar is tapped
    @IBOutlet private weak var destinationOverlayButton: UIButton!
    /// StackView containing all search bars
    @IBOutlet private weak var searchBarStackView: UIStackView!

    /// Container for the cancel button of the view
    @IBOutlet private weak var cancelButtonContainer: UIView!
    /// UIStackView containing the cancel button and search bars
    @IBOutlet private weak var cancelButtonStackView: UIStackView!
    /// Container for the directions button
    @IBOutlet private weak var directionsButtonContainer: UIView!
    /// Directions button for completing the search process
    @IBOutlet private weak var directionsButton: UIButton!
    /// Container for the Mode of Transportation segmented control
    @IBOutlet private weak var motSegmentedControlContainer: UIView!

    /// Container for the search results table view
    @IBOutlet private weak var tableViewContainer: UIView!
    /// Table view for results of a location search
    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Public Members
    /// Distance between the bottom of the view and the nearest content
    var bottomInset: CGFloat = 0 {
        didSet {
            self.tableView.contentInset.bottom = bottomInset
        }
    }

    /// State Enum Declaration
    enum SearchHeaderState {
        // Start - Single destination search bar shown. User interaction button is enabled
        case start
        // Destination Search - Full screen mode, single search bar, with table view and keyboard bur no current location
        case destinationSearch
        // Route Search - Full screen mode, dual search bars, with table view, keyboard and current location
        case routeSearch
        // Retrieving Route - Full screen mode, dual search bars, no direction button, no table view, route types may or not be there.
        case retrievingRoute
        // Route Overview - Both start and end search bars with mode of travel buttons showing. User interaction buttons enabled.
        case routeOverview

        /// Updates the given view to the appropriate layout based on the new state
        /// - Parameter searchHeaderView: The view to be updated to a new layout
        func updateView(_ searchHeaderView: SearchHeaderView) {
            switch self {
            case .start:
                searchHeaderView.moveToStartState()
            case .destinationSearch:
                searchHeaderView.moveToDestinationSearch()
            case .routeSearch:
                searchHeaderView.moveToRouteSearch()
            case .retrievingRoute:
                searchHeaderView.moveToRetrievingRoute()
            case .routeOverview:
                searchHeaderView.moveToRouteOverview()
            }
        }
    }

    // MARK: - Private Members
    /// Search delegate for this header view
    private weak var searchDelegate: SearchDelegate?
    /// Mode Of Transportation Delegate for this header view
    private weak var motDelegate: ModeOfTravelDelegate?
    /// Delegate for searchResultsTableView (name truncated for the linter)
    private var searchResultsTable: SearchResultsTable?
    /// Storage for the currently active search bar
    private var activeSearchBar: UISearchBar?
    /// Storage for the height constraint of the view when searching
    private var heightConstraint: NSLayoutConstraint?

    /// Current state of the view
    var state: SearchHeaderState = .start {
        willSet {
            previousState = state
        }
        didSet {
            DispatchQueue.main.async {
                self.state.updateView(self)
            }
        }
    }
    /// Previous state of the view
    private var previousState: SearchHeaderState = .start

    /// Holds the most recent current location.  This not 100% current all the time but should be close enough for the rough calculations
    private let currentLocation = VLTLocation(named: "Current Location",
                                              coordinate: CLLocationCoordinate2DMake(42.3637, -71.053_604),
                                              isCurrentLocation: true)

    /// Closure called to update the current location.  
    private var currentLocationUpdate: VoidClosure?

    /// Route Starting Location
    private var startLocation: VLTLocation?

    /// Route End/Destination Location
    private var destinationLocation: VLTLocation?

    /// Determine whether a route can be generated from selected locations
    private var validRoute: Bool {
        return startLocation != nil && destinationLocation != nil
    }
    /// Track whether to show user location because it is tied to state
    private var showUserLocation = false

    /// Timer for updating search query calls
    private var searchTimer: Timer?

    // MARK: - Internal Methods
    /// Update the state of the view to show and hide search components
    /// - Parameters:
    ///   - searchDelegate: The delegate to update as search processes are initiated, completed, or cancelled
    ///   - imperialMeasure: Indicator of whether or not search result distances should be displayed in imperial units
    ///   - getLocationClosure: Closure to be called when the user's current location should be updated
    internal func setupView(searchDelegate: SearchDelegate?,
                            imperialMeasure: Bool,
                            getLocatonClosure: @escaping VoidClosure) {
        // Set view object to their correct visiblity for the state engine to work properly
        startingLocationContainer.isHidden = true
        startingLocationContainer.alpha = 0
        destinationImageContainer.isHidden = true
        destinationImageContainer.alpha = 0
        cancelButtonContainer.isHidden = true
        cancelButtonContainer.alpha = 0
        directionsButtonContainer.isHidden = true
        directionsButtonContainer.alpha = 0
        motSegmentedControlContainer.isHidden = true
        motSegmentedControlContainer.alpha = 0
        tableViewContainer.isHidden = true
        self.searchResultsTable = SearchResultsTable(self, tableView: tableView, imperialMeasure: imperialMeasure)
        self.startLocation = currentLocation
        self.searchDelegate = searchDelegate
        self.currentLocationUpdate = getLocatonClosure
    }

    // MARK: - Internal Methods
    /// Updates the user's current location data
    internal func updateCurrentLocation(_ coordinates: CLLocationCoordinate2D) {
        currentLocation.setCoordinate(coordinates)
    }

    /// Update the Mode of Travel delegate
    /// - Parameters:
    ///   - motDelegate: The delegate to update when a different Mode of Travel is selected by the user
    internal func updateMOTDelegate(to motDelegate: ModeOfTravelDelegate) {
        self.motDelegate = motDelegate
    }

    /// Rewinds the state of the search header to the previous state
    func rewindState() {
        self.state = previousState
    }

    // MARK: - Private IBActions
    /// Called when Mode Of Travel changes on the segmented control
    ///  - Parameter sender: The UISegmentedControl whose value changed
    @IBAction private func motValueChanged(_ sender: UISegmentedControl) {
        // Update the mode of travel for the map route
        switch sender.selectedSegmentIndex {
        case 0:
            motDelegate?.updated(routeType: .car)
        case 1:
            motDelegate?.updated(routeType: .pedestrian)
        default:
            motDelegate?.updated(routeType: .truck)
        }
    }

    /// Handle a search bar's corresponding overlaying button being tapped
    ///  - Parameter sender: The UIButton that was tapped
    @IBAction private func overlayButtonTapped(_ sender: UIButton) {
        if sender == startingLocationOverlayButton {
            activeSearchBar = startingLocationSearchBar
        } else {
            activeSearchBar = destinationSearchBar
        }
        searchDelegate?.searchInitiated()
    }

    /// Handle the tapping of the directions button by the user (update the search delegate that this search is complete)
    @IBAction private func directionsButtonTapped() {
        if validRoute {
            searchDelegate?.searchComplete(withLocations: layoutRoute())
        } else {
            if state == .destinationSearch {
                state = .routeSearch
            } else {
                searchDelegate?.showSearchDialog(title: "Get Directions", message: "Unable to get a directions without both a starting and destination location.")
            }
        }
    }

    /// Handle the tapping of the cancel button by the user (update the search delegate that this search has been cancelled)
    @IBAction private func cancelButtonTapped() {
        // Note: Calling controller should place this back in the correct state of `.start`
        searchDelegate?.exitView()
    }
}

// MARK: Layout Methods
extension SearchHeaderView {
    /// Move the view to its initial layout state (only destination bar visible with overlay button active, cancel button hidden)
    private func moveToStartState() {
        startLocation = nil
        destinationLocation = nil
        showUserLocation = false
        hideButtonOverlays(false)
        activeSearchBar?.resignFirstResponder()
        activeSearchBar = nil
        hideTables()
        destinationSearchBar.text = nil
        startingLocationSearchBar.text = nil

        UIView.animate(withDuration: 0.5) {
            // Hide Cancel Button
            if !self.cancelButtonContainer.isHidden {
                self.cancelButtonContainer.alpha = 0
                self.cancelButtonContainer.isHidden = true
                self.cancelButtonStackView.layoutIfNeeded()
            }

            // Hide destination image
            if !self.destinationImageContainer.isHidden {
                self.destinationImageContainer.alpha = 0
                self.destinationImageContainer.isHidden = true
                self.destinationStackView.layoutIfNeeded()
            }

            var shouldRefreshMain = false

            // Hide startingLocationStackView
            if !self.startingLocationContainer.isHidden {
                self.startingLocationContainer.alpha = 0
                self.startingLocationContainer.isHidden = true
                shouldRefreshMain = true
            }
            // Hide mot segmented control
            if !self.motSegmentedControlContainer.isHidden {
                self.motSegmentedControlContainer.alpha = 0
                self.motSegmentedControlContainer.isHidden = true
                shouldRefreshMain = true
            }

            // Hide Directions button
            if !self.directionsButtonContainer.isHidden {
                self.directionsButtonContainer.alpha = 0
                self.directionsButtonContainer.isHidden = true
                shouldRefreshMain = true
            }

            if shouldRefreshMain {
                self.mainStackView.layoutIfNeeded()
            }
        }
    }

    /// Move the view to its destination search layout state (only destination bar visible, destination image visible, tableView visible, and overlay button disabled, cancel button visible)
    private func moveToDestinationSearch() {
        showUserLocation = false
        hideButtonOverlays(true)

        UIView.animate(withDuration: 0.5) {
            if self.cancelButtonContainer.isHidden {
                // Show Cancel Button
                self.cancelButtonContainer.alpha = 1
                self.cancelButtonContainer.isHidden = false
                self.cancelButtonStackView.layoutIfNeeded()
            }

            if !self.directionsButtonContainer.isHidden {
                // Hide Directions Button
                self.directionsButtonContainer.alpha = 0
                self.directionsButtonContainer.isHidden = true
            }

            if self.destinationImageContainer.isHidden {
                // Show destination image
                self.destinationImageContainer.alpha = 1
                self.destinationImageContainer.isHidden = false
                // Refresh destinationStackView subviews
                self.destinationStackView.layoutIfNeeded()
            }

            var updateMainStack = false

            // Hide startingLocationStackView
            if !self.startingLocationContainer.isHidden {
                self.startingLocationContainer.alpha = 0
                self.startingLocationContainer.isHidden = true
                updateMainStack = true
            }
            // Hide mot segmented control
            if !self.motSegmentedControlContainer.isHidden {
                self.motSegmentedControlContainer.alpha = 0
                self.motSegmentedControlContainer.isHidden = true
                updateMainStack = true
            }

            if updateMainStack {
                self.mainStackView.layoutIfNeeded()
            }
        } completion: { _ in
            self.showTables()
            // Set the destinationSearchBar as first responder
            self.destinationSearchBar.becomeFirstResponder()
        }
    }

    /// Move the view to its route search layout state (both search bars visible with images, tableView visible, overlay buttons disabled, cancel button visible)
    private func moveToRouteSearch() {
        showUserLocation = true
        hideButtonOverlays(true)
        showTables()
        // Need to reload the table showing user location
        searchResultsTable?.update(locations: [], showUserLocation: showUserLocation)

        updateStartLocation(startLocation ?? currentLocation)
        startingLocationSearchBar.text = startLocation?.name

        UIView.animate(withDuration: 0.5) {
            // Set destination name to first route stop or current destination
            self.destinationSearchBar.text = self.destinationLocation?.name
            // Set starting location name to current location or current starting location
            self.startingLocationSearchBar.text = self.startLocation?.name

            // Show Cancel Button
            if self.cancelButtonContainer.isHidden {
                self.cancelButtonContainer.alpha = 1
                self.cancelButtonContainer.isHidden = false
                // Update cancel buttons stackView
                self.cancelButtonStackView.layoutIfNeeded()
            }

            var shouldRefreshMain = false

            // Show startingLocationStackView
            if self.startingLocationContainer.isHidden {
                self.startingLocationContainer.alpha = 1
                self.startingLocationContainer.isHidden = false
                shouldRefreshMain = true
            }

            // Hide mot segmented control
            if !self.motSegmentedControlContainer.isHidden {
                self.motSegmentedControlContainer.alpha = 0
                self.motSegmentedControlContainer.isHidden = true
                shouldRefreshMain = true
            }

            // Show directionsButtonContainer
            if self.directionsButtonContainer.isHidden {
                self.directionsButtonContainer.alpha = 1
                self.directionsButtonContainer.isHidden = false
                shouldRefreshMain = true
            }

            if shouldRefreshMain {
                // Update Main StackView
                self.mainStackView.layoutIfNeeded()
            }
        } completion: { _ in
            // Set the last-selected search bar as first responder
            self.activeSearchBar?.becomeFirstResponder()
        }
    }

    /// Move the view to its .retrievingRoute state (Both search fields visible and populated with the user's selected path waypoint locations, segmented control visible)
    private func moveToRetrievingRoute() {
        showUserLocation = false
        hideButtonOverlays(false)
        hideTables()

        UIView.animate(withDuration: 0.5) {
            var updateMainStack = false

            // Hide Directions Button
            if !self.directionsButtonContainer.isHidden {
                self.directionsButtonContainer.alpha = 0
                self.directionsButtonContainer.isHidden = true
                updateMainStack = true
            }

            // Show mot segmented control
            if self.motSegmentedControlContainer.isHidden {
                self.motSegmentedControlContainer.alpha = 1
                self.motSegmentedControlContainer.isHidden = false
                updateMainStack = true
            }

            // Re-layout the main stack view
            if updateMainStack {
                self.mainStackView.layoutIfNeeded()
            }
        }
    }

    /// Move the view to its route overview state (both search bars visible without images, Mode of Travel picker visible, cancel button hidden)
    private func moveToRouteOverview() {
        showUserLocation = false
        hideButtonOverlays(false)
        hideTables()

        UIView.animate(withDuration: 0.5) {
            // Hide Cancel Button
            if !self.cancelButtonContainer.isHidden {
                self.cancelButtonContainer.alpha = 0
                self.cancelButtonContainer.isHidden = true
            }

            // Show startingLocationStackView
            if self.startingLocationContainer.isHidden {
                self.startingLocationContainer.alpha = 1
                self.startingLocationContainer.isHidden = false
            }

            var updateMainStack = false

            // Hide Directions Button
            if !self.directionsButtonContainer.isHidden {
                self.directionsButtonContainer.alpha = 0
                self.directionsButtonContainer.isHidden = true
                updateMainStack = true
            }

            // Show mot segmented control
            if self.motSegmentedControlContainer.isHidden {
                self.motSegmentedControlContainer.alpha = 1
                self.motSegmentedControlContainer.isHidden = false
                updateMainStack = true
            }

            // Update Main Stack View
            if updateMainStack {
                self.mainStackView.layoutIfNeeded()
            }
        }
    }

    /// Hides the tableView and removes the height constraint for the view
    private func hideTables() {
        searchResultsTable?.update(locations: [])
        if !tableViewContainer.isHidden {
            tableView.alpha = 1
            UIView.animate(withDuration: 0.5) {
                self.tableView.alpha = 0
                self.tableViewContainer.isHidden = true
                self.mainStackView.layoutIfNeeded()
            }
        }
    }

    /// Shows the search result tables and expands the view to fill the screen
    private func showTables() {
        if tableViewContainer.isHidden {
            tableView.alpha = 0
            tableViewContainer.isHidden = false

            UIView.animate(withDuration: 0.25) {
                self.tableView.alpha = 1
            }
        }
    }

    /// Shows and hides the overlay buttons for the search bars
    /// - Parameters:
    ///   - shouldHide: Indicator or whether or not the overlay buttons should be hidden
    private func hideButtonOverlays(_ shouldHide: Bool) {
        startingLocationOverlayButton.isHidden = shouldHide
        destinationOverlayButton.isHidden = shouldHide
    }

    /// Define the content of the current route
    /// - Returns: The list of locations that the route should pass through
    private func layoutRoute() -> [VLTLocation] {
        var routeLocations = [VLTLocation]()
        if let startLocation = startLocation { routeLocations.append(startLocation) }
        if let destinationLocation = destinationLocation { routeLocations.append(destinationLocation) }
        return routeLocations
    }
}

// MARK: Search
extension SearchHeaderView {
    /// Search for places that are close to the given query string, but not necessarily direct matches
    /// - Parameters:
    ///   - queryString: String to perform a suggestion search against
    func suggest(queryString: String) {
        currentLocationUpdate?()
        let searchBias = UserLocationBias(userLocation: startLocation?.coordinate ?? currentLocation.coordinate)
        // Initiate the search for suggestions with the current query string
        Search(apiKey: apiKey).suggest(query: queryString, limit: 10, searchBias: searchBias) { result in
            switch result {
            case .success(let response):
                let searchLocations = self.convertToLocation(fromAutoSuggestResults: response.results)
                DispatchQueue.main.async {
                    self.searchResultsTable?.update(locations: searchLocations, showUserLocation: self.showUserLocation)
                }
            case .failure(let error):
                DemoError(file: #file, function: #function, line: #line, error: error).print()
            }
        }
    }

    /// Search directly for places that match the search term in the query string
    /// - Parameters:
    ///   - queryString: String to perform a matched search against
    func search(queryString: String) {
        // Prepare local members
        currentLocationUpdate?()
        let searchBias = UserLocationBias(userLocation: startLocation?.coordinate ?? currentLocation.coordinate)

        // Perform search
        Search(apiKey: apiKey).search(query: queryString, limit: 10, searchBias: searchBias) { result in
            switch result {
            case .success(let response):
                let searchLocations = self.convertToLocation(fromSearchResults: response.results)
                DispatchQueue.main.async {
                    self.searchResultsTable?.update(locations: searchLocations, showUserLocation: self.showUserLocation)
                }
            case .failure(let error):
                DemoError(file: #file, function: #function, line: #line, error: error).print()
            }
        }
    }

    /// Converts list of AutoSuggestResults into a list of VLTDestinations
    /// - Parameters:
    ///   - fromSearchResults: List of AutoSuggestResult objects to be converted
    private func convertToLocation(fromAutoSuggestResults searchResults: [AutoSuggestResult]) -> [VLTLocation] {
        return searchResults.map({
            VLTLocation(named: $0.name,
                        coordinate: $0.position ?? CLLocationCoordinate2DMake(0, 0),
                        distanceFromSearchPoint: $0.distanceFromSearchPoint,
                        address: $0.vicinity)
        })
    }

    /// Converts a list of SearchResults into a VLTDestinations
    /// - Parameters:
    ///   - fromSearchResults: List of SearchResult objects to be converted
    private func convertToLocation(fromSearchResults searchResults: [SearchResult]) -> [VLTLocation] {
        return searchResults.map({
            VLTLocation(named: $0.name ?? "<-- Search Error -->",
                        coordinate: $0.position ?? CLLocationCoordinate2DMake(0, 0),
                        distanceFromSearchPoint: $0.distanceFromSearchPoint,
                        address: $0.vicinity)
        })
    }
}

// MARK: UISearchBarDelegate
extension SearchHeaderView {
    /// Respond the the search bar entering an editing state by noting the active search bar
    /// - Parameters:
    ///   - searchBar: The search bar that has begun editing
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        activeSearchBar = searchBar

        // Go ahead and start the search if it was previously searched before
        if let searchText = activeSearchBar?.text, searchText.count > 2, searchText != "Current Location" {
            suggest(queryString: searchText)
        } else {
            searchResultsTable?.update(locations: [], showUserLocation: showUserLocation)
        }
    }

    /// Respond to the given search bar's 'Search' or 'Return' button being tapped by performing a matched search on the content of the search bar
    /// - Parameters:
    ///   - searchBar: The search bar whose search button was tapped
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchTimer != nil {
            searchTimer?.invalidate()
            searchTimer = nil
        }
        guard let queryString = searchBar.text else {
            return
        }
        self.search(queryString: queryString)

        searchBar.resignFirstResponder()
    }

    /// Respond to updates in the text of the given search bar by initiating a suggestion search on the content
    /// - Parameters:
    ///   - searchBar: The search bar whose text has been updated
    ///   - textDidChange: The new text content of the search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Display an empty table if there are fewer than 3 characters in the search field
        guard searchText.count > 2 else {
            searchResultsTable?.update(locations: [], showUserLocation: showUserLocation)
            return
        }

        // Invalidate the timer if it exists
        if searchTimer != nil {
            searchTimer?.invalidate()
            searchTimer = nil
        }

        // Set a new timer to fire a suggestion search in 0.5 seconds
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {_ in
            self.suggest(queryString: searchText)
        })

        if searchBar == startingLocationSearchBar {
            updateStartLocation(nil)
        } else {
            updateDestinationLocation(nil)
        }
    }

    /// Update the start location
    private func updateStartLocation(_ location: VLTLocation?) {
        startLocation = location
    }

    /// Update the destination location
    private func updateDestinationLocation(_ location: VLTLocation?) {
        destinationLocation = location
    }
}

// MARK: SearchResultsTableDelegate
extension SearchHeaderView {
    /// React to a location being selected in the tableView by updating the current route
    /// - Parameter location: The location that was selected in the tableView
    func tableViewSelected(location: VLTLocation) {
        guard let searchBar = activeSearchBar else { return }
        DispatchQueue.main.async {
            searchBar.text = location.name
            searchBar.resignFirstResponder()
        }

        if searchBar == startingLocationSearchBar {
            updateStartLocation(location)
        } else {
            updateDestinationLocation(location)
            state = .routeSearch
        }

        activeSearchBar = nil

        searchResultsTable?.update(locations: [], showUserLocation: showUserLocation)
    }

    /// React to a destination being selected in the tableView by performing a matched search or updating the current route
    func currentLocationSelected() {
        guard let searchBar = activeSearchBar else { return }
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }

        if searchBar == startingLocationSearchBar {
            updateStartLocation(currentLocation)
        } else {
            updateDestinationLocation(currentLocation)
        }
        state = .routeSearch

        activeSearchBar = nil
    }

    /// React to a destination being selected in the tableView
    /// - Parameter destination: The destination that was selected in the tableView
    func destinationSelected(_ destination: VLTLocation) {
        guard let searchBar = activeSearchBar else { DemoError(file: #file, function: #function, line: #line, message: "Logic error").print(); return }

        let name = destination.name
        searchBar.text = name

        if let _ = destination.distanceFromSearchPoint {
            tableViewSelected(location: destination)
        } else {
            searchBarSearchButtonClicked(searchBar)
        }
    }
}
