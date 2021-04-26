//
// MapViewController.swift
//
// Created by Verizon Location Technology.
// Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import CoreLocation
import heresdk
import Mapbox
import UIKit
import VLTMaps

// MARK: - MapViewController
/// Main map view for displaying the map, user location, routing, and navigation
/// Processes user requests from some subordinate views displayed as headers and/or footers that have specific effects on the map itself.
/// All other user interactions are passed straight to the coordinator to drive the user experience.
class MapViewController: UIViewController,
                         Storyboarded,                  // Project: Allows for quick instantiation of the MapViewController
                         LayerOptionsViewDelegate,      // Project: User interactions from the LayerOptionsView
                         ModeOfTravelDelegate,          // Project: Respond when a change in mode of travel is made
                         VLTMapViewDelegate,            // VLTMaps: Respond to fired VLTMap delegates
                         MGLMapViewDelegate,            // Mapbox:  Respond to fired Mapbox delegates
                         SearchDelegate                 // Interaction from Search components`
{
    // MARK: - Private variables

    /// Most-recent state of the map
    private var previousState: MapControllerState = .start
    /// Keep track of layers hidden on the map
    private var hiddenFeatures = [VLTMapFeature]()

    // Header Views
    /// Header for the .start, .routeOverview, and .search map states
    private var searchHeaderView = SearchHeaderView()
    /// Header for the .navigating map state
    private var navigationDirectionHeaderView = NavigationDirectionHeaderView()
    /// Bottom constraint for the header container view
    private var headerBottomConstraint: NSLayoutConstraint?

    // Footer Views
    /// Footer for the .displayLayers map state
    private var mapLayersFooterView = LayerOptionsView()
    /// Footer for the .routeOverview and .navigating map state
    private var routeOverviewFooterView = RouteOverviewFooterView()

    /// Getter for all header views
    private var headers: [UIView] { [searchHeaderView, navigationDirectionHeaderView] }
    /// Getter for all footer views
    private var footers: [UIView] { [mapLayersFooterView, routeOverviewFooterView] }

    /// Listener for changes in the keyboard
    private var keyboardObserver: NSObjectProtocol?

    /// Routing processing
    private var routing: VLTMapRouting?
    /// Type of route to use when generating routes and navigating
    private var routeType: TransportMode = .car {
        didSet {
            if state == .routeOverview {
                refreshRoute()
            }
        }
    }

    /// Navigation processing
    private var navigation: VLTNavigation

    /// Switch to define whether or not the route is being recalculated (Note: Set to true is test without trigger rerouting)
    private var rerouting = false

    /// Current state of the map
    private(set) var state: MapControllerState = .start {
        willSet {
            previousState = state
        }
        didSet {
            DispatchQueue.main.async {
                self.state.updateView(self)
            }
        }
    }

    /// Manager in charge of the blue dot
    private var vltLocationManager = VLTLocationManager()
    /// Define the units of measure to be displayed
    private var unitSystem = globalUnitSystem
    /// Canned boolean to know if the UnitSystem is imperal
    private var imperialMeasure: Bool { return unitSystem == UnitSystem.imperial }

    // MARK: - Internal variables

    /// Delegate for communicating user interactions and events from this controller
    weak var coordinatorDelegate: NavigationCoordinatorDelegate?

    /// Various states that this MapViewController can reside in
    enum MapControllerState {
        // Initial state
        case start
        // Layer/traffic dialog is being presented and used
        case displayLayers
        // Search dialog is happening
        case search
        // Search is completed and attemping to retrieve the route. If an error occurs while retrieving possible routes it stays in this state
        case retrievingRoute
        // Routes have been successfully retrieved
        case routeOverview
        // Currently navigation on the map
        case navigating
        // Reached the user's destination via navigation
        case destinationReached

        // State controller, as state are change the view controller is put into the proper configuration
        func updateView(_ controller: MapViewController) {
            switch self {
            case .start:
                controller.updateStartView()
            case .displayLayers:
                controller.updateDisplayLayersView()
            case .search:
                controller.updateSearchView()
            case .retrievingRoute:
                controller.updateRetrievingRoute()
            case .routeOverview:
                controller.updateRouteOverviewView()
            case .navigating:
                controller.updateNavigatingView()
            case .destinationReached:
                controller.updateDestinationReachedView()
            }
        }
    }

    // MARK: - Outlets
    @IBOutlet private weak var mapView: VLTMapView!
    @IBOutlet private weak var showLayersButton: UIButton!
    @IBOutlet private weak var showUserLocationButton: UIButton!

    // Header and footer container views
    /// Container for any header views
    @IBOutlet private weak var headerContainerView: UIView!
    /// Container for any footer views
    @IBOutlet private weak var footerContainerView: UIView!

    // MARK: - Page life cycle

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        navigation = VLTNavigation(locationManager: vltLocationManager, unitSystem: .imperialUs)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        navigation = VLTNavigation(locationManager: vltLocationManager, unitSystem: .imperialUs)
        super.init(coder: coder)
    }

    /// Signals that the view has loaded
    /// Prepares all header and footer views with the appropriate delegates
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initiate and store the keyboard observer for removal on deinit
        keyboardObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: nil) { [weak self] in
            self?.handleKeyboard(notification: $0)
        }

        // Assign delegates to this controller
        searchHeaderView.updateMOTDelegate(to: self)
        mapLayersFooterView.delegate = self

        // Setup closure for updating the Search header with the user's current location
        let getCurrentLocation: VoidClosure = {
            if let currentLocation = self.vltLocationManager.lastKnownLocation {
                self.searchHeaderView.updateCurrentLocation(currentLocation.coordinate)
            }
        }

        // Assign delegates to the delegate of this view (NavigationCoordinator)
        searchHeaderView.setupView(searchDelegate: self, imperialMeasure: imperialMeasure, getLocatonClosure: getCurrentLocation)
        routeOverviewFooterView.navigationCoordinatorDelegate = coordinatorDelegate
        routeOverviewFooterView.exitableViewDelegate = self

        // Bring the Header container to the front of the view
        view.bringSubviewToFront(headerContainerView)

        // Set up the features to hide
        hiddenFeatures.append(contentsOf: [.traffic, .incidents])

        // Configure the map with the initial mode, any built-in features that should be hidden, and the initial center for the camera
        let mapConfiguration = MapConfiguration(mode: .day,
                                                hiddenFeatures: hiddenFeatures,
                                                cameraCenter: CLLocationCoordinate2DMake(0, 0))

        // Load the map using your given API key
        mapView.loadMap(apiKey: apiKey, configuration: mapConfiguration)
        /// Set this view controller as the VLTMapViewDelegate for the mapView
        mapView.delegate = self

        let singleLpgr = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        singleLpgr.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(singleLpgr)
        let doubleLpgr = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        doubleLpgr.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(doubleLpgr)
    }

    deinit {
        /// Remove our keyboard observer, since we used a block-based observer to call on the keyboard
        guard let observer = keyboardObserver else { return }
        NotificationCenter.default.removeObserver(observer)
    }

    /// Signals that the view will begin appearing
    /// Hides the navigation bar of the parent UINavigationController for the current view
    /// - Parameter animated: Indicator of whether or not the view should appear with animations
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    /// Signals that the view will begin disappearing
    /// Shows the navigation bar of the parent UINavigationController for the upcoming view
    /// - Parameter animated: Indicator of whether or not the view should disappear with animations
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - IBActions

    /// Handle the user tapping on the 'Show Layers' button on the map
    @IBAction private func showLayersButtonTapped() {
        state == .displayLayers ? exitView() : setStateTo(.displayLayers)
    }

    /// Handle the user tapping on the 'Show User Location' button on the map
    @IBAction private func showUserLocationButtonTapped() {
        DispatchQueue.main.async {
            self.mapView.map?.showsUserLocation = true
            switch self.state {
            case .navigating:
                self.mapView.map?.userTrackingMode = .followWithCourse
            case .routeOverview:
                self.mapView.map?.userTrackingMode = .none
            default:
                self.mapView.map?.userTrackingMode = .follow
            }
        }
    }

    /// Generate a route by long-pressing on the map at a location
    /// - Parameter gestureRecognizer: Gesture recognizer that catches the long-press action
    @IBAction private func longPressed(_ gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizer.State.began {
            guard !headerFooterPressed(gestureReconizer) else { return }
            if gestureReconizer.numberOfTouches == 1 {
                let touchPoint = gestureReconizer.location(in: self.mapView)
                let touchCoordinate = mapView.convertPointToCoordinate(point: touchPoint)
                if let userLocation = self.mapView.map?.userLocation?.coordinate {
                    state = .retrievingRoute
                    showBlockingOverlay(withMessage: "Getting Routes") {
                        DispatchQueue.main.async {
                            self.routing?.calculateRoutes(startingAt: userLocation, andEndingAt: touchCoordinate, routeType: self.routeType, completion: self.updateRoutesCompletion)
                        }
                    }
                } else {
                    DemoError(file: #file, function: #function, line: #line, message: "Current location not provided").print()
                }
            }
            if gestureReconizer.numberOfTouches == 2, let routeSelected = routing?.routeSelected {
                if state == .routeOverview || state == .navigating {
                    state = .navigating
                    if !vltLocationManager.simulating {
                        vltLocationManager.simulateUsingRoute(routeSelected, speedFactor: 2)
                    }
                }
            }
        }
    }

    // MARK: - Private Functions
    /// Determine is a gesture happened on the header or footer views.
    /// - Parameter gestureRecognizer: gesture recognizer to interrogate
    /// - Returns: True: gesture occured in the header or footer views | False: gesture did not occured in the header or footer views
    private func headerFooterPressed (_ gestureRecognizer: UILongPressGestureRecognizer) -> Bool {
        let touchLocation = gestureRecognizer.location(in: gestureRecognizer.view)
        if headerContainerView.frame.contains(touchLocation) {
            return true
        }
        if footerContainerView.frame.contains(touchLocation) {
            return true
        }
        return false
    }

    /// Starts the VLTNavigation object that drives directions and voice prompts
    /// - Parameter usingRoute: The route that the user should be navigated through
    private func startNavigating(usingRoute route: Route) throws {
        // What the view controller should do when the progress along the route is updated
        let routeProgressBlock: VLTNavRouteProgressClosure? = { nextManeuver, nextManeuverProgress in
            DispatchQueue.main.async {
                self.navigationDirectionHeaderView.hereManeuver(nextManeuver, withProgress: nextManeuverProgress, imperialMeasure: self.imperialMeasure)
            }
        }

        // What the view controller should do when the distance to final destination has changed
        let routeRemainingBlock: VLTNavRouteRemainingClosure? = { meters, seconds in
            self.routeOverviewFooterView.update(withDistance: meters, andTime: seconds, imperialMeasure: self.imperialMeasure)
        }

        // What the view controller should do when the speed limit along the route being navigated changes
        let speedLimitUpatedBlock: VLTNavSpeedLimitUpdatedClosure? = { _ in
            // Stub for speedLimitUpatedBlock
        }

        // What the view controller should do when the navigation think one has started speeding...shame!
        let startedSpeedingBlock: VoidClosure? = {
            // Stub for startedSpeedingBlock
        }

        // What the view controller should do when the navigation thinks one has stopped speeding
        let stoppedSpeedingBlock: VoidClosure? = {
            // Stub for stoppedSpeedingBlock
        }

        // What the view controller should do when the location is matched against HERE locations during navigation
        let matchedLocationBlock: VLTNavMatchedLocationClosure? = { _ in
            // Stub for matchedLocationBlock
        }

        // What the view controller should do when the destination is reached
        let destinationReachedBlock: VoidClosure? = {
            self.state = .destinationReached
        }

        // Start navigating the route
        do {
            try navigation.startNavigatingRoute(route,
                                                routeProgressBlock: routeProgressBlock,
                                                routeRemainingBlock: routeRemainingBlock,
                                                speedLimitUpatedBlock: speedLimitUpatedBlock,
                                                startedSpeedingBlock: startedSpeedingBlock,
                                                stoppedSpeedingBlock: stoppedSpeedingBlock,
                                                matchedLocationBlock: matchedLocationBlock,
                                                milestoneReachedBlock: routing?.navigationReached,
                                                destinationReachedBlock: destinationReachedBlock,
                                                routeDeviatedBlock: rerouteUser,
                                                routeDeviationSensitivity: 10)
        } catch {
            throw error
        }
    }

    /// Stops the navigation process and centers the map on the user's location
    private func stopNavigation() {
        DispatchQueue.main.async {
            self.navigation.stopNavigating()
            self.showUserLocationButtonTapped()
        }
    }

    // MARK: - Internal Functions
    /// Initial setup for the coordinator so it can properly control the MapViewController
    ///  - Parameter delegate: The delegate that should be reported to for updates
    func coordinateMap(delegate: NavigationCoordinatorDelegate?) {
        coordinatorDelegate = delegate
    }

    /// Updates the current state on the MapViewController.
    /// - Parameter state: State the MapViewController should be in right now.
    func setStateTo(_ state: MapControllerState) {
        self.state = state
    }

    /// Set the UnitSystem used
    /// - Parameter unitSystem: Only two to choose from
    func updateUnitSystem(_ unitSystem: UnitSystem ) {
        self.unitSystem = unitSystem
    }
}

// MARK: - View Update Methods
extension MapViewController {
    /// Updates the view to the .start state layout (only the search bar is visible)
    private func updateStartView() {
        if previousState == .routeOverview || previousState == .navigating || previousState == .destinationReached {
            stopNavigation()
            do {
                try routing?.clearRoutes()
                try mapView.camera.updateCamera(tilt: 0, withAnimation: false, animationTime: 0.5)
            } catch {
                DemoError(file: #file, function: #function, line: #line, error: error).print()
            }
        }

        // Reset the currently stored route in the coordinator
        coordinatorDelegate?.routeSelected(nil)
        searchHeaderView.state = .start
        removeHeaderBottomConstraint()
        fillHeaderView(with: searchHeaderView)

        removeFooters()
    }

    /// Updates the view to the .displayLayers state layout (the layerOptionsView is displayed above other present views)
    private func updateDisplayLayersView() {
        mapLayersFooterView.update(withMode: mapView.mode,
                                   trafficOn: !hiddenFeatures.contains(.traffic),
                                   incidentsOn: !hiddenFeatures.contains(.incidents))
        fillFooterView(with: mapLayersFooterView)
    }

    /// Updates the view to the .search state layout (Search header covers the entire screen)
    private func updateSearchView() {
        if state == .retrievingRoute {
            searchHeaderView.state = .routeSearch
        } else {
            searchHeaderView.state = routing?.routeSelected == nil ? .destinationSearch : .routeSearch
        }

        if let constraint = headerBottomConstraint {
            constraint.constant = 0
        } else {
            headerBottomConstraint = headerContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        }

        headerBottomConstraint?.isActive = true

        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }

    /// Updates the view to the .retrievingRoute state layout (searchHeaderView displaying start, destination, and transport mode, and a 'Routing...' overlay)
    private func updateRetrievingRoute() {
        // Reset the currently stored route in the coordinator
        coordinatorDelegate?.routeSelected(nil)

        searchHeaderView.state = .retrievingRoute
        removeHeaderBottomConstraint()
        removeFooters()
    }

    /// Updates the view to the .routeOverviewView state layout (searchHeaderView displaying start, destination, and transport mode, and routeOverviewFooterView displaying route info)
    private func updateRouteOverviewView() {
        guard let route = routing?.routeSelected else {
            state = .start
            return
        }
        // Save the current route to the coordinator
        coordinatorDelegate?.routeSelected(route)

        routeOverviewFooterView.mode = .preNavigation

        fillHeaderView(with: searchHeaderView)
        fillFooterView(with: routeOverviewFooterView)

        searchHeaderView.state = .routeOverview

        if let route = routing?.routeSelected {
            routeOverviewFooterView.update(withRoute: route, imperialMeasure: imperialMeasure)
        } else {
            DemoError(file: #file, function: #function, line: #line, message: "No selected route.").print()
        }
        removeHeaderBottomConstraint()
    }

    /// Updates the view to the .navigating state layout (navigationDirectionHeaderView displays navigation directions, routeOverviewFooterView displays current route info)
    private func updateNavigatingView() {
        let failBlock: (Error?) -> Void = {
            DemoError(file: #file, function: #function, line: #line, error: $0).print()
            self.updateStartView()
        }

        guard let route = routing?.routeSelected else {
            failBlock(nil)
            return
        }

        // Prevent us from attempting to simulate a route while we are in the middle of simulating a route
        guard !(vltLocationManager.simulating) else { return }

        // Completion block for setting the user tracking mode
        let trackingModeCompletion: VoidClosure = {
            do {
                // End of animations, begin navigating
                try self.routing?.nagivateRoute()
                try self.startNavigating(usingRoute: route)

                // Update Views, since everything that could have failed has succeeded
                self.navigationDirectionHeaderView.proceedToRoute()
                self.routeOverviewFooterView.update(withRoute: route, imperialMeasure: self.imperialMeasure)
                self.routeOverviewFooterView.mode = .navigation

                self.fillHeaderView(with: self.navigationDirectionHeaderView)
                self.fillFooterView(with: self.routeOverviewFooterView)
                self.removeHeaderBottomConstraint()
            } catch { failBlock(error) }
        }

        // Completion block for updating the camera
        let cameraUpdateCompletion: VoidClosure = {
            // Update the user tracking mode
            self.mapView.map?.setUserTrackingMode(.followWithCourse, animated: true, completionHandler: trackingModeCompletion)
        }

        // Update the camera with a short animation
        do {
            try mapView.camera.updateCamera(tilt: 50,
                                            zoom: 14,
                                            target: vltLocationManager.lastKnownLocation?.coordinate,
                                            withAnimation: true,
                                            animationTime: 1.0,
                                            completion: cameraUpdateCompletion)
        } catch { failBlock(error) }

        if !(vltLocationManager.simulating) {
            #if targetEnvironment(simulator)
            // Turn on if simulation should start automatically in simulator
            // vltLocationManager.simulateUsingRoute(route, speedFactor: 2)
            #endif
        }
    }

    /// Updates the view to the .destinationReached state layout. (navigationDirectionHeaderView with 'Destination Reached' banner, routeOverviewFooterView with route data hidden and ability to exit visible)
    private func updateDestinationReachedView() {
        guard let route = routing?.routeSelected else {
            DemoError(file: #file, function: #function, line: #line, message: "Could not locate route travelled").print()
            state = .start
            return
        }

        navigationDirectionHeaderView.destinationReached(for: route)
        routeOverviewFooterView.mode = .postNavigation

        fillHeaderView(with: navigationDirectionHeaderView)
        fillFooterView(with: routeOverviewFooterView)
    }

    /// Set map to initial zoom, tilt and bearing
    /// - Parameters:
    ///   - withAnimation: Should this camera change animate. True: Animated | False: No Animation
    ///   - completion: Block of work to be completed after the map camera has finished initializing
    /// - Throws: Error if one occurs attempting to update the map camera
    //  Note: If the userTracking mode is being set the animation does not function properly.
    private func initializeMapCamera(withAnimation shouldAnimate: Bool = false, completion: VoidClosure? = nil) throws {
        try mapView.camera.updateCamera(tilt: 0,
                                        bearing: 0,
                                        zoom: 12,
                                        withAnimation: shouldAnimate,
                                        animationTime: 1.0,
                                        completion: completion)
    }

    /// Refreshes the route based on the current waypoint and transport mode data
    private func refreshRoute() {
        showBlockingOverlay(withMessage: "Getting Routes") {
            self.routing?.updateRoutes(for: self.routeType, completion: self.updateRoutesCompletion)
        }
    }

    /// Completion block for updating routes
    /// - Parameters:
    ///   - error: Error thrown while updating/searching routes
    private func updateRoutesCompletion(_ error: Error?) {
        self.dismissBlockingOverlay {
            let errorBlock: ErrorClosure = { error in
                self.showAlert(title: "NavigationViewController_Routing", message: "Error while calculating a route:\n\(String(describing: error))")
            }
            if let error = error {
                errorBlock(error)
            } else {
                self.state = .routeOverview
                do {
                    try self.routing?.setCameraToShowAvailableRoutes()
                } catch { errorBlock(error) }
            }
        }
    }

    /// Reroutes the user according to the user's current position and the remainder of the current route waypoints
    /// - Parameters:
    ///   - currentCoordinate: The current location of the user that rerouting should occur from
    ///   - headingInDegrees: Optional heading/course/bearing be traveled so route continues on current path
    private func rerouteUser(from currentCoordinate: CLLocationCoordinate2D, headingInDegrees: Double?) {
        // Check if we are already rerouting the user
        if !rerouting {
            // Prevent rerouting multiple times
            rerouting = true

            // Define an error block that any failure can call
            let errorBlock: (String) -> Void = { details in
                self.rerouting = false
                DispatchQueue.main.async {
                    self.showAlert(title: "NavigationViewController_ReRouting",
                                   message: "Error while recalculating a route: \n\(details)")
                    self.updateStartView()
                }
            }

            // Completion block for recalculation of the route
            let reCalculateCompletion: ErrorClosure = { error in
                self.dismissBlockingOverlay {
                    if let error = error {
                        errorBlock(String(describing: error))
                    } else {
                        guard let route = self.routing?.routeSelected else {
                            errorBlock("Could not define a new route")
                            return
                        }
                        DispatchQueue.main.async {
                            self.navigation.updateNavigatingRoute(route)
                            self.showUserLocationButtonTapped()
                            self.rerouting = false
                        }
                    }
                }
            }

            // Notify the user that they are being rerouted and begin recalculating the route
            showBlockingOverlay(withMessage: "Rerouting...") {
                DemoError(file: #file, function: #function, line: #line, message: "Calculating route....").print()
                self.routing?.recalculateRoute(from: currentCoordinate, headingInDegrees: headingInDegrees, completion: reCalculateCompletion)
            }
        }
    }
}

// MARK: - Layout Helpers
extension MapViewController {
    /// Handle the showing and hiding of the keyboard
    /// - Parameter notification: The KeyboardWillChangeFrame notification that initiates this call
    private func handleKeyboard(notification: Notification) {
        // Verify that the correct notification was received
        guard notification.name == UIResponder.keyboardWillChangeFrameNotification else { return }
        // Retrieve the final frame info of the keyboard after animation
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue) {
            // Set the content inset of the searchHeaderView to compensate for the visibility of the keyboard
            searchHeaderView.bottomInset = endFrame.cgRectValue.size.height
        }
    }

    /// Adds a subview to the header container and fills the header with the new subview
    /// - Parameter subview: View to be added to the header and pinned in place
    private func fillHeaderView(with subview: UIView) {
        if subview.superview == nil {
            removeHeaders()
            fill(headerContainerView, with: subview)
        }
    }

    /// Adds a subview to the footer container and fills the footer with the new subview
    /// - Parameter subview: View to be added to the footer and pinned in place
    private func fillFooterView(with subview: UIView) {
        if subview.superview == nil {
            removeFooters()
            fill(footerContainerView, with: subview)
        }
    }

    /// Adds a subview to a containing view and pins the subview sides to the container sides
    /// - Parameters:
    ///   - containerView: The view to have a subview added
    ///   - subview: The view to be added and constrained in place
    private func fill(_ containerView: UIView, with subview: UIView) {
        containerView.addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false

        containerView.safeAreaLayoutGuide.build {
            subview.topAnchor.constraint(equalTo: $0.topAnchor).isActive = true
            subview.leadingAnchor.constraint(equalTo: $0.leadingAnchor).isActive = true
            subview.trailingAnchor.constraint(equalTo: $0.trailingAnchor).isActive = true
            subview.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        }
        subview.clipsToBounds = true
    }

    /// Clear out all constraints attached to headers
    private func removeHeaders() {
        headers.forEach({
            $0.removeFromSuperview()
        })
    }

    /// Clear out all constraints attached to footers
    private func removeFooters() {
        footers.forEach({
            $0.removeFromSuperview()
        })
    }

    /// Removes the bottom constraint for the header view
    private func removeHeaderBottomConstraint() {
        guard headerBottomConstraint != nil else {
            return
        }

        self.headerBottomConstraint?.isActive = false
        self.headerBottomConstraint = nil
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - ModeOfTravelDelegate
extension MapViewController {
    /// Update the route being displayed to reflect a new VLTRouteType
    /// - Parameters:
    ///   - routeType: The new transportMode to be used for routing
    func updated(routeType: TransportMode) {
        // Update the route type being displayed on the map
        guard routeType != self.routeType else { return }
        self.routeType = routeType
    }
}

// MARK: - LayerOptionsViewDelegate
extension MapViewController {
    /// Update the map display to reflect a new mode
    /// - Parameter mode: The mode to switch the map display to
    func didSelectMapMode(_ mode: VLTMapMode) {
        do {
            /// Update the map to use the designated mode
            try mapView.setMode(mode: mode)
        } catch {
            /// If the map mode update fails, display an error
            showError(withMessage: "\(VLTLiterals.ModesVCLiterals.modeUpdateErrorMessage): \(error)")
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

// MARK: - VLTMapViewDelegate
extension MapViewController {
    /// Completion event for the loading of the VLTMapView
    /// - Parameter mapView: The mapView that has finished loading
    func didFinishLoadingMap(mapView: VLTMapView) {
        // Set the delegate for the Mapbox - MGLMapViewDelegate to fire properly
        if let map = mapView.map, routing == nil {
            map.delegate = self
            map.locationManager = vltLocationManager
            map.locationManager.requestWhenInUseAuthorization()
            routing = VLTMapRouting(withMapView: mapView, imperialMeasure: imperialMeasure)
            map.compassView.compassVisibility = .visible
            map.showsUserLocation = true
            map.setUserTrackingMode(.follow, animated: false) {
                do {
                    try self.initializeMapCamera()
                } catch {
                    DemoError(file: #file, function: #function, line: #line, error: error).print()
                }
            }
        } else {
            DemoError(file: #file, function: #function, line: #line, message: "Map not initialized when didFinishLoadingMap(mapView:) fired.").print()
        }
    }

    /// React to the user tapping on a polyline added to the map
    /// - Parameters:
    ///   - mapView: The mapView containing the polyline that was tapped
    ///   - polyline: The polyline that was tapped
    ///   - coordinate: The coordinate where the tap occurred
    func tappedOnPolyline(mapView: VLTMapView, polyline: VLTMapPolyline, coordinate: CLLocationCoordinate2D) {
        guard let lengthInMeters = polyline.metadata as? Int32,
              let selectedRoute = routing?.routes?.first(where: { $0.lengthInMeters == lengthInMeters }) else {
            DemoError(file: #file, function: #function, line: #line,
                      message: "Data unavailable for route selection; \nroutes: \(String(describing: routing?.routes)); \nlengthInMeters: \(String(describing: polyline.metadata as? Int32));").print()
            return
        }

        do {
            try routing?.selectRoute(selectedRoute)
            routeOverviewFooterView.update(withRoute: selectedRoute, imperialMeasure: imperialMeasure)
        } catch {
            DemoError(file: #file, function: #function, line: #line, error: error).print()
        }
    }
}

// MARK: - ExitableViewDelegate
extension MapViewController {
    /// Pass an exit command from a subview to the coordinator
    func exitView() {
        switch state {
        case .start, .search, .retrievingRoute, .routeOverview, .navigating, .destinationReached:
            state = .start
        case .displayLayers:
            state = previousState
        }
    }
}

// MARK: - SearchDelegate
extension MapViewController {
    /// Function to pass dialog back from the Search to be displayed
    /// - Parameters:
    ///   - title: Title of the displayed dialog
    ///   - message: Content of the displayed dialog
    func showSearchDialog(title: String, message: String) {
        showAlert(title: title, message: message)
    }

    /// Handle the initiation of a search process with the SearchHeaderView
    func searchInitiated() {
        switch state {
        case .start,
             .retrievingRoute,
             .routeOverview,
             .displayLayers:
            self.state = .search
        default:
            DemoError(file: #file, function: #function, line: #line, message: "Invalid state: \(state)").print()
        }
    }

    /// Handle the completion of a successful search from the SearchHeaderView
    /// - Parameter withLocations: The list of locations describing a sequence of locations on a route
    func searchComplete(withLocations locations: [VLTLocation]) {
        state = .retrievingRoute
        var adjustedLocations = [VLTLocation]()

        // Check if a 'current location' exists in the location list
        let currentLocation = locations.first(where: { $0.isCurrentLocation })

        // Make sure any 'current location' is the most current location
        if currentLocation != nil {
            if let lastCoordinate = vltLocationManager.lastKnownLocation?.coordinate {
                for location in locations {
                    if location.isCurrentLocation {
                        adjustedLocations.append(VLTLocation(named: "Current Location", coordinate: lastCoordinate))
                    } else {
                        adjustedLocations.append(location)
                    }
                }
            }
        } else {
            adjustedLocations = locations
        }

        showBlockingOverlay(withMessage: "Getting Routes") {
            self.routing?.calculateRoutes(locations: adjustedLocations, routeType: self.routeType, completion: self.updateRoutesCompletion)
        }
    }
}
