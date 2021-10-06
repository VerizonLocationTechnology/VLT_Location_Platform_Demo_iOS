//
//  GPXRecording.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import CoreLocation

/// Records a simulated route into a GPX file format and prints the results to the console
class GPXRecording {
    /// Where the running gpx file is kept
    var gpxFile = String()
    /// Keep track of the last location so turns can be noted
    private var lastLocation: CLLocation?

    /// Add a location to the recording
    /// - Parameter point: Location to add
    func addLocation(at point: CLLocation) {
        if gpxFile.isEmpty {
            gpxFile = "<?xml version=\"1.0\"?>\n<gpx version=\"1.1\" creator=\"Xcode\">\n"
            writeLocationLine(point: point)
        } else {
            writeLocationLine(point: point)
        }
        lastLocation = point
    }

    /// Finishes the recording process by writing the last location X times with very small positioning change.  This allows time to change the simulation in Xcode while the application is running without it rerun the simulated route. The gpx file prints into the output window to cut and paste into the media of your choice.
    /// - Parameter withLastLocationStall: time in second the simulation should dwell at the final location.
    func finishRecording(withLastLocationStall stalling: Int) {
        guard let lastLocation = lastLocation else { return }
        var workLatitude = lastLocation.coordinate.latitude
        let longitude = lastLocation.coordinate.longitude.precisionDisplayable(precision: 10, trailingZeroes: true)

        // Write the last location X times/seconds to stall
        for _ in 0...stalling {
            workLatitude += 0.000_000_000_1
            let latitude = workLatitude.precisionDisplayable(precision: 10, trailingZeroes: true)
            gpxFile.append("<wpt lat=\"\(latitude!)\" lon=\"\(longitude!)\" stalling=\"!-!-!-!-!-!-!-!-!\"> </wpt>\n")
        }
        gpxFile.append( "</gpx>\n")
        print("\n********** Start Of Simulation GPX File **************************************************\n")
        print("\(gpxFile)")
        print("\n********** End Of Simulation GPX File   **************************************************\n")
    }

    /// Write the actual wpt tag to the file noting if this could be a turn as the bearing change went over 30 degrees
    /// - Parameter point: Location to write.
    private func writeLocationLine(point: CLLocation) {
        let latitude = point.coordinate.latitude.precisionDisplayable(precision: 10, trailingZeroes: true)
        let longitude = point.coordinate.longitude.precisionDisplayable(precision: 10, trailingZeroes: true)

        if let lastLocation = lastLocation, abs(lastLocation.course) - abs(point.course) > 30 {
            gpxFile.append("<wpt lat=\"\(latitude!)\" lon=\"\(longitude!)\" turn=\"possible\"> </wpt>\n")
        } else {
            gpxFile.append("<wpt lat=\"\(latitude!)\" lon=\"\(longitude!)\"> </wpt>\n")
        }
    }
}
