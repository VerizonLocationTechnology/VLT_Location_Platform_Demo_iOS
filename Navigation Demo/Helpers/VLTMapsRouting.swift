//
// VLTMapsRouting.swift
//
// Created by Verizon Location Technology
// Copyright © 2021 Verizon Location Technology
//

import CoreLocation
import heresdk
import UIKit
import VLTMaps

/// VLTMaps combined with HERE routing to help in route presentation.
class VLTMapRouting {
    // MARK: - Private variables
    /// The map view that the route should be displayed on
    private var mapView: VLTMapView
    /// The HERE routing engine that should describe the route
    private var routingEngine: RoutingEngine?
    /// The list of milestones reacheds on the present route
    private var reachedMilestones = [Milestone]()

    // MARK: - Public read only variables
    /// List of milestones that the route should pass through, including starting and destination locations
    private(set) var routeWaypoints = [Waypoint]()
    /// List of possible routes through the given waypoints
    private(set) var routes: [Route]?
    /// The presently selected route
    private(set) var routeSelected: Route?
    /// The polyline displaying the presently selected route
    private(set) var routeSelectedPolyline: VLTMapPolyline?
    /// Image indicating the starting location of the route
    private(set) var routeStartImage: VLTImage
    /// Image indicating waypoints/stops in between the initial location and final destination
    private(set) var routeRallyPointImage = VLTImage(image: UIImage(named: "red_point") ?? #imageLiteral(resourceName: "red_point"))
    /// Image indicating the destination location of the route
    private(set) var routeDestinationImage: VLTImage
    /// Map Polylines depicting all possible routes that the user could elect to take
    private(set) var routingPolylines = [VLTMapPolyline]()
    /// Map Markers depicting the starting and destination locations, as well as any waypoints in between
    private(set) var routingMarkers = [VLTMapMarker]()
    /// Indicator of whether or not to use imperial measurements
    private(set) var imperialMeasure: Bool

    // MARK: - Initializers

    /// Core initialization of the routing.
    /// - Parameters:
    ///   - mapView: VLTMapView to do drawing against
    ///   - routeStartImage: Image to define the start of a route. Default: Black Location Indicator
    ///   - routeRallyPointImage: Image to define the rally/waypoint of a route. Default: Red Circle Dot
    ///   - routeDestinationImage: Image to define the destination of a route. Default: White Location Indicator
    ///   - imperialMeasure: show distance measurement in imperial units
    init(withMapView mapView: VLTMapView,
         routeStartImage: VLTImage? = nil,
         routeRallyPointImage: VLTImage? = nil,
         routeDestinationImage: VLTImage? = nil,
         imperialMeasure: Bool) {
        self.mapView = mapView
        // Set the route start image
        if let routeStartImage = routeStartImage {
            self.routeStartImage = routeStartImage
        } else {
            let image = ((UIImage(named: "black_pin") ?? #imageLiteral(resourceName: "black_pin")) as UIImage).scaleTo(CGSize(width: 12, height: 12))
            self.routeStartImage = VLTImage(image: image)
        }

        // Set the route rally point image if it has been passed in
        if let routeRallyPointImage = routeRallyPointImage {
            self.routeRallyPointImage = routeRallyPointImage
        }

        // Set the route destination image
        if let routeDestinationImage = routeDestinationImage {
            self.routeDestinationImage = routeDestinationImage
        } else {
            let image = ((UIImage(named: "white_pin") ?? #imageLiteral(resourceName: "black_pin")) as UIImage).scaleTo(CGSize(width: 12, height: 12))
            self.routeDestinationImage = VLTImage(image: image)
        }
        self.imperialMeasure = imperialMeasure
    }

    // MARK: - Public Functions

    /// Calculate and draw the possible routese based on an array of VLTLocations
    /// - Parameters:
    ///   - locations: Array of VLTLocation. 1st = Starting, Last = Destination, all other are the rally/waypoint of a route.
    ///   - routeType: The mode of transportation to calculate the route for
    ///   - completion: Block to be called when the process completes or an error is encountered
    func calculateRoutes(locations: [VLTLocation],
                         routeType: TransportMode,
                         completion: @escaping ErrorClosure) {
        guard locations.count >= 2 else {
            completion(GenericError(title: "VLTMapRouting.calculateRoutes - Start or End location missing.", code: 0))
            return
        }
        let startPoint = locations[locations.startIndex].coordinate
        var runningThrough = [CLLocationCoordinate2D]()
        let destination = locations[locations.endIndex - 1].coordinate

        if locations.count > 2 {
            for idx in 2...(locations.endIndex - 1) {
                runningThrough.append(locations[idx].coordinate)
            }
        }
        calculateRoutes(startingAt: startPoint, runningThrough: runningThrough, andEndingAt: destination, routeType: routeType, completion: completion)
    }

    /// Calculate and draw the possible routes between two coordinates on the map.
    /// - Parameters:
    ///   - startingAt: Route starting coordinate
    ///   - andEndingAt: Route destination coordinate
    ///   - routeType: The mode of transportation to calculate the route for
    ///   - completion: Block to be called when the process completes or an error is encountered
    func calculateRoutes(startingAt start: CLLocationCoordinate2D,
                         andEndingAt destination: CLLocationCoordinate2D,
                         routeType: TransportMode,
                         completion: @escaping ErrorClosure) {
            calculateRoutes(startingAt: start, runningThrough: [CLLocationCoordinate2D](), andEndingAt: destination, routeType: routeType, completion: completion)
    }

    /// Calculate and draw the possible route between the start and destination coordinates while navigating through rally point coordinates on the way.
    /// - Parameters:
    ///   - startingAt: Route starting coordinate
    ///   - runningThrough: Coordinates that the route should pass through before reaching the destination
    ///   - destination: Route destination coordinate
    ///   - completion: Block to be called when the process completes or an error is encountered
    func calculateRoutes(startingAt start: CLLocationCoordinate2D,
                         runningThrough rallyPoints: [CLLocationCoordinate2D],
                         andEndingAt destination: CLLocationCoordinate2D,
                         routeType: TransportMode,
                         completion: @escaping ErrorClosure) {
        do {
            if routingEngine == nil {
                try routingEngine = RoutingEngine()
            }
            try clearRoutingMarkers()
        } catch {
            completion(error)
        }

        var waypoints = [Waypoint]()
        waypoints.append(Waypoint(coordinates: start.geoCoordinates))
        for points in rallyPoints {
            waypoints.append(Waypoint(coordinates: points.geoCoordinates))
        }
        waypoints.append(Waypoint(coordinates: destination.geoCoordinates))
        routeWaypoints = waypoints

        updateRoutes(for: routeType, completion: completion)
    }

    /// Recalculates a route using the remaining waypoints, the user's current location, and the settings for the current route
    /// - Parameters:
    ///   - currentLocation: The present location (coordinates) from which a new route should start
    ///   - headingInDegrees: Current heading/bearing/course
    ///   - completion: A block of code to be run at the conclusion of route recalculation or when an error is encountered
    func recalculateRoute(from currentLocation: CLLocationCoordinate2D,
                          headingInDegrees: Double?,
                          completion: @escaping ErrorClosure) {
        DemoError(file: #file, function: #function, line: #line, message: "RECALCULATING ROUTE!!!!!").print()
        guard let transportMode = routeSelected?.transportMode else {
            completion(GenericError(title: "VLTMapRouting.recalculateRoute - TransportMode missing.", code: 1)) // This should never happen unless recalculateRoute is called before calculateRoute
            return
        }

        do {
            try self.clearRoutingMarkers()
            try self.clearRoutingPolylines(exceptSelectedRoute: true)
        } catch {
            completion(GenericError(title: "VLTMapRouting.recalculateRoute - Failed to clear previous route", code: 4))
        }

        routeWaypoints.removeFirst(reachedMilestones.count + 1)
        routeWaypoints.insert(Waypoint(coordinates: currentLocation.geoCoordinates, headingInDegrees: headingInDegrees), at: 0)

        updateRoutes(for: transportMode, alternatives: 0, completion: completion)
    }

    /// Refresh the routes on the map with a new route type
    /// - Parameters:
    ///   - routeType: The TransportMode that the route should be optimized for
    ///   - alternatives: The number of potential alternative routes that should be calculated. Defaults to 2
    ///   - completion: A block of code to be run at the conclusion of the route update
    func updateRoutes(for routeType: TransportMode,
                      alternatives: Int = 2,
                      completion: @escaping ErrorClosure) {
        guard !routeWaypoints.isEmpty else { return }

        let routeOptions = RouteOptions(optimizationMode: .fastest, alternatives: Int32(alternatives))

        let completionHandler: CalculateRouteCompletionHandler = { routingError, routes in
            if let error = routingError {
                // NOTE: heresdk.CalculateRouteCompletionHandler does not actually return an error but will print the actual error for some reason.
                completion(GenericError(title: String(describing: error), code: error.rawValue))
                return
            } else if let routes = routes {
                DispatchQueue.main.async {
                    do {
                        try self.displayRoutes(routes)
                    } catch {
                        completion(error)
                        return
                    }
                }
            }
            completion(nil)
        }

        switch routeType {
        case .car:
            let options = CarOptions(routeOptions: routeOptions,
                                     textOptions: RouteTextOptions(unitSystem: globalUnitSystem),
                                     avoidanceOptions: AvoidanceOptions())
            self.routingEngine?.calculateRoute(with: routeWaypoints,
                                               carOptions: options,
                                               completion: completionHandler)
        case .pedestrian:
            let options = PedestrianOptions(routeOptions: routeOptions,
                                            textOptions: RouteTextOptions(unitSystem: globalUnitSystem))
            self.routingEngine?.calculateRoute(with: routeWaypoints,
                                               pedestrianOptions: options,
                                               completion: completionHandler)
        case .truck:
            let options = TruckOptions(routeOptions: routeOptions,
                                       textOptions: RouteTextOptions(unitSystem: globalUnitSystem),
                                       avoidanceOptions: AvoidanceOptions(),
                                       specifications: TruckSpecifications(),
                                       tunnelCategory: nil,
                                       hazardousGoods: [])
            self.routingEngine?.calculateRoute(with: routeWaypoints, truckOptions: options, completion: completionHandler)
        case .scooter:
            let options = ScooterOptions(routeOptions: routeOptions, textOptions: RouteTextOptions(), avoidanceOptions: AvoidanceOptions(), allowHighway: false)
            self.routingEngine?.calculateRoute(with: routeWaypoints, scooterOptions: options, completion: completionHandler)
        case .publicTransit:
            // After confirming with HERE, this is a case that slipped out. The feature will be fully released in v4.7.0 or v4.7.1
            #warning("HERE has provided a new .publicTransit case, but no way of generating options or calculating a route along it at this time. (As of v4.6.4.0)")
            fatalError("Public Transit is not supported at this time")
        @unknown default:
            DemoError(file: #file, function: #function, line: #line, message: "Unkown TransportMode").print()
            completion(GenericError(title: #function + "UnkownTransportMode", code: 0))
        }
    }

    /// Draw routes on the map and hydrate the variables of the class properly
    /// - Parameter routes: Routes to display, route in first position will be high lighted.
    /// - Throws: Processing errors are rethrown to be handled by caller
    func displayRoutes(_ routes: [Route]) throws {
        guard let route = routes.first else {
            routeSelected = nil
            return
        }

        var lastPolyline: VLTMapPolyline?
        try clearRoutingPolylines()
        self.routes = routes
        routeSelected = route

        // Draw all of the routes on the map in gray
        for possibleRoute in routes {
            lastPolyline = try showRouteOnMap(route: possibleRoute, above: lastPolyline)
        }

        // Draw the selected route
        try selectRoute(route)
        try showWaypointsOnMap(startingAt: route.clLocationCoordinates2D[0],
                               runningThrough: nil, // Note:
                               andEndingAt: route.clLocationCoordinates2D[route.polyline.count - 1])
    }

    /// Keep track of the list of reached Waypoints along the user's route
    /// - Parameters:
    ///   - milestone: Milestone (Waypoint) that has been reached on the map. This may or may not correspond with the original waypoints used to define the route
    func navigationReached(milestone: Milestone) {
        if let _ = milestone.waypointIndex {
            reachedMilestones.append(milestone)
        }
    }

    /// Updates the highlighted route on the map
    /// - Parameters:
    ///   - selectedRoute: The route that should be highlighted on the map
    /// - Throws: Processing errors are rethrown to be handled by caller
    func selectRoute(_ selectedRoute: Route) throws {
        guard routes?.contains(selectedRoute) ?? false else {
            throw GenericError(title: "Routing service does not contain the route selected in the possible routes.", code: 0)
        }

        if let selectedLine = routeSelectedPolyline {
            selectedLine.coordinates = selectedRoute.clLocationCoordinates2D
            try mapView.update(object: selectedLine)
        } else {
            let selectedLine = VLTMapPolyline(coordinates: selectedRoute.clLocationCoordinates2D,
                                              title: nil,
                                              subtitle: nil,
                                              showCallout: false,
                                              strokeWidth: 5.0,
                                              strokeColor: .blue,
                                              metadata: selectedRoute.lengthInMeters)
            try mapView.add(objectsToTop: [selectedLine])
            routeSelectedPolyline = selectedLine
        }
        routeSelected = selectedRoute
    }

    /// Updates the camera of the map to display the entirety of all currently calculated routes
    /// - Throws: Processing error is rethrown while updating the camera
    func setCameraToShowAvailableRoutes() throws {
        guard let routes = self.routes, !routes.isEmpty else {
            throw GenericError(title: "Cannot display routes, no routes have been calculated", code: 3)
        }

        try setCameraToShowAllRoutes(routes)
    }

    /// Removes all routing from the map and puts the class to its initial clean state
    /// - Throws: Processing errors are rethrown to be handled by caller
    func clearRoutes() throws {
        try clearRoutingPolylines()
        routingPolylines = [VLTMapPolyline]()
        try clearRoutingMarkers()
        routingMarkers = [VLTMapMarker]()
        routeSelected = nil
        routeSelectedPolyline = nil
        routes = nil
        routeWaypoints = [Waypoint]()
    }

    /// Puts the routing process in a navigating state by removing all the possible route polylines from the map except the one currently selected
    /// - Throws: Processing errors are rethrown to be handled by caller
    func nagivateRoute() throws {
        guard routeSelected != nil else {
            throw GenericError(title: "There is currently no route selected.", code: 0)
        }

        try clearRoutingPolylines(exceptSelectedRoute: true)
    }

    // MARK: - Private Functions

    /// Draws the route on the map
    /// - Parameters:
    ///   - route: Route to draw
    ///   - above: Reference polyline to draw the new route line above
    /// - Throws: Processing errors are rethrown to be handled by caller
    private func showRouteOnMap(route: Route, above: VLTMapPolyline? = nil) throws -> VLTMapPolyline? {
        mapView.showsUserLocation = false
        mapView.map?.userTrackingMode = .none

        let routePolylineWidth: Float = 5.0
        let routePolylineStrokeColor = UIColor.lightGray

        let routePolyline = VLTMapPolyline(coordinates: route.clLocationCoordinates2D,
                                           title: nil,
                                           subtitle: nil,
                                           showCallout: false,
                                           strokeWidth: routePolylineWidth,
                                           strokeColor: routePolylineStrokeColor,
                                           metadata: route.lengthInMeters)

        if let above = above {
            try mapView.add(objects: [routePolyline], above: above)
        } else {
            try mapView.add(object: routePolyline)
        }

        self.routingPolylines.append(routePolyline)
        return routePolyline
    }

    /// Draws the start, destination, and rally point icons at the respective coordinates
    /// - Parameters:
    ///   - startingAt: Route starting coordinate
    ///   - runningThrough: Coordinates that the route should pass through before reaching the destination
    ///   - andEndingAt: Route destination coordinate
    /// - Throws: Processing errors are rethrown to be handled by caller
    private func showWaypointsOnMap(startingAt start: CLLocationCoordinate2D, runningThrough rallyPoints: [CLLocationCoordinate2D]?, andEndingAt destination: CLLocationCoordinate2D) throws {
        try addWaypointMarker(coordinate: start, image: routeStartImage)
        if let rallyPoints = rallyPoints {
            for geoCoordinates in rallyPoints {
                try addWaypointMarker(coordinate: geoCoordinates, image: routeRallyPointImage)
            }
        }
        try addWaypointMarker(coordinate: destination, image: routeDestinationImage)
    }

    /// Add the physical object to the map for marker
    /// - Parameters:
    ///   - coordinate: Coordinate for marker
    ///   - image: Image for marker
    /// - Throws: Processing errors are rethrown to be handled by caller
    private func addWaypointMarker(coordinate: CLLocationCoordinate2D, image: VLTImage) throws {
        let mapMarker = VLTMapMarker(coordinate: coordinate, image: image)
        try mapView.add(objectsToTop: [mapMarker])
        routingMarkers.append(mapMarker)
    }

    /// Removes all route markers
    /// - Throws: Processing errors are rethrown to be handled by caller
    private func clearRoutingMarkers() throws {
        guard !routingMarkers.isEmpty else { return }

        try mapView.remove(objects: routingMarkers)
        routingMarkers.removeAll()
    }

    /// Removes all the route polylines from the map except the one passed
    /// - Parameter exceptSelectedRoute: Polyline to keep while others are removed
    /// - Throws: Processing errors are rethrown to be handled by caller
    private func clearRoutingPolylines(exceptSelectedRoute keepSelected: Bool = false) throws {
        if !routingPolylines.isEmpty {
            try mapView.remove(objects: routingPolylines)
            routingPolylines.removeAll()
        }

        if !keepSelected, let selectedLine = routeSelectedPolyline {
            try mapView.remove(object: selectedLine)
            routeSelectedPolyline = nil
        }
    }

    /// Set map's camera to include all routes for proper viewing
    /// - Parameter routes: All routes to be included
    /// - Throws: Processing errors are rethrown to be handled by caller
    private func setCameraToShowAllRoutes(_ routes: [Route]) throws {
        var coordinates = [CLLocationCoordinate2D]()
        for route in routes {
            coordinates.append(route.boundingBox.northEastCorner.clLocationCoordinate2D)
            coordinates.append(route.boundingBox.southWestCorner.clLocationCoordinate2D)
        }
        // This computation was borrowed from Turf's BoundingBox.init
        let startValue = (minLat: coordinates.first!.latitude,
                          maxLat: coordinates.first!.latitude,
                          minLon: coordinates.first!.longitude,
                          maxLon: coordinates.first!.longitude)
        let (minLat, maxLat, minLon, maxLon) = coordinates
            .reduce(startValue) { result, coordinate -> (minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) in
                let minLat = min(coordinate.latitude, result.0)
                let maxLat = max(coordinate.latitude, result.1)
                let minLon = min(coordinate.longitude, result.2)
                let maxLon = max(coordinate.longitude, result.3)
                return (minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon)
            }
        let sw = CLLocationCoordinate2D(latitude: minLat, longitude: minLon)
        let ne = CLLocationCoordinate2D(latitude: maxLat, longitude: maxLon)

        try self.mapView.camera.updateCamera(
            southwestBound: sw,
            northeastBound: ne,
            padding: UIEdgeInsets(
                top: 100,
                left: 100,
                bottom: 300,
                right: 100
            ),
            withAnimation: true)
    }
}
