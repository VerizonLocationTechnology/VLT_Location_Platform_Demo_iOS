//
//  VLTLocationManager.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import CoreLocation
import Foundation
import heresdk
import Mapbox

// Couple notes on the VLTLocationManager:
// This location manager's main job is brokering interaction between the HERE Location Engine, HERE Location Delegate, and CoreLocationManager while keeping the
// MGLocationManager location updated properly allowing the blue dot on the map to move natively on a VLTMaps.
// It can run in three modes:
// 1) Device Location: Location processing in its pure form.
// 2) HERE simulation: Location processing over a route to be navigated.  Great for testing core functionality and creating GPX files but doesn't really allow for certain testing scenarios.
// 3) GPX simulation: Location processing from a GPX file.  Allows better scenario driven testing.
// When testing and working with the VLTLocationManager only run one of these modes at a time. Mixing them is the same session will not produce the proper results.

/// Dedicated location manager to plug straight into VLTMaps and properly use device location while working properly with HERE navigation, the HERE simulator, and GPX file usage.
class VLTLocationManager: NSObject,
                          CLLocationManagerDelegate,
                          LocationDelegate,
                          LocationStatusDelegate,
                          MGLLocationManager {
    // MARK: - Private variables
    /// CoreLocation is used to get permission, help conform to MGLLocationManager, and update locations until the first navigation task when HERE's Location Engine takes over location duties.
    private var clLocationManager = CLLocationManager()
    /// HERE's location engine runs location position once navigation is needed and from then on.
    private var hereLocationEngine: LocationEngine
    /// Where the location delegate should be firing at any one point in time.
    private weak var hereLocationDelegate: LocationDelegate?
    /// Keeps track on whether to show the numerous tracking print statements
    private var printDebugStatements = true

    /// HERE SIMULATION - HERE's location simulator
    private var locationSimulator: LocationSimulator?
    /// HERE SIMULATION - Keep track when the simulator is running (don't want both simulator processes running at once)
    private (set) var simulating = false

    /// GPX SIMULATION RECORD - Keep track of whether the HERE simulation results should be outputed as GPX file after navigation.
    private (set) var recordSimulation = true
    /// GPX SIMULATION RECORD - Object containing gpx locations.
    private (set) var gpxRecording: GPXRecording?
    /// GPX SIMULATION RECORD - Finishing position stall in seconds
    private (set) var gpxFinishingStall = 20 as Int
    /// GPX SIMULATION PLAY - On file playback this allows us to adjust the course/bearing. Also used as an idicator the GPX file simulation is running.
    private var lastGpxLocation: CLLocation?
    /// GPX SIMULATION PLAY - Flag set to test against a gpx file. This process will adjust the course/bearing to simulate more accurately. It is recommeded to NOT release with this flag set to `true`.
    private var adjustCourseForGpxTesting = true

    // MARK: - Public variables
    /// Allows the calling controller to run a block of code once the initial location of the device is established.
    var initialLocationSet: CLLocationClosure?

    /// Last location of the device
    var lastKnownLocation: CLLocation? {
        willSet {
            if lastKnownLocation == nil, let newLocation = newValue {
                initialLocationSet?(newLocation)
                debugPrint("--*-- VLTLocationManager - Initial location: \(newLocation.coordinate.latitude) | \(newLocation.coordinate.longitude)")
            }
        }
    }
    
    @available(iOS 14.0, *)
    var accuracyAuthorization: CLAccuracyAuthorization {
        return clLocationManager.accuracyAuthorization
    }

    /// Conformance to MGLLocationManager - relay's location info back to move the blue dot properly on the map.
    weak var delegate: MGLLocationManagerDelegate?

    // MARK: - Initializers
    override init() {
        do {
            try hereLocationEngine = LocationEngine()
        } catch let engineInstantiationError {
            fatalError("--*-- VLTLocationManager - Failed to initialize LocationEngine. Cause: \(engineInstantiationError)")
        }
        super.init()
        clLocationManager.delegate = self
        clLocationManager.requestAlwaysAuthorization()
    }

    /// Updates the activity type of the location manager when needed
    /// - Parameter activityType: What type you want the
    func changeActivityTypeTo(_ activityType: CLActivityType) {
        clLocationManager.activityType = activityType
    }

    /// Turns off the current device positioning and runs location updates based on the given route.
    /// - Parameters:
    ///   - route: route to drive or walk
    ///   - speedFactor: Speed multiplier based on the current speed limit. Default: 3
    ///   - frequency: How often the location is updated in millisecond. Default: 1000 or every second
    func simulateUsingRoute(_ route: Route, speedFactor: Double = 3, frequency: Int32 = 1000) {
        // Stop any simulation that is currently running.
        if let locationSimulator = locationSimulator {
            locationSimulator.stop()
            self.locationSimulator = nil
            gpxRecording?.finishRecording(withLastLocationStall: gpxFinishingStall)
            gpxRecording = nil
        }
        let locationSimulatorOptions = LocationSimulatorOptions(speedFactor: speedFactor, notificationIntervalInMilliseconds: frequency)
        if recordSimulation { gpxRecording = GPXRecording() }
        do {
            try locationSimulator = LocationSimulator(route: route, options: locationSimulatorOptions)
            // } catch InstantiationErrorCode.illegalArguments {
            //    fatalError("VTLHereLocationProvider - Failed to initialize Location Simulator with illegalArguments")
            // } catch InstantiationErrorCode.failed {
            //    fatalError("VTLHereLocationProvider - Simulate initialization failed")
            // } catch InstantiationErrorCode.sharedSdkEngineNotInstantiated {
            //    fatalError("VTLHereLocationProvider - Failed to initialize LocationSimulator with sharedSdkEngineNotInstantiated.")
        } catch {
            fatalError("VTLHereLocationProvider - Failed to initialize LocationSimulator with error: \(error).")
        }
        stopUpdatingLocation()
        // Set up HERE's LocationDeligate(s) properly for handling HERE simulation positioning since startNavigationLocating sets up for device positioning
        locationSimulator?.delegate = self
        hereLocationEngine.removeLocationDelegate(locationDelegate: self)
        locationSimulator?.start()
        simulating = true
    }

    /// Stops any route simulation. Call stopNavigationLocating() after to return on proper device positioning.
    func stopSimulatingRoute() {
        locationSimulator?.stop()
        locationSimulator = nil
        hereLocationEngine.addLocationDelegate(locationDelegate: self)
        gpxRecording?.finishRecording(withLastLocationStall: gpxFinishingStall)
        gpxRecording = nil
        simulating = false
    }

    /// Ready to navigate? Call this method after setting up the HERE Navigator class.
    /// - Parameters:
    ///   - locationDelegate: Subscribe to location engine's Location Delegate updates. Pass in the HERE's Navigator class for simulation to work properly.
    ///   - accuracy: Desired location accuracy
    func startNavigationLocating(locationDelegate: LocationDelegate?, accuracy: LocationAccuracy) {
        stopCoreLocationManager()
        if hereLocationEngine.isStarted {
            return
        }
        hereLocationDelegate = locationDelegate
        if let hereLocationDelegate = hereLocationDelegate {
            hereLocationEngine.addLocationDelegate(locationDelegate: hereLocationDelegate)
        }
        hereLocationEngine.addLocationDelegate(locationDelegate: self)
        hereLocationEngine.addLocationStatusDelegate(locationStatusDelegate: self)
        let engineStatus = hereLocationEngine.start(locationAccuracy: accuracy)
        debugPrint("--*-- VLTLocationManager.startNavigationLocating - Engine Status \(engineStatus)")
    }

    /// Stop HERE's simulation if needed and preps
    func stopNavigationLocating() {
        if simulating {
           stopSimulatingRoute()
         }
        lastGpxLocation = nil
        debugPrint("--*-- VLTLocationManager.stopNavigationLocating")
    }

    /// Called then a new route is set because of a reroute or new navigation
    func navigationRouteUpdated() {
        // Rerouting somehow polutes the LocationEngine and the CLLocationManager delegates start firing along side the HERE location updates with GPX files.
        // Just turn off the CLCoreLocation delegate and the GPX file simulation run correctly after reroute.
        if lastGpxLocation != nil {
            clLocationManager.delegate = nil
        }
    }

    /// Turns on core location for location updates.
    /// Note: Only have HERE's location engine the clLocationManager running at one time or double location updates will occur.
    private func startCoreLocationManager() {
        debugPrint("--*-- VLTLocationManager.startCoreLocationManager")
        startUpdatingLocation()
        startUpdatingHeading()
    }

    /// Turns off core location so the HERE Location Engine drives the whole location process
    private func stopCoreLocationManager() {
        debugPrint("--*-- VLTLocationManager.stopCoreLocationManager")
        stopUpdatingHeading()
        stopUpdatingLocation()
    }

    /// Prints debug statements if wanted.
    private func debugPrint(_ statement: String) {
        if printDebugStatements {
            print(statement)
        }
    }

    private func initializeLocationEngine() {
        do {
            try hereLocationEngine = LocationEngine()
        } catch let engineInstantiationError {
            fatalError("--*-- VLTLocationManager - Failed to initialize LocationEngine. Cause: \(engineInstantiationError)")
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension VLTLocationManager {
    var authorizationStatus: CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return clLocationManager.authorizationStatus
        }
        return CLLocationManager.authorizationStatus()
    }
   
    var headingOrientation: CLDeviceOrientation {
        get {
            return clLocationManager.headingOrientation
        } set {
            clLocationManager.headingOrientation = newValue
        }
    }

    func requestAlwaysAuthorization() {
        clLocationManager.requestAlwaysAuthorization()
    }

    func requestWhenInUseAuthorization() {
        clLocationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        clLocationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        clLocationManager.stopUpdatingLocation()
    }

    func startUpdatingHeading() {
        clLocationManager.startUpdatingHeading()
    }

    func stopUpdatingHeading() {
        clLocationManager.stopUpdatingHeading()
    }
    
    func dismissHeadingCalibrationDisplay() {
        clLocationManager.dismissHeadingCalibrationDisplay()
    }
    
    @available(iOS 14.0, *)
    func requestTemporaryFullAccuracyAuthorization(withPurposeKey purposeKey: String) {
        clLocationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: purposeKey)
    }
}

// MARK: - CLLocationManagerDelegate
extension VLTLocationManager {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        delegate?.locationManager(self, didUpdate: newHeading)
        debugPrint("--*-- VLTLocationManager.didUpdateHeading")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if location != lastKnownLocation {
            // Keep MGLLocationManager is sync with location, updates blue dot placement when CLCoreLocation delegates are firing.
            delegate?.locationManager(self, didUpdate: locations)
            debugPrint("--*-- VLTLocationManager.didUpdateLocations - lastKnownLocation: \(location.coordinate.latitude)) | \(location.coordinate.longitude) Course: \(location.course)")
            lastKnownLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            debugPrint("--*-- VLTLocationManager - Native location services restricted by user in device settings")
        case .denied:
            debugPrint("--*-- VLTLocationManager - Native location services denied by user in device settings")
        case .notDetermined:
            debugPrint("--*-- VLTLocationManager - Native location services notDetermined by user in device settings")
        case .authorizedWhenInUse:
             debugPrint("--*-- VLTLocationManager - Native location services when is use authorized by user.")
        case .authorizedAlways:
            debugPrint("--*-- VLTLocationManager - Native location services always authorized by user.")
            if #available(iOS 14.0, *) {
                if manager.accuracyAuthorization == .reducedAccuracy {
                    debugPrint("--*-- VLTLocationManager - Native location services asking for full accuracy.")
                    requestTemporaryFullAccuracyAuthorization(withPurposeKey: "VLTLocationManager")
                }
            }
        @unknown default:
            fatalError("--*-- VLTLocationManager - Unknown location authorization status.")
        }
    }
}

// MARK: - LocationDelegate
extension VLTLocationManager {
    /// Called by `LocationProvider` each time a new location is available. Invoked on the main thread.
    /// - Parameter location: Current location.
    func onLocationUpdated(_ location: Location) {
        if simulating {
            if recordSimulation { gpxRecording?.addLocation(at: location.clLocation) }
            hereLocationDelegate?.onLocationUpdated(location)
            delegate?.locationManager(self, didUpdate: [location.clLocation])
            if printDebugStatements {
                let latDisplayable = location.coordinates.latitude.precisionDisplayable(precision: 6, trailingZeroes: true)!
                let longDisplayable = location.coordinates.longitude.precisionDisplayable(precision: 6, trailingZeroes: true)!
                let courseDisplayable = (location.bearingInDegrees ?? 0).precisionDisplayable(precision: 6, trailingZeroes: true)!
                debugPrint("--*-- VLTLocationManager - onLocationUpdated - Simulation -  \(latDisplayable)) | \(longDisplayable) Bearing: \(courseDisplayable)")
            }
        } else {
            var locationToReturn = location.clLocation
            // GPX file processing check. GPX files have no course/bearing and probably will never be a pure whole number.
            if lastKnownLocation?.course == 0 && location.bearingInDegrees == nil && adjustCourseForGpxTesting {
                if let lastGpxLocation = lastGpxLocation {
                    // NOTE: Course/bearing calculation is actually lagging behind one since its impossible to look forward. Better than nothing?
                    locationToReturn = lastGpxLocation.withCourse(to: location.clLocation)
                    self.lastGpxLocation = locationToReturn
                } else {
                    self.lastGpxLocation = location.clLocation
                }
                debugPrint("--*-- VLTLocationManager - onLocationUpdated - GPX file course adjustment made.")
            }
            delegate?.locationManager(self, didUpdate: [locationToReturn])
            if printDebugStatements {
                let latDisplayable = locationToReturn.coordinate.latitude.precisionDisplayable(precision: 6, trailingZeroes: true)!
                let longDisplayable = locationToReturn.coordinate.longitude.precisionDisplayable(precision: 6, trailingZeroes: true)!
                let courseDisplayable = locationToReturn.course.precisionDisplayable(precision: 6, trailingZeroes: true)!
                debugPrint("--*-- VLTLocationManager - onLocationUpdated - \(latDisplayable)) | \(longDisplayable) Bearing: \(courseDisplayable)")
            }
            lastKnownLocation = location.clLocation
        }
    }

    /// Periodically called by `LocationProvider` when location signal loss is detected. Invoked on the main thread.
    func onLocationTimeout() {
        debugPrint("--*-- VLTLocationManager - onLocationTimeout")
    }
}

// MARK: - LocationStatusDelegate
extension VLTLocationManager {
    func onStatusChanged(locationEngineStatus: LocationEngineStatus) {
        debugPrint("--*-- VLTLocationManager - Location engine status changed: \(locationEngineStatus)")
    }

    func onFeaturesNotAvailable(features: [LocationFeature]) {
        debugPrint("--*-- VLTLocationManager - onFeaturesNotAvailable: \(features)")
        // for feature in features { }
    }
}
