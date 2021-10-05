//
// Double+Extensions.swift
//
// Created by Verizon Location Technology
// Copyright © 2020 Verizon Location Technology
//

import Foundation

extension Double {
    /// Returns the a string representing this double rounded to the nearest hundredth
    func roundedString() -> String {
        return String(format: "%.2f", self)
    }

    /// Turns doubles into pretty strings of proper precision for display
    /// - Parameters:
    ///   - precision: places after the decimal point to display
    ///   - trailingZeroes: fill with trailing zeroes to precision point when need. Default: false
    /// - Returns: String representing this double set the to precision output needed
    func precisionDisplayable(precision: Int, trailingZeroes: Bool = false) -> String? {
         let theNumber = NSNumber(value: self)
         let precisionFormatter = NumberFormatter()
         precisionFormatter.locale = Locale.current
         precisionFormatter.numberStyle = .decimal
         precisionFormatter.maximumFractionDigits = precision
         if trailingZeroes { precisionFormatter.minimumFractionDigits = precision }
         precisionFormatter.roundingMode = .down
         return precisionFormatter.string(from: theNumber)
     }
}
