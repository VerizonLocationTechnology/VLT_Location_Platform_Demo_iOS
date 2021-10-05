//
// NavigationCoordinator.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import heresdk
import UIKit
import VLTMaps

/// Coordinates all actions and transitions required to provide and control the Navigation experience as a whole
class NavigationCoordinator: NSObject,
                             Coordinator,                   // Core of the Coordinator pattern
                             NavigationCoordinatorDelegate  // Core interaction this coordinator is responsible for handling
{
    /// UINavigationController to be used for transitioning through the navigation experience
    var navigationController: UINavigationController
    /// The map controller that is the root view for the navigation experience
    private var mapViewController = MapViewController.instantiate(fromStoryboardNamed: "Navigation")
    /// The directions view controller for displaying directions to the user
    private var directionsViewController: DirectionsViewController?
    /// The current state of the navigation experience.
    private var coordinatorState = CoordinatorState.showMap {
        willSet {
            previousState = coordinatorState
        }
        didSet {
            DispatchQueue.main.async {
                self.coordinatorState.updateStatus(self)
            }
        }
    }
    /// The previous state of the navigation experience
    private var previousState = CoordinatorState.showMap
    /// The current route designated by the user, if one is being worked with.
    private var currentRoute: Route?
    /// Set the unit of measure for the entire project
    let unitSystem = globalUnitSystem

    /// The various states of the navigation experience driven by this coordinator
    private enum CoordinatorState {
        // Current states the Navigation Coordinator can in
        case showMap, showDirections

        // Keeps subordinate View Controller state in sync when Navigation Coordinator state changes.
        func updateStatus(_ navigationCoordinator: NavigationCoordinator) {
            switch self {
            case .showMap:
                navigationCoordinator.showMap()
            case .showDirections:
                navigationCoordinator.showDirectionsState()
            }
        }
    }

    /// Internal Initializer
    /// - Parameter navigationController: The navigation controller that should be used to present the navigation experience
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    /// Initiates the beginning of the navigation experience
    func start() {
        // Set the current state to the start state
        coordinatorState = .showMap
        // Instantiate the MapViewController to serve as the root view controller
        mapViewController.coordinateMap(delegate: self)
        mapViewController.setStateTo(.start)
        navigationController.pushViewController(mapViewController, animated: true)
        mapViewController.updateUnitSystem(unitSystem)
    }
}

// MARK: - State Update Logic
extension NavigationCoordinator {
    /// Display the mapViewController
    private func showMap() {
        if previousState == .showDirections, let directionsViewController = directionsViewController {
            directionsViewController.dismiss(animated: true, completion: nil)
        }
    }

    /// Enter the .showDirections state of the experience (Show the DirectionsViewController)
    private func showDirectionsState() {
        // Instantiate the DirectionsViewController
        directionsViewController = DirectionsViewController.instantiate(fromStoryboardNamed: "Navigation")

        guard let directionsViewController = directionsViewController else {
            return
        }
        directionsViewController.updateUnitSystem(unitSystem)
        // Update the DirectionsViewController with a route, and indicator of whether or not navigation is in-progress, and a delegate pointer to this coordinator
        directionsViewController.coordinateDirections(delegate: self,
                                                      route: currentRoute,
                                                      isNavigating: mapViewController.state == .navigating)

        // Display the directions view controller to the user
        navigationController.showDetailViewController(directionsViewController, sender: nil)
    }
}

// MARK: NavigationCoordinatorDelegate
extension NavigationCoordinator {
    /// Handles the route being selected by a coordinated component
    /// - Parameter route: The route that has been selected
    func routeSelected(_ route: Route?) {
        self.currentRoute = route
    }

    /// Initiate the navigation state
    func startNavigation() {
        coordinatorState = .showMap
        mapViewController.setStateTo(.navigating)
    }

    /// Leave the navigation state
    func endNavigation() {
        mapViewController.setStateTo(.start)
    }

    /// Initiate the directions state
    func showDirections() {
        coordinatorState = .showDirections
    }

    /// Display the current MapViewController state
    func dismissDirections() {
        coordinatorState = .showMap
    }
}

// MARK: ExitableViewDelegate
extension NavigationCoordinator {
    /// Handles the exiting of a current view and return to a previous view
    func exitView() {
        switch coordinatorState {
        case .showDirections:
            showMap()
        default:
            DemoError(file: #file, function: #function, line: #line, message: "Attempting to exit from unnacounted state").print()
        }
    }
}
