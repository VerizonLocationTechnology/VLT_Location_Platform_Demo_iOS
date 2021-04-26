//
// VLTMapNavigation.swift
//
// Created by Verizon Location Technology
// Copyright © 2021 Verizon Location Technology
//

import CoreLocation
import Foundation
import heresdk

// MARK: - VLTNavigation specific closures
/// Closure type for speed limit updates
typealias VLTNavSpeedLimitUpdatedClosure = (Double) -> Void // Always in Meters per Second
/// Closure type for updates to route progress
typealias VLTNavRouteProgressClosure = (Maneuver, ManeuverProgress) -> Void
/// Closure type for updates to traffic delays
typealias VLTNavTrafficDelayClosure = (Int32) -> Void // Seconds
/// Closure type for successful location matches
typealias VLTNavMatchedLocationClosure = (NavigableLocation) -> Void
/// Closure type for updates to the remaining route
typealias VLTNavRouteRemainingClosure = (Int32, Int32) -> Void // Meters, Seconds
/// Closure type for the reaching of a milestone
typealias VLTNavMilestoneReached = (Milestone) -> Void
/// Closure type for deviation from the route
typealias VLTNavRouteDeviationClosure = (CLLocationCoordinate2D, Double?) -> Void // Current User Coordinates, Bearing/Heading/Course

/// Map navigation service to encapsulate the robust HERE `NavigatorProtocol` and provide specific points of contact so a generic navigation experience can be easily achieved. Most of this code was ported from HERE examples and modified for this service type implementation.
class VLTNavigation: NavigableLocationDelegate,     // Notifications about the current location from `Navigator`
                     SpeedWarningDelegate,          // Notifications when a speed limit on a road is exceeded or speed is restored back to normal.
                     RouteProgressDelegate,         // Notifications about the route progress from `Navigator`
                     RouteDeviationDelegate,        // Notifications about route deviations from `Navigator`.
                     ManeuverNotificationDelegate,  // Notifications when maneuver notifications are available from `Navigator`
                     MilestoneReachedDelegate,      // Notifications about the arrival at each `Milestone`.
                     DestinationReachedDelegate     // Notifications about the arrival at the destination.
{
    // MARK: - Private variables

    /// Manager for the present location
    private var locationManager: VLTLocationManager
    /// Unit system that data should be reported in
    private var unitSystem: UnitSystem
    /// Block to be called when route progress is to be updated
    private var routeProgressBlock: VLTNavRouteProgressClosure?
    /// Block to be called when a traffic delay occurs
    private var trafficDelayBlock: VLTNavTrafficDelayClosure?
    /// Block to be called when remaining route data is updated
    private var routeRemainingBlock: VLTNavRouteRemainingClosure?
    /// Block to be called when the speed limit is updated
    private var speedLimitUpatedBlock: VLTNavSpeedLimitUpdatedClosure?
    /// Block to be called when the user has begun to speed
    private var startedSpeedingBlock: VoidClosure?
    /// Block to be called when the user has stopped speeding
    private var stoppedSpeedingBlock: VoidClosure?
    /// Block to be called when the user's location has been matched during navigation
    private var matchedLocationBlock: VLTNavMatchedLocationClosure?
    /// Block to be called when a milestone has been reached
    private var milestoneReachedBlock: VLTNavMilestoneReached?
    /// Block to be called when the destination has been reached
    private var destinationReachedBlock: VoidClosure?
    /// Block to be called when the user has deviated from the route by a greater distance than the deviation sensitivity
    private var routeDeviatedBlock: VLTNavRouteDeviationClosure?
    /// Sensitivity for deviation from the route. Defaults to 20 meters
    private var deviationSensitivity: Double = 20
    /// Keeps track of deviation notifications received, allows smoothing of rerouting in conjunction with sensitivity
    private var deviationCounter = 0
    /// Voice assistant for audio queues during navigation
    private let voiceAssistant = HEREVoiceAssistant()
    /// Navigator for the route, announcing key events during navigation
    private var navigator: Navigator?
    /// Indicator of whether or not navigation is occuring
    private var navigating = false

    // MARK: - Initializers

    /// Fire up some navigation
    /// - Parameters:
    ///   - locationManager: Pass in the location manager being used
    ///   - unitSystem: System of measure for speech and prompts
    init(locationManager: VLTLocationManager,
         unitSystem: UnitSystem) {
        self.locationManager = locationManager
        self.unitSystem = unitSystem
    }

    // MARK: - Public funcations

    /// Starts the navigaion down the route provided
    /// - Parameters:
    ///   - route: Route to traverse
    ///   - routeProgressBlock: Block to run when route progess is updated
    ///   - routeRemainingBlock: Block to run when update to route remaining is updated
    ///   - speedLimitUpatedBlock: Block to run when speed limit is updated
    ///   - startedSpeedingBlock: Block to run when the speed limit is being exceeded
    ///   - stoppedSpeedingBlock: Block to run when the speed limit no longer is being exceeded
    ///   - matchedLocationBlock: Block to run when the current location matches something HERE recognizes
    ///   - milestoneReachedBlock: Block to run when a milstone is reached
    ///   - destinationReachedBlock: Block to run when the destination is reached
    ///   - routeDeviatedBlock: Block to run when the user has deviated from the route
    ///   - routeDeviationSensitivity: Distance (in meters) from the route the user should be before a route is considered as having deviated from the route. Defaults to 20 meters
    /// - Throws: Errors are thrown if needed compenents can't be started properly
    // swiftlint:disable untyped_error_in_catch
    func startNavigatingRoute(_ route: Route,
                              routeProgressBlock: VLTNavRouteProgressClosure? = nil,
                              routeRemainingBlock: VLTNavRouteRemainingClosure? = nil ,
                              speedLimitUpatedBlock: VLTNavSpeedLimitUpdatedClosure? = nil,
                              startedSpeedingBlock: VoidClosure? = nil,
                              stoppedSpeedingBlock: VoidClosure? = nil,
                              matchedLocationBlock: VLTNavMatchedLocationClosure? = nil,
                              milestoneReachedBlock: VLTNavMilestoneReached? = nil,
                              destinationReachedBlock: VoidClosure? = nil,
                              routeDeviatedBlock: VLTNavRouteDeviationClosure? = nil,
                              routeDeviationSensitivity: Double = 20) throws {
        // Update called closures
        self.routeProgressBlock = routeProgressBlock
        self.routeRemainingBlock = routeRemainingBlock
        self.speedLimitUpatedBlock = speedLimitUpatedBlock
        self.startedSpeedingBlock = startedSpeedingBlock
        self.stoppedSpeedingBlock = stoppedSpeedingBlock
        self.milestoneReachedBlock = milestoneReachedBlock
        self.destinationReachedBlock = destinationReachedBlock
        self.routeDeviatedBlock = routeDeviatedBlock
        self.deviationSensitivity = routeDeviationSensitivity

        // Update or instantiate navigator object
        if let navigator = navigator {
            navigator.route = route
            locationManager.navigationRouteUpdated()
            navigating = true
        } else {
            do {
                // Without a route set, this starts tracking mode.
                try navigator = Navigator()
                if let navigator = navigator {
                    navigator.navigableLocationDelegate = self
                    navigator.routeDeviationDelegate = self
                    navigator.routeProgressDelegate = self
                    navigator.maneuverNotificationDelegate = self
                    navigator.destinationReachedDelegate = self
                    navigator.milestoneReachedDelegate = self
                    navigator.speedWarningDelegate = self
                    navigator.route = route
                    locationManager.startNavigationLocating(locationDelegate: navigator, accuracy: .navigation)
                    setupVoiceGuidance()
                    self.navigating = true
                } else {
                    let error = "HERE Navigator is nil."
                    DemoError(file: #file, function: #function, line: #line, message: error).print()
                    throw GenericError(title: error, code: 0)
                }
            } catch let engineInstantiationError {
                let error = "Failed to initialize HERE Navigator. Cause: \(engineInstantiationError)"
                DemoError(file: #file, function: #function, line: #line, message: error).print()
                throw GenericError(title: error, code: 0)
            }
        }
    }

    func updateNavigatingRoute(_ route: Route) {
        if let navigator = navigator {
            navigator.route = route
            locationManager.navigationRouteUpdated()
        } else {
            let error = "Failed to update reroute route becuase HERE Navigator is nil"
            DemoError(file: #file, function: #function, line: #line, message: error).print()
        }
    }

    /// End navigation
    func stopNavigating() {
        locationManager.stopNavigationLocating()
        navigator?.route = nil
        navigating = false
    }

    // MARK: - Private functions

    /// Set up the voice assistant for use during navigation
    /// - Throws: Errors are throw if needed compenents can't be started properly
    private func setupVoiceGuidance() {
        if let navigator = navigator {
            let ttsLanguageCode = getLanguageCodeForDevice(supportedVoiceSkins: Navigator.availableLanguagesForManeuverNotifications())
            navigator.maneuverNotificationOptions = ManeuverNotificationOptions(language: ttsLanguageCode, unitSystem: unitSystem)

            // Set language to our TextToSpeech engine.
            let locale = HERELanguageCodeConverter.getLocale(languageCode: ttsLanguageCode)
            DispatchQueue.main.async {
                if !self.voiceAssistant.setLanguage(locale: locale) {
                    let message = "TextToSpeech engine does not support this language: \(locale)"
                    DemoError(file: #file, function: #function, line: #line, message: message).print()
                }
            }
        } else {
            let error = "Navigator is nil while attempting to setupVoiceGuidance()"
            DemoError(file: #file, function: #function, line: #line, message: error).print()
        }
    }

    /// Get the preferred language for this device
    /// - Parameter supportedVoiceSkins: Voices supported by the navigator
    /// - Returns: Language code for the voice prompt to use
    private func getLanguageCodeForDevice(supportedVoiceSkins: [heresdk.LanguageCode]) -> LanguageCode {
        // 1. Determine if preferred device language is supported by our TextToSpeech engine.
        let identifierForCurrenDevice = Locale.preferredLanguages.first!
        var localeForCurrenDevice = Locale(identifier: identifierForCurrenDevice)
        if !voiceAssistant.isLanguageAvailable(identifier: identifierForCurrenDevice) {
            let message = "TextToSpeech engine does not support: \(identifierForCurrenDevice), falling back to en-US."
            DemoError(file: #file, function: #function, line: #line, message: message).print()
            localeForCurrenDevice = Locale(identifier: "en-US")
        }

        // 2. Determine supported voice skins from HERE SDK.
        var languageCodeForCurrenDevice = HERELanguageCodeConverter.getLanguageCode(locale: localeForCurrenDevice)
        if !supportedVoiceSkins.contains(languageCodeForCurrenDevice) {
            let message = "No voice skins available for \(languageCodeForCurrenDevice), falling back to en-Us."
            DemoError(file: #file, function: #function, line: #line, message: message).print()
            languageCodeForCurrenDevice = LanguageCode.enUs
        }
        return languageCodeForCurrenDevice
    }

    // MARK: - NavigableLocationDelegate

    /// Called whenever the current location has been updated.
    /// - Parameter navigableLocation: The current location update.
    func onNavigableLocationUpdated(_ navigableLocation: NavigableLocation) {
        guard  navigableLocation.mapMatchedLocation != nil else {
            // Not sure whether to report on this or not
            // let message = "This new location could not be map-matched. Using raw location.""
            // DemoError(file: #file, function: #function, line: #line, message: message).print()
            return
        }
        matchedLocationBlock?(navigableLocation)

        if let newSpeedLimit = navigableLocation.speedLimitInMetersPerSecond {
            speedLimitUpatedBlock?(newSpeedLimit)
        }
    }

    // MARK: - DestinationReachedDelegate

    /// Called when the destination has been reached.
    func onDestinationReached() {
        stopNavigating()
        destinationReachedBlock?()
    }

    // MARK: - MilestoneReachedDelegate

    /// Called when a milestone has been reached.
    /// - Parameter milestone: A `Milestone` on the route.
    func onMilestoneReached(_ milestone: Milestone) {
        milestoneReachedBlock?(milestone)
    }

    // MARK: - SpeedWarningDelegate

    /// Called whenever a new `SpeedWarningStatus` is available.
    /// - Parameter status: The new status of the speed warning.
    func onSpeedWarningStatusChanged(_ status: SpeedWarningStatus) {
        if status == SpeedWarningStatus.speedLimitExceeded {    // Driver is faster than current speed limit (plus an optional offset).
            startedSpeedingBlock?()
        }

        if status == SpeedWarningStatus.speedLimitRestored {
            stoppedSpeedingBlock?()
        }
    }

    // MARK: - RouteProgressDelegate

    /// Called whenever route progress has been updated.
    /// - Parameter routeProgress: The route progress update.
    func onRouteProgressUpdated(_ routeProgress: RouteProgress) {
        if let last = routeProgress.sectionProgress.last {
            routeRemainingBlock?(last.remainingDistanceInMeters, last.remainingDurationInSeconds)
            trafficDelayBlock?(last.trafficDelayInSeconds)
        }
        // Contains the progress for the next maneuver ahead and the next-next maneuvers, if any.
        let nextManeuverProgressList = routeProgress.maneuverProgress
        guard let nextManeuverProgress = nextManeuverProgressList.first else {
            // No next manuever available - probably end of navigation
            return
        }

        let nextManeuverIndex = nextManeuverProgress.maneuverIndex
        guard let nextManeuver = navigator?.getManeuver(index: nextManeuverIndex) else {
            // Should never happen as we retrieved the next maneuver progress above.
            return
        }

        if nextManeuver.action == ManeuverAction.arrive {
            // Do nothing the onDestinationReached() should have fired so deal with it there
        } else {
            routeProgressBlock?(nextManeuver, nextManeuverProgress)
        }
    }

    // MARK: - RouteDeviationDelegate

    /// Called whenever route deviation has been observed. It contains the information that can be used to decide whether to request a re-route calculation from the routing engine.
    /// - Parameter routeDeviation: The route deviation observed.
    func onRouteDeviation(_ routeDeviation: RouteDeviation) {
        guard navigating else {
            navigator?.route = nil
            return
        }

        guard deviationCounter >= 1 else {
            deviationCounter += 1
            return
        }
        deviationCounter = 0
        var bearingInDegrees: Double?

        // Get current geographic coordinates.
        var currentGeoCoordinates = routeDeviation.currentLocation.originalLocation.coordinates
        if let currentMapMatchedLocation = routeDeviation.currentLocation.mapMatchedLocation {
            currentGeoCoordinates = currentMapMatchedLocation.coordinates
        }

        // Get last geographic coordinates on route.
        var lastGeoCoordinates: GeoCoordinates?
        if let lastLocationOnRoute = routeDeviation.lastLocationOnRoute {
            lastGeoCoordinates = lastLocationOnRoute.originalLocation.coordinates
            if let lastMapMatchedLocationOnRoute = lastLocationOnRoute.mapMatchedLocation {
                lastGeoCoordinates = lastMapMatchedLocationOnRoute.coordinates
                bearingInDegrees = lastMapMatchedLocationOnRoute.bearingInDegrees
            }
        } else {
            // User was never following the route. So, we take the start of the route instead
            lastGeoCoordinates = navigator?.route?.sections.first?.departurePlace.mapMatchedCoordinates
        }

        guard let lastGeoCoordinatesOnRoute = lastGeoCoordinates else {
            // No lastGeoCoordinatesOnRoute found. Should never happen.
            return
        }

        let distanceInMeters = currentGeoCoordinates.distance(to: lastGeoCoordinatesOnRoute)

        if distanceInMeters > deviationSensitivity {
            navigator?.route = nil
            let currentCoords = currentGeoCoordinates.clLocationCoordinate2D
            routeDeviatedBlock?(currentCoords, bearingInDegrees)
        }
    }

    // MARK: - ManeuverNotificationDelegate

    /// Called whenever there is a new notification for a maneuver (multiple notifications can be given for the same maneuver at different distances (for example: "After 500 meters turn right." or "Now turn right.") and in that case, this method will be called once for each distance.
    /// - Parameter text: The text of the maneuver notification.
    func onManeuverNotification(_ text: String) {
        deviationCounter = 0
        voiceAssistant.speak(message: text)
    }
}
