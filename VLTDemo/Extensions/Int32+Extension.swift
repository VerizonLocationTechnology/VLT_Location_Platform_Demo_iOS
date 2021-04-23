//
// Int32+Extension.swift
//
// Created by Verizon Location Technology
// Copyright © 2021 Verizon Location Technology
//

import Foundation

extension Int32 {
    /// Display the value as a measure of time in hours and minute.
    func formatSecondsIntoTimeDisplay() -> String {
        let hours: Int32 = self / 3600
        let minutes: Int32 = (self % 3600) / 60

        if hours > 0 {
            let hrString = hours > 1 ? " hrs" : " hr"
            let minString = minutes > 1 ? " mins" : " min"
            return "\(hours)\(hrString) \(minutes)\(minString)"
        } else {
            if minutes > 0 {
                let minString = minutes > 1 ? " mins" : " min"
                return "\(minutes)\(minString)"
            } else {
                return "\(self) secs"
            }
        }
    }

    /// Take meters and display properly value as unit of length
    /// - Parameter imperialMeasure: True: Distance in imperial measure, False: Distance in metric measure. Default: false
    /// - Returns: Display distance in units required. km/m or miles/yards/feet
    func formatMetersAsLengthDisplay(imperialMeasure: Bool = false) -> String {
        if imperialMeasure {
            let miles = (Double(self) * 0.000_621_37)
            if miles > 0.4 {
                return (miles.precisionDisplayable(precision: 2) ?? "0") + " miles"
            } else {
                let yards = (Double(self) * 1.0931).rounded()
                if yards > 100 {
                    return (yards.precisionDisplayable(precision: 0) ?? "0") + " yards"
                } else {
                    let feet = (Double(self) * 3.280_84).rounded()
                    return (feet.precisionDisplayable(precision: 0) ?? "0") + " ft"
                }
            }
        } else {
            let kilometers: Int32 = self / 1000
            let remainingMeters: Int32 = self % 1000

            if kilometers > 1 {
                if kilometers < 10 {
                    return "( \(kilometers).\(remainingMeters) km)"
                } else {
                    return "\(kilometers) km"
                }
            } else {
                return "(\(remainingMeters) m)"
            }
        }
    }
}
