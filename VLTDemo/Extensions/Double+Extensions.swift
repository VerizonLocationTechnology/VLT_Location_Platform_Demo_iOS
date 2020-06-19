//
//  Double+Extensions.swift
//  VLTDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import Foundation

extension Double {
    /// Returns the a string representing this double rounded to the nearest hundredth
    func roundedString() -> String {
        return String(format: "%.2f", self)
    }
}
